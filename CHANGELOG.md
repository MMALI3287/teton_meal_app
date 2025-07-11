# CHANGELOG

All notable changes to the Teton Meal App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Dark/Light Theme System**
  - Complete dark and light mode implementation with `ThemeMode.system`
  - Theme-aware color system in `AppColors` class with context-dependent getters
  - Automatic theme switching based on system preference
  - Updated `main.dart` with comprehensive dark theme configuration

- **Standardized Back Button Component**
  - `lib/shared/presentation/widgets/common/standard_back_button.dart`
  - Unified back button design matching Figma specifications (node 241:3352)
  - Rounded rectangle design with 12.r border radius, 40.w x 40.h size
  - Dark gray background (#383a3f) with white arrow icon
  - Applied across 7 key screens for consistency

- **Enhanced Color Management**
  - Extended `AppColors` class with dark mode variants (d prefix)
  - Theme-aware getter methods for dynamic color resolution
  - Context-dependent color switching: `AppColors.textH1(context)`
  - Support for both static and theme-aware color usage

### Changed

- **Theme Architecture Overhaul**
  - Updated `app_theme.dart` with dark mode color constants
  - Modified all theme-aware widgets to use context-dependent colors
  - Replaced static color references with dynamic theme-aware getters
  - Enhanced theming system for comprehensive light/dark mode support

- **Back Button Standardization**
  - Replaced inconsistent back buttons across all screens
  - Updated `polls_by_date_screen.dart`, `select_menu_item_screen.dart`, `poll_votes_detail_screen.dart`
  - Updated `user_edit_screen.dart`, `account_overview_screen.dart`, `user_request_details_screen.dart`
  - Updated `add_reminder_screen.dart` with standardized back button

### Fixed

- **Theme System Implementation**
  - Resolved issue where only text boxes responded to theme changes
  - Fixed static color references preventing proper theme switching
  - Updated widget color usage to respect system theme settings
  - Ensured all UI elements respond correctly to light/dark mode changes

- **Design Consistency Issues**
  - Eliminated back button size variations (30x30, 36x36, 40x40)
  - Fixed inconsistent shapes (circular vs rounded rectangles)
  - Standardized color variations across different screens
  - Unified icon consistency and navigation patterns

### Technical Improvements

- **Code Quality**
  - Systematic conversion from static to theme-aware color references
  - Enhanced maintainability with single source of truth for back buttons
  - Improved responsive design with ScreenUtil integration
  - Better separation of concerns in theme management

## [1.2.0] - 2025-01-07

### Added in 1.2.0

- **Comprehensive Reminder System**
  - Local notification-based reminder functionality
  - User-specific reminder management
  - Daily, weekly, and monthly repeat options
  - Enable/disable toggle for individual reminders
  - Integration with app startup for existing reminder restoration

- **Custom Dialog System**
  - `CustomExceptionDialog` for error, warning, success, and info messages
  - `CustomDeleteDialog` for destructive action confirmations
  - Consistent, beautiful UI design throughout the app
  - Better accessibility support

- **New Services**
  - `NotificationService` for local notification management
  - `ReminderService` for reminder CRUD operations
  - Permission handling for notifications and exact alarms

- **New Models**
  - `ReminderModel` with Firestore serialization support

- **New UI Components**
  - Reminders page in account settings
  - Add reminder page with time picker and repeat options
  - Settings page integration for reminder management

### Changed in 1.2.0

- **Replaced Toast Messages**
  - All `Fluttertoast.showToast()` calls replaced with custom dialogs
  - Improved user feedback consistency
  - Better error message presentation

- **Android Build Configuration**
  - Updated `compileSdkVersion` to 34
  - Updated `minSdkVersion` to 21
  - Updated `targetSdkVersion` to 34
  - Updated Gradle version to 8.3
  - Updated Android Gradle Plugin to 8.1.0

- **Dependencies**
  - Added `flutter_local_notifications: ^17.2.3`
  - Reduced dependency on `fluttertoast` package
  - Disabled `firebase_analytics` to resolve build conflicts

- Updated app entry logic in `main.dart` to include splash screen routing

### Fixed in 1.2.0

- **Android Build Issues**
  - Resolved Kotlin version conflicts
  - Fixed Gradle compatibility issues
  - Added required notification permissions

- **UI/UX Improvements**
  - Consistent dialog styling across all screens
  - Professional appearance for user feedback
  - Proper error handling with custom dialogs

- **Code Quality**
  - Removed unused imports
  - Standardized error handling patterns
  - Improved code organization

### Security

- **Android Permissions**
  - Added `RECEIVE_BOOT_COMPLETED` permission
  - Added `VIBRATE` permission
  - Added `SCHEDULE_EXACT_ALARM` permission
  - Added `USE_EXACT_ALARM` permission

## [1.1.0] - Previous Version

### Added in 1.1.0

- Basic meal voting system
- Menu management for planners
- User authentication and role management
- Calendar and grid views for meal planning

### Fixed in 1.1.0

- Cross button functionality in menu creation pages
- Title alignment in page headers
- Date picker functionality
- Button layout improvements

## [1.0.0] - Initial Release

### Added in 1.0.0

- Core meal management application
- User roles (Diner, Planner, Admin)
- Firebase integration
- Cross-platform support (Android, iOS, Web, macOS, Windows, Linux)

---

## Types of Changes

- **Added** for new features
- **Changed** for changes in existing functionality  
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities

## Migration Guide

### From 1.1.0 to 1.2.0

1. **Update Dependencies**

   ```bash
   flutter pub get
   ```

2. **Android Build Updates**
   - The Android build configuration has been updated
   - Minimum SDK version is now 21
   - Target SDK version is now 34

3. **Notification Permissions**
   - New notification permissions will be requested on first app launch
   - Users can manage reminder permissions in device settings

4. **UI Changes**
   - Toast messages have been replaced with custom dialogs
   - All user feedback now uses consistent dialog components
   - No breaking changes to existing functionality

### New Features Available

- Access reminders from Settings → Reminders
- Set up custom meal reminders with flexible repeat options
- Enjoy improved user feedback with beautiful custom dialogs
- Better error handling and success notifications

### Deprecated Features

- `Fluttertoast` usage is now deprecated in favor of custom dialogs
- Direct toast message calls should be replaced with appropriate dialog calls
