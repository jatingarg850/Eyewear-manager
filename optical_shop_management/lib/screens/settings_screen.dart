import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';

/// Settings screen for managing shop information and app configuration
/// Requirements: 5.1, 5.4, 5.5
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settingsService = SettingsService();
  final _backupService = BackupService();

  // Controllers for form fields
  late TextEditingController _companyNameController;
  late TextEditingController _gstNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _defaultTaxController;

  // State variables
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String _selectedCurrency = '₹';
  bool _enableGST = false;

  // Currency options
  final List<String> _currencies = [
    '₹',
    '\$',
    '€'
  ];

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _gstNumberController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _defaultTaxController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _gstNumberController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _defaultTaxController.dispose();
    super.dispose();
  }

  /// Load current settings from database
  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);

      final settings = await _settingsService.getSettings();

      setState(() {
        _companyNameController.text = settings.companyName;
        _gstNumberController.text = settings.gstNumber ?? '';
        _phoneController.text = settings.phoneNumber;
        _addressController.text = settings.address ?? '';
        _selectedCurrency = settings.currency;
        _enableGST = settings.enableGST;
        _defaultTaxController.text = settings.defaultTax.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Failed to load settings: $e');
      }
    }
  }

  /// Save settings to database
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => _isSaving = true);

      final settings = Settings(
        companyName: _companyNameController.text.trim(),
        gstNumber: _gstNumberController.text.trim().isEmpty ? null : _gstNumberController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        currency: _selectedCurrency,
        enableGST: _enableGST,
        defaultTax: double.tryParse(_defaultTaxController.text) ?? 0.0,
      );

      await _settingsService.updateSettings(settings);

      setState(() => _isSaving = false);

      if (mounted) {
        _showSuccessSnackBar('Settings saved successfully');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showErrorSnackBar('Failed to save settings: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Backup data to JSON file
  /// Requirement: 6.1
  Future<void> _backupData() async {
    try {
      setState(() => _isBackingUp = true);

      final filePath = await _backupService.exportData();

      setState(() => _isBackingUp = false);

      if (mounted) {
        _showSuccessSnackBar('Backup saved to: $filePath');
      }
    } catch (e) {
      setState(() => _isBackingUp = false);
      if (mounted) {
        _showErrorSnackBar('Failed to backup data: $e');
      }
    }
  }

  /// Restore data from JSON file
  /// Requirement: 6.2
  Future<void> _restoreData() async {
    try {
      // Pick file
      final filePath = await _backupService.pickBackupFile();
      if (filePath == null) {
        return; // User cancelled
      }

      // Confirm restore
      final confirmed = await _showConfirmDialog(
        title: 'Restore Data',
        message: 'This will import data from the backup file. Continue?',
      );

      if (!confirmed) return;

      setState(() => _isRestoring = true);

      await _backupService.importData(filePath);

      setState(() => _isRestoring = false);

      if (mounted) {
        _showSuccessSnackBar('Data restored successfully');
        // Reload settings
        _loadSettings();
      }
    } catch (e) {
      setState(() => _isRestoring = false);
      if (mounted) {
        _showErrorSnackBar('Failed to restore data: $e');
      }
    }
  }

  /// Clear all data with password confirmation
  /// Requirement: 6.3
  Future<void> _clearAllData() async {
    // Show password confirmation dialog
    final password = await _showPasswordDialog();
    if (password == null) return;

    // Simple password check (in production, use proper authentication)
    if (password != 'DELETE') {
      _showErrorSnackBar('Incorrect password. Type DELETE to confirm.');
      return;
    }

    try {
      // Clear all boxes
      await DatabaseService.clearAllData();

      if (mounted) {
        _showSuccessSnackBar('All data cleared successfully');
        // Reload settings (will create defaults)
        _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to clear data: $e');
      }
    }
  }

  /// Show confirmation dialog
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show password dialog for clear data
  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear All Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone!',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Type DELETE to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                children: [
                  _buildShopInformationSection(),
                  const SizedBox(height: AppTheme.spacing24),
                  _buildAppConfigurationSection(),
                  const SizedBox(height: AppTheme.spacing32),
                  _buildSaveButton(),
                  const SizedBox(height: AppTheme.spacing24),
                  _buildDataManagementSection(),
                  const SizedBox(height: AppTheme.spacing24),
                  _buildAboutSection(),
                  const SizedBox(height: AppTheme.spacing16),
                ],
              ),
            ),
    );
  }

  /// Build shop information section
  Widget _buildShopInformationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            CustomTextField(
              label: 'Company Name',
              hint: 'Enter your shop name',
              controller: _companyNameController,
              validator: Validators.validateCompanyName,
            ),
            const SizedBox(height: AppTheme.spacing12),
            CustomTextField(
              label: 'GST Number',
              hint: 'Enter 15-digit GST number (optional)',
              controller: _gstNumberController,
              validator: Validators.validateGST,
            ),
            const SizedBox(height: AppTheme.spacing12),
            CustomTextField(
              label: 'Phone Number',
              hint: 'Enter 10-digit phone number',
              controller: _phoneController,
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppTheme.spacing12),
            CustomTextField(
              label: 'Address',
              hint: 'Enter shop address (optional)',
              controller: _addressController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Build app configuration section
  Widget _buildAppConfigurationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Currency dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // GST toggle
            SwitchListTile(
              title: const Text('Enable GST'),
              subtitle: const Text('Include GST in calculations'),
              value: _enableGST,
              onChanged: (value) {
                setState(() => _enableGST = value);
              },
              activeTrackColor: AppTheme.accentColor.withOpacity(0.5),
              activeThumbColor: AppTheme.accentColor,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Default tax rate
            CustomTextField(
              label: 'Default Tax Rate (%)',
              hint: 'Enter default tax percentage',
              controller: _defaultTaxController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tax rate is required';
                }
                final tax = double.tryParse(value);
                if (tax == null || tax < 0 || tax > 100) {
                  return 'Tax rate must be between 0 and 100';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Build data management section
  /// Requirements: 6.1, 6.2, 6.3
  Widget _buildDataManagementSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Backup button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isBackingUp ? null : _backupData,
                icon: _isBackingUp
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup),
                label: const Text('Backup Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Restore button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isRestoring ? null : _restoreData,
                icon: _isRestoring
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restore),
                label: const Text('Restore Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Clear all data button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearAllData,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear All Data'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppTheme.errorColor),
                  foregroundColor: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build about section
  /// Requirement: 5.1
  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // App version
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),

            // Developer credits
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.code, color: AppTheme.primaryColor),
              title: const Text('Developer'),
              subtitle: const Text('Optical Shop Management Team'),
            ),

            // Terms and privacy (placeholder)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description, color: AppTheme.primaryColor),
              title: const Text('Terms & Privacy'),
              subtitle: const Text('View terms and privacy policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Placeholder for terms and privacy
                _showErrorSnackBar('Terms and privacy policy coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }
}
