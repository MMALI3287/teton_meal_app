# Teton Meal App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Version-1.2.1-blue?style=for-the-badge" alt="Version 1.2.1"/>
</div>

## 📱 Overview

Teton Meal App is a comprehensive meal management application designed for organizations to streamline their lunch ordering and meal planning processes. The app facilitates communication between diners, meal planners, and administrators, creating an efficient system for meal voting, menu planning, and account management.

[![wakatime](https://wakatime.com/badge/user/55b3480f-fbb9-40ba-bd9a-c04c257f4e39/project/24ce2be9-0569-4529-88d6-303241bc328e.svg)](https://wakatime.com/badge/user/55b3480f-fbb9-40ba-bd9a-c04c257f4e39/project/24ce2be9-0569-4529-88d6-303241bc328e)

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Recent Major Updates](#-recent-major-updates-july-2025)
- [Technologies Used](#-technologies-used)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Project Structure](#️-project-structure)
- [User Roles](#-user-roles)
- [Development and Testing](#-development-and-testing)
- [Architecture Documentation](#-architecture-documentation)
- [Testing Guide](#-testing-guide)
- [Bug Fixes & Improvements](#-bug-fixes--improvements)
- [Firebase Configuration](#-firebase-configuration)
- [Agent Development](#-agent-development)
- [Cross-Platform Support](#-technologies-used)
- [Code Style Guidelines](#-code-style-guidelines)
- [License](#-license)
- [Contact](#-contact)
- [Acknowledgements](#-acknowledgements)

## ✨ Features

### For All Users

- **Authentication System**: Secure login and account management
- **Voting System**: Vote on daily lunch menu options with intuitive interface
- **Profile Management**: Update personal information and notification preferences
- **Reminder System**: Set up custom meal reminders with local notifications
- **Beautiful UI Dialogs**: Custom-designed error, warning, and success dialogs
- **Theme Support**: Automatic dark/light mode switching based on system preferences
- **Standardized Navigation**: Consistent back button design across all screens
- **Enhanced Forms**: Dropdown fields with clear arrow indicators for better usability
- **Improved Accessibility**: Better touch targets and visual hierarchy throughout the app
- **Cross-Platform Polish**: Optimized experience for both iOS and Android devices
- **Lunch Receipts**: Generate and share lunch receipts

### For Planners

- **Menu Management**: Create and manage lunch menus with calendar integration
- **Calendar View**: Organize meals in a comprehensive calendar format
- **Grid View**: Alternative view for efficient meal planning
- **Voting Analytics**: View detailed voting results and statistics

### For Administrators

- **User Management**: Register and manage employee accounts
- **Role Assignment**: Assign roles (Diner, Planner, Admin)
- **System Oversight**: Monitor and manage the entire meal system
- **Analytics Dashboard**: Comprehensive system analytics and reporting

## 🎨 Recent Major Updates (July 2025)

### ✅ Enhanced User Interface & Experience

- **Form Field Improvements**: Added dropdown arrow indicators to all form fields for better usability
- **Font System Upgrade**: Implemented Google Fonts integration for Work Sans font family
- **Splash Screen Enhancement**: Repositioned welcome text to upper third for better visual balance
- **Settings UI Polish**: Increased individual settings item heights for improved touch targets
- **Button Design Refresh**: Updated back buttons with modern square design and subtle shadows

### ✅ iOS Platform Optimizations

- **Checkbox Fix**: Resolved iOS-specific checkbox focus overlay issues
- **Touch Responsiveness**: Improved touch targets and interaction feedback on iOS devices
- **Visual Consistency**: Fixed platform-specific UI artifacts and styling inconsistencies

### ✅ Code Quality & Maintainability

- **Standardized Dialogs**: Implemented consistent deletion dialog system using `CustomDeleteDialog`
- **Improved Spacing**: Enhanced UI element spacing throughout the app for better visual hierarchy
- **Registration Simplification**: Streamlined registration form by removing unnecessary validation steps
- **Cross-Platform Compatibility**: Addressed platform-specific rendering and behavior issues

### ✅ Dark/Light Theme System

- **Complete Theme Implementation**: Automatic switching based on system preferences
- **Theme-Aware Colors**: Context-dependent color system throughout the app
- **Professional Design**: Consistent theming across all UI components

### ✅ Back Button Standardization

- **Unified Design**: All back buttons now match Figma specifications exactly
- **Consistent Experience**: Same design and behavior across 7+ screens
- **Professional Quality**: Rounded rectangle design with proper styling

### ✅ UI/UX Improvements

- **Custom Dialog System**: Beautiful dialogs for all user feedback
- **Enhanced Navigation**: Standardized back button component
- **Responsive Design**: Consistent sizing across all screen sizes
- **Modern Interface**: Clean, professional appearance throughout

## 🔧 Technologies Used

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Cloud Firestore (Database)
  - Firebase Messaging (Notifications)
  - Firebase Analytics
- **Authentication**: Custom authentication system
- **State Management**: Provider
- **Charts & Visualization**: fl_chart
- **Calendar**: table_calendar
- **Notifications**: firebase_messaging, flutter_local_notifications
- **UI Components**: Custom dialogs and widgets
- **Cross-Platform**: Android, iOS, Web, macOS, Windows, Linux

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart](https://dart.dev/get-dart) (SDK version compatible with Flutter)
- [Git](https://git-scm.com/downloads)
- A code editor (VS Code, Android Studio, etc.)

## 🚀 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/MMALI3287/teton_meal_app.git
   cd teton_meal_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - The project is already configured with Firebase
   - If you want to use your own Firebase project:
     1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
     2. Configure Flutter app with Firebase using [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
     3. Update the `firebase_options.dart` file

4. **Run the application**

   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```text
teton_meal_app/
├── lib/
│   ├── Screens/                 # UI screens
│   │   ├── BottomNavPages/      # Bottom navigation pages
│   │   │   ├── Account/         # Account management & reminders
│   │   │   ├── Menus/           # Menu management
│   │   │   └── Votes/           # Voting system
│   │   ├── login.dart           # Login screen
│   │   ├── Navbar.dart          # Navigation bar
│   │   └── Register.dart        # Registration screen
│   ├── Styles/                  # App styling
│   │   └── colors.dart          # Color definitions
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models
│   │   │   ├── user_model.dart  # User data structure
│   │   │   └── reminder_model.dart  # Reminder data structure
│   │   └── services/            # Business logic services
│   │       ├── auth_service.dart    # Authentication service
│   │       ├── notification_service.dart # Local notification service
│   │       └── reminder_service.dart     # Reminder management service
│   ├── features/                # Feature modules
│   │   ├── authentication/      # Authentication feature
│   │   │   └── presentation/    # UI components
│   │   │       ├── screens/     # Authentication screens
│   │   │       └── widgets/     # Authentication widgets
│   │   ├── user_management/     # User management feature
│   │   │   └── presentation/    # UI components
│   │   │       ├── screens/     # User management screens
│   │   │       └── widgets/     # User management widgets
│   │   └── reminders/           # Reminders feature
│   │       └── presentation/    # UI components
│   │           ├── screens/     # Reminder screens
│   │           └── widgets/     # Reminder widgets
│   ├── shared/                  # Shared components
│   │   └── presentation/        # Shared UI components
│   │       └── widgets/         # Reusable widgets
│   ├── firebase_options.dart    # Firebase configuration
│   └── main.dart                # App entry point
├── android/                     # Android-specific code
├── ios/                         # iOS-specific code
├── web/                         # Web-specific code
├── macos/                       # macOS-specific code
├── windows/                     # Windows-specific code
├── linux/                       # Linux-specific code
├── functions/                   # Firebase Cloud Functions
├── pubspec.yaml                 # Dependencies
└── README.md                    # Project documentation
```

## 👥 User Roles

The app supports three user roles, each with different permissions:

1. **Diner**
   - Vote on lunch options
   - View menus
   - Manage personal profile

2. **Planner**
   - Create and manage menus
   - View voting results
   - Manage personal profile

3. **Admin**
   - All Planner capabilities
   - Register new users
   - Assign user roles
   - System administration

## 🧪 Development and Testing

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Building for Production

```bash
flutter build apk --release  # For Android
flutter build ios --release  # For iOS
flutter build web --release  # For Web
```

## 📚 Architecture Documentation

### Component-Based Architecture

The app follows a modular component-based architecture:

- **StandardBackButton**: Unified back button component matching Figma design
- **CustomExceptionDialog**: Consistent dialog system for user feedback  
- **Theme-Aware Colors**: Dynamic color system supporting light/dark modes
- **Responsive Components**: ScreenUtil integration for consistent sizing

### Menu Management System

- **Modular Design**: Reusable components for date selection, item management
- **Transaction-Based**: Ensures data consistency during menu creation
- **Voting Integration**: Seamless connection between menu creation and voting

### State Management

- **Provider Pattern**: Efficient state management across the app
- **Firebase Real-time**: Live data synchronization
- **Local Storage**: User preferences and offline capability

## 🧪 Testing Guide

### Manual Testing Checklist

#### Theme System Testing

1. **System Theme Changes**:
   - Change device to dark mode → App should switch to dark theme
   - Change device to light mode → App should switch to light theme
   - Verify all UI elements respond to theme changes

2. **Back Button Consistency**:
   - Navigate through all screens with back buttons
   - Verify consistent design (40x40, rounded rectangle, dark gray)
   - Test navigation behavior

#### Menu Creation Flow

1. **Access Points**:
   - From Votes page: Red "+" button in top-right
   - From Menus page: Floating action button

2. **Date Selection**:
   - Tap date selector → Date picker opens
   - Select future date → Display updates with date and day name

3. **Item Management**:
   - Add items → Navigate to item selection
   - Remove items → Confirm deletion
   - Edit items → Modify existing items

#### Voting System

1. **Vote Registration**:
   - Cast votes on menu items
   - Verify vote persistence
   - Test vote modifications

2. **Real-time Updates**:
   - Multiple users voting simultaneously
   - Vote count accuracy
   - UI responsiveness

### Automated Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Code analysis
flutter analyze

# Format check
flutter format --set-exit-if-changed .
```

## 🐛 Bug Fixes & Improvements

### Recent Fixes (July 2025)

#### UI/UX Enhancements

- **Issue**: Missing dropdown indicators on form fields causing confusion
- **Solution**: Added `suffixIcon` with dropdown arrows to all relevant form fields
- **Impact**: Improved form field recognition and user experience

#### Font System Improvements

- **Issue**: Custom font loading reliability problems
- **Solution**: Migrated to Google Fonts integration using `GoogleFonts.workSans()`
- **Impact**: Better font consistency and loading reliability across platforms

#### iOS Platform Optimizations

- **Issue**: Checkbox focus overlays causing visual artifacts on iOS
- **Solution**: Implemented transparent overlay removal with Theme wrapper
- **Impact**: Clean checkbox appearance and improved touch responsiveness on iOS

#### Visual Hierarchy Improvements

- **Issue**: Splash screen text positioning and settings items too cramped
- **Solution**: Repositioned splash text to upper third, increased settings item padding
- **Impact**: Better visual balance and improved touch targets

#### Theme System Implementation

- **Issue**: Only text boxes responding to theme changes
- **Root Cause**: Static color references instead of theme-aware getters
- **Solution**: Systematic conversion to `AppColors.colorName(context)` pattern
- **Impact**: Complete light/dark mode functionality

#### Back Button Standardization

- **Issue**: Inconsistent back button designs across screens
- **Problems**: Various sizes (30x30, 36x36, 40x40), different shapes, color variations
- **Solution**: Created `StandardBackButton` component matching Figma design
- **Result**: Unified design across 7+ screens

### Historical Fixes

#### Menu Creation System

- **Cross Button Functionality**: Fixed navigation in menu creation pages
- **Title Alignment**: Centered page titles consistently
- **Date Picker**: Resolved tap area issues
- **Button Layout**: Fixed vertical to horizontal layout

#### Voting System Persistence

- **MenuItem Format**: Fixed newline character issues in Firebase field names
- **Transaction Safety**: Implemented proper menu creation/deactivation
- **Vote Recording**: Resolved special character handling in vote options

#### Firebase Storage Integration

- **Profile Image Upload**: Fixed "no object found" errors
- **Storage Rules**: Proper authentication-based access control
- **Error Handling**: Enhanced debugging and error classification

## 🔥 Firebase Configuration

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images - authenticated users only
    match /profile_images/{profileImage} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Default rule - require authentication
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Firestore Security

- **Role-based Access**: Diner, Planner, Admin permissions
- **User Data Protection**: Users can only modify their own data
- **Menu Management**: Planners and Admins can create/modify menus
- **Vote Privacy**: Secure vote recording and aggregation

### Cloud Functions

- **Notification Triggers**: Automated notifications for new menus
- **Data Validation**: Server-side validation for critical operations
- **Analytics Processing**: Vote counting and reporting

## 🤖 Agent Development

### Automated Pipelines

#### Lint & Format Agent

```bash
# Trigger: PR to feature/* or main
flutter analyze
flutter format --set-exit-if-changed .
```

#### Test Runner Agent

```bash
# Trigger: PR events and nightly builds
flutter test --coverage
# Retry failures up to 2x
```

#### Build & Release Agent

```bash
# Trigger: Push to main or release/*
flutter build apk --release
flutter build ios --release
flutter build web --release
```

#### Security Audit Agent

```bash
# Trigger: Weekly schedule
flutter pub outdated
npm audit  # for Node-based scripts
```

### Development Conventions

#### Branch Naming

- `feature/<JIRA-ID>-short-desc`
- `bugfix/<ID>-short-desc`
- `release/<version>`

#### Commit Messages

```Text
feat: add dark theme support
fix: resolve back button navigation
docs: update README with testing guide
refactor: standardize color management
```

#### PR Requirements

- Linked issue/ticket reference
- Summary of changes and impact
- Test coverage report (if applicable)
- Screenshots for UI/behavior changes
- Code review approval from team lead

### Code Quality Standards

#### Import Organization

```dart
// 1. Flutter SDK imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 2. Third-party package imports
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 3. Local project imports
import 'package:teton_meal_app/features/auth/auth_service.dart';
import 'package:teton_meal_app/shared/widgets/custom_dialog.dart';
```

#### Naming Conventions

- **Variables/Methods**: `camelCase` (e.g., `userName`, `getUserData()`)
- **Classes/Files**: `PascalCase` (e.g., `UserModel`, `AuthService`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Files**: `snake_case` (e.g., `user_service.dart`, `custom_dialog.dart`)

#### Error Handling Pattern

```dart
try {
  final result = await firebaseOperation();
  // Success handling
  CustomExceptionDialog.showSuccess(
    context: context,
    title: 'Success',
    message: 'Operation completed successfully',
  );
} catch (e) {
  // Error handling
  if (kDebugMode) {
    print('Operation failed: $e');
  }
  CustomExceptionDialog.showError(
    context: context,
    title: 'Error',
    message: 'Operation failed. Please try again.',
  );
}
```

## 📄 Code Style Guidelines

- Follow the [Flutter style guide](https://flutter.dev/docs/development/ui/style)
- Use 2-space indentation
- Use camelCase for variables/methods, PascalCase for classes
- Group Flutter imports first, then project imports
- Implement proper error handling with try/catch blocks

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

MD Musaddique Ali Erfan - [erfanali3287@gmail.com](mailto:erfanali3287@gmail.com)

Project Link: [https://github.com/MMALI3287/teton_meal_app](https://github.com/MMALI3287/teton_meal_app)

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Dart](https://dart.dev/)
- All the contributors who have helped shape this project

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)

---

<div align="center">
  <p>Built with ❤️ by MD Musaddique Ali Erfan</p>
</div>
