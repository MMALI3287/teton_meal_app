import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String role;
  final String? fcmToken;
  final bool? notificationsEnabled;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    this.fcmToken,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      role: map['role'] ?? 'Diner',
      fcmToken: map['fcm_token'],
      notificationsEnabled: map['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'fcm_token': fcmToken,
      'notifications_enabled': notificationsEnabled,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    String? fcmToken,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authStateController = BehaviorSubject<UserModel?>();
  final _uuid = Uuid();
  SharedPreferences? _prefs;

  // Singleton instance
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

  // Get current user
  UserModel? get currentUser => _authStateController.valueOrNull;

  // Auth state stream
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  // Sign in user
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Query Firestore for a user with this email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No user found for that email.');
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      // Check if password matches
      if (userData['password'] != password) {
        throw Exception('Wrong password provided for that user.');
      }

      // Create user model
      final user = UserModel.fromMap(userData, userDoc.id);
      
      // Save user ID to shared preferences
      await _prefs!.setString('user_id', user.uid);
      
      // Update the auth state
      _authStateController.add(user);
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Register a new user
  Future<UserModel> register(String email, String password, String role) async {
    try {
      // Check if email already exists
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('The email address is already in use by another account.');
      }

      // Create a new user ID
      final userId = _uuid.v4();
      
      // Create user data
      final userData = {
        'email': email,
        'password': password,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(userData);
      
      // Create user model
      final user = UserModel(
        uid: userId,
        email: email,
        role: role,
      );
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
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
        
        // Update current user in memory if needed
        if (_authStateController.hasValue && _authStateController.value?.uid == uid) {
          final updatedUser = _authStateController.value!.copyWith(
            displayName: displayName,
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

  // Sign out
  Future<void> signOut() async {
    await _prefs!.remove('user_id');
    _authStateController.add(null);
  }

  // Get user by ID
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

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}