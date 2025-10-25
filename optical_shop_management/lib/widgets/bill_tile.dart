import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../theme/app_theme.dart';

/// BillTile widget displays bill information in a list tile format
/// Features customer name, bill date, amount, payment method badge, and item count
/// Color-coded border based on payment method
/// Supports tap handler for navigation
class BillTile extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;

  const BillTile({
    super.key,
    required this.bill,
    this.onTap,
  });

  /// Get color based on payment method
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

  /// Get icon based on payment method
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

  /// Format currency
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final billDate = DateTime(date.year, date.month, date.day);

    if (billDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (billDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentColor = _getPaymentMethodColor();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: paymentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with customer name and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.customerName,
                          style: const TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          bill.customerPhone,
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 12,
                            color: AppTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(bill.totalAmount),
                    style: const TextStyle(
                      fontFamily: AppTheme.headingFont,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              // Date and details row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    _formatDate(bill.billingDate),
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: AppTheme.textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    '${bill.items.length} ${bill.items.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      fontFamily: AppTheme.bodyFont,
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              // Payment method badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: paymentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: paymentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPaymentMethodIcon(),
                      size: 16,
                      color: paymentColor,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      bill.paymentMethod.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: paymentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
