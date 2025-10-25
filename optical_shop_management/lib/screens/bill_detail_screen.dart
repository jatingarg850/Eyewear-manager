import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';

/// BillDetailScreen displays detailed information about a specific bill
/// Features:
/// - Customer info section
/// - Line items table with product, quantity, price
/// - Pricing breakdown (subtotal, discounts, total)
/// - Payment method badge
/// - Timestamp display
/// - Share and delete buttons
/// - Confirmation dialog for delete action
/// Requirements: 2.5, 2.6
class BillDetailScreen extends StatelessWidget {
  final Bill bill;

  const BillDetailScreen({
    super.key,
    required this.bill,
  });

  /// Format currency
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Format date and time
  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  /// Get payment method color
  Color _getPaymentMethodColor() {
    switch (bill.paymentMethod.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10b981); // Green
      case 'card':
        return const Color(0xFF3b82f6); // Blue
      case 'upi':
        return const Color(0xFF8b5cf6); // Purple
      default:
        return AppTheme.textColor;
    }
  }

  /// Get payment method icon
  IconData _getPaymentMethodIcon() {
    switch (bill.paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.qr_code_2;
      default:
        return Icons.payment;
    }
  }

  /// Calculate discount amount for special discount
  double _calculateSpecialDiscountAmount() {
    if (bill.discountType == 'percentage') {
      return bill.subtotal * (bill.specialDiscount / 100);
    }
    return bill.specialDiscount;
  }

  /// Calculate discount amount for additional discount
  double _calculateAdditionalDiscountAmount() {
    final afterSpecial = bill.subtotal - _calculateSpecialDiscountAmount();
    if (bill.additionalDiscountType == 'percentage') {
      return afterSpecial * (bill.additionalDiscount / 100);
    }
    return bill.additionalDiscount;
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Bill',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this bill? This action cannot be undone.',
          style: TextStyle(fontFamily: AppTheme.bodyFont),
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
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: AppTheme.bodyFont),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteBill(context);
    }
  }

  /// Delete bill
  Future<void> _deleteBill(BuildContext context) async {
    try {
      await context.read<BillProvider>().deleteBill(bill.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bill deleted successfully',
              style: TextStyle(fontFamily: AppTheme.bodyFont),
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting bill: $e',
              style: const TextStyle(fontFamily: AppTheme.bodyFont),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Share bill (placeholder for future implementation)
  void _shareBill(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Share functionality coming soon',
          style: TextStyle(fontFamily: AppTheme.bodyFont),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentColor = _getPaymentMethodColor();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Bill Details',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBill(context),
            tooltip: 'Share bill',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete bill',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Section
            _buildSectionCard(
              title: 'Customer Information',
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Name',
                    value: bill.customerName,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: bill.customerPhone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Line Items Section
            _buildSectionCard(
              title: 'Items',
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'Product',
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'Price',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  // Line items
                  ...bill.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: AppTheme.spacing16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.bodyFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing8,
                                      vertical: AppTheme.spacing4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: TextStyle(
                                        fontFamily: AppTheme.bodyFont,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentColor.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTheme.bodyFont,
                                  fontSize: 14,
                                  color: AppTheme.textColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatCurrency(item.totalPrice),
                                    style: const TextStyle(
                                      fontFamily: AppTheme.bodyFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    '${_formatCurrency(item.unitPrice)} each',
                                    style: TextStyle(
                                      fontFamily: AppTheme.bodyFont,
                                      fontSize: 11,
                                      color: AppTheme.textColor.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Pricing Breakdown Section
            _buildSectionCard(
              title: 'Pricing Breakdown',
              child: Column(
                children: [
                  _buildPricingRow(
                    label: 'Subtotal',
                    value: _formatCurrency(bill.subtotal),
                    isSubtotal: true,
                  ),
                  if (bill.specialDiscount > 0) ...[
                    const SizedBox(height: AppTheme.spacing8),
                    _buildPricingRow(
                      label: 'Special Discount (${bill.discountType == 'percentage' ? '${bill.specialDiscount}%' : 'Fixed'})',
                      value: '-${_formatCurrency(_calculateSpecialDiscountAmount())}',
                      isDiscount: true,
                    ),
                  ],
                  if (bill.additionalDiscount > 0) ...[
                    const SizedBox(height: AppTheme.spacing8),
                    _buildPricingRow(
                      label: 'Additional Discount (${bill.additionalDiscountType == 'percentage' ? '${bill.additionalDiscount}%' : 'Fixed'})',
                      value: '-${_formatCurrency(_calculateAdditionalDiscountAmount())}',
                      isDiscount: true,
                    ),
                  ],
                  const Divider(height: AppTheme.spacing24),
                  _buildPricingRow(
                    label: 'Total Amount',
                    value: _formatCurrency(bill.totalAmount),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Payment Method Section
            _buildSectionCard(
              title: 'Payment Method',
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: paymentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: paymentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(),
                      size: 24,
                      color: paymentColor,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Text(
                      bill.paymentMethod.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: paymentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Timestamp Section
            _buildSectionCard(
              title: 'Timestamp',
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Billing Date',
                    value: _formatDateTime(bill.billingDate),
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _buildInfoRow(
                    icon: Icons.history,
                    label: 'Created At',
                    value: _formatDateTime(bill.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build section card wrapper
  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTheme.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            child,
          ],
        ),
      ),
    );
  }

  /// Build info row with icon, label, and value
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textColor.withValues(alpha: 0.6),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 12,
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build pricing row
  Widget _buildPricingRow({
    required String label,
    required String value,
    bool isSubtotal = false,
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: isTotal ? AppTheme.headingFont : AppTheme.bodyFont,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppTheme.successColor : (isTotal ? AppTheme.primaryColor : AppTheme.textColor),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: isTotal ? AppTheme.headingFont : AppTheme.bodyFont,
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDiscount ? AppTheme.successColor : (isTotal ? AppTheme.primaryColor : AppTheme.textColor),
          ),
        ),
      ],
    );
  }
}
