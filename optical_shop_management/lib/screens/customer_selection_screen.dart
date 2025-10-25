import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/highlighted_customer_tile.dart';
import 'add_edit_customer_screen.dart';

/// CustomerSelectionScreen - Step 1 of Create Bill flow
/// Displays existing customer list with search and allows customer selection
/// Features:
/// - Search bar for filtering customers
/// - Add New Customer button at top
/// - Delete button next to each customer with confirmation dialog
/// - Navigate to product selection on customer selection
class CustomerSelectionScreen extends StatefulWidget {
  const CustomerSelectionScreen({super.key});

  @override
  State<CustomerSelectionScreen> createState() => _CustomerSelectionScreenState();
}

class _CustomerSelectionScreenState extends State<CustomerSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load customers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handle customer selection
  void _onCustomerSelected(Customer customer) {
    // Start new bill with selected customer
    context.read<BillProvider>().startNewBill(customer);

    // Navigate to product selection screen
    Navigator.pushNamed(context, '/create-bill/products');
  }

  /// Handle add new customer
  Future<void> _onAddNewCustomer() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditCustomerScreen(),
      ),
    );

    // Reload customers if a new customer was added
    if (result == true && mounted) {
      context.read<CustomerProvider>().loadCustomers();
    }
  }

  /// Handle delete customer with confirmation
  Future<void> _onDeleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<CustomerProvider>().deleteCustomer(customer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${customer.name} deleted successfully'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete customer: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Handle search query change
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      context.read<CustomerProvider>().loadCustomers();
    } else {
      context.read<CustomerProvider>().searchCustomers(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Customer',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add New Customer button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: ElevatedButton.icon(
              onPressed: _onAddNewCustomer,
              icon: const Icon(Icons.person_add),
              label: const Text('Add New Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          // Customer list
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'Error loading customers',
                          style: const TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        ElevatedButton(
                          onPressed: () => provider.loadCustomers(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          _searchQuery.isEmpty ? 'No customers yet' : 'No customers found',
                          style: const TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          _searchQuery.isEmpty ? 'Add your first customer to get started' : 'Try a different search term',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) {
                    final customer = provider.customers[index];
                    return HighlightedCustomerTile(
                      key: ValueKey(customer.id),
                      customer: customer,
                      searchQuery: _searchQuery,
                      onTap: () => _onCustomerSelected(customer),
                      onDelete: () => _onDeleteCustomer(customer),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
