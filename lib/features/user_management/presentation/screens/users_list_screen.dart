import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/user_edit_screen.dart';

// Simple User data class for this page
class UserData {
  final String uid;
  final String email;
  final String role;
  final String? displayName;
  final String? department;
  final String? profileImageUrl;

  UserData({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.department,
    this.profileImageUrl,
  });
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _isLoading = true;
  List<UserData> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch verified users from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isVerified', isEqualTo: true)
          .orderBy('email')
          .get();

      _users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserData(
          uid: doc.id,
          email: data['email'] ?? '',
          role: data['role'] ?? 'Diner',
          displayName: data['displayName'],
          department: data['department'],
          profileImageUrl: data['profileImageUrl'],
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: ${e.toString()}'),
          backgroundColor: AppColors.fRed2,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42.w,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColors.fTextH1,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.fWhite,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Users',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.fTextH1,
                        letterSpacing: -0.12,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Users List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64.sp,
                                color: AppColors.fIconAndLabelText,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.fTextH1,
                                  fontFamily: 'Mulish',
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'No verified users yet',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.fIconAndLabelText,
                                  fontFamily: 'Mulish',
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return _buildUserCard(user);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserData user) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserEditScreen(
              userId: user.uid,
              userData: {
                'email': user.email,
                'role': user.role,
                'displayName': user.displayName,
                'department': user.department,
                'profileImageUrl': user.profileImageUrl,
              },
            ),
          ),
        );

        // Reload users if changes were made
        if (result == true) {
          _loadUsers();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.fTextH1.withValues(alpha: 0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // User Avatar with actual profile image
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.fWhiteBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
                  width: 1,
                ),
                image: user.profileImageUrl != null &&
                        user.profileImageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(user.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                      ? Icon(
                          Icons.person_outline,
                          color: AppColors.fIconAndLabelText,
                          size: 24.sp,
                        )
                      : null,
            ),
            SizedBox(width: 16.w),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName!
                        : user.email.split('@').first,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fTextH1,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.fIconAndLabelText,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  // Department badge
                  if (user.department != null &&
                      user.department!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.fCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        user.department!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fCyan,
                          fontFamily: 'Mulish',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Role Badge with different colors
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: _getRoleColor(user.role),
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.fRedBright; // Red for admin
      case 'planner':
        return AppColors.saveGreen; // Green for planner
      case 'diner':
      default:
        return AppColors.fYellow; // Yellow for diner
    }
  }
}
