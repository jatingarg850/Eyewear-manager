# Create Bill Flow Implementation

This document describes the Create Bill flow implementation consisting of 4 screens.

## Overview

The Create Bill flow is a multi-step process that guides users through:
1. **Customer Selection** - Select or add a customer
2. **Product Selection** - Add products to cart with quantities
3. **Billing Details** - Apply discounts and select payment method
4. **Bill Completion** - Save bill and show success animation

## Screens

### 1. CustomerSelectionScreen
**File:** `customer_selection_screen.dart`

**Features:**
- Displays list of existing customers with search functionality
- "Add New Customer" button at the top
- Delete button next to each customer with confirmation dialog
- Shows customer name, phone, total visits, and last visit date
- Integrates with CustomerProvider and BillProvider

**Navigation:**
- Entry point: Navigate to this screen to start bill creation
- On customer selection: Navigates to ProductSelectionScreen
- On "Add New Customer": Opens AddEditCustomerScreen

### 2. ProductSelectionScreen
**File:** `product_selection_screen.dart`

**Features:**
- Category tabs (Service, Frame, Lens) for filtering products
- Product list showing active products only
- Add (+) button and quantity stepper for each product
- Cart summary at bottom showing item count and subtotal
- "Next" button to proceed (enabled only when cart has items)

**Navigation:**
- Previous: CustomerSelectionScreen
- Next: BillingDetailsScreen

### 3. BillingDetailsScreen
**File:** `billing_details_screen.dart`

**Features:**
- Cart summary with editable quantities and delete buttons
- Special discount input with percentage/fixed toggle
- Additional discount input with percentage/fixed toggle
- Live calculation display for discount amounts
- Payment method selector (Cash, Card, UPI) with radio buttons
- Total amount prominently displayed
- "Complete Bill" button

**Navigation:**
- Previous: ProductSelectionScreen
- Next: BillCompletionScreen

### 4. BillCompletionScreen
**File:** `bill_completion_screen.dart`

**Features:**
- Saves bill to database
- Increments customer visit count and updates last visit timestamp
- Shows success animation with checkmark and confetti effect
- Automatically navigates back to bills list after 2.5 seconds
- Error handling with retry option

**Navigation:**
- Previous: BillingDetailsScreen
- On success: Automatically returns to bills list
- Back button disabled during processing

## Integration Guide

### Step 1: Add Routes

Add the following routes to your router configuration (e.g., using GoRouter or named routes):

```dart
// Example with named routes in MaterialApp
routes: {
  '/create-bill': (context) => const CustomerSelectionScreen(),
  '/create-bill/products': (context) => const ProductSelectionScreen(),
  '/create-bill/billing-details': (context) => const BillingDetailsScreen(),
  '/create-bill/complete': (context) => const BillCompletionScreen(),
}
```

### Step 2: Start the Flow

From your bills screen or dashboard, navigate to the customer selection screen:

```dart
Navigator.pushNamed(context, '/create-bill');
```

### Step 3: Ensure Providers are Available

Make sure the following providers are available in your widget tree:
- `CustomerProvider` - For customer data
- `BillProvider` - For bill state management
- `ProductProvider` - For product data

Example with MultiProvider:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CustomerProvider(CustomerService())),
    ChangeNotifierProvider(create: (_) => BillProvider(BillService())),
    ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
  ],
  child: MaterialApp(...),
)
```

## Data Flow

1. **CustomerSelectionScreen**: User selects a customer
   - Calls `BillProvider.startNewBill(customer)` to initialize a new bill
   
2. **ProductSelectionScreen**: User adds products to cart
   - Calls `BillProvider.addLineItem(product, quantity)` for each product
   - Updates quantities with `BillProvider.updateQuantity(index, quantity)`
   
3. **BillingDetailsScreen**: User applies discounts and selects payment
   - Calls `BillProvider.applySpecialDiscount(amount, type)`
   - Calls `BillProvider.applyAdditionalDiscount(amount, type)`
   - Calls `BillProvider.setPaymentMethod(method)`
   
4. **BillCompletionScreen**: System saves the bill
   - Calls `BillProvider.createBill(currentBill)` to save to database
   - Calls `CustomerService.incrementVisitCount(customerId)` to update customer
   - Shows success animation and navigates back

## State Management

The `BillProvider` maintains a `currentBill` object throughout the flow:

```dart
class BillProvider extends ChangeNotifier {
  Bill? _currentBill;
  
  void startNewBill(Customer customer) { ... }
  void addLineItem(Product product, int quantity) { ... }
  void updateQuantity(int index, int quantity) { ... }
  void applySpecialDiscount(double amount, String type) { ... }
  void applyAdditionalDiscount(double amount, String type) { ... }
  void setPaymentMethod(String method) { ... }
  Future<void> createBill(Bill bill) { ... }
  void clearCurrentBill() { ... }
}
```

## Requirements Satisfied

This implementation satisfies the following requirements from the spec:

- **Requirement 2.1**: Customer selection before product addition
- **Requirement 2.2**: Multiple products with quantity
- **Requirement 2.3**: Special discount then additional discount
- **Requirement 2.4**: Prevent negative totals
- **Requirement 2.5**: Save bill with all details
- **Requirement 2.6**: Search bills by customer
- **Requirement 1.5**: Increment customer visit count
- **Requirements 10.1-10.8**: Customer selection with search, add, and delete

## Testing

To test the complete flow:

1. Ensure you have at least one customer in the database
2. Ensure you have active products in each category
3. Navigate to `/create-bill`
4. Select a customer
5. Add products from different categories
6. Apply discounts (optional)
7. Select payment method
8. Complete the bill
9. Verify the bill appears in the bills list
10. Verify the customer's visit count increased

## Notes

- The flow uses named routes for navigation between screens
- Back navigation is handled automatically by Flutter's Navigator
- The BillCompletionScreen prevents back navigation during processing
- All screens use the app's theme (AppTheme) for consistent styling
- Error handling is implemented at each step with user-friendly messages
