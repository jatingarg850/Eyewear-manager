import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';

/// BillingDetailsScreen - Step 3 of Create Bill flow
/// Displays cart summary and allows applying discounts and selecting payment method
/// Features:
/// - Cart summary with editable quantities
/// - Subtotal calculation
/// - Special discount input with percentage/fixed toggle
/// - Additional discount input with percentage/fixed toggle
/// - Live calculation display for discount amounts
/// - Payment method selector (Cash, Card, UPI)
/// - Total amount display
/// - Complete Bill button
class BillingDetailsScreen extends StatefulWidget {
  const BillingDetailsScreen({super.key});

  @override
  State<BillingDetailsScreen> createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<BillingDetailsScreen> {
  final TextEditingController _specialDiscountController = TextEditingController();
  final TextEditingController _additionalDiscountController = TextEditingController();

  String _specialDiscountType = 'percentage';
  String _additionalDiscountType = 'percentage';
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();

    // Initialize with current bill values if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentBill = context.read<BillProvider>().currentBill;
      if (currentBill != null) {
        _specialDiscountController.text = currentBill.specialDiscount > 0 ? currentBill.specialDiscount.toString() : '';
        _additionalDiscountController.text = currentBill.additionalDiscount > 0 ? currentBill.additionalDiscount.toString() : '';
        setState(() {
          _specialDiscountType = currentBill.discountType;
          _additionalDiscountType = currentBill.additionalDiscountType;
          _paymentMethod = currentBill.paymentMethod;
        });
      }
    });
  }

  @override
  void dispose() {
    _specialDiscountController.dispose();
    _additionalDiscountController.dispose();
    super.dispose();
  }

  /// Update special discount
  void _updateSpecialDiscount() {
    final value = double.tryParse(_specialDiscountController.text) ?? 0.0;
    context.read<BillProvider>().applySpecialDiscount(value, _specialDiscountType);
  }

  /// Update additional discount
  void _updateAdditionalDiscount() {
    final value = double.tryParse(_additionalDiscountController.text) ?? 0.0;
    context.read<BillProvider>().applyAdditionalDiscount(value, _additionalDiscountType);
  }

  /// Update payment method
  void _updatePaymentMethod(String method) {
    setState(() {
      _paymentMethod = method;
    });
    context.read<BillProvider>().setPaymentMethod(method);
  }

  /// Update item quantity
  void _updateQuantity(int index, int newQuantity) {
    context.read<BillProvider>().updateQuantity(index, newQuantity);
  }

  /// Remove item from cart
  void _removeItem(int index) {
    context.read<BillProvider>().removeLineItem(index);
  }

  /// Complete bill and navigate to success screen
  void _completeBill() {
    final currentBill = context.read<BillProvider>().currentBill;

    if (currentBill == null || currentBill.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to bill completion flow
    Navigator.pushNamed(context, '/create-bill/complete');
  }

  /// Format currency
  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Calculate discount amount
  double _calculateDiscountAmount(double base, double discount, String type) {
    if (type == 'percentage') {
      return base * (discount / 100);
    }
    return discount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Billing Details',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          final currentBill = billProvider.currentBill;

          if (currentBill == null) {
            return const Center(
              child: Text('No bill in progress'),
            );
          }

          final subtotal = currentBill.subtotal;
          final specialDiscountAmount = _calculateDiscountAmount(
            subtotal,
            currentBill.specialDiscount,
            currentBill.discountType,
          );
          final afterSpecialDiscount = subtotal - specialDiscountAmount;
          final additionalDiscountAmount = _calculateDiscountAmount(
            afterSpecialDiscount,
            currentBill.additionalDiscount,
            currentBill.additionalDiscountType,
          );
          final total = currentBill.totalAmount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Summary
                const Text(
                  'Cart Summary',
                  style: TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      children: [
                        ...currentBill.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontFamily: AppTheme.bodyFont,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: AppTheme.spacing4),
                                      Text(
                                        '${_formatCurrency(item.unitPrice)} × ${item.quantity}',
                                        style: TextStyle(
                                          fontFamily: AppTheme.bodyFont,
                                          fontSize: 12,
                                          color: AppTheme.textColor.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity controls
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _updateQuantity(index, item.quantity - 1),
                                        icon: const Icon(Icons.remove, size: 18),
                                        color: AppTheme.accentColor,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 24),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontFamily: AppTheme.headingFont,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _updateQuantity(index, item.quantity + 1),
                                        icon: const Icon(Icons.add, size: 18),
                                        color: AppTheme.accentColor,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacing8),
                                // Price
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    _formatCurrency(item.totalPrice),
                                    style: const TextStyle(
                                      fontFamily: AppTheme.headingFont,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                // Delete button
                                IconButton(
                                  onPressed: () => _removeItem(index),
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  color: AppTheme.errorColor,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal:',
                              style: TextStyle(
                                fontFamily: AppTheme.bodyFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatCurrency(subtotal),
                              style: const TextStyle(
                                fontFamily: AppTheme.headingFont,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Special Discount
                const Text(
                  'Special Discount',
                  style: TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Type toggle
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'percentage', label: Text('%')),
                                ButtonSegment(value: 'fixed', label: Text('₹')),
                              ],
                              selected: {
                                _specialDiscountType
                              },
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _specialDiscountType = newSelection.first;
                                });
                                _updateSpecialDiscount();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            // Input field
                            Expanded(
                              child: TextField(
                                controller: _specialDiscountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                decoration: InputDecoration(
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing12,
                                    vertical: AppTheme.spacing12,
                                  ),
                                ),
                                onChanged: (_) => _updateSpecialDiscount(),
                              ),
                            ),
                          ],
                        ),
                        if (specialDiscountAmount > 0) ...[
                          const SizedBox(height: AppTheme.spacing8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount:',
                                style: TextStyle(
                                  fontFamily: AppTheme.bodyFont,
                                  fontSize: 14,
                                  color: AppTheme.textColor.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '-${_formatCurrency(specialDiscountAmount)}',
                                style: const TextStyle(
                                  fontFamily: AppTheme.headingFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Additional Discount
                const Text(
                  'Additional Discount',
                  style: TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Type toggle
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'percentage', label: Text('%')),
                                ButtonSegment(value: 'fixed', label: Text('₹')),
                              ],
                              selected: {
                                _additionalDiscountType
                              },
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _additionalDiscountType = newSelection.first;
                                });
                                _updateAdditionalDiscount();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            // Input field
                            Expanded(
                              child: TextField(
                                controller: _additionalDiscountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                decoration: InputDecoration(
                                  hintText: '0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing12,
                                    vertical: AppTheme.spacing12,
                                  ),
                                ),
                                onChanged: (_) => _updateAdditionalDiscount(),
                              ),
                            ),
                          ],
                        ),
                        if (additionalDiscountAmount > 0) ...[
                          const SizedBox(height: AppTheme.spacing8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount:',
                                style: TextStyle(
                                  fontFamily: AppTheme.bodyFont,
                                  fontSize: 14,
                                  color: AppTheme.textColor.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '-${_formatCurrency(additionalDiscountAmount)}',
                                style: const TextStyle(
                                  fontFamily: AppTheme.headingFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Payment Method
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('Cash'),
                          value: 'Cash',
                          groupValue: _paymentMethod,
                          onChanged: (value) => _updatePaymentMethod(value!),
                          activeColor: AppTheme.primaryColor,
                        ),
                        RadioListTile<String>(
                          title: const Text('Card'),
                          value: 'Card',
                          groupValue: _paymentMethod,
                          onChanged: (value) => _updatePaymentMethod(value!),
                          activeColor: AppTheme.primaryColor,
                        ),
                        RadioListTile<String>(
                          title: const Text('UPI'),
                          value: 'UPI',
                          groupValue: _paymentMethod,
                          onChanged: (value) => _updatePaymentMethod(value!),
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Total Amount
                Card(
                  color: AppTheme.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: const TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Complete Bill button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _completeBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: const Text(
                      'Complete Bill',
                      style: TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          );
        },
      ),
    );
  }
}
