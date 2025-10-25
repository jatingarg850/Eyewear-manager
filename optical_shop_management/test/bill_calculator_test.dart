import 'package:flutter_test/flutter_test.dart';
import 'package:optical_shop_management/utils/bill_calculator.dart';
import 'package:optical_shop_management/models/bill.dart';
import 'package:optical_shop_management/models/line_item.dart';

void main() {
  group('BillCalculator', () {
    test('calculateTotal applies special discount first, then additional discount', () {
      // Requirement 2.3: Special discount first, then additional
      // Subtotal: 1000
      // Special discount: 10% = 100 off -> 900
      // Additional discount: 50 fixed -> 850
      final result = BillCalculator.calculateTotal(
        subtotal: 1000,
        specialDiscount: 10,
        specialDiscountType: 'percentage',
        additionalDiscount: 50,
        additionalDiscountType: 'fixed',
      );

      expect(result, 850);
    });

    test('calculateTotal prevents negative totals', () {
      // Requirement 2.4: Prevent negative totals
      final result = BillCalculator.calculateTotal(
        subtotal: 100,
        specialDiscount: 50,
        specialDiscountType: 'percentage',
        additionalDiscount: 200,
        additionalDiscountType: 'fixed',
      );

      // 100 - 50% = 50, 50 - 200 = -150, clamped to 0
      expect(result, 0);
    });

    test('calculateTotal handles percentage discounts correctly', () {
      final result = BillCalculator.calculateTotal(
        subtotal: 1000,
        specialDiscount: 20,
        specialDiscountType: 'percentage',
        additionalDiscount: 10,
        additionalDiscountType: 'percentage',
      );

      // 1000 - 20% = 800, 800 - 10% = 720
      expect(result, 720);
    });

    test('calculateTotal handles fixed discounts correctly', () {
      final result = BillCalculator.calculateTotal(
        subtotal: 1000,
        specialDiscount: 100,
        specialDiscountType: 'fixed',
        additionalDiscount: 50,
        additionalDiscountType: 'fixed',
      );

      // 1000 - 100 = 900, 900 - 50 = 850
      expect(result, 850);
    });

    test('calculateTotal handles no discounts', () {
      final result = BillCalculator.calculateTotal(
        subtotal: 1000,
        specialDiscount: 0,
        specialDiscountType: 'percentage',
        additionalDiscount: 0,
        additionalDiscountType: 'percentage',
      );

      expect(result, 1000);
    });

    test('calculateTotalCached uses memoization', () {
      // Clear cache first
      BillCalculator.clearCache();

      final bill = Bill(
        id: 'test-1',
        customerId: 'cust-1',
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        items: [],
        subtotal: 1000,
        specialDiscount: 10,
        discountType: 'percentage',
        additionalDiscount: 50,
        additionalDiscountType: 'fixed',
        totalAmount: 0,
        paymentMethod: 'Cash',
        billingDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // First call should calculate and cache
      final result1 = BillCalculator.calculateTotalCached(bill);
      expect(result1, 850);
      expect(BillCalculator.getCacheSize(), 1);

      // Second call should use cache
      final result2 = BillCalculator.calculateTotalCached(bill);
      expect(result2, 850);
      expect(BillCalculator.getCacheSize(), 1);
    });

    test('clearCache removes all cached calculations', () {
      final bill = Bill(
        id: 'test-2',
        customerId: 'cust-2',
        customerName: 'Test Customer',
        customerPhone: '1234567890',
        items: [],
        subtotal: 500,
        specialDiscount: 5,
        discountType: 'percentage',
        additionalDiscount: 25,
        additionalDiscountType: 'fixed',
        totalAmount: 0,
        paymentMethod: 'Cash',
        billingDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      BillCalculator.calculateTotalCached(bill);
      expect(BillCalculator.getCacheSize(), greaterThan(0));

      BillCalculator.clearCache();
      expect(BillCalculator.getCacheSize(), 0);
    });
  });
}
