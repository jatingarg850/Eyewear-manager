import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phoneNumber;

  @HiveField(3)
  late int age;

  @HiveField(4)
  String? prescriptionLeft;

  @HiveField(5)
  String? prescriptionRight;

  @HiveField(6)
  String? address;

  @HiveField(7)
  late DateTime firstVisit;

  @HiveField(8)
  late DateTime lastVisit;

  @HiveField(9)
  late int totalVisits;

  @HiveField(10)
  late DateTime createdAt;

  @HiveField(11)
  late DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.age,
    this.prescriptionLeft,
    this.prescriptionRight,
    this.address,
    required this.firstVisit,
    required this.lastVisit,
    required this.totalVisits,
    required this.createdAt,
    required this.updatedAt,
  });
}
