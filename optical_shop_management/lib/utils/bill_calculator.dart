import '../models/bill.dart';

/// Utility class for bill calculation with optimization and memoization
/// Handles discount calculations and prevents negative totals
class BillCalculator {
  // Cache for memoized calculations
  static final Map<String, double> _calculationCache = {};

  /// Calculate bill total with discount logic
  /// Special discount is applied first, then additional discount
  /// Returns clamped value to prevent negative totals
  static double calculateTotal({
    required double subtotal,
    required double specialDiscount,
    required String specialDiscountType,
    required double additionalDiscount,
    required String additionalDiscountType,
  }) {
    // Apply special discount first
    double afterSpecialDiscount = subtotal;
    if (specialDiscount > 0) {
      if (specialDiscountType == 'percentage') {
        afterSpecialDiscount = subtotal * (1 - specialDiscount / 100);
      } else {
        // Fixed amount
        afterSpecialDiscount = subtotal - specialDiscount;
      }
    }

    // Apply additional discount
    double finalAmount = afterSpecialDiscount;
    if (additionalDiscount > 0) {
      if (additionalDiscountType == 'percentage') {
        finalAmount = afterSpecialDiscount * (1 - additionalDiscount / 100);
      } else {
        // Fixed amount
        finalAmount = afterSpecialDiscount - additionalDiscount;
      }
    }

    // Prevent negative totals
    return finalAmount.clamp(0, double.infinity);
  }

  /// Calculate bill total with memoization for repeated calculations
  /// Uses cache key based on bill parameters to avoid redundant calculations
  static double calculateTotalCached(Bill bill) {
    final key = '${bill.subtotal}_${bill.specialDiscount}_'
        '${bill.discountType}_${bill.additionalDiscount}_'
        '${bill.additionalDiscountType}';

    if (_calculationCache.containsKey(key)) {
      return _calculationCache[key]!;
    }

    final result = calculateTotal(
      subtotal: bill.subtotal,
      specialDiscount: bill.specialDiscount,
      specialDiscountType: bill.discountType,
      additionalDiscount: bill.additionalDiscount,
      additionalDiscountType: bill.additionalDiscountType,
    );

    _calculationCache[key] = result;
    return result;
  }

  /// Clear the calculation cache
  /// Should be called periodically to prevent memory buildup
  static void clearCache() {
    _calculationCache.clear();
  }

  /// Get cache size for monitoring
  static int getCacheSize() {
    return _calculationCache.length;
  }
}
