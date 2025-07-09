# CHANGELOG

All notable changes to the Teton Meal App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Splash Screen**
  - `lib/shared/presentation/widgets/common/app_splash_screen.dart`
  - Initial splash screen displayed on app launch

- **Authentication UI Enhancements**
  - Updated login and registration flows (`lib/features/authentication/presentation/screens/login_screen.dart`, `lib/features/authentication/presentation/screens/user_registration_screen.dart`)

- **Menu & Voting UI Updates**
  - Improved create new menu page (`lib/features/menu_management/presentation/screens/create_menu_screen.dart`)
  - Enhanced voting page (`votes_page.dart`)

## [1.2.0] - 2025-01-07

### Added

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

### Changed

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

### Fixed

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
