import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 4)
class Settings extends HiveObject {
  @HiveField(0)
  late String companyName;

  @HiveField(1)
  String? gstNumber;

  @HiveField(2)
  late String phoneNumber;

  @HiveField(3)
  String? address;

  @HiveField(4)
  late String currency;

  @HiveField(5)
  late bool enableGST;

  @HiveField(6)
  late double defaultTax;

  Settings({
    required this.companyName,
    this.gstNumber,
    required this.phoneNumber,
    this.address,
    required this.currency,
    required this.enableGST,
    required this.defaultTax,
  });
}
