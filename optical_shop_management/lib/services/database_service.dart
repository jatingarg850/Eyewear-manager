import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/bill.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../models/line_item.dart';

class DatabaseService {
  static const String customersBox = 'customers';
  static const String billsBox = 'bills';
  static const String productsBox = 'products';
  static const String settingsBox = 'settings';

  static bool _initialized = false;

  /// Initialize Hive with Flutter and register all type adapters
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register all type adapters
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(BillAdapter());
    Hive.registerAdapter(LineItemAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(SettingsAdapter());

    // Open all boxes
    await Future.wait([
      Hive.openBox<Customer>(customersBox),
      Hive.openBox<Bill>(billsBox),
      Hive.openBox<Product>(productsBox),
      Hive.openBox<Settings>(settingsBox),
    ]);

    _initialized = true;
  }

  /// Get the customers box
  static Box<Customer> getCustomersBox() {
    return Hive.box<Customer>(customersBox);
  }

  /// Get the bills box
  static Box<Bill> getBillsBox() {
    return Hive.box<Bill>(billsBox);
  }

  /// Get the products box
  static Box<Product> getProductsBox() {
    return Hive.box<Product>(productsBox);
  }

  /// Get the settings box
  static Box<Settings> getSettingsBox() {
    return Hive.box<Settings>(settingsBox);
  }

  /// Close all boxes (useful for testing or cleanup)
  static Future<void> closeAll() async {
    await Hive.close();
    _initialized = false;
  }

  /// Clear all data from all boxes
  /// Requirement: 6.3
  static Future<void> clearAllData() async {
    await Future.wait([
      getCustomersBox().clear(),
      getBillsBox().clear(),
      getProductsBox().clear(),
      getSettingsBox().clear(),
    ]);
  }
}
