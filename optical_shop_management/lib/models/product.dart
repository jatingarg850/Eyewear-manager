import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 3)
class Product extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late double price;

  @HiveField(4)
  String? description;

  @HiveField(5)
  late int stock;

  @HiveField(6)
  late bool isActive;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
