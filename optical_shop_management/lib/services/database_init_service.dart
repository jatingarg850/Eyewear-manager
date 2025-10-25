import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/bill.dart';
import '../models/line_item.dart';
import '../models/product.dart';
import '../models/settings.dart';

/// Service responsible for initializing Hive database
/// Registers all type adapters and opens all required boxes
class DatabaseInitService {
  static bool _isInitialized = false;

  /// Initialize Hive with Flutter and set up all boxes
  /// This should be called once at app startup
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register all type adapters
    _registerAdapters();

    // Open all boxes
    await _openBoxes();

    _isInitialized = true;
  }

  /// Register all Hive type adapters
  static void _registerAdapters() {
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(BillAdapter());
    Hive.registerAdapter(LineItemAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(SettingsAdapter());
  }

  /// Open all required Hive boxes
  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<Customer>('customers'),
      Hive.openBox<Bill>('bills'),
      Hive.openBox<Product>('products'),
      Hive.openBox<Settings>('settings'),
    ]);
  }

  /// Check if database is initialized
  static bool get isInitialized => _isInitialized;

  /// Close all boxes (useful for testing or cleanup)
  static Future<void> closeAll() async {
    await Hive.close();
    _isInitialized = false;
  }
}
