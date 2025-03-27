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
- **Error Handling**: Use try/catch for Firebase operations
- **Folder Structure**:
  - Use PascalCase for folders: `/Screens`, `/Styles`
  - Dart files use snake_case for non-class files

## Project Structure
- `/lib` - Main Dart code
  - `/Screens` - UI screens and pages
  - `/Styles` - Color schemes and theme data
- `/android`, `/ios`, `/web` - Platform-specific code
- `pubspec.yaml` - Dependencies and configuration
- `analysis_options.yaml` - Linting rules