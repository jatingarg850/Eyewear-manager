# Error Handling and User Feedback Guide

This guide explains how to use the error handling utilities and user feedback widgets in the Optical Shop Management application.

## ErrorHandler Utility

The `ErrorHandler` class provides static methods for displaying user-friendly messages and confirmation dialogs.

### Usage Examples

#### 1. Show Error Messages

```dart
import '../utils/error_handler.dart';

// In your async operation
try {
  await someOperation();
} catch (e) {
  if (mounted) {
    ErrorHandler.showError(context, e);
  }
}
```

The `showError` method automatically:
- Extracts meaningful messages from exceptions
- Displays a red snackbar with an error icon
- Shows for 4 seconds
- Uses floating behavior with rounded corners

#### 2. Show Success Messages

```dart
import '../utils/error_handler.dart';

// After successful operation
if (mounted) {
  ErrorHandler.showSuccess(context, 'Customer added successfully');
}
```

Success messages:
- Display in teal green color
- Show a checkmark icon
- Appear for 3 seconds

#### 3. Show Info Messages

```dart
ErrorHandler.showInfo(context, 'Syncing data...');
```

#### 4. Show Warning Messages

```dart
ErrorHandler.showWarning(context, 'Low stock alert');
```

#### 5. Confirmation Dialogs

```dart
final confirmed = await ErrorHandler.showConfirmDialog(
  context,
  title: 'Delete Customer',
  message: 'Are you sure you want to delete this customer? This action cannot be undone.',
  confirmText: 'Delete',
  cancelText: 'Cancel',
  isDangerous: true, // Makes confirm button red
);

if (confirmed) {
  // Proceed with deletion
}
```

## Empty State Widgets

Use empty state widgets to provide helpful feedback when lists are empty.

### EmptyCustomersState

```dart
import '../widgets/empty_state.dart';

if (customers.isEmpty) {
  return EmptyCustomersState(
    onAddCustomer: () => navigateToAddCustomer(),
  );
}
```

### EmptyBillsState

```dart
if (bills.isEmpty) {
  return EmptyBillsState(
    onCreateBill: () => navigateToCreateBill(),
  );
}
```

### EmptyProductsState

```dart
if (products.isEmpty) {
  return EmptyProductsState(
    onAddProduct: () => navigateToAddProduct(),
  );
}
```

### EmptySearchState

```dart
if (searchResults.isEmpty && searchQuery.isNotEmpty) {
  return EmptySearchState(
    searchQuery: searchQuery,
  );
}
```

### EmptyFilterState

```dart
if (filteredResults.isEmpty) {
  return EmptyFilterState(
    filterName: 'Recent',
    onClearFilter: () => clearFilter(),
  );
}
```

### Custom Empty State

```dart
EmptyState(
  icon: Icons.shopping_cart_outlined,
  title: 'Cart is Empty',
  message: 'Add some products to your cart to continue.',
  actionLabel: 'Browse Products',
  onAction: () => navigateToProducts(),
)
```

## Loading Indicators

### Full Screen Loading

```dart
import '../widgets/loading_indicator.dart';

if (isLoading) {
  return const LoadingIndicator(
    message: 'Loading customers...',
  );
}
```

### Small Inline Loading

```dart
if (isProcessing) {
  return const SmallLoadingIndicator();
}
```

### Loading Overlay

Useful for showing loading state over existing content:

```dart
LoadingOverlay(
  isLoading: isProcessing,
  message: 'Saving...',
  child: YourContentWidget(),
)
```

### Loading Button

Button that shows loading state:

```dart
LoadingButton(
  isLoading: isSaving,
  onPressed: () => saveData(),
  label: 'Save',
  icon: Icons.save,
  backgroundColor: AppTheme.primaryColor,
)
```

## Complete Screen Example

Here's a complete example showing all error handling patterns:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await context.read<CustomerProvider>().loadCustomers();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _deleteItem(String id) async {
    if (!mounted) return;
    
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      title: 'Delete Item',
      message: 'Are you sure?',
      isDangerous: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await context.read<CustomerProvider>().deleteCustomer(id);
      if (mounted) {
        ErrorHandler.showSuccess(context, 'Item deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          // Show loading state
          if (provider.isLoading) {
            return const LoadingIndicator(
              message: 'Loading data...',
            );
          }

          // Show error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  const Text('Error loading data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (provider.customers.isEmpty) {
            return EmptyCustomersState(
              onAddCustomer: () => navigateToAdd(),
            );
          }

          // Show data
          return ListView.builder(
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
              return ListTile(
                title: Text(customer.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(customer.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Best Practices

1. **Always check `mounted` before showing messages after async operations**
   ```dart
   if (mounted) {
     ErrorHandler.showSuccess(context, 'Done!');
   }
   ```

2. **Use appropriate message types**
   - Error: For failures and exceptions
   - Success: For completed operations
   - Warning: For cautionary information
   - Info: For neutral information

3. **Provide context in empty states**
   - Use specific empty state widgets for different scenarios
   - Include action buttons when appropriate
   - Make messages helpful and actionable

4. **Show loading indicators for async operations**
   - Use full-screen loading for initial data loads
   - Use loading buttons for form submissions
   - Use loading overlays for background operations

5. **Make error messages user-friendly**
   - The ErrorHandler automatically converts technical errors to user-friendly messages
   - For custom errors, throw exceptions with clear messages

6. **Use confirmation dialogs for destructive actions**
   - Always confirm before deleting data
   - Set `isDangerous: true` for destructive actions
   - Provide clear context in the message

## Requirements Coverage

This implementation satisfies the following requirements:

- **Requirement 8.1**: Form validation with clear error messages
- **Requirement 8.5**: Shake animation for validation errors (integrated with form fields)
- **Requirement 7.4**: Debounced search with loading indicators
- **Requirement 9.3**: Fast database operations with error handling
