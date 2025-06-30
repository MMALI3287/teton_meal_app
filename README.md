# Teton Meal App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge" alt="Version 1.0.0"/>
</div>

## 📱 Overview

Teton Meal App is a comprehensive meal management application designed for organizations to streamline their lunch ordering and meal planning processes. The app facilitates communication between diners, meal planners, and administrators, creating an efficient system for meal voting, menu planning, and account management.

[![wakatime](https://wakatime.com/badge/user/55b3480f-fbb9-40ba-bd9a-c04c257f4e39/project/24ce2be9-0569-4529-88d6-303241bc328e.svg)](https://wakatime.com/badge/user/55b3480f-fbb9-40ba-bd9a-c04c257f4e39/project/24ce2be9-0569-4529-88d6-303241bc328e)

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Technologies Used](#-technologies-used)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Project Structure](#️-project-structure)
- [User Roles](#-user-roles)
- [Development and Testing](#-development-and-testing)
- [Supported Platforms](#-supported-platforms)
- [Contributing](#-contributing)
- [Code Style Guidelines](#-code-style-guidelines)
- [License](#-license)
- [Contact](#-contact)
- [Acknowledgements](#-acknowledgements)

## ✨ Features

### For All Users

- **Authentication System**: Secure login and account management
- **Voting System**: Vote on daily lunch menu options
- **Profile Management**: Update personal information and notification preferences
- **Lunch Receipts**: Generate and share lunch receipts

### For Planners

- **Menu Management**: Create and manage lunch menus
- **Calendar View**: Organize meals in a calendar format
- **Grid View**: Alternative view for meal planning

### For Administrators

- **User Management**: Register and manage employee accounts
- **Role Assignment**: Assign roles (Diner, Planner, Admin)
- **System Oversight**: Monitor and manage the entire meal system

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
- **Notifications**: firebase_messaging, fluttertoast
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
│   │   │   ├── Account/         # Account management
│   │   │   ├── Menus/           # Menu management
│   │   │   └── Votes/           # Voting system
│   │   ├── login.dart           # Login screen
│   │   ├── Navbar.dart          # Navigation bar
│   │   └── Register.dart        # Registration screen
│   ├── Styles/                  # App styling
│   │   └── colors.dart          # Color definitions
│   ├── services/                # Business logic services
│   │   └── auth_service.dart    # Authentication service
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

## 📱 Supported Platforms

- Android
- iOS
- Web
- macOS
- Windows
- Linux

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

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
