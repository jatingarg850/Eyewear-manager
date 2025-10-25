import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  List<Product> _products = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  ProductProvider(this._service);

  // Getters
  List<Product> get products => _filteredProducts();
  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.readAll();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new product
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.create(product);
      await loadProducts(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing product
  Future<void> updateProduct(String id, Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.update(id, product);
      await loadProducts(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle product active status (soft delete)
  Future<void> toggleProductActive(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.toggleActive(id);
      await loadProducts(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a product permanently
  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(id);
      await loadProducts(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected category for filtering
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Get filtered products based on selected category
  List<Product> _filteredProducts() {
    if (_selectedCategory.toLowerCase() == 'all') {
      return _products;
    }

    return _products.where((product) => product.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  /// Get active products only
  List<Product> getActiveProducts() {
    return _products.where((product) => product.isActive).toList();
  }

  /// Get active products by category
  List<Product> getActiveProductsByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      return getActiveProducts();
    }

    return _products.where((product) => product.isActive && product.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Search products with debouncing (300ms delay)
  Future<void> searchProducts(String query) async {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Create new timer with 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        _products = await _service.search(query);
        _error = null;
      } catch (e) {
        _error = e.toString();
        _products = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Load products by category
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getProductsByCategory(category);
      _selectedCategory = category;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
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
