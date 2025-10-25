import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/animated_counter.dart';

/// Dashboard screen displaying key business metrics and statistics
/// Features time-based greeting, animated stat cards, and pull-to-refresh
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final SettingsService _settingsService = SettingsService();
  String _companyName = 'Optical Shop';
  String _currencySymbol = '₹';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadDashboardData();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.getSettings();
      if (mounted) {
        setState(() {
          _companyName = settings.companyName;
          _currencySymbol = settings.currency;
        });
      }
    } catch (e) {
      // Use default values if settings fail to load
    }
  }

  Future<void> _loadDashboardData() async {
    final provider = context.read<DashboardProvider>();
    await provider.loadDashboardData();
  }

  Future<void> _handleRefresh() async {
    await _loadSettings();
    final provider = context.read<DashboardProvider>();
    await provider.refresh();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _navigateToFilteredBills(BuildContext context, String filter) {
    // Navigate to bills screen (filtering can be added later)
    context.go('/bills');
  }

  void _navigateToCustomers(BuildContext context) {
    context.go('/customers');
  }

  void _navigateToSettings(BuildContext context) {
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          _companyName,
          style: const TextStyle(
            fontFamily: AppTheme.headingFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _navigateToSettings(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.totalRevenue == 0) {
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
                    'Failed to load dashboard data',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  ElevatedButton(
                    onPressed: _handleRefresh,
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

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    _buildGreetingSection(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Stats Cards Section
                    _buildStatsSection(provider),
                    const SizedBox(height: AppTheme.spacing24),

                    // Quick Actions or Additional Info
                    _buildQuickActionsSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              _getGreetingIcon(),
              color: AppTheme.accentColor,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Welcome back to $_companyName',
                  style: TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny;
    } else if (hour < 17) {
      return Icons.wb_cloudy;
    } else {
      return Icons.nights_stay;
    }
  }

  Widget _buildStatsSection(DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              StatCard(
                title: 'Total Revenue',
                value: AnimatedCounter(
                  value: provider.totalRevenue,
                  prefix: _currencySymbol,
                  decimalPlaces: 0,
                ),
                icon: Icons.account_balance_wallet,
                color: AppTheme.successColor,
                onTap: () => _navigateToFilteredBills(context, 'all'),
              ),
              const SizedBox(width: AppTheme.spacing12),
              StatCard(
                title: 'Customers Today',
                value: AnimatedCounter(
                  value: provider.customersToday.toDouble(),
                  decimalPlaces: 0,
                ),
                icon: Icons.people,
                color: AppTheme.accentColor,
                onTap: () => _navigateToCustomers(context),
              ),
              const SizedBox(width: AppTheme.spacing12),
              StatCard(
                title: 'Total Sales',
                value: AnimatedCounter(
                  value: provider.totalSales.toDouble(),
                  decimalPlaces: 0,
                ),
                icon: Icons.receipt_long,
                color: AppTheme.primaryColor,
                onTap: () => _navigateToFilteredBills(context, 'all sales'),
              ),
              const SizedBox(width: AppTheme.spacing12),
              StatCard(
                title: 'Monthly Revenue',
                value: AnimatedCounter(
                  value: provider.monthlyRevenue,
                  prefix: _currencySymbol,
                  decimalPlaces: 0,
                ),
                icon: Icons.trending_up,
                color: const Color(0xFF8b5cf6), // Purple
                onTap: () => _navigateToFilteredBills(context, 'monthly'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.person_add,
                title: 'Add Customer',
                color: AppTheme.accentColor,
                onTap: () {
                  // TODO: Navigate to add customer screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigate to add customer'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.receipt,
                title: 'Create Bill',
                color: AppTheme.successColor,
                onTap: () {
                  // TODO: Navigate to create bill screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigate to create bill'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
