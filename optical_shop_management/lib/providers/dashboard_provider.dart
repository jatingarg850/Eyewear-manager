import 'package:flutter/foundation.dart';
import '../services/bill_service.dart';
import '../services/customer_service.dart';

class DashboardProvider extends ChangeNotifier {
  final BillService _billService;
  final CustomerService _customerService;

  double _totalRevenue = 0.0;
  int _customersToday = 0;
  int _totalSales = 0;
  double _monthlyRevenue = 0.0;
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._billService, this._customerService);

  // Getters
  double get totalRevenue => _totalRevenue;
  int get customersToday => _customersToday;
  int get totalSales => _totalSales;
  double get monthlyRevenue => _monthlyRevenue;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Calculate total revenue (all time)
      final allBills = await _billService.readAll();
      _totalRevenue = allBills.fold<double>(
        0.0,
        (sum, bill) => sum + bill.totalAmount,
      );

      // Calculate customers today
      final customersToday = await _customerService.getCustomersByDateRange(
        startOfDay,
        endOfDay,
      );
      _customersToday = customersToday.length;

      // Calculate total sales count (all time)
      _totalSales = allBills.length;

      // Calculate monthly revenue
      _monthlyRevenue = await _billService.getTotalRevenue(
        startOfMonth,
        endOfMonth,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
      _totalRevenue = 0.0;
      _customersToday = 0;
      _totalSales = 0;
      _monthlyRevenue = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  /// Get today's revenue
  Future<double> getTodayRevenue() async {
    try {
      return await _billService.getTodayRevenue();
    } catch (e) {
      return 0.0;
    }
  }

  /// Get today's sales count
  Future<int> getTodaySalesCount() async {
    try {
      final todayBills = await _billService.getTodayBills();
      return todayBills.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get total customer count
  Future<int> getTotalCustomerCount() async {
    try {
      return await _customerService.getCount();
    } catch (e) {
      return 0;
    }
  }
}
