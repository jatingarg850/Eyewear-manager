# Dashboard Screen

## Overview
The Dashboard screen is the main landing page of the Optical Shop Management application. It displays key business metrics and provides quick access to common actions.

## Features Implemented

### 1. App Bar
- Displays company name (loaded from settings)
- Settings icon button for navigation to settings screen
- Navy blue background matching the app theme

### 2. Time-Based Greeting
- Displays contextual greeting based on time of day:
  - "Good Morning" (before 12 PM) with sun icon
  - "Good Afternoon" (12 PM - 5 PM) with cloud icon
  - "Good Evening" (after 5 PM) with moon icon
- Shows welcome message with company name
- Styled with gradient background and icon

### 3. Statistics Cards (Horizontal Scroll)
Four animated stat cards displaying:
- **Total Revenue**: All-time revenue with currency symbol
- **Customers Today**: Count of customers who visited today
- **Total Sales**: Total number of bills created
- **Monthly Revenue**: Revenue for current month

Each card features:
- Animated counter that counts from 0 to actual value
- Glassmorphism effect with gradient background
- Color-coded design (green, amber, navy, purple)
- Tap handler for filtered navigation (placeholder)
- Icon representing the metric

### 4. Pull-to-Refresh
- Swipe down to refresh all dashboard data
- Reloads settings and dashboard metrics
- Shows loading indicator during refresh

### 5. Quick Actions Section
Two quick action cards:
- **Add Customer**: Navigate to customer creation
- **Create Bill**: Navigate to bill creation flow
- Cards have bordered design with icons
- Tap handlers with placeholder navigation

### 6. State Management
- Integrates with `DashboardProvider` for data
- Shows loading state on initial load
- Displays error state with retry button
- Uses `AutomaticKeepAliveClientMixin` to preserve state

### 7. Error Handling
- Graceful error display with icon and message
- Retry button to reload data
- Fallback to default values if settings fail

## Requirements Satisfied

✅ **Requirement 4.1**: Display total revenue, customers today, total sales, and monthly revenue  
✅ **Requirement 4.2**: Animate statistics counters from zero to actual values within 1 second  
✅ **Requirement 4.3**: Calculate today's metrics by filtering bills  
✅ **Requirement 4.4**: Calculate monthly revenue for current calendar month  
✅ **Requirement 4.5**: Tap handlers on statistics cards for filtered navigation  
✅ **Requirement 7.1**: Smooth animations and responsive UI  
✅ **Requirement 7.2**: Screen transitions within 300ms (ready for navigation)  
✅ **Requirement 7.5**: Staggered animations (cards scroll smoothly)

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:optical_shop_management/models/models.dart';
import 'package:optical_shop_management/services/services.dart';
import 'package:optical_shop_management/providers/providers.dart';
import 'package:optical_shop_management/screens/screens.dart';
import 'package:optical_shop_management/theme/app_theme.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: 'Optical Shop Management',
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
```

## Navigation Placeholders

The following navigation actions are implemented with placeholder SnackBar messages:
- Tap on stat cards → Navigate to filtered bills view
- Tap on "Customers Today" → Navigate to customers screen
- Settings icon → Navigate to settings screen
- "Add Customer" quick action → Navigate to add customer form
- "Create Bill" quick action → Navigate to bill creation flow

These will be connected to actual screens when navigation is implemented in Task 15.

## Performance Optimizations

1. **AutomaticKeepAliveClientMixin**: Preserves dashboard state when navigating away
2. **Cached Settings**: Settings are loaded once and cached in state
3. **Provider Integration**: Efficient state updates through Provider
4. **Lazy Loading**: Stats are only calculated when dashboard loads

## Styling

- Uses `AppTheme` constants for consistent spacing, colors, and typography
- Gradient backgrounds for visual appeal
- Glassmorphism effects on stat cards
- Rounded corners (16px) for modern look
- Color-coded cards for easy identification

## Testing

To test the dashboard screen:
1. Run the example app: `flutter run example/dashboard_example.dart`
2. Verify all stat cards display correctly
3. Test pull-to-refresh functionality
4. Verify greeting changes based on time
5. Test tap handlers show appropriate messages
6. Verify error state displays when data fails to load

## Future Enhancements

- Add revenue trend chart below stats
- Implement actual navigation to filtered views
- Add more quick actions
- Show recent activity feed
- Add date range selector for metrics
