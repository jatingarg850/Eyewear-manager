import 'package:hive/hive.dart';
import '../models/bill.dart';
import '../utils/bill_calculator.dart';
import 'database_service.dart';

class BillService {
  late Box<Bill> _box;
  List<Bill>? _cachedBills;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  BillService() {
    _box = DatabaseService.getBillsBox();
  }

  /// Create a new bill
  Future<String> create(Bill bill) async {
    try {
      await _box.put(bill.id, bill);
      invalidateCache();
      return bill.id;
    } catch (e) {
      throw Exception('Failed to create bill: $e');
    }
  }

  /// Read a bill by ID
  Future<Bill?> read(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to read bill: $e');
    }
  }

  /// Read all bills with caching
  Future<List<Bill>> readAll() async {
    try {
      // Return cached data if valid
      if (_cachedBills != null && _cacheTime != null && DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedBills!;
      }

      // Fetch from database and cache
      _cachedBills = _box.values.toList()..sort((a, b) => b.billingDate.compareTo(a.billingDate));
      _cacheTime = DateTime.now();
      return _cachedBills!;
    } catch (e) {
      throw Exception('Failed to read all bills: $e');
    }
  }

  /// Update an existing bill
  Future<void> update(String id, Bill bill) async {
    try {
      if (!_box.containsKey(id)) {
        throw Exception('Bill with id $id not found');
      }
      await _box.put(id, bill);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  /// Delete a bill
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }

  /// Search bills by customer name, phone, or date
  Future<List<Bill>> search(String query) async {
    try {
      if (query.isEmpty) {
        return await readAll();
      }

      final bills = await readAll();
      final lowerQuery = query.toLowerCase();

      return bills.where((bill) {
        final nameMatch = bill.customerName.toLowerCase().contains(lowerQuery);
        final phoneMatch = bill.customerPhone.contains(query);
        final dateMatch = bill.billingDate.toString().contains(query);
        return nameMatch || phoneMatch || dateMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }

  /// Get bills by specific date
  Future<List<Bill>> getBillsByDate(DateTime date) async {
    try {
      final bills = await readAll();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return bills.where((bill) {
        return bill.billingDate.isAfter(startOfDay) && bill.billingDate.isBefore(endOfDay);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get bills by date: $e');
    }
  }

  /// Get bills by date range
  Future<List<Bill>> getBillsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final bills = await readAll();

      return bills.where((bill) {
        return bill.billingDate.isAfter(start) && bill.billingDate.isBefore(end);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get bills by date range: $e');
    }
  }

  /// Get total revenue for a date range
  Future<double> getTotalRevenue(DateTime start, DateTime end) async {
    try {
      final bills = await getBillsByDateRange(start, end);
      return bills.fold<double>(0.0, (sum, bill) => sum + bill.totalAmount);
    } catch (e) {
      throw Exception('Failed to get total revenue: $e');
    }
  }

  /// Get bill count for a date range
  Future<int> getBillCount(DateTime start, DateTime end) async {
    try {
      final bills = await getBillsByDateRange(start, end);
      return bills.length;
    } catch (e) {
      throw Exception('Failed to get bill count: $e');
    }
  }

  /// Calculate bill total with discount logic using BillCalculator utility
  /// Special discount is applied first, then additional discount
  double calculateBillTotal(Bill bill) {
    try {
      return BillCalculator.calculateTotalCached(bill);
    } catch (e) {
      throw Exception('Failed to calculate bill total: $e');
    }
  }

  /// Invalidate the cache
  void invalidateCache() {
    _cachedBills = null;
    _cacheTime = null;
  }

  /// Get total bill count
  Future<int> getCount() async {
    try {
      return _box.length;
    } catch (e) {
      throw Exception('Failed to get bill count: $e');
    }
  }

  /// Get bills for today
  Future<List<Bill>> getTodayBills() async {
    try {
      return await getBillsByDate(DateTime.now());
    } catch (e) {
      throw Exception('Failed to get today bills: $e');
    }
  }

  /// Get revenue for today
  Future<double> getTodayRevenue() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      return await getTotalRevenue(startOfDay, endOfDay);
    } catch (e) {
      throw Exception('Failed to get today revenue: $e');
    }
  }

  /// Get revenue for current month
  Future<double> getMonthlyRevenue() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return await getTotalRevenue(startOfMonth, endOfMonth);
    } catch (e) {
      throw Exception('Failed to get monthly revenue: $e');
    }
  }
}
