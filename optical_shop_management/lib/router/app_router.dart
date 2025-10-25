import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/screens.dart';
import '../widgets/main_scaffold.dart';
import '../providers/providers.dart';

/// Application router configuration using GoRouter
/// Implements nested routes with bottom navigation
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Dashboard route
        GoRoute(
          path: '/',
          name: 'dashboard',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
          ),
        ),

        // Customers routes
        GoRoute(
          path: '/customers',
          name: 'customers',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const CustomersScreen(),
          ),
          routes: [
            GoRoute(
              path: 'add',
              name: 'add-customer',
              builder: (context, state) => const AddEditCustomerScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'edit-customer',
              builder: (context, state) {
                // Find customer by ID from provider
                final customerId = state.pathParameters['id'];
                final customerProvider = context.read<CustomerProvider>();
                final customer = customerProvider.customers.where((c) => c.id == customerId).firstOrNull;

                return AddEditCustomerScreen(customer: customer);
              },
            ),
          ],
        ),

        // Bills routes
        GoRoute(
          path: '/bills',
          name: 'bills',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const BillsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'create',
              name: 'create-bill',
              builder: (context, state) => const CustomerSelectionScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'bill-detail',
              builder: (context, state) {
                // Find bill by ID from provider
                final billId = state.pathParameters['id']!;
                final billProvider = context.read<BillProvider>();
                final bill = billProvider.bills.where((b) => b.id == billId).first;

                return BillDetailScreen(bill: bill);
              },
            ),
          ],
        ),

        // Products routes
        GoRoute(
          path: '/products',
          name: 'products',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ProductsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'add',
              name: 'add-product',
              builder: (context, state) => const AddEditProductScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'edit-product',
              builder: (context, state) => AddEditProductScreen(
                productId: state.pathParameters['id'],
              ),
            ),
          ],
        ),

        // Settings route
        GoRoute(
          path: '/settings',
          name: 'settings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
