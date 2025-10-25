import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/models/customer.dart';
import '../lib/models/bill.dart';
import '../lib/models/line_item.dart';
import '../lib/models/product.dart';
import '../lib/models/settings.dart';
import '../lib/services/services.dart';
import '../lib/providers/providers.dart';
import '../lib/screens/screens.dart';
import '../lib/theme/app_theme.dart';

/// Example app demonstrating the Dashboard screen
/// This shows how to initialize the app with providers and services
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(BillAdapter());
  Hive.registerAdapter(LineItemAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SettingsAdapter());

  // Open boxes
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<Bill>('bills');
  await Hive.openBox<Product>('products');
  await Hive.openBox<Settings>('settings');

  runApp(const DashboardExampleApp());
}

class DashboardExampleApp extends StatelessWidget {
  const DashboardExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final customerService = CustomerService();
    final billService = BillService();
    final productService = ProductService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(customerService),
        ),
        ChangeNotifierProvider(
          create: (_) => BillProvider(billService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productService),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(billService, customerService),
        ),
      ],
      child: MaterialApp(
        title: 'Dashboard Example',
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
