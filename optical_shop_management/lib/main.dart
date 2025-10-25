import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_initializer.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/providers.dart';
import 'services/services.dart';
import 'screens/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optical Shop Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppInitializerWidget(),
    );
  }
}

/// Widget that handles app initialization and displays splash screen
class AppInitializerWidget extends StatefulWidget {
  const AppInitializerWidget({super.key});

  @override
  State<AppInitializerWidget> createState() => _AppInitializerWidgetState();
}

class _AppInitializerWidgetState extends State<AppInitializerWidget> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize the app (Hive, adapters, boxes)
      await AppInitializer.initialize();

      // Add a small delay to show splash screen (minimum 1 second)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize app: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error screen if initialization failed
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Initialization Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show splash screen while initializing
    if (!_isInitialized) {
      return const SplashScreen();
    }

    // Show main app after initialization
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(CustomerService())..loadCustomers(),
        ),
        ChangeNotifierProvider(
          create: (_) => BillProvider(BillService())..loadBills(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductService())..loadProducts(),
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider(
            BillService(),
            CustomerService(),
          )..loadDashboardData(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Optical Shop Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
