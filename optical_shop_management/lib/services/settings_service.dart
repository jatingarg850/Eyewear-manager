import 'package:hive/hive.dart';
import '../models/settings.dart';
import 'database_service.dart';

class SettingsService {
  late Box<Settings> _box;
  static const String _settingsKey = 'app_settings';

  SettingsService() {
    _box = DatabaseService.getSettingsBox();
  }

  /// Get the current settings
  /// Returns default settings if none exist
  Future<Settings> getSettings() async {
    try {
      final settings = _box.get(_settingsKey);
      if (settings != null) {
        return settings;
      }

      // Return default settings if none exist
      final defaultSettings = _createDefaultSettings();
      await _box.put(_settingsKey, defaultSettings);
      return defaultSettings;
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  /// Update settings
  Future<void> updateSettings(Settings settings) async {
    try {
      await _box.put(_settingsKey, settings);
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = _createDefaultSettings();
      await _box.put(_settingsKey, defaultSettings);
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  /// Create default settings
  Settings _createDefaultSettings() {
    return Settings(
      companyName: 'Optical Shop',
      phoneNumber: '',
      currency: '₹',
      enableGST: false,
      defaultTax: 0.0,
    );
  }

  /// Check if settings exist
  Future<bool> hasSettings() async {
    try {
      return _box.containsKey(_settingsKey);
    } catch (e) {
      throw Exception('Failed to check settings existence: $e');
    }
  }

  /// Update specific setting fields
  Future<void> updateCompanyName(String companyName) async {
    try {
      final settings = await getSettings();
      settings.companyName = companyName;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update company name: $e');
    }
  }

  Future<void> updateGSTNumber(String? gstNumber) async {
    try {
      final settings = await getSettings();
      settings.gstNumber = gstNumber;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update GST number: $e');
    }
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      final settings = await getSettings();
      settings.phoneNumber = phoneNumber;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update phone number: $e');
    }
  }

  Future<void> updateAddress(String? address) async {
    try {
      final settings = await getSettings();
      settings.address = address;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      final settings = await getSettings();
      settings.currency = currency;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update currency: $e');
    }
  }

  Future<void> updateEnableGST(bool enableGST) async {
    try {
      final settings = await getSettings();
      settings.enableGST = enableGST;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update GST enable: $e');
    }
  }

  Future<void> updateDefaultTax(double defaultTax) async {
    try {
      final settings = await getSettings();
      settings.defaultTax = defaultTax;
      await updateSettings(settings);
    } catch (e) {
      throw Exception('Failed to update default tax: $e');
    }
  }
}
