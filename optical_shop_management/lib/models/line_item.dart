import 'package:hive/hive.dart';

part 'line_item.g.dart';

@HiveType(typeId: 2)
class LineItem {
  @HiveField(0)
  late String productId;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late double unitPrice;

  @HiveField(5)
  late double totalPrice;

  LineItem({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
