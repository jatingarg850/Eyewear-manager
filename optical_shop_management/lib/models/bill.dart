import 'package:hive/hive.dart';
import 'line_item.dart';

part 'bill.g.dart';

@HiveType(typeId: 1)
class Bill extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String customerId;

  @HiveField(2)
  late String customerName;

  @HiveField(3)
  late String customerPhone;

  @HiveField(4)
  late List<LineItem> items;

  @HiveField(5)
  late double subtotal;

  @HiveField(6)
  late double specialDiscount;

  @HiveField(7)
  late String discountType;

  @HiveField(8)
  late double additionalDiscount;

  @HiveField(9)
  late String additionalDiscountType;

  @HiveField(10)
  late double totalAmount;

  @HiveField(11)
  late String paymentMethod;

  @HiveField(12)
  late DateTime billingDate;

  @HiveField(13)
  late DateTime createdAt;

  Bill({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.specialDiscount,
    required this.discountType,
    required this.additionalDiscount,
    required this.additionalDiscountType,
    required this.totalAmount,
    required this.paymentMethod,
    required this.billingDate,
    required this.createdAt,
  });
}
