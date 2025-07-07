# CLAUDE.md - Teton Meal App Developer Guide

## Build & Test Commands

- `flutter pub get` - Install dependencies
- `flutter analyze` - Run code analysis
- `flutter test` - Run unit tests
- `flutter test test/widget_test.dart` - Run specific test
- `flutter run` - Run the app in debug mode

## Code Style Guidelines

- **Imports**: Group Flutter imports first, then project imports
- **Formatting**: Use 2-space indentation
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Error Handling**: Use try/catch for Firebase operations and custom dialogs instead of toast messages
- **UI Components**: Use custom dialogs for all user feedback (errors, warnings, success messages)
- **Folder Structure**:
  - Use PascalCase for folders: `/Screens`, `/Styles`
  - Dart files use snake_case for non-class files

## UI/UX Best Practices

- **Dialogs**: Always use `CustomExceptionDialog` for error/warning/success messages
- **Confirmations**: Use `CustomDeleteDialog` for all destructive actions
- **No Toast Messages**: Avoid using `Fluttertoast` - use custom dialogs instead
- **Notifications**: Use `NotificationService` for local notifications and reminders

## Project Structure

- `/lib` - Main Dart code
- `/Screens` - UI screens and pages
- `/Styles` - Color schemes and theme data
- `/services` - Business logic (auth, notifications, reminders)
- `/models` - Data models (reminder, user, etc.)
- `/widgets` - Reusable UI components (custom dialogs)
- `/android`, `/ios`, `/web` - Platform-specific code
- `pubspec.yaml` - Dependencies and configuration
- `analysis_options.yaml` - Linting rules

## Recent Major Updates

- **Reminder System**: Complete local notification-based reminder system
- **Custom Dialogs**: Replaced all toast messages with beautiful custom dialogs
- **Android Build**: Updated Gradle, Kotlin, and Android permissions for notifications
- **UI Consistency**: Standardized all user feedback through custom dialog components
