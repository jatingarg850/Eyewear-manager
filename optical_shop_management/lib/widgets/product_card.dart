import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// ProductCard widget displays product information in a card format
/// Features product name, category badge, price
/// Includes edit, toggle active, and add to cart buttons
/// Category color-coding for visual distinction
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onToggleActive,
    this.onAddToCart,
  });

  /// Get color based on product category
  Color _getCategoryColor() {
    switch (product.category.toLowerCase()) {
      case 'service':
        return const Color(0xFF3b82f6); // Blue
      case 'frame':
        return const Color(0xFFf59e0b); // Amber
      case 'lens':
        return const Color(0xFF10b981); // Green
      default:
        return AppTheme.textColor;
    }
  }

  /// Get icon based on product category
  IconData _getCategoryIcon() {
    switch (product.category.toLowerCase()) {
      case 'service':
        return Icons.medical_services;
      case 'frame':
        return Icons.visibility;
      case 'lens':
        return Icons.lens;
      default:
        return Icons.inventory_2;
    }
  }

  /// Format currency
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Card(
      margin: const EdgeInsets.all(AppTheme.spacing8),
      elevation: product.isActive ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: categoryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Opacity(
        opacity: product.isActive ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 14,
                          color: categoryColor,
                        ),
                        const SizedBox(width: AppTheme.spacing4),
                        Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!product.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Text(
                        'INACTIVE',
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              // Product name
              Text(
                product.name,
                style: const TextStyle(
                  fontFamily: AppTheme.headingFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  product.description!,
                  style: TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 12,
                    color: AppTheme.textColor.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppTheme.spacing12),
              // Price
              Text(
                _formatCurrency(product.price),
                style: const TextStyle(
                  fontFamily: AppTheme.headingFont,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              // Stock info
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: AppTheme.textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              // Action buttons
              Row(
                children: [
                  // Edit button
                  if (onEdit != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                  if (onEdit != null && onToggleActive != null) const SizedBox(width: AppTheme.spacing8),
                  // Toggle active button
                  if (onToggleActive != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleActive,
                        icon: Icon(
                          product.isActive ? Icons.visibility_off : Icons.visibility,
                          size: 16,
                        ),
                        label: Text(product.isActive ? 'Hide' : 'Show'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: product.isActive ? AppTheme.errorColor : AppTheme.successColor,
                          side: BorderSide(
                            color: product.isActive ? AppTheme.errorColor : AppTheme.successColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Add to cart button (if provided)
              if (onAddToCart != null) ...[
                const SizedBox(height: AppTheme.spacing8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: product.isActive ? onAddToCart : null,
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
