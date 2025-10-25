import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/customer.dart';
import '../models/bill.dart';
import '../models/line_item.dart';
import '../models/product.dart';
import '../models/settings.dart';
import 'customer_service.dart';
import 'bill_service.dart';
import 'product_service.dart';
import 'settings_service.dart';

/// Service for handling data backup and restore operations
/// Requirements: 6.1, 6.2, 6.3, 6.5
class BackupService {
  final CustomerService _customerService = CustomerService();
  final BillService _billService = BillService();
  final ProductService _productService = ProductService();
  final SettingsService _settingsService = SettingsService();

  /// Export all data to JSON file
  /// Requirement: 6.1
  Future<String> exportData() async {
    try {
      // Collect all data
      final customers = await _customerService.readAll();
      final bills = await _billService.readAll();
      final products = await _productService.readAll();
      final settings = await _settingsService.getSettings();

      // Convert to JSON-serializable format
      final data = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'customers': customers.map((c) => _customerToJson(c)).toList(),
        'bills': bills.map((b) => _billToJson(b)).toList(),
        'products': products.map((p) => _productToJson(p)).toList(),
        'settings': _settingsToJson(settings),
      };

      // Convert to JSON string
      final jsonString = jsonEncode(data);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'optical_shop_backup_$timestamp.json';
      final file = File('${directory.path}/$filename');

      // Write to file
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Import data from JSON file
  /// Requirement: 6.2, 6.5
  Future<void> importData(String filePath) async {
    try {
      // Read file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate JSON structure
      _validateBackupStructure(data);

      // Import customers
      if (data['customers'] != null) {
        final customers = (data['customers'] as List).map((c) => _customerFromJson(c)).toList();
        for (final customer in customers) {
          await _customerService.create(customer);
        }
      }

      // Import products
      if (data['products'] != null) {
        final products = (data['products'] as List).map((p) => _productFromJson(p)).toList();
        for (final product in products) {
          await _productService.create(product);
        }
      }

      // Import bills
      if (data['bills'] != null) {
        final bills = (data['bills'] as List).map((b) => _billFromJson(b)).toList();
        for (final bill in bills) {
          await _billService.create(bill);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = _settingsFromJson(data['settings']);
        await _settingsService.updateSettings(settings);
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Pick a file for restore
  Future<String?> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'json'
        ],
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Validate backup JSON structure
  /// Requirement: 6.5
  void _validateBackupStructure(Map<String, dynamic> data) {
    if (!data.containsKey('version')) {
      throw Exception('Invalid backup file: missing version');
    }
    if (!data.containsKey('exportDate')) {
      throw Exception('Invalid backup file: missing export date');
    }
    // Additional validation can be added here
  }

  /// Convert Customer to JSON
  Map<String, dynamic> _customerToJson(Customer customer) {
    return {
      'id': customer.id,
      'name': customer.name,
      'phoneNumber': customer.phoneNumber,
      'age': customer.age,
      'prescriptionLeft': customer.prescriptionLeft,
      'prescriptionRight': customer.prescriptionRight,
      'address': customer.address,
      'firstVisit': customer.firstVisit.toIso8601String(),
      'lastVisit': customer.lastVisit.toIso8601String(),
      'totalVisits': customer.totalVisits,
      'createdAt': customer.createdAt.toIso8601String(),
      'updatedAt': customer.updatedAt.toIso8601String(),
    };
  }

  /// Convert JSON to Customer
  Customer _customerFromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      age: json['age'],
      prescriptionLeft: json['prescriptionLeft'],
      prescriptionRight: json['prescriptionRight'],
      address: json['address'],
      firstVisit: DateTime.parse(json['firstVisit']),
      lastVisit: DateTime.parse(json['lastVisit']),
      totalVisits: json['totalVisits'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert Bill to JSON
  Map<String, dynamic> _billToJson(Bill bill) {
    return {
      'id': bill.id,
      'customerId': bill.customerId,
      'customerName': bill.customerName,
      'customerPhone': bill.customerPhone,
      'items': bill.items
          .map((item) => {
                'productId': item.productId,
                'productName': item.productName,
                'category': item.category,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'totalPrice': item.totalPrice,
              })
          .toList(),
      'subtotal': bill.subtotal,
      'specialDiscount': bill.specialDiscount,
      'discountType': bill.discountType,
      'additionalDiscount': bill.additionalDiscount,
      'additionalDiscountType': bill.additionalDiscountType,
      'totalAmount': bill.totalAmount,
      'paymentMethod': bill.paymentMethod,
      'billingDate': bill.billingDate.toIso8601String(),
      'createdAt': bill.createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to Bill
  Bill _billFromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List)
          .map((item) => LineItem(
                productId: item['productId'],
                productName: item['productName'],
                category: item['category'],
                quantity: item['quantity'],
                unitPrice: item['unitPrice'],
                totalPrice: item['totalPrice'],
              ))
          .toList(),
      subtotal: json['subtotal'],
      specialDiscount: json['specialDiscount'],
      discountType: json['discountType'],
      additionalDiscount: json['additionalDiscount'],
      additionalDiscountType: json['additionalDiscountType'],
      totalAmount: json['totalAmount'],
      paymentMethod: json['paymentMethod'],
      billingDate: DateTime.parse(json['billingDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'description': product.description,
      'stock': product.stock,
      'isActive': product.isActive,
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt.toIso8601String(),
    };
  }

  /// Convert JSON to Product
  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      description: json['description'],
      stock: json['stock'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert Settings to JSON
  Map<String, dynamic> _settingsToJson(Settings settings) {
    return {
      'companyName': settings.companyName,
      'gstNumber': settings.gstNumber,
      'phoneNumber': settings.phoneNumber,
      'address': settings.address,
      'currency': settings.currency,
      'enableGST': settings.enableGST,
      'defaultTax': settings.defaultTax,
    };
  }

  /// Convert JSON to Settings
  Settings _settingsFromJson(Map<String, dynamic> json) {
    return Settings(
      companyName: json['companyName'],
      gstNumber: json['gstNumber'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      currency: json['currency'],
      enableGST: json['enableGST'],
      defaultTax: json['defaultTax'],
    );
  }
}
