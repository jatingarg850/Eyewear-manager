# Requirements Document

## Introduction

This document specifies the requirements for a fully serverless, offline-first Flutter application designed for optical eyewear shop management. The system enables shop owners to manage customers, products, bills, and shop settings with a warm, humanized UI featuring eyewear-themed design elements. All data is stored locally using Hive or Sqflite, requiring no internet connectivity for core operations.

## Glossary

- **System**: The Flutter Optical Shop Management Application
- **Shop Owner**: The primary user who manages the optical shop
- **Customer Record**: A data entity containing customer information including name, phone, age, prescriptions, and visit history
- **Bill**: A transaction record containing line items, pricing, discounts, and payment information
- **Product**: An inventory item categorized as service, frame, or lens with associated pricing
- **Line Item**: An individual product entry within a bill containing quantity and pricing details
- **Local Storage**: Device-based data persistence using Hive or Sqflite database
- **Dashboard**: The home screen displaying key business metrics and statistics
- **Special Discount**: The first discount applied to bill subtotal (percentage or fixed amount)
- **Additional Discount**: The second discount applied after special discount (percentage or fixed amount)
- **Soft Delete**: Marking records as inactive without permanent deletion

## Requirements

### Requirement 1: Customer Management

**User Story:** As a Shop Owner, I want to manage customer records with their contact information and prescription details, so that I can maintain a comprehensive customer database and track their visit history.

#### Acceptance Criteria

1. THE System SHALL store customer records with name, phone number (10 digits), age, optional prescription values for left and right eyes, and optional address
2. WHEN a Shop Owner creates a new customer record, THE System SHALL automatically save the first visit timestamp and initialize the visit counter to one
3. WHEN a Shop Owner searches for customers, THE System SHALL return results matching the search query against name OR phone number within 100 milliseconds for up to 1000 customer records
4. THE System SHALL validate that phone numbers contain exactly 10 numeric digits before saving customer records
5. WHEN a customer is selected during bill creation, THE System SHALL automatically increment their total visit count and update the last visit timestamp

### Requirement 2: Bill Creation and Management

**User Story:** As a Shop Owner, I want to create bills with multiple products and apply discounts, so that I can accurately charge customers and maintain transaction records.

#### Acceptance Criteria

1. THE System SHALL require selection of an existing customer before allowing product addition to a bill
2. WHEN a Shop Owner adds products to a bill, THE System SHALL calculate the subtotal by summing all line item total prices
3. THE System SHALL apply special discount first (percentage or fixed amount), then apply additional discount to the discounted amount
4. THE System SHALL prevent the final bill total from becoming negative by clamping the minimum value to zero
5. WHEN a Shop Owner completes a bill, THE System SHALL save the bill record with customer information, line items, pricing breakdown, payment method, and billing timestamp within 100 milliseconds
6. THE System SHALL allow Shop Owner to search bills by customer name OR phone number OR date

### Requirement 3: Product Inventory Management

**User Story:** As a Shop Owner, I want to manage products categorized as services, frames, or lenses with pricing information, so that I can quickly add items to bills and maintain inventory records.

#### Acceptance Criteria

1. THE System SHALL store products with name, category (service, frame, or lens), price, optional description, stock count, and active status
2. THE System SHALL validate that product prices are greater than zero before saving
3. WHEN a Shop Owner marks a product as inactive, THE System SHALL retain the product record but exclude it from active product listings
4. THE System SHALL allow Shop Owner to filter products by category tabs (All, Service, Frame, Lens)
5. THE System SHALL display products in a searchable list with real-time filtering as the Shop Owner types

### Requirement 4: Dashboard Analytics

**User Story:** As a Shop Owner, I want to view key business metrics on the dashboard, so that I can quickly understand daily and monthly performance.

#### Acceptance Criteria

1. THE System SHALL display total revenue, customers today count, total sales count, and monthly revenue on the dashboard
2. WHEN the dashboard loads, THE System SHALL animate the statistics counters from zero to their actual values within 1 second
3. THE System SHALL calculate today's metrics by filtering bills where billing date matches the current date
4. THE System SHALL calculate monthly revenue by summing all bill totals where billing date falls within the current calendar month
5. WHEN a Shop Owner taps a statistics card, THE System SHALL navigate to the relevant filtered view (e.g., revenue card shows filtered bill list)

### Requirement 5: Shop Settings Configuration

**User Story:** As a Shop Owner, I want to configure shop information including company name, GST number, and contact details, so that I can personalize the application for my business.

#### Acceptance Criteria

1. THE System SHALL store shop settings including company name, optional GST number, phone number, optional address, currency symbol, GST enable toggle, and default tax percentage
2. THE System SHALL validate that company name contains between 2 and 100 characters before saving
3. WHEN GST is enabled, THE System SHALL validate that GST number contains exactly 15 alphanumeric characters if provided
4. THE System SHALL allow Shop Owner to select currency symbol from a predefined list (₹, $, €)
5. THE System SHALL persist all settings changes to local storage immediately upon save action

### Requirement 6: Data Backup and Restore

**User Story:** As a Shop Owner, I want to backup and restore my data, so that I can protect against data loss and migrate to new devices.

#### Acceptance Criteria

1. WHEN a Shop Owner initiates data backup, THE System SHALL export all customers, bills, products, and settings to a JSON file saved to device storage
2. WHEN a Shop Owner initiates data restore, THE System SHALL import data from a selected JSON file and merge it with existing records
3. WHEN a Shop Owner initiates clear all data, THE System SHALL require password confirmation before permanently deleting all records
4. THE System SHALL complete backup export operations within 5 seconds for databases containing up to 10,000 records
5. THE System SHALL validate JSON file structure before importing to prevent data corruption

### Requirement 7: User Interface Responsiveness

**User Story:** As a Shop Owner, I want smooth animations and fast screen transitions, so that the application feels responsive and pleasant to use.

#### Acceptance Criteria

1. THE System SHALL complete screen transitions within 300 milliseconds using slide and fade animations
2. THE System SHALL maintain 60 frames per second during list scrolling for lists containing up to 1000 items
3. WHEN the application launches, THE System SHALL display the dashboard within 2 seconds
4. THE System SHALL debounce search input by 300 milliseconds to optimize performance during typing
5. THE System SHALL use staggered fade-in animations for list items with 200 milliseconds delay between consecutive items

### Requirement 8: Form Validation

**User Story:** As a Shop Owner, I want clear validation feedback on forms, so that I can correct errors before saving data.

#### Acceptance Criteria

1. WHEN a Shop Owner enters invalid data in a form field, THE System SHALL display a specific error message below the field within 100 milliseconds
2. THE System SHALL validate customer names contain between 2 and 50 characters with only letters and spaces
3. THE System SHALL validate customer age is between 1 and 120 years
4. THE System SHALL validate product names contain between 2 and 100 characters
5. WHEN a Shop Owner attempts to save a form with validation errors, THE System SHALL prevent submission and animate invalid fields with a shake effect lasting 400 milliseconds

### Requirement 9: Offline-First Architecture

**User Story:** As a Shop Owner, I want the application to work completely offline, so that I can manage my shop without depending on internet connectivity.

#### Acceptance Criteria

1. THE System SHALL store all data locally using Hive or Sqflite database on the device
2. THE System SHALL perform all create, read, update, and delete operations without requiring internet connectivity
3. THE System SHALL complete database write operations within 100 milliseconds for individual records
4. THE System SHALL use indexed queries on name and phone number fields to optimize search performance
5. THE System SHALL cache frequently accessed data (customer list, product list) in memory to reduce database queries

### Requirement 10: Customer Selection and Deletion in Bill Flow

**User Story:** As a Shop Owner, I want to select existing customers or add new ones during bill creation, and optionally delete customers from the selection screen, so that I can manage customer records efficiently within the billing workflow.

#### Acceptance Criteria

1. WHEN a Shop Owner initiates bill creation, THE System SHALL display a customer selection screen showing all existing customers with name, phone number, total visits count, and last visit date
2. THE System SHALL provide a search bar on the customer selection screen that filters customers in real-time as the Shop Owner types
3. THE System SHALL display an "Add New Customer" button at the top of the customer selection screen
4. WHEN a Shop Owner taps "Add New Customer", THE System SHALL navigate to the customer creation form and return to the customer selection screen after successful creation
5. THE System SHALL display a delete button next to each customer in the selection list
6. WHEN a Shop Owner taps the delete button, THE System SHALL display a confirmation dialog stating "Are you sure? This action cannot be undone."
7. WHEN a Shop Owner confirms customer deletion, THE System SHALL permanently remove the customer record from the database and refresh the customer list
8. WHEN a Shop Owner selects a customer from the list, THE System SHALL navigate to the product selection step of the bill creation flow
