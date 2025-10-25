/// Validators class provides static validation methods for form inputs
/// throughout the application.
class Validators {
  /// Validates customer name
  /// Requirements: 2-50 characters, letters and spaces only
  /// Requirement: 8.2
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2 || value.length > 50) {
      return 'Name must be between 2 and 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates phone number
  /// Requirements: exactly 10 digits
  /// Requirement: 8.1, 1.4
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  /// Validates customer age
  /// Requirements: 1-120 years
  /// Requirement: 8.3
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 120) {
      return 'Age must be between 1 and 120';
    }
    return null;
  }

  /// Validates product price
  /// Requirements: greater than 0
  /// Requirement: 8.4, 3.2
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  /// Validates GST number
  /// Requirements: exactly 15 alphanumeric characters
  /// Requirement: 5.2, 5.3
  static String? validateGST(String? value) {
    // GST is optional, so null or empty is valid
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[a-zA-Z0-9]{15}$').hasMatch(value)) {
      return 'GST number must be exactly 15 alphanumeric characters';
    }
    return null;
  }

  /// Validates company name
  /// Requirements: 2-100 characters
  /// Requirement: 5.2
  static String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company name is required';
    }
    if (value.length < 2 || value.length > 100) {
      return 'Company name must be between 2 and 100 characters';
    }
    return null;
  }
}
