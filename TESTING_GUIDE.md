# Testing Guide for New Create Menu Flow

## Prerequisites

- App running on emulator or device
- User logged in with Admin or Planner role
- Internet connection for Firebase operations

## Test Scenarios

### 1. Access Create New Menu

**From Votes Page:**

1. Navigate to Votes tab
2. Look for red "+" button in top-right corner
3. Tap the button
4. Should navigate to Create New Menu page

**From Menus Page:**

1. Navigate to Menus tab  
2. Look for floating action button (red circle with "+" icon)
3. Tap the floating action button
4. Should navigate to Create New Menu page

### 2. Create New Menu Flow

**Main Page Components:**

1. **Date Selector**:
   - Should show current date by default
   - Tap to open date picker
   - Select future date (up to 30 days)
   - Should update display with selected date and day name

2. **Add Item Button**:
   - Orange button with "Add Item" text and plus icon
   - Tap to navigate to Select Item page

3. **End Time Selector**:
   - Should show "10:00 AM" by default
   - Tap to open time picker
   - Select different time
   - Should update display

### 3. Select Items Flow

**Initial State:**

- If no items exist: Shows empty state with message
- If items exist: Shows list of all previously saved items

**Item Selection:**

- Tap any item to select/deselect
- Selected items show checkmark and blue border
- Can select multiple items

**Add New Item:**

1. Tap "Add New Item" button (red outlined)
2. Should navigate to Add New Item page

### 4. Add New Item Flow

**Form Fields:**

1. **Item Name**: Required field with food icon
2. **Sub Item**: Optional field for additional details

**Actions:**

1. **Cancel**: Returns to Select Item page without saving
2. **Save**: Validates form and saves to Firebase
   - Shows loading spinner during save
   - Returns to Select Item page with new item selected

**Validation:**

- Item name is required
- Shows error if name is empty

### 5. Complete Menu Creation

**Back on Create New Menu Page:**

1. Selected items should be listed below Add Item button
2. Shows count: "Selected Items (X)"
3. Each item shows as a small card with bullet point

**Create Menu:**

1. Tap "Create Menu" button (red button)
2. Should validate that at least one item is selected
3. Shows loading spinner during creation
4. On success: Returns to previous page with success message
5. On error: Shows error message

**Cancel:**

- Tap "Cancel" button
- Returns to previous page without creating menu

### 6. Data Persistence Testing

**Menu Items:**

1. Create a new item with name and sub-item
2. Navigate away and come back
3. New item should appear in the Select Item list

**Created Menus:**

1. Create a complete menu
2. Check Menus page - new menu should appear
3. Check menu details - should show selected items
4. Voting should work normally

### 7. Role-Based Access

**Admin/Planner Users:**

- Should see "+" button on Votes page
- Should see floating action button on Menus page
- Can access all Create Menu functionality

**Diner Users:**

- Should NOT see "+" button on Votes page  
- Should NOT see floating action button on Menus page
- Cannot access Create Menu functionality

### 8. Error Scenarios

**Network Issues:**

1. Disconnect internet
2. Try to load items - should show error message
3. Try to save item - should show error message
4. Reconnect internet - functionality should restore

**Invalid Data:**

1. Try to create menu with no items - should show validation error
2. Try to save item with empty name - should show validation error

**Firebase Errors:**

- Check console for any Firebase-related errors
- All operations should handle errors gracefully

### 9. Custom Dialog System Testing

**Error Dialogs:**

1. Try logging in with invalid credentials
2. Verify custom error dialog appears (not toast)
3. Check dialog styling matches app design
4. Test "OK" button functionality

**Warning Dialogs:**

1. Try registering without agreeing to terms
2. Verify custom warning dialog appears
3. Check orange/warning color scheme
4. Test dialog dismissal

**Success Dialogs:**

1. Successfully register a new user
2. Verify custom success dialog appears
3. Check green/success color scheme
4. Test "OK" button functionality

**Delete Confirmation Dialogs:**

1. Try to delete a reminder
2. Verify custom delete dialog appears
3. Test "Cancel" and "Delete" buttons
4. Confirm destructive action styling

### 10. Reminder System Testing

**Add Reminder:**

1. Navigate to Settings → Reminders
2. Tap "Add Reminder" button
3. Test time picker functionality
4. Test repeat option selection
5. Save reminder and verify it appears in list

**Notification Testing:**

1. Set a reminder for 1-2 minutes in the future
2. Wait for notification to appear
3. Test notification tap behavior
4. Verify notification permissions are properly requested

**Reminder Management:**

1. Test enable/disable toggle functionality
2. Test reminder deletion with confirmation dialog
3. Verify changes persist after app restart

## Expected UI/UX

- All pages should match Figma design specifications
- Smooth navigation transitions
- Consistent color scheme (red primary, yellow secondary)
- Proper loading states and feedback
- Responsive design with proper spacing
- Icons and text should be clearly visible

## Performance Expectations

- Page transitions should be smooth (< 300ms)
- Firebase operations should have loading indicators
- Lists should scroll smoothly even with many items
- No memory leaks or performance issues

## Browser Testing (Web)

If testing on web:

- All functionality should work the same
- Date/time pickers should use web-appropriate UI
- Touch interactions should work with mouse clicks
- Responsive design should adapt to different screen sizes

## Common Issues & Solutions

1. **Empty item list**: Make sure Firebase rules allow read/write access
2. **Navigation not working**: Check for console errors
3. **Styles not applied**: Ensure ScreenUtil is working properly
4. **Date picker not opening**: Check platform-specific implementations
5. **Save operations failing**: Verify Firebase configuration

## Success Criteria

✅ Can access Create New Menu from both entry points
✅ Date and time selectors work correctly  
✅ Can create and save new menu items
✅ Can select multiple existing items
✅ Can complete menu creation successfully
✅ Created menus appear in the Menus list
✅ Role-based access control works
✅ Error handling works properly
✅ UI matches design specifications
✅ No console errors or crashes
