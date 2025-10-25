import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service;

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  CustomerProvider(this._service);

  // Getters
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all customers
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _service.readAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _customers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new customer
  Future<void> addCustomer(Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.create(customer);
      await loadCustomers(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing customer
  Future<void> updateCustomer(String id, Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.update(id, customer);
      await loadCustomers(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      await loadCustomers(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search customers with debouncing (300ms delay)
  Future<void> searchCustomers(String query) async {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Create new timer with 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _customers = await _service.search(query);
        _error = null;
      } catch (e) {
        _error = e.toString();
        _customers = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Get recent customers (within specified days)
  Future<void> loadRecentCustomers(int days) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _service.getRecentCustomers(days);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _customers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get customers by date range
  Future<void> loadCustomersByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _service.getCustomersByDateRange(start, end);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _customers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
