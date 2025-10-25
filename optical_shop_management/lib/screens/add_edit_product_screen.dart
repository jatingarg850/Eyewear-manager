import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';
import '../theme/app_theme.dart';

/// AddEditProductScreen provides a form for creating or editing products
/// Features:
/// - Form fields for name, category, price, description, stock
/// - Validation using Validators class
/// - Save and cancel buttons
/// - Success/error messages
/// Requirements: 3.1, 3.2, 8.4
class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedCategory = 'Service';
  final List<String> _categories = [
    'Service',
    'Frame',
    'Lens'
  ];
  bool _isLoading = false;
  bool _isEditMode = false;
  Product? _existingProduct;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    if (_isEditMode) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ProductProvider>();
      _existingProduct = provider.allProducts.firstWhere(
        (p) => p.id == widget.productId,
      );

      if (_existingProduct != null) {
        _nameController.text = _existingProduct!.name;
        _priceController.text = _existingProduct!.price.toString();
        _descriptionController.text = _existingProduct!.description ?? '';
        _stockController.text = _existingProduct!.stock.toString();
        _selectedCategory = _existingProduct!.category;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load product: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String? _validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 2 || value.length > 100) {
      return 'Product name must be between 2 and 100 characters';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock count is required';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Stock must be a non-negative number';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final product = Product(
        id: _isEditMode ? widget.productId! : const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        isActive: _isEditMode ? _existingProduct!.isActive : true,
        createdAt: _isEditMode ? _existingProduct!.createdAt : now,
        updatedAt: now,
      );

      final provider = context.read<ProductProvider>();

      if (_isEditMode) {
        await provider.updateProduct(widget.productId!, product);
      } else {
        await provider.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Product updated successfully' : 'Product added successfully',
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Product?',
          style: TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this product? This action cannot be undone.',
          style: TextStyle(
            fontFamily: AppTheme.bodyFont,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                color: AppTheme.textColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ProductProvider>();
      await provider.deleteProduct(widget.productId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
          _isEditMode ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            fontFamily: AppTheme.headingFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isLoading ? null : _handleDelete,
                  tooltip: 'Delete Product',
                ),
              ]
            : null,
      ),
      body: _isLoading && _isEditMode
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product name field
                    CustomTextField(
                      label: 'Product Name',
                      hint: 'Enter product name',
                      controller: _nameController,
                      validator: _validateProductName,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    // Category dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                        vertical: AppTheme.spacing4,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 20,
                                  color: _getCategoryColor(category),
                                ),
                                const SizedBox(width: AppTheme.spacing8),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.bodyFont,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    // Price field
                    CustomTextField(
                      label: 'Price',
                      hint: 'Enter price',
                      controller: _priceController,
                      validator: Validators.validatePrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    // Stock field
                    CustomTextField(
                      label: 'Stock Count',
                      hint: 'Enter stock count',
                      controller: _stockController,
                      validator: _validateStock,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    // Description field
                    CustomTextField(
                      label: 'Description (Optional)',
                      hint: 'Enter product description',
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppTheme.spacing32),
                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textColor,
                              side: BorderSide(
                                color: Colors.grey[400]!,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacing16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: AppTheme.bodyFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        // Save button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacing16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isEditMode ? 'Update' : 'Save',
                                    style: const TextStyle(
                                      fontFamily: AppTheme.bodyFont,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Get color based on product category
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'service':
        return const Color(0xFF3b82f6); // Blue
      case 'frame':
        return const Color(0xFFf59e0b); // Amber
      case 'lens':
        return const Color(0xFF10b981); // Green
      default:
        return AppTheme.textColor;
    }
  }

  /// Get icon based on product category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'service':
        return Icons.medical_services;
      case 'frame':
        return Icons.visibility;
      case 'lens':
        return Icons.lens;
      default:
        return Icons.inventory_2;
    }
  }
}
