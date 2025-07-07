import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/Screens/navbar.dart';
import 'package:teton_meal_app/Screens/Authentications/login.dart';
import 'package:teton_meal_app/services/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:teton_meal_app/services/auth_service.dart';
import 'package:teton_meal_app/widgets/custom_exception_dialog.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/services/menu_item_service.dart';
import 'package:teton_meal_app/services/notification_service.dart';

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

    // Initialize local notifications
    await NotificationService().initialize();
    await NotificationService().requestPermissions();

    // Initialize default menu items
    await MenuItemService.initializeDefaultItems();

    runApp(const MyApp());
  } catch (e) {
    print("Failed to initialize app: ${e.toString()}");
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
    print("Failed to setup notifications: ${e.toString()}");
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
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
              primary: AppColors.primaryColor,
              secondary: AppColors.secondaryColor,
              tertiary: AppColors.warning,
              error: AppColors.error,
              surface: AppColors.backgroundColor,
              onPrimary: AppColors.white,
              onSecondary: AppColors.white,
              onSurface: AppColors.primaryText,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: AppColors.backgroundColor,
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.cardBackground,
              shadowColor: AppColors.shadowColor,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.inputBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.inputBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primaryColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
              hintStyle: const TextStyle(color: AppColors.tertiaryText),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
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
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          home: child,
        );
      },
      child: const AuthCheck(),
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
            // Show error dialog for invalid user role
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
