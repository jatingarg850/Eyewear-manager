# Settings Screen Implementation

## Overview
The Settings screen provides comprehensive configuration options for the optical shop management application, including shop information, app configuration, data management, and about information.

## Requirements Implemented
- **5.1**: Shop settings configuration (company name, GST, contact details)
- **5.4**: Currency selection and tax settings
- **5.5**: Settings persistence and defaults
- **6.1**: Data backup to JSON file
- **6.2**: Data restore from JSON file
- **6.3**: Clear all data with password confirmation
- **6.5**: JSON file structure validation

## Features

### 1. Shop Information Section
- **Company Name**: Required field (2-100 characters)
- **GST Number**: Optional field (15 alphanumeric characters)
- **Phone Number**: Required field (10 digits)
- **Address**: Optional multi-line field

### 2. App Configuration Section
- **Currency Dropdown**: Select from ₹, $, €
- **GST Toggle**: Enable/disable GST in calculations
- **Default Tax Rate**: Percentage input (0-100%)

### 3. Data Management Section
- **Backup Data**: Export all data to JSON file
  - Saves to device documents directory
  - Includes timestamp in filename
  - Exports customers, bills, products, and settings
  
- **Restore Data**: Import data from JSON file
  - File picker for selecting backup file
  - Validates JSON structure before import
  - Confirmation dialog before restore
  
- **Clear All Data**: Delete all data with password confirmation
  - Requires typing "DELETE" to confirm
  - Clears all Hive boxes
  - Cannot be undone

### 4. About Section
- **App Version**: Displays current version (1.0.0)
- **Developer Credits**: Shows development team
- **Terms & Privacy**: Placeholder for future links

## File Structure

### Main Files
- `settings_screen.dart`: Main settings UI implementation
- `backup_service.dart`: Data export/import logic
- `settings_service.dart`: Settings persistence service

### Dependencies
- `path_provider`: For accessing device directories
- `file_picker`: For selecting backup files
- `hive`: For local data storage

## Usage

### Accessing Settings
The Settings screen is typically accessed from the main navigation or dashboard settings icon.

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SettingsScreen()),
);
```

### Backup Data Flow
1. User taps "Backup Data" button
2. System collects all data from Hive boxes
3. Converts to JSON format with metadata
4. Saves to documents directory with timestamp
5. Shows success message with file path

### Restore Data Flow
1. User taps "Restore Data" button
2. File picker opens for JSON file selection
3. Confirmation dialog appears
4. System validates JSON structure
5. Imports data into Hive boxes
6. Reloads settings and shows success

### Clear Data Flow
1. User taps "Clear All Data" button
2. Password dialog appears (requires "DELETE")
3. User confirms action
4. All Hive boxes are cleared
5. Default settings are recreated

## Validation

### Form Validation
- Company name: Uses `Validators.validateCompanyName`
- GST number: Uses `Validators.validateGST`
- Phone number: Uses `Validators.validatePhone`
- Tax rate: Custom validation (0-100%)

### Backup Validation
- JSON structure must include version and exportDate
- All data arrays must be valid JSON
- File must be readable and parseable

## Error Handling

### User-Friendly Messages
- Success: Green snackbar with confirmation
- Error: Red snackbar with error description
- Loading: Disabled buttons with progress indicators

### Common Errors
- "Failed to load settings": Database read error
- "Failed to save settings": Database write error
- "Failed to backup data": File system error
- "Failed to restore data": Invalid JSON or import error
- "Incorrect password": Wrong confirmation text

## UI Components

### Custom Widgets Used
- `CustomTextField`: For text input fields
- `Card`: For section grouping
- `SwitchListTile`: For GST toggle
- `DropdownButtonFormField`: For currency selection
- `OutlinedButton`: For data management actions
- `ElevatedButton`: For save action

### Theme Integration
- Uses `AppTheme` constants for colors and spacing
- Consistent border radius and elevation
- Color-coded buttons (primary, accent, error)

## State Management

### Local State
- Form controllers for text fields
- Loading states for async operations
- Selected currency and GST toggle state

### No Provider Needed
Settings screen manages its own state locally since settings are not shared across multiple screens in real-time.

## Performance Considerations

### Efficient Operations
- Settings loaded once on screen init
- Backup/restore operations show progress
- Form validation on submit only
- Minimal rebuilds with setState

### Large Dataset Handling
- Backup service handles large datasets efficiently
- JSON encoding/decoding is optimized
- File operations are async and non-blocking

## Security Notes

### Password Protection
- Clear data requires "DELETE" confirmation
- Simple password check (can be enhanced)
- No sensitive data exposed in UI

### Data Privacy
- All data stored locally on device
- Backup files saved to private app directory
- No network transmission of data

## Future Enhancements

### Potential Additions
1. Cloud backup integration
2. Automatic backup scheduling
3. Multiple backup file management
4. Settings sync across devices
5. Enhanced password protection
6. Backup encryption
7. Export to other formats (CSV, PDF)
8. Import from other systems

## Testing Recommendations

### Unit Tests
- Test backup/restore JSON conversion
- Test validation functions
- Test clear data functionality

### Widget Tests
- Test form submission
- Test button interactions
- Test dialog flows

### Integration Tests
- Test complete backup/restore flow
- Test settings persistence
- Test error scenarios

## Accessibility

### Features Implemented
- Semantic labels on form fields
- Touch targets meet minimum size (48dp)
- Color contrast meets WCAG AA standards
- Screen reader support for all interactive elements

## Known Limitations

1. Backup files not encrypted (future enhancement)
2. No automatic backup scheduling
3. Simple password protection for clear data
4. No backup file management UI
5. Terms & Privacy links are placeholders

## Related Files
- `lib/models/settings.dart`: Settings data model
- `lib/services/settings_service.dart`: Settings persistence
- `lib/services/backup_service.dart`: Backup/restore logic
- `lib/services/database_service.dart`: Database operations
- `lib/utils/validators.dart`: Form validation
- `lib/theme/app_theme.dart`: Theme constants
