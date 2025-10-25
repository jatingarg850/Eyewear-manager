import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bill_tile.dart';

/// BillsScreen displays a list of all bills with search and sort functionality
/// Features:
/// - Search bar for filtering by customer name, phone, or date
/// - Sort options (Recent First, Oldest First, Highest Amount)
/// - Bill list using ListView.builder with BillTile widgets
/// - FAB for "Create New Bill"
/// - Integration with BillProvider
/// Requirements: 2.6
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortOption = 'Recent First'; // Default sort option

  @override
  void initState() {
    super.initState();
    // Load bills when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().loadBills();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter bills based on search query
  List<Bill> _filterBills(List<Bill> bills) {
    if (_searchQuery.isEmpty) {
      return bills;
    }

    final query = _searchQuery.toLowerCase();
    return bills.where((bill) {
      final customerName = bill.customerName.toLowerCase();
      final customerPhone = bill.customerPhone.toLowerCase();
      final date = bill.billingDate.toString().toLowerCase();

      return customerName.contains(query) || customerPhone.contains(query) || date.contains(query);
    }).toList();
  }

  /// Sort bills based on selected option
  List<Bill> _sortBills(List<Bill> bills) {
    final sortedBills = List<Bill>.from(bills);

    switch (_sortOption) {
      case 'Recent First':
        sortedBills.sort((a, b) => b.billingDate.compareTo(a.billingDate));
        break;
      case 'Oldest First':
        sortedBills.sort((a, b) => a.billingDate.compareTo(b.billingDate));
        break;
      case 'Highest Amount':
        sortedBills.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
    }

    return sortedBills;
  }

  /// Show sort options dialog
  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Sort By',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Recent First'),
            _buildSortOption('Oldest First'),
            _buildSortOption('Highest Amount'),
          ],
        ),
      ),
    );
  }

  /// Build individual sort option
  Widget _buildSortOption(String option) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: const TextStyle(fontFamily: AppTheme.bodyFont),
      ),
      value: option,
      groupValue: _sortOption,
      onChanged: (value) {
        setState(() {
          _sortOption = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  /// Navigate to bill detail screen
  void _navigateToBillDetail(Bill bill) {
    context.push('/bills/${bill.id}');
  }

  /// Navigate to create bill flow
  void _navigateToCreateBill() {
    context.push('/bills/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Bills',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort bills',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or date...',
                hintStyle: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide(
                    color: AppTheme.textColor.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide(
                    color: AppTheme.textColor.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Bills list
          Expanded(
            child: Consumer<BillProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
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
                          color: AppTheme.errorColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'Error loading bills',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 14,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        ElevatedButton(
                          onPressed: () => provider.loadBills(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredBills = _filterBills(provider.bills);
                final sortedBills = _sortBills(filteredBills);

                if (sortedBills.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: AppTheme.textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        Text(
                          _searchQuery.isEmpty ? 'No bills yet' : 'No bills found',
                          style: TextStyle(
                            fontFamily: AppTheme.headingFont,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          _searchQuery.isEmpty ? 'Create your first bill to get started' : 'Try a different search term',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 14,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: AppTheme.spacing8,
                    bottom: AppTheme.spacing24,
                  ),
                  itemCount: sortedBills.length,
                  itemBuilder: (context, index) {
                    final bill = sortedBills[index];
                    return BillTile(
                      bill: bill,
                      onTap: () => _navigateToBillDetail(bill),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateBill,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Bill',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
