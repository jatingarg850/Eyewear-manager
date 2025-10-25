import 'package:hive/hive.dart';
import '../models/product.dart';
import 'database_service.dart';

class ProductService {
  late Box<Product> _box;
  List<Product>? _cachedProducts;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  ProductService() {
    _box = DatabaseService.getProductsBox();
  }

  /// Create a new product
  Future<String> create(Product product) async {
    try {
      await _box.put(product.id, product);
      invalidateCache();
      return product.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Read a product by ID
  Future<Product?> read(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to read product: $e');
    }
  }

  /// Read all products with caching
  Future<List<Product>> readAll() async {
    try {
      // Return cached data if valid
      if (_cachedProducts != null && _cacheTime != null && DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedProducts!;
      }

      // Fetch from database and cache
      _cachedProducts = _box.values.toList()..sort((a, b) => a.name.compareTo(b.name));
      _cacheTime = DateTime.now();
      return _cachedProducts!;
    } catch (e) {
      throw Exception('Failed to read all products: $e');
    }
  }

  /// Update an existing product
  Future<void> update(String id, Product product) async {
    try {
      if (!_box.containsKey(id)) {
        throw Exception('Product with id $id not found');
      }
      await _box.put(id, product);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Search products by name or description
  Future<List<Product>> search(String query) async {
    try {
      if (query.isEmpty) {
        return await readAll();
      }

      final products = await readAll();
      final lowerQuery = query.toLowerCase();

      return products.where((product) {
        final nameMatch = product.name.toLowerCase().contains(lowerQuery);
        final descriptionMatch = product.description != null && product.description!.toLowerCase().contains(lowerQuery);
        return nameMatch || descriptionMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final products = await readAll();

      if (category.toLowerCase() == 'all') {
        return products;
      }

      return products.where((product) => product.category.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  /// Get only active products
  Future<List<Product>> getActiveProducts() async {
    try {
      final products = await readAll();
      return products.where((product) => product.isActive).toList();
    } catch (e) {
      throw Exception('Failed to get active products: $e');
    }
  }

  /// Get active products by category
  Future<List<Product>> getActiveProductsByCategory(String category) async {
    try {
      final products = await getProductsByCategory(category);
      return products.where((product) => product.isActive).toList();
    } catch (e) {
      throw Exception('Failed to get active products by category: $e');
    }
  }

  /// Toggle product active status (soft delete)
  Future<void> toggleActive(String id) async {
    try {
      final product = await read(id);
      if (product == null) {
        throw Exception('Product with id $id not found');
      }

      product.isActive = !product.isActive;
      product.updatedAt = DateTime.now();
      await _box.put(id, product);
      invalidateCache();
    } catch (e) {
      throw Exception('Failed to toggle product active status: $e');
    }
  }

  /// Invalidate the cache
  void invalidateCache() {
    _cachedProducts = null;
    _cacheTime = null;
  }

  /// Get total product count
  Future<int> getCount() async {
    try {
      return _box.length;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }

  /// Get active product count
  Future<int> getActiveCount() async {
    try {
      final activeProducts = await getActiveProducts();
      return activeProducts.length;
    } catch (e) {
      throw Exception('Failed to get active product count: $e');
    }
  }
}
