# Implementation Plan

- [x] 1. Set up Flutter project structure and dependencies





  - Create new Flutter project with minimum SDK 3.10
  - Add dependencies: hive, hive_flutter, provider, go_router, uuid, intl
  - Add dev dependencies: hive_generator, build_runner
  - Configure project structure: lib/models/, lib/screens/, lib/widgets/, lib/services/, lib/utils/, lib/theme/
  - _Requirements: 9.1, 9.2_

- [x] 2. Implement data models with Hive annotations




  - [x] 2.1 Create Customer model with Hive type adapter


    - Define Customer class with all fields (id, name, phoneNumber, age, prescriptions, address, visit tracking, timestamps)
    - Add Hive annotations (@HiveType, @HiveField)
    - _Requirements: 1.1, 1.2_
  
  - [x] 2.2 Create Bill and LineItem models with Hive type adapters


    - Define Bill class with customer info, line items, pricing, discounts, payment method
    - Define LineItem class with product details, quantity, pricing
    - Add Hive annotations for both models
    - _Requirements: 2.1, 2.3, 2.4_
  
  - [x] 2.3 Create Product model with Hive type adapter


    - Define Product class with name, category, price, description, stock, active status
    - Add Hive annotations
    - _Requirements: 3.1, 3.3_
  
  - [x] 2.4 Create Settings model with Hive type adapter


    - Define Settings class with company info, GST, currency, tax settings
    - Add Hive annotations
    - _Requirements: 5.1, 5.4_
  
  - [x] 2.5 Generate Hive type adapters


    - Run build_runner to generate adapter code
    - Verify generated files compile without errors
    - _Requirements: 9.1_

- [x] 3. Implement database services layer




  - [x] 3.1 Create database initialization service







    - Initialize Hive with Flutter
    - Register all type adapters
    - Open all boxes (customers, bills, products, settings)
    - _Requirements: 9.1, 9.3_
  

  - [x] 3.2 Implement CustomerService with CRUD operations






    - Implement create, read, readAll, update, delete methods
    - Implement search method with name and phone number filtering
    - Implement getRecentCustomers and getCustomersByDateRange methods
    - Implement incrementVisitCount method
    - Add caching for frequently accessed data
    - _Requirements: 1.1, 1.3, 1.5, 9.4, 9.5_
  
  - [x] 3.3 Implement BillService with CRUD and calculation operations






    - Implement create, read, readAll, update, delete methods
    - Implement search method for bills
    - Implement getBillsByDate and getBillsByDateRange methods
    - Implement getTotalRevenue and getBillCount methods
    - Implement calculateBillTotal method with discount logic
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 4.3, 4.4, 9.3_
  
  - [x] 3.4 Implement ProductService with CRUD operations







    - Implement create, read, readAll, update, delete methods
    - Implement search method
    - Implement getProductsByCategory and getActiveProducts methods
    - _Requirements: 3.1, 3.2, 3.4, 3.5_
  
  - [x] 3.5 Implement SettingsService






    - Implement getSettings and updateSettings methods
    - Implement resetToDefaults method
    - _Requirements: 5.1, 5.5_


- [x] 4. Implement validation utilities




- [ ] 4. Implement validation utilities

  - Create Validators class with static validation methods
  - Implement validateName (2-50 chars, letters and spaces only)
  - Implement validatePhone (exactly 10 digits)
  - Implement validateAge (1-120 years)
  - Implement validatePrice (greater than 0)
  - Implement validateGST (15 alphanumeric chars)
  - Implement validateCompanyName (2-100 chars)
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 5.2, 5.3_

- [x] 5. Implement theme configuration





  - Create AppTheme class with color constants (primary, accent, background, text, success, error)
  - Define typography with Poppins for headings and Inter for body text
  - Configure ThemeData with custom colors, card theme, input decoration theme, FAB theme
  - Set up spacing and border radius constants
  - _Requirements: 7.1_

- [x] 6. Implement state management providers




  - [x] 6.1 Create CustomerProvider with ChangeNotifier


    - Implement state properties (customers list, isLoading, error)
    - Implement loadCustomers, addCustomer, updateCustomer, deleteCustomer methods
    - Implement searchCustomers with debouncing
    - Add cache invalidation on mutations
    - _Requirements: 1.1, 1.3, 1.5, 7.4, 9.5_
  
  - [x] 6.2 Create BillProvider with ChangeNotifier


    - Implement state properties (bills list, currentBill, isLoading)
    - Implement loadBills, createBill, deleteBill methods
    - Implement startNewBill, addLineItem, removeLineItem, updateQuantity methods
    - Implement applySpecialDiscount, applyAdditionalDiscount methods
    - Implement calculateTotal method with real-time updates
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_
  
  - [x] 6.3 Create ProductProvider with ChangeNotifier


    - Implement state properties (products list, selectedCategory)
    - Implement loadProducts, addProduct, updateProduct methods
    - Implement toggleProductActive method for soft delete
    - Implement setCategory and filteredProducts methods
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [x] 6.4 Create DashboardProvider with ChangeNotifier


    - Implement state properties (totalRevenue, customersToday, totalSales, monthlyRevenue)
    - Implement loadDashboardData method to calculate all metrics
    - Implement refresh method
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 7. Implement reusable UI widgets





  - [x] 7.1 Create StatCard widget


    - Display title, animated value, icon, and color
    - Implement tap handler for navigation
    - Add glassmorphism effect with gradient background
    - _Requirements: 4.1, 4.5, 7.1_
  
  - [x] 7.2 Create CustomerTile widget


    - Display circular avatar with initials, name, phone, last visit, total visits badge
    - Implement tap and delete handlers
    - Add color-coded avatar based on name hash
    - _Requirements: 1.1, 10.5_
  
  - [x] 7.3 Create BillTile widget


    - Display customer name, bill date, amount, payment method badge, item count
    - Add color-coded border based on payment method
    - Implement tap handler
    - _Requirements: 2.6_
  
  - [x] 7.4 Create ProductCard widget


    - Display product name, category badge, price
    - Add edit, toggle active, and add to cart buttons
    - Implement category color-coding
    - _Requirements: 3.4, 3.5_
  
  - [x] 7.5 Create CustomTextField widget


    - Implement themed text field with label, hint, validation
    - Add error display below field
    - Support different keyboard types and max lines
    - _Requirements: 8.1_
  
  - [x] 7.6 Create AnimatedCounter widget


    - Animate number counting from 0 to target value
    - Support prefix and suffix (currency symbols)
    - Use smooth easing curve
    - _Requirements: 4.2, 7.1_



- [x] 8. Implement animation utilities





  - [x] 8.1 Create SlidePageRoute for page transitions


    - Implement custom PageRouteBuilder with slide and fade animations
    - Set duration to 300ms with easeInOutCubic curve
    - _Requirements: 7.1, 7.2_
  
  - [x] 8.2 Create StaggeredListView widget


    - Implement staggered fade and slide animations for list items
    - Use 200ms delay between consecutive items
    - _Requirements: 7.5_
  
  - [x] 8.3 Create TapScaleButton widget


    - Implement scale-down animation on tap (0.95 scale)
    - Use 100ms duration
    - _Requirements: 7.1_
  
  - [x] 8.4 Create shake animation for validation errors


    - Implement shake effect with 5 oscillations in 400ms
    - Apply to form fields with validation errors
    - _Requirements: 8.5_
-

- [x] 9. Implement Dashboard screen




  - Create DashboardScreen with app bar showing company name and settings icon
  - Add greeting section with time-based message (Good Morning/Afternoon/Evening)
  - Implement stats cards row with horizontal scroll (total revenue, customers today, total sales, monthly revenue)
  - Add AnimatedCounter widgets to stats cards
  - Implement tap handlers on stats cards for filtered navigation
  - Add pull-to-refresh functionality
  - Integrate with DashboardProvider for data
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 7.1, 7.2, 7.5_

- [x] 10. Implement Customers screen



  - [x] 10.1 Create CustomersScreen with list view


    - Add search bar with real-time filtering (300ms debounce)
    - Add filter chips (All, Recent, This Month, Custom Date Range)
    - Implement customer list using ListView.builder with CustomerTile widgets
    - Add FAB for "Add Customer"
    - Integrate with CustomerProvider
    - _Requirements: 1.1, 1.3, 7.4, 7.5_
  
  - [x] 10.2 Create AddEditCustomerScreen form


    - Implement form with CustomTextField widgets for name, phone, age, prescriptions, address
    - Add validation using Validators class
    - Implement auto-save of first visit timestamp on creation
    - Add save and cancel buttons with loading states
    - Show success/error messages using SnackBar
    - _Requirements: 1.1, 1.2, 8.1, 8.2, 8.3, 8.5_
  
  - [x] 10.3 Implement customer search and filtering


    - Add search functionality matching name OR phone number
    - Implement date range picker for custom filtering
    - Add empty state illustration when no customers found
    - Highlight matching text in search results
    - _Requirements: 1.3, 1.4_
- [x] 11. Implement Bills screen



- [ ] 11. Implement Bills screen

  - [x] 11.1 Create BillsScreen with list view


    - Add search bar for filtering by customer name, phone, or date
    - Add sort options (Recent First, Oldest First, Highest Amount)
    - Implement bill list using ListView.builder with BillTile widgets
    - Add FAB for "Create New Bill"
    - Integrate with BillProvider
    - _Requirements: 2.6_
  
  - [x] 11.2 Create BillDetailScreen modal


    - Display customer info section
    - Show line items table with product, quantity, price
    - Display pricing breakdown (subtotal, discounts, total)
    - Show payment method badge
    - Add timestamp display
    - Implement share and delete buttons
    - Add confirmation dialog for delete action
    - _Requirements: 2.5, 2.6_



- [x] 12. Implement Create Bill flow





  - [x] 12.1 Create CustomerSelectionScreen (Step 1)


    - Display existing customer list with name, phone, total visits, last visit date
    - Add search bar for filtering customers
    - Add "Add New Customer" button at top
    - Implement delete button next to each customer with confirmation dialog
    - Handle customer selection to navigate to product selection
    - Integrate with CustomerProvider and BillProvider
    - _Requirements: 2.1, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8_
  
  - [x] 12.2 Create ProductSelectionScreen (Step 2)


    - Add category tabs (Service, Frame, Lens)
    - Display product list filtered by selected category
    - Implement add (+) button with quantity stepper for each product
    - Add "Create New Product" quick action button
    - Show cart summary at bottom with item count and subtotal
    - Add "Next" button to proceed to billing details
    - Integrate with ProductProvider and BillProvider
    - _Requirements: 2.1, 2.2, 3.4_
  
  - [x] 12.3 Create BillingDetailsScreen (Step 3)


    - Display cart summary with editable quantities
    - Show subtotal calculation
    - Implement special discount input with percentage/fixed toggle
    - Implement additional discount input with percentage/fixed toggle
    - Add live calculation display for discount amounts
    - Implement payment method selector (Cash, Card, UPI) with radio buttons
    - Display total amount prominently
    - Add "Complete Bill" button
    - Integrate with BillProvider for real-time calculations
    - _Requirements: 2.2, 2.3, 2.4, 2.5_
  
  - [x] 12.4 Implement bill completion flow


    - Save bill to database with all details
    - Increment customer visit count and update last visit timestamp
    - Show success animation (checkmark with confetti effect)
    - Navigate back to bills list
    - Display new bill at top of list
    - _Requirements: 2.5, 1.5_
-

- [x] 13. Implement Products screen




  - [x] 13.1 Create ProductsScreen with grid/list view


    - Add category tabs (All, Service, Frame, Lens)
    - Add search bar for filtering products
    - Display products using ProductCard widgets
    - Add FAB for "Add Product"
    - Integrate with ProductProvider
    - _Requirements: 3.4, 3.5_
  
  - [x] 13.2 Create AddEditProductScreen form


    - Implement form with fields for name, category dropdown, price, description, stock count
    - Add validation using Validators class
    - Implement save and cancel buttons
    - Show success/error messages
    - _Requirements: 3.1, 3.2, 8.4_
  
  - [x] 13.3 Implement product management features


    - Add active/inactive toggle for soft delete
    - Implement confirmation dialog for delete action
    - Add category color-coding throughout UI
    - _Requirements: 3.3_

- [x] 14. Implement Settings screen





  - [x] 14.1 Create SettingsScreen with sections


    - Create Shop Information section with editable fields (company name, GST number, phone, address)
    - Create App Configuration section with currency dropdown, GST toggle, default tax rate input
    - Add save button at bottom
    - Integrate with SettingsService
    - _Requirements: 5.1, 5.4, 5.5_
  
  - [x] 14.2 Implement data management features


    - Add "Backup Data" button to export all data to JSON file
    - Add "Restore Data" button to import from JSON file
    - Add "Clear All Data" button with password confirmation dialog
    - Implement file picker for restore functionality
    - Add validation for JSON file structure on import
    - _Requirements: 6.1, 6.2, 6.3, 6.5_
  
  - [x] 14.3 Add About section

    - Display app version
    - Add developer credits
    - Add placeholder for terms and privacy links
    - _Requirements: 5.1_



- [x] 15. Implement navigation and routing





  - Set up GoRouter with all routes (dashboard, customers, bills, products, settings)
  - Create MainScaffold with bottom navigation bar (5 tabs with icons)
  - Implement nested routes for add/edit screens
  - Configure page transitions using SlidePageRoute
  - Add badge to Bills tab showing today's bill count
  - _Requirements: 7.1, 7.2_

- [x] 16. Implement error handling and user feedback




  - Create ErrorHandler utility class with showError and showSuccess methods
  - Wrap all database operations in try-catch blocks
  - Display user-friendly error messages via SnackBar
  - Implement empty state widgets with illustrations for all list screens
  - Add loading indicators for async operations
  - _Requirements: 8.1, 8.5_
-

- [x] 17. Implement search debouncing and performance optimizations




  - Create SearchDebouncer utility class with 300ms delay
  - Implement caching in all service classes for frequently accessed data
  - Add cache invalidation on data mutations
  - Use ListView.builder for all lists
  - Add const constructors where possible
  - Implement AutomaticKeepAliveClientMixin for Dashboard screen
  - _Requirements: 7.3, 7.4, 9.4, 9.5_


- [x] 18. Implement bill calculation with optimization




  - Create BillCalculator utility class with calculateTotal method
  - Implement discount calculation logic (special then additional)
  - Add clamping to prevent negative totals
  - Implement memoization for repeated calculations
  - Integrate with BillProvider for real-time updates
  - _Requirements: 2.3, 2.4, 9.3_
-

- [x] 19. Set up app initialization and main entry point



  - Create AppInitializer class to initialize Hive and open all boxes
  - Register all Hive type adapters
  - Set up MultiProvider with all providers (Customer, Bill, Product, Dashboard)
  - Configure MaterialApp with theme and router
  - Add splash screen with app logo
  - _Requirements: 9.1, 9.2, 7.3_

- [-] 20. Polish UI with eyewear theme elements


  - Apply color palette throughout app (navy blue, amber, cream, charcoal, teal)
  - Add rounded corners (16px+) to all cards and containers
  - Implement glassmorphism effects on stat cards
  - Add custom eyewear-themed icons where appropriate
  - Apply Poppins font to headings and Inter to body text
  - Ensure all touch targets are minimum 48x48 dp
  - _Requirements: 7.1_

- [ ] 21. Write unit tests for core functionality

  - [ ] 21.1 Write tests for Validators class
    - Test all validation methods with valid and invalid inputs
    - Test edge cases and boundary values
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [ ] 21.2 Write tests for BillCalculator
    - Test discount calculations (percentage and fixed)
    - Test discount order (special then additional)
    - Test negative total prevention
    - _Requirements: 2.3, 2.4_
  
  - [ ] 21.3 Write tests for service classes
    - Mock Hive boxes for isolated testing
    - Test CRUD operations for CustomerService, BillService, ProductService
    - Test search and filter methods
    - _Requirements: 1.3, 2.6, 3.5_

- [ ] 22. Write widget tests for UI components

  - [ ] 22.1 Test reusable widgets
    - Test StatCard displays correct data and handles taps
    - Test CustomerTile displays customer information correctly
    - Test BillTile displays bill information correctly
    - Test ProductCard displays product information correctly
    - _Requirements: 4.1, 1.1, 2.6, 3.4_
  
  - [ ] 22.2 Test form validation
    - Test CustomTextField shows validation errors
    - Test AddEditCustomerScreen validates inputs
    - Test AddEditProductScreen validates inputs
    - _Requirements: 8.1, 8.5_

- [ ] 23. Write integration tests for user flows

  - [ ] 23.1 Test complete bill creation flow
    - Test customer selection step
    - Test product selection step
    - Test billing details and completion
    - Verify bill is saved and customer visit count incremented
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 1.5_
  
  - [ ] 23.2 Test customer management flow
    - Test adding new customer
    - Test editing existing customer
    - Test deleting customer
    - Test search and filtering
    - _Requirements: 1.1, 1.2, 1.3_

- [ ] 24. Final testing and optimization

  - Test app with large datasets (1000+ customers, 10000+ bills)
  - Verify all performance targets are met (< 2s startup, < 100ms searches, 60 FPS scrolling)
  - Test on multiple device sizes and orientations
  - Verify all animations are smooth
  - Test backup and restore functionality
  - Perform accessibility audit
  - _Requirements: 7.3, 9.3, 9.4, 6.4_
