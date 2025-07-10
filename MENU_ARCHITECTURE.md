# Create New Menu - Modular Architecture Documentation

## Overview

The Create New Menu functionality has been completely redesigned and modularized according to the Figma design specifications. The new implementation follows a page-based architecture with reusable components and proper state management.

## Architecture

### 1. Components (Reusable UI Elements)

Located in: `lib/features/menu_management/presentation/components/`

#### `date_selector_component.dart`

- **Purpose**: Date and day selector with calendar icon
- **Features**:
  - Interactive date picker
  - Shows formatted date (dd/MM/yyyy) and day name (e.g., Wednesday)
  - Consistent styling with app theme
- **Props**: `selectedDate`, `onDateChanged`

#### `add_item_button_component.dart`

- **Purpose**: Orange "Add Item" button
- **Features**:
  - Plus icon with label
  - Enabled/disabled states
  - Consistent button styling
- **Props**: `onPressed`, `isEnabled`

#### `end_time_selector_component.dart`

- **Purpose**: End time selector (default 10:00 AM)
- **Features**:
  - Time picker integration
  - Dropdown-style UI
  - Matches vote page design
- **Props**: `selectedTime`, `onTimeChanged`

### 2. Data Models

Located in: `lib/features/menu_management/data/models/`

#### `menu_item.dart`

- **Purpose**: Data model for menu items
- **Properties**: `id`, `name`, `subItem`, `createdAt`
- **Methods**: `toMap()`, `fromMap()`, `toString()`
- **Features**: Firebase serialization, proper equality comparison

### 3. Pages (Full Screen Views)

Located in: `lib/features/menu_management/presentation/screens/`

#### `create_menu_screen.dart`

- **Purpose**: Main menu creation page
- **Features**:
  - Date selector at top
  - Add Item button
  - Selected items display
  - End time selector
  - Create Menu / Cancel actions
  - Form validation and error handling
  - Firebase integration

#### `select_item_page.dart`

- **Purpose**: Multi-select item selection
- **Features**:
  - Load previously saved items from Firebase
  - Multi-select with checkboxes
  - Delete items functionality
  - "Add New Item" button
  - Save selected items
  - Empty state handling

#### `add_new_item_page.dart`

- **Purpose**: Create new menu items
- **Features**:
  - Item name input field
  - Optional sub-item field
  - Form validation
  - Firebase save functionality
  - Loading states and error handling

## Integration Points

### Entry Points

1. **Votes Page**: Top-right "+" button (Admin/Planner only)
2. **Menus Page**: Floating Action Button (Admin/Planner only)

### Navigation Flow

```text
Entry Point → Create New Menu Page
                ↓ (Add Item button)
            Select Item Page
                ↓ (Add New Item button)
            Add New Item Page
                ↓ (Save)
            ← Back to Select Item Page
                ↓ (Save selection)
            ← Back to Create New Menu Page
                ↓ (Create Menu)
            ← Back to previous page
```

## Firebase Integration

### Collections Used

1. **`menu_items`**: Stores reusable menu items
   - `name`: Item name
   - `subItem`: Optional sub-item description
   - `createdAt`: Creation timestamp

2. **`polls`**: Stores created menus (existing collection)
   - Extended with `selectedItems` field for item references
   - Maintains backward compatibility

### Data Flow

1. Load existing items from `menu_items` collection
2. Allow user to select items and/or create new ones
3. Save new items to `menu_items` collection
4. Create poll with selected items in `polls` collection

## Key Features

### 1. Modular Design

- Each component is self-contained and reusable
- Clear separation of concerns
- Easy to maintain and extend

### 2. State Management

- Local state for UI interactions
- Firebase for data persistence
- Proper loading and error states

### 3. User Experience

- Intuitive navigation flow
- Consistent design language
- Proper feedback and validation
- Role-based access control

### 4. Error Handling

- Network error handling
- Form validation
- User-friendly error messages
- Graceful degradation

## Design System Compliance

### Colors

- Primary: `AppColors.primaryColor` (Red)
- Secondary: `AppColors.fYellow` (Yellow)
- Success: `AppColors.saveGreen`
- Background: `AppColors.fWhiteBackground`

### Typography

- Uses `ScreenUtil` for responsive sizing
- Consistent font weights and sizes
- Proper hierarchy and contrast

### Components

- Rounded corners (12.r standard)
- Consistent padding and margins
- Proper shadows and elevations
- Material Design principles

## Future Enhancements

1. **Search and Filter**: Add search functionality in select item page
2. **Categories**: Group items by categories (appetizers, mains, etc.)
3. **Templates**: Save and reuse menu templates
4. **Bulk Operations**: Select multiple items for deletion
5. **Analytics**: Track popular items and usage patterns

## Testing

### Manual Testing Checklist

- [ ] Date selector works correctly
- [ ] Add Item button navigation
- [ ] Item selection and deselection
- [ ] New item creation and validation
- [ ] End time selection
- [ ] Menu creation with validation
- [ ] Cancel operations
- [ ] Role-based access control
- [ ] Error handling scenarios
- [ ] Firebase data persistence

### Known Limitations

- Requires internet connection for Firebase operations
- Admin/Planner role required for access
- No offline support currently

## Backward Compatibility

The new implementation maintains backward compatibility with existing polls in the database. Old menus will continue to work, while new menus will have enhanced item tracking capabilities.
