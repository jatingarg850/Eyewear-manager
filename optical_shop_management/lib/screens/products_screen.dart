import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../theme/app_theme.dart';

/// ProductsScreen displays all products with category filtering and search
/// Features:
/// - Category tabs (All, Service, Frame, Lens)
/// - Search bar for filtering products
/// - Grid/List view of products using ProductCard widgets
/// - FAB for adding new products
/// Requirements: 3.4, 3.5
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _categories = [
    'All',
    'Service',
    'Frame',
    'Lens'
  ];

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _handleCategoryChange(String category) {
    context.read<ProductProvider>().setCategory(category);
  }

  void _navigateToAddProduct() {
    context.push('/products/add').then((_) {
      // Reload products after returning from add screen
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  void _navigateToEditProduct(String productId) {
    context.push('/products/$productId/edit').then((_) {
      // Reload products after returning from edit screen
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  Future<void> _handleToggleActive(String productId) async {
    // Get the product to check its current status
    final provider = context.read<ProductProvider>();
    final product = provider.allProducts.firstWhere((p) => p.id == productId);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          product.isActive ? 'Hide Product?' : 'Show Product?',
          style: const TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          product.isActive ? 'This product will be hidden from active listings. You can show it again later.' : 'This product will be shown in active listings.',
          style: const TextStyle(
            fontFamily: AppTheme.bodyFont,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                color: AppTheme.textColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: product.isActive ? AppTheme.errorColor : AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              product.isActive ? 'Hide' : 'Show',
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await provider.toggleProductActive(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              product.isActive ? 'Product hidden successfully' : 'Product shown successfully',
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing16,
              0,
              AppTheme.spacing16,
              AppTheme.spacing16,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                color: AppTheme.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.textColor.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
              ),
            ),
          ),
          // Category tabs
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = provider.selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppTheme.spacing8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _handleCategoryChange(category),
                          backgroundColor: Colors.grey[200],
                          selectedColor: AppTheme.accentColor,
                          labelStyle: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.textColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing12,
                            vertical: AppTheme.spacing8,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          // Products list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'Failed to load products',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 14,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadProducts(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter products by search query
                final filteredProducts = _searchQuery.isEmpty
                    ? provider.products
                    : provider.products.where((product) {
                        final nameMatch = product.name.toLowerCase().contains(_searchQuery);
                        final descriptionMatch = product.description != null && product.description!.toLowerCase().contains(_searchQuery);
                        return nameMatch || descriptionMatch;
                      }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: AppTheme.textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          _searchQuery.isEmpty ? 'No products yet' : 'No products found',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          _searchQuery.isEmpty ? 'Add your first product to get started' : 'Try a different search term',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 14,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(
                      key: ValueKey(product.id),
                      product: product,
                      onEdit: () => _navigateToEditProduct(product.id),
                      onToggleActive: () => _handleToggleActive(product.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Product',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
