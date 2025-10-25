import 'package:hive/hive.dart';
import '../models/customer.dart';
import 'database_service.dart';

class CustomerService {
  late Box<Customer> _box;
  List<Customer>? _cachedCustomers;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  CustomerService() {
    _box = DatabaseService.getCustomersBox();
  }

  /// Create a new customer
  Future<String> create(Customer customer) async {
    try {
      await _box.put(customer.id, customer);
      invalidateCache();
      return customer.id;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  /// Read a customer by ID
  Future<Customer?> read(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to read customer: $e');
    }
  }

  /// Read all customers with caching
  Future<List<Customer>> readAll() async {
    try {
      // Return cached data if valid
      if (_cachedCustomers != null && _cacheTime != null && DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedCustomers!;
      }

      // Fetch from database and cache
      _cachedCustomers = _box.values.toList();
      _cacheTime = DateTime.now();
      return _cachedCustomers!;
    } catch (e) {
      throw Exception('Failed to read all customers: $e');
    }
  }

  /// Update an existing customer
  Future<void> update(String id, Customer customer) async {
    try {
      if (!_box.containsKey(id)) {
        throw Exception('Customer with id $id not found');
      }
      await _box.put(id, customer);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  /// Delete a customer
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  /// Search customers by name or phone number
  Future<List<Customer>> search(String query) async {
    try {
      if (query.isEmpty) {
        return await readAll();
      }

      final customers = await readAll();
      final lowerQuery = query.toLowerCase();

      return customers.where((customer) {
        final nameMatch = customer.name.toLowerCase().contains(lowerQuery);
        final phoneMatch = customer.phoneNumber.contains(query);
        return nameMatch || phoneMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  /// Get recent customers within specified days
  Future<List<Customer>> getRecentCustomers(int days) async {
    try {
      final customers = await readAll();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      return customers.where((customer) {
        return customer.lastVisit.isAfter(cutoffDate);
      }).toList()
        ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    } catch (e) {
      throw Exception('Failed to get recent customers: $e');
    }
  }

  /// Get customers by date range
  Future<List<Customer>> getCustomersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final customers = await readAll();

      return customers.where((customer) {
        return customer.lastVisit.isAfter(start) && customer.lastVisit.isBefore(end);
      }).toList()
        ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    } catch (e) {
      throw Exception('Failed to get customers by date range: $e');
    }
  }

  /// Increment visit count for a customer
  Future<void> incrementVisitCount(String customerId) async {
    try {
      final customer = await read(customerId);
      if (customer == null) {
        throw Exception('Customer with id $customerId not found');
      }

      customer.totalVisits += 1;
      customer.lastVisit = DateTime.now();
      customer.updatedAt = DateTime.now();

      await _box.put(customerId, customer);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to increment visit count: $e');
    }
  }

  /// Invalidate the cache
  void invalidateCache() {
    _cachedCustomers = null;
    _cacheTime = null;
  }

  /// Get total customer count
  Future<int> getCount() async {
    try {
      return _box.length;
    } catch (e) {
      throw Exception('Failed to get customer count: $e');
    }
  }
}
