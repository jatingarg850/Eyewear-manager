import 'package:flutter/material.dart';

/// Widget to display when a list is empty
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with circular background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1a365d).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: const Color(0xFF1a365d).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2d3748),
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),

            // Action button (optional)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf59e0b),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state specifically for customers list
class EmptyCustomersState extends StatelessWidget {
  final VoidCallback? onAddCustomer;

  const EmptyCustomersState({
    super.key,
    this.onAddCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'No Customers Yet',
      message: 'Start building your customer base by adding your first customer.',
      actionLabel: 'Add Customer',
      onAction: onAddCustomer,
    );
  }
}

/// Empty state specifically for bills list
class EmptyBillsState extends StatelessWidget {
  final VoidCallback? onCreateBill;

  const EmptyBillsState({
    super.key,
    this.onCreateBill,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No Bills Yet',
      message: 'Create your first bill to start tracking sales and revenue.',
      actionLabel: 'Create Bill',
      onAction: onCreateBill,
    );
  }
}

/// Empty state specifically for products list
class EmptyProductsState extends StatelessWidget {
  final VoidCallback? onAddProduct;

  const EmptyProductsState({
    super.key,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No Products Yet',
      message: 'Add products to your inventory to include them in bills.',
      actionLabel: 'Add Product',
      onAction: onAddProduct,
    );
  }
}

/// Empty state for search results
class EmptySearchState extends StatelessWidget {
  final String searchQuery;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'No results found for "$searchQuery". Try a different search term.',
    );
  }
}

/// Empty state for filtered results
class EmptyFilterState extends StatelessWidget {
  final String filterName;
  final VoidCallback? onClearFilter;

  const EmptyFilterState({
    super.key,
    required this.filterName,
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.filter_list_off,
      title: 'No Results',
      message: 'No items match the "$filterName" filter.',
      actionLabel: onClearFilter != null ? 'Clear Filter' : null,
      onAction: onClearFilter,
    );
  }
}
