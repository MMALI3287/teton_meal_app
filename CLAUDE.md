# CLAUDE.md - Teton Meal App Developer Guide

## Recent Development Summary (July 11, 2025)

### Dark/Light Theme Implementation

- **Issue**: Dark/light theme only affecting text boxes due to static color references
- **Solution**: Implemented theme-aware color system with context-dependent getters
- **Status**: Systematic conversion from `AppColors.fTextH1` to `AppColors.textH1(context)` in progress

### Back Button Standardization - COMPLETED ✅

- **Achievement**: All back buttons standardized across 7+ screens
- **Component**: `StandardBackButton` widget matching Figma design (node 241:3352)
- **Design**: 40x40 rounded rectangle, dark gray background, white arrow icon

## Build & Test Commands

- `flutter pub get` - Install dependencies
- `flutter analyze` - Run code analysis (currently clean - no errors)
- `flutter test` - Run unit tests
- `flutter test test/widget_test.dart` - Run specific test
- `flutter run` - Run the app in debug mode

## Code Style Guidelines

- **Imports**: Group Flutter imports first, then project imports
- **Formatting**: Use 2-space indentation
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Error Handling**: Use try/catch for Firebase operations and custom dialogs instead of toast messages
- **UI Components**: Use custom dialogs for all user feedback (errors, warnings, success messages)
- **Theme Colors**: Use theme-aware colors: `AppColors.textH1(context)` instead of `AppColors.fTextH1`
- **Folder Structure**:
  - Use PascalCase for folders: `/Screens`, `/Styles`
  - Dart files use snake_case for non-class files

## UI/UX Best Practices

- **Dialogs**: Always use `CustomExceptionDialog` for error/warning/success messages
- **Confirmations**: Use `CustomDeleteDialog` for all destructive actions
- **No Toast Messages**: Avoid using `Fluttertoast` - use custom dialogs instead
- **Notifications**: Use `NotificationService` for local notifications and reminders
- **Back Buttons**: Use `StandardBackButton` component for consistency
- **Theme Support**: Ensure all colors use theme-aware getters for proper dark/light mode

## Theme System Architecture

### Color Management

- **Static Colors**: `AppColors.fRedBright` (light mode), `AppColors.dRedBright` (dark mode)
- **Theme-Aware Colors**: `AppColors.redBright(context)` - automatically switches based on theme
- **Implementation Pattern**:

  ```dart
  // OLD (static)
  color: AppColors.fTextH1
  
  // NEW (theme-aware)
  color: AppColors.textH1(context)
  ```

### Theme Configuration

- **Light Theme**: Complete configuration in `main.dart`
- **Dark Theme**: Infrastructure ready, systematic color conversion needed
- **System Integration**: `ThemeMode.system` automatically follows device settings

## Project Structure

- `/lib` - Main Dart code
- `/features` - Feature-based architecture
  - `/authentication` - Login, registration
  - `/menu_management` - Menu creation, voting
  - `/user_management` - User profiles, settings
  - `/voting_system` - Voting interface
  - `/reminders` - Notification reminders
- `/shared` - Shared components
  - `/presentation/widgets/common` - Reusable widgets (StandardBackButton, dialogs)
- `/app` - App-level configuration (themes, colors)
- `/data` - Data layer (models, services)
- `/core` - Core functionality (Firebase config)
- `pubspec.yaml` - Dependencies and configuration
- `analysis_options.yaml` - Linting rules

## Architecture Patterns

### Component Architecture

- **StandardBackButton**: Unified back button matching Figma design
- **CustomExceptionDialog**: Consistent user feedback system
- **Theme-Aware Colors**: Context-dependent color resolution

### State Management

- **Provider**: Used for state management
- **Firebase**: Real-time data synchronization
- **Local Storage**: SharedPreferences for user preferences

### Navigation

- **Bottom Navigation**: Main app navigation
- **Standard Back Navigation**: Consistent back button behavior
- **Deep Linking**: Support for direct navigation

## Agent Development Guidelines

### Automated Testing

- **Lint Agent**: `flutter analyze` on all PRs
- **Format Agent**: `flutter format --set-exit-if-changed .`
- **Test Agent**: `flutter test --coverage` with retry logic
- **Unit Tests**: Model validation, service logic
- **Widget Tests**: UI component behavior
- **Integration Tests**: End-to-end user flows

### Build Pipeline

- **Android**: `flutter build apk --release`
- **iOS**: `flutter build ios --release`
- **Web**: `flutter build web --release`

### Code Quality Standards

- **Imports**: Flutter SDK → 3rd-party packages → local modules
- **Indentation**: 2 spaces, trailing commas in multi-line literals
- **Naming**: `camelCase` for methods/vars, `PascalCase` for classes
- **Error Handling**: Wrap async Firebase operations in `try/catch`
- **Debug Logs**: Use `if (kDebugMode)` for debug-only logging

## Firebase Integration

### Services

- **AuthService**: User authentication and role management
- **NotificationService**: Local notification management
- **ReminderService**: Reminder CRUD operations
- **StorageService**: Firebase Storage for profile images

### Security Rules

- **Firestore**: Role-based access control
- **Storage**: Authenticated user access to profile images
- **Authentication**: Custom role system (Diner, Planner, Admin)

## Testing Guidelines

### Manual Testing

- **Theme Switching**: Test light/dark mode transitions
- **Back Button Consistency**: Verify StandardBackButton across all screens
- **Dialog System**: Test all CustomExceptionDialog variants
- **Responsive Design**: Test across different screen sizes

## Recent Major Updates

- **Theme System**: Complete dark/light mode infrastructure
- **Back Button Standardization**: Unified design across all screens
- **Color Architecture**: Theme-aware color management system
- **Custom Dialogs**: Replaced all toast messages with beautiful dialogs
- **Android Build**: Updated Gradle, Kotlin, and Android permissions
- **Reminder System**: Complete local notification-based reminder system

## Migration Patterns

### Static to Theme-Aware Colors

```dart
// Before
Container(
  color: AppColors.fRedBright,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.fTextH1),
  ),
)

// After
Container(
  color: AppColors.redBright(context),
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textH1(context)),
  ),
)
```

### Standard Back Button Usage

```dart
// Before (inconsistent)
IconButton(
  onPressed: () => Navigator.pop(context),
  icon: Icon(Icons.arrow_back),
)

// After (standardized)
StandardBackButton()
```
