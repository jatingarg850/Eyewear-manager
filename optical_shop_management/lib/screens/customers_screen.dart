import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/highlighted_customer_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import '../utils/error_handler.dart';

/// CustomersScreen displays a list of all customers with search and filter capabilities
/// Features:
/// - Search bar with real-time filtering (300ms debounce)
/// - Filter chips (All, Recent, This Month, Custom Date Range)
/// - Customer list using ListView.builder with CustomerTile widgets
/// - FAB for "Add Customer"
/// Requirements: 1.1, 1.3, 7.4, 7.5
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

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

  /// Handle search input with debouncing
  void _onSearchChanged(String query) {
    final provider = context.read<CustomerProvider>();
    if (query.isEmpty) {
      _applyFilter(_selectedFilter);
    } else {
      provider.searchCustomers(query);
    }
  }

  /// Apply filter based on selected chip
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _searchController.clear();
    });

    final provider = context.read<CustomerProvider>();

    switch (filter) {
      case 'All':
        provider.loadCustomers();
        break;
      case 'Recent':
        provider.loadRecentCustomers(7); // Last 7 days
        break;
      case 'This Month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        provider.loadCustomersByDateRange(startOfMonth, endOfMonth);
        break;
      case 'Custom Date Range':
        _showDateRangePicker();
        break;
    }
  }

  /// Show date range picker for custom filtering
  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      context.read<CustomerProvider>().loadCustomersByDateRange(
            picked.start,
            picked.end,
          );
    } else {
      // If cancelled, revert to 'All' filter
      setState(() {
        _selectedFilter = 'All';
      });
      context.read<CustomerProvider>().loadCustomers();
    }
  }

  /// Navigate to add customer screen
  void _navigateToAddCustomer() {
    context.push('/customers/add').then((_) {
      // Reload customers after returning
      _applyFilter(_selectedFilter);
    });
  }

  /// Navigate to edit customer screen
  void _navigateToEditCustomer(Customer customer) {
    context.push('/customers/${customer.id}/edit').then((_) {
      // Reload customers after returning
      _applyFilter(_selectedFilter);
    });
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(Customer customer) async {
    if (!mounted) return;

    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      title: 'Delete Customer',
      message: 'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      try {
        await context.read<CustomerProvider>().deleteCustomer(customer.id);
        if (mounted) {
          ErrorHandler.showSuccess(context, '${customer.name} deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  color: AppTheme.textColor.withValues(alpha: 0.4),
                ),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: AppTheme.spacing8),
                  _buildFilterChip('Recent'),
                  const SizedBox(width: AppTheme.spacing8),
                  _buildFilterChip('This Month'),
                  const SizedBox(width: AppTheme.spacing8),
                  _buildFilterChip('Custom Date Range'),
                ],
              ),
            ),
          ),

          // Customer list
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator(
                    message: 'Loading customers...',
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'Error loading customers',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        ElevatedButton.icon(
                          onPressed: () => _applyFilter(_selectedFilter),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.customers.isEmpty) {
                  // Show appropriate empty state based on context
                  if (_searchController.text.isNotEmpty) {
                    return EmptySearchState(
                      searchQuery: _searchController.text,
                    );
                  } else if (_selectedFilter != 'All') {
                    return EmptyFilterState(
                      filterName: _selectedFilter,
                      onClearFilter: () => _applyFilter('All'),
                    );
                  } else {
                    return EmptyCustomersState(
                      onAddCustomer: _navigateToAddCustomer,
                    );
                  }
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    _applyFilter(_selectedFilter);
                  },
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: AppTheme.spacing8,
                      bottom: AppTheme.spacing16,
                    ),
                    itemCount: provider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = provider.customers[index];
                      return HighlightedCustomerTile(
                        key: ValueKey(customer.id),
                        customer: customer,
                        searchQuery: _searchController.text,
                        onTap: () => _navigateToEditCustomer(customer),
                        onDelete: () => _showDeleteConfirmation(customer),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddCustomer,
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Customer',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build filter chip widget
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _applyFilter(label);
        }
      },
      labelStyle: TextStyle(
        fontFamily: AppTheme.bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textColor,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.2),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
    );
  }
}
