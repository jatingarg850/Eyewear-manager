import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_text_field.dart';

/// AddEditCustomerScreen provides a form to add or edit customer information
/// Features:
/// - Form with CustomTextField widgets for name, phone, age, prescriptions, address
/// - Validation using Validators class
/// - Auto-save of first visit timestamp on creation
/// - Save and cancel buttons with loading states
/// - Success/error messages using SnackBar
/// Requirements: 1.1, 1.2, 8.1, 8.2, 8.3, 8.5
class AddEditCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _prescriptionLeftController = TextEditingController();
  final _prescriptionRightController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.customer != null;

    // Populate fields if editing
    if (_isEditMode) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phoneNumber;
      _ageController.text = widget.customer!.age.toString();
      _prescriptionLeftController.text = widget.customer!.prescriptionLeft ?? '';
      _prescriptionRightController.text = widget.customer!.prescriptionRight ?? '';
      _addressController.text = widget.customer!.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _prescriptionLeftController.dispose();
    _prescriptionRightController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Save customer data
  Future<void> _saveCustomer() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final customer = Customer(
        id: _isEditMode ? widget.customer!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        prescriptionLeft: _prescriptionLeftController.text.trim().isEmpty ? null : _prescriptionLeftController.text.trim(),
        prescriptionRight: _prescriptionRightController.text.trim().isEmpty ? null : _prescriptionRightController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        firstVisit: _isEditMode ? widget.customer!.firstVisit : now,
        lastVisit: _isEditMode ? widget.customer!.lastVisit : now,
        totalVisits: _isEditMode ? widget.customer!.totalVisits : 1,
        createdAt: _isEditMode ? widget.customer!.createdAt : now,
        updatedAt: now,
      );

      final provider = context.read<CustomerProvider>();

      if (_isEditMode) {
        await provider.updateCustomer(customer.id, customer);
      } else {
        await provider.addCustomer(customer);
      }

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          _isEditMode ? 'Customer updated successfully' : 'Customer added successfully',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Customer' : 'Add Customer',
          style: const TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            // Name field
            CustomTextField(
              label: 'Name *',
              hint: 'Enter customer name',
              controller: _nameController,
              validator: Validators.validateName,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Phone field
            CustomTextField(
              label: 'Phone Number *',
              hint: 'Enter 10-digit phone number',
              controller: _phoneController,
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Age field
            CustomTextField(
              label: 'Age *',
              hint: 'Enter age',
              controller: _ageController,
              validator: Validators.validateAge,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.cake_outlined),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Prescription section header
            const Text(
              'Prescription Details (Optional)',
              style: TextStyle(
                fontFamily: AppTheme.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Prescription Left Eye
            CustomTextField(
              label: 'Left Eye',
              hint: 'e.g., -2.50, +1.75',
              controller: _prescriptionLeftController,
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(Icons.visibility_outlined),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Prescription Right Eye
            CustomTextField(
              label: 'Right Eye',
              hint: 'e.g., -2.50, +1.75',
              controller: _prescriptionRightController,
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(Icons.visibility_outlined),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Address section header
            const Text(
              'Additional Information (Optional)',
              style: TextStyle(
                fontFamily: AppTheme.headingFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Address field
            CustomTextField(
              label: 'Address',
              hint: 'Enter customer address',
              controller: _addressController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing16,
                      ),
                      side: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),

                // Save button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      disabledBackgroundColor: AppTheme.textColor.withValues(alpha: 0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Update' : 'Save',
                            style: const TextStyle(
                              fontFamily: AppTheme.headingFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Required fields note
            Text(
              '* Required fields',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
