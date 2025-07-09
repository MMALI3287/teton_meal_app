import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:teton_meal_app/data/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authStateController = BehaviorSubject<UserModel?>();
  static const _uuid = Uuid();
  SharedPreferences? _prefs;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final String? userId = _prefs!.getString('user_id');
    if (userId != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final user = UserModel.fromMap(userData, userId);
          _authStateController.add(user);
        } else {
          await _prefs!.remove('user_id');
          _authStateController.add(null);
        }
      } catch (e) {
        _authStateController.add(null);
      }
    } else {
      _authStateController.add(null);
    }
  }

  UserModel? get currentUser => _authStateController.valueOrNull;

  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('user-not-found');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      if (userData['password'] != password) {
        throw Exception('incorrect-credentials');
      }

      // Check if user is verified - only allow login if isVerified is explicitly true
      final isVerified = userData['isVerified'];
      if (isVerified != true) {
        throw Exception('account-not-verified');
      }

      final user = UserModel.fromMap(userData, userDoc.id);

      await _prefs!.setString('user_id', user.uid);

      _authStateController.add(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(String email, String password, String role,
      {String? name, String? department}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception(
            'The email address is already in use by another account.');
      }

      final userId = _uuid.v4();

      final userData = {
        'email': email,
        'password': password,
        'role': role,
        'displayName': name,
        'department': department,
        'isVerified': false, // User registration defaults to false
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).set(userData);

      final user = UserModel(
        uid: userId,
        email: email,
        displayName: name,
        department: department,
        role: role,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Admin registration with pre-verified status
  Future<UserModel> adminRegister(String email, String password, String role,
      {String? name, String? department}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception(
            'The email address is already in use by another account.');
      }

      final userId = _uuid.v4();

      final userData = {
        'email': email,
        'password': password,
        'role': role,
        'displayName': name,
        'department': department,
        'isVerified': true, // Admin registration defaults to true
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).set(userData);

      final user = UserModel(
        uid: userId,
        email: email,
        displayName: name,
        department: department,
        role: role,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? department,
    String? email,
    String? password,
    String? fcmToken,
    bool? notificationsEnabled,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (displayName != null) {
        updates['displayName'] = displayName;
      }

      if (department != null) {
        updates['department'] = department;
      }

      if (email != null) {
        updates['email'] = email;
      }

      if (password != null) {
        updates['password'] = password;
      }

      if (fcmToken != null) {
        updates['fcm_token'] = fcmToken;
      }

      if (notificationsEnabled != null) {
        updates['notifications_enabled'] = notificationsEnabled;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);

        if (_authStateController.hasValue &&
            _authStateController.value?.uid == uid) {
          final updatedUser = _authStateController.value!.copyWith(
            displayName: displayName,
            department: department,
            email: email,
            fcmToken: fcmToken,
            notificationsEnabled: notificationsEnabled,
          );
          _authStateController.add(updatedUser);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setupFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      const vapidKey =
          "BDclHqth8ixTjMFYKUj3WjXpXEkpULwD84XPLqBM100gFmetTQGaokvfyQl-V6G9TPFlZGOzpmgtGPItEbgGhxI";
      final token = await messaging.getToken(vapidKey: vapidKey);

      if (token != null) {
        final user = currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcm_token': token,
            'notifications_enabled': true,
          });
        }
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final user = currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'fcm_token': newToken,
          });
        }
      });
    } catch (e) {
      print("Failed to setup notifications: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _prefs!.remove('user_id');
    _authStateController.add(null);
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
