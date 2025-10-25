import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bill.dart';
import '../models/customer.dart';
import '../models/line_item.dart';
import '../models/product.dart';
import '../services/bill_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService _service;

  List<Bill> _bills = [];
  Bill? _currentBill;
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  BillProvider(this._service);

  // Getters
  List<Bill> get bills => _bills;
  Bill? get currentBill => _currentBill;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all bills
  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bills = await _service.readAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _bills = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new bill
  Future<void> createBill(Bill bill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.create(bill);
      await loadBills(); // Reload to get updated list
      _currentBill = null; // Clear current bill after creation
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a bill
  Future<void> deleteBill(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      await loadBills(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start a new bill for a customer
  void startNewBill(Customer customer) {
    final uuid = const Uuid();
    _currentBill = Bill(
      id: uuid.v4(),
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phoneNumber,
      items: [],
      subtotal: 0.0,
      specialDiscount: 0.0,
      discountType: 'percentage',
      additionalDiscount: 0.0,
      additionalDiscountType: 'percentage',
      totalAmount: 0.0,
      paymentMethod: 'Cash',
      billingDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Add a line item to the current bill
  void addLineItem(Product product, int quantity) {
    if (_currentBill == null) return;

    final totalPrice = product.price * quantity;
    final lineItem = LineItem(
      productId: product.id,
      productName: product.name,
      category: product.category,
      quantity: quantity,
      unitPrice: product.price,
      totalPrice: totalPrice,
    );

    _currentBill!.items.add(lineItem);
    _recalculateSubtotal();
    _recalculateTotal();
    notifyListeners();
  }

  /// Remove a line item from the current bill
  void removeLineItem(int index) {
    if (_currentBill == null || index < 0 || index >= _currentBill!.items.length) {
      return;
    }

    _currentBill!.items.removeAt(index);
    _recalculateSubtotal();
    _recalculateTotal();
    notifyListeners();
  }

  /// Update quantity of a line item
  void updateQuantity(int index, int quantity) {
    if (_currentBill == null || index < 0 || index >= _currentBill!.items.length) {
      return;
    }

    if (quantity <= 0) {
      removeLineItem(index);
      return;
    }

    final lineItem = _currentBill!.items[index];
    lineItem.quantity = quantity;
    lineItem.totalPrice = lineItem.unitPrice * quantity;

    _recalculateSubtotal();
    _recalculateTotal();
    notifyListeners();
  }

  /// Apply special discount
  void applySpecialDiscount(double amount, String type) {
    if (_currentBill == null) return;

    _currentBill!.specialDiscount = amount;
    _currentBill!.discountType = type;
    _recalculateTotal();
    notifyListeners();
  }

  /// Apply additional discount
  void applyAdditionalDiscount(double amount, String type) {
    if (_currentBill == null) return;

    _currentBill!.additionalDiscount = amount;
    _currentBill!.additionalDiscountType = type;
    _recalculateTotal();
    notifyListeners();
  }

  /// Set payment method
  void setPaymentMethod(String method) {
    if (_currentBill == null) return;

    _currentBill!.paymentMethod = method;
    notifyListeners();
  }

  /// Calculate total with real-time updates
  double calculateTotal() {
    if (_currentBill == null) return 0.0;
    return _service.calculateBillTotal(_currentBill!);
  }

  /// Recalculate subtotal from line items
  void _recalculateSubtotal() {
    if (_currentBill == null) return;

    _currentBill!.subtotal = _currentBill!.items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  /// Recalculate total amount with discounts
  void _recalculateTotal() {
    if (_currentBill == null) return;

    _currentBill!.totalAmount = _service.calculateBillTotal(_currentBill!);
  }

  /// Search bills with debouncing (300ms delay)
  Future<void> searchBills(String query) async {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Create new timer with 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _bills = await _service.search(query);
        _error = null;
      } catch (e) {
        _error = e.toString();
        _bills = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Load bills by date range
  Future<void> loadBillsByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bills = await _service.getBillsByDateRange(start, end);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _bills = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current bill
  void clearCurrentBill() {
    _currentBill = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
