import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';

/// ProductSelectionScreen - Step 2 of Create Bill flow
/// Displays products filtered by category and allows adding to cart
/// Features:
/// - Category tabs (Service, Frame, Lens)
/// - Product list filtered by selected category
/// - Add (+) button with quantity stepper for each product
/// - Cart summary at bottom with item count and subtotal
/// - Next button to proceed to billing details
class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, int> _productQuantities = {}; // Track quantities for each product

  final List<String> _categories = [
    'Service',
    'Frame',
    'Lens'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.loadProducts();
      provider.setCategory(_categories[0]);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      context.read<ProductProvider>().setCategory(_categories[_tabController.index]);
    }
  }

  /// Add product to cart
  void _addToCart(Product product) {
    final currentQty = _productQuantities[product.id] ?? 0;
    setState(() {
      _productQuantities[product.id] = currentQty + 1;
    });

    context.read<BillProvider>().addLineItem(product, 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Increment product quantity
  void _incrementQuantity(Product product, int currentIndex) {
    final billProvider = context.read<BillProvider>();
    final currentBill = billProvider.currentBill;

    if (currentBill != null && currentIndex >= 0) {
      final currentQty = currentBill.items[currentIndex].quantity;
      billProvider.updateQuantity(currentIndex, currentQty + 1);

      setState(() {
        _productQuantities[product.id] = (_productQuantities[product.id] ?? 0) + 1;
      });
    }
  }

  /// Decrement product quantity
  void _decrementQuantity(Product product, int currentIndex) {
    final billProvider = context.read<BillProvider>();
    final currentBill = billProvider.currentBill;

    if (currentBill != null && currentIndex >= 0) {
      final currentQty = currentBill.items[currentIndex].quantity;
      if (currentQty > 1) {
        billProvider.updateQuantity(currentIndex, currentQty - 1);
        setState(() {
          _productQuantities[product.id] = (_productQuantities[product.id] ?? 1) - 1;
        });
      } else {
        // Remove item if quantity becomes 0
        billProvider.removeLineItem(currentIndex);
        setState(() {
          _productQuantities.remove(product.id);
        });
      }
    }
  }

  /// Get current quantity of product in cart
  int _getProductQuantity(Product product) {
    final currentBill = context.watch<BillProvider>().currentBill;
    if (currentBill == null) return 0;

    final index = currentBill.items.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      return currentBill.items[index].quantity;
    }
    return 0;
  }

  /// Get index of product in cart
  int _getProductIndex(Product product) {
    final currentBill = context.read<BillProvider>().currentBill;
    if (currentBill == null) return -1;

    return currentBill.items.indexWhere((item) => item.productId == product.id);
  }

  /// Navigate to billing details
  void _proceedToBillingDetails() {
    final currentBill = context.read<BillProvider>().currentBill;

    if (currentBill == null || currentBill.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product to continue'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/create-bill/billing-details');
  }

  /// Format currency
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Products',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: _categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Product list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
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
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        const Text(
                          'Error loading products',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        ElevatedButton(
                          onPressed: () => provider.loadProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final activeProducts = provider.getActiveProductsByCategory(
                  _categories[_tabController.index],
                );

                if (activeProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppTheme.textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        const Text(
                          'No products available',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Add products in this category to get started',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  itemCount: activeProducts.length,
                  itemBuilder: (context, index) {
                    final product = activeProducts[index];
                    final quantity = _getProductQuantity(product);
                    final productIndex = _getProductIndex(product);

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        child: Row(
                          children: [
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.headingFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    _formatCurrency(product.price),
                                    style: const TextStyle(
                                      fontFamily: AppTheme.headingFont,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  if (product.description != null && product.description!.isNotEmpty) ...[
                                    const SizedBox(height: AppTheme.spacing4),
                                    Text(
                                      product.description!,
                                      style: TextStyle(
                                        fontFamily: AppTheme.bodyFont,
                                        fontSize: 12,
                                        color: AppTheme.textColor.withValues(alpha: 0.6),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing16),
                            // Add/Quantity controls
                            if (quantity == 0)
                              ElevatedButton(
                                onPressed: () => _addToCart(product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentColor,
                                  foregroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: const Icon(Icons.add),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _decrementQuantity(product, productIndex),
                                      icon: const Icon(Icons.remove),
                                      color: AppTheme.accentColor,
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 32),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontFamily: AppTheme.headingFont,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _incrementQuantity(product, productIndex),
                                      icon: const Icon(Icons.add),
                                      color: AppTheme.accentColor,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Cart summary
          Consumer<BillProvider>(
            builder: (context, billProvider, child) {
              final currentBill = billProvider.currentBill;
              final itemCount = currentBill?.items.length ?? 0;
              final subtotal = currentBill?.subtotal ?? 0.0;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Cart info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cart: $itemCount ${itemCount == 1 ? 'item' : 'items'}',
                              style: const TextStyle(
                                fontFamily: AppTheme.bodyFont,
                                fontSize: 14,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _formatCurrency(subtotal),
                              style: const TextStyle(
                                fontFamily: AppTheme.headingFont,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Next button
                      ElevatedButton(
                        onPressed: itemCount > 0 ? _proceedToBillingDetails : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing32,
                            vertical: AppTheme.spacing16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
