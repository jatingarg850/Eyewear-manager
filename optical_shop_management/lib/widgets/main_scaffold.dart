import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Main scaffold with bottom navigation bar
/// Wraps all main screens and provides navigation between them
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/customers')) return 1;
    if (location.startsWith('/bills')) return 2;
    if (location.startsWith('/products')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/customers');
        break;
      case 2:
        context.go('/bills');
        break;
      case 3:
        context.go('/products');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Consumer<BillProvider>(
      builder: (context, billProvider, child) {
        // Calculate today's bill count for badge
        final today = DateTime.now();
        final todayBills = billProvider.bills.where((bill) {
          return bill.billingDate.year == today.year && bill.billingDate.month == today.month && bill.billingDate.day == today.day;
        }).length;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Customers',
            ),
            BottomNavigationBarItem(
              icon: todayBills > 0
                  ? Badge(
                      label: Text('$todayBills'),
                      backgroundColor: AppTheme.accentColor,
                      child: const Icon(Icons.receipt_long_rounded),
                    )
                  : const Icon(Icons.receipt_long_rounded),
              label: 'Bills',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Products',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}
