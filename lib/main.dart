import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/app_navigation_bar.dart';
import 'package:teton_meal_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/app_splash_screen.dart';
import 'package:teton_meal_app/core/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:teton_meal_app/data/models/user_model.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/custom_exception_dialog.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/menu_item_service.dart';
import 'package:teton_meal_app/data/services/notification_service.dart';
import 'package:teton_meal_app/data/services/reminder_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final storage = FirebaseStorage.instance;
    if (kDebugMode) {
      print('Firebase Storage initialized: ${storage.bucket}');
    }

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
    const vapidKey =
        "BDclHqth8ixTjMFYKUj3WjXpXEkpULwD84XPLqBM100gFmetTQGaokvfyQl-V6G9TPFlZGOzpmgtGPItEbgGhxI";

    String? token;

    if (DefaultFirebaseOptions.currentPlatform == DefaultFirebaseOptions.web) {
      token = await messaging.getToken(
        vapidKey: vapidKey,
      );
    } else {
      token = await messaging.getToken();
    }

    if (kDebugMode) {
      print('Registration Token=$token');
    }

    await setupFirebaseMessaging();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await NotificationService().initialize();
    await NotificationService().requestPermissions();

    final hasExactAlarmPermission =
        await NotificationService().checkExactAlarmPermission();
    if (!hasExactAlarmPermission) {
      await NotificationService().requestExactAlarmPermission();
    }

    await MenuItemService.initializeDefaultItems();

    try {
      await ReminderService().rescheduleAllActiveReminders();
      if (kDebugMode) {
        print('Active reminders rescheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error rescheduling reminders: $e');
      }
    }

    try {
      await ReminderService().cleanupExpiredReminders();
      if (kDebugMode) {
        print('Expired reminders cleaned up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up expired reminders: $e');
      }
    }

    runApp(const MyApp());
  } catch (e) {
    if (kDebugMode) {
      print("Failed to initialize app: ${e.toString()}");
    }
  }
}

Future<void> setupFirebaseMessaging() async {
  try {
    final messaging = FirebaseMessaging.instance;
    const vapidKey =
        "BDclHqth8ixTjMFYKUj3WjXpXEkpULwD84XPLqBM100gFmetTQGaokvfyQl-V6G9TPFlZGOzpmgtGPItEbgGhxI";
    final token = await messaging.getToken(vapidKey: vapidKey);

    if (token != null) {
      final user = AuthService().currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcm_token': token,
          'notifications_enabled': true,
        });
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = AuthService().currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcm_token': newToken,
        });
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print("Failed to setup notifications: ${e.toString()}");
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    const double figmaDesignWidth = 392.73;
    const double figmaDesignHeight = 802.91;

    return ScreenUtilInit(
      designSize: const Size(figmaDesignWidth, figmaDesignHeight),
      minTextAdapt: false,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Teton Meal App',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            primaryColor: AppColors.fRedBright,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.fRedBright,
              primary: AppColors.fRedBright,
              secondary: AppColors.fYellow,
              tertiary: AppColors.fNameBoxYellow,
              error: AppColors.fRed2,
              surface: AppColors.fWhite,
              onPrimary: AppColors.fWhite,
              onSecondary: AppColors.fWhite,
              onSurface: AppColors.fTextH1,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: AppColors.fWhiteBackground,
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.fWhite,
              shadowColor: AppColors.fWhite.withValues(alpha: 0.3),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.fWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.fIconAndLabelText),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.fIconAndLabelText),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.fRedBright, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
              hintStyle: const TextStyle(color: AppColors.fNameBoxYellow),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                backgroundColor: AppColors.fRedBright,
                foregroundColor: AppColors.fWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.fRedBright,
              foregroundColor: AppColors.fWhite,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.fWhite,
              ),
            ),
          ),
          // darkTheme: ThemeData(
          //   primaryColor: AppColors.dRedBright,
          //   colorScheme: ColorScheme.fromSeed(
          //     seedColor: AppColors.dRedBright,
          //     primary: AppColors.dRedBright,
          //     secondary: AppColors.dYellow,
          //     tertiary: AppColors.dNameBoxYellow,
          //     error: AppColors.dRed2,
          //     surface: AppColors.dWhite,
          //     onPrimary: AppColors.dWhite,
          //     onSecondary: AppColors.dWhite,
          //     onSurface: AppColors.dTextH1,
          //     brightness: Brightness.dark,
          //   ),
          //   useMaterial3: true,
          //   fontFamily: 'Poppins',
          //   scaffoldBackgroundColor: AppColors.dWhiteBackground,
          //   cardTheme: CardThemeData(
          //     elevation: 2,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //     color: AppColors.dWhite,
          //     shadowColor: AppColors.dWhite.withValues(alpha: 0.3),
          //   ),
          //   inputDecorationTheme: InputDecorationTheme(
          //     filled: true,
          //     fillColor: AppColors.dWhite,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: BorderSide(color: AppColors.dIconAndLabelText),
          //     ),
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: BorderSide(color: AppColors.dIconAndLabelText),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: BorderSide(color: AppColors.dRedBright, width: 1.5),
          //     ),
          //     contentPadding: const EdgeInsets.all(16),
          //     hintStyle: const TextStyle(color: AppColors.dNameBoxYellow),
          //   ),
          //   elevatedButtonTheme: ElevatedButtonThemeData(
          //     style: ElevatedButton.styleFrom(
          //       elevation: 0,
          //       padding:
          //           const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          //       backgroundColor: AppColors.dRedBright,
          //       foregroundColor: AppColors.dWhite,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       textStyle: const TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w600,
          //         letterSpacing: 0.5,
          //       ),
          //     ),
          //   ),
          //   textButtonTheme: TextButtonThemeData(
          //     style: TextButton.styleFrom(
          //       padding:
          //           const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          //   appBarTheme: AppBarTheme(
          //     backgroundColor: AppColors.dRedBright,
          //     foregroundColor: AppColors.dWhite,
          //     elevation: 0,
          //     centerTitle: true,
          //     titleTextStyle: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.dWhite,
          //     ),
          //   ),
          // ),
          home: child,
        );
      },
      child: SplashScreen(nextScreen: const AuthCheck()),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final userRole = snapshot.data!.role;
          if (userRole == 'Planner' ||
              userRole == 'Admin' ||
              userRole == 'Diner') {
            return const Navbar();
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CustomExceptionDialog.showError(
                context: context,
                title: 'Access Denied',
                message:
                    'Invalid user role. Please contact support for assistance.',
              );
            });
            return const LoginPage();
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
