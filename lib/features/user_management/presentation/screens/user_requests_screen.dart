import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/authentication/presentation/screens/admin_registration_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/user_detail_screen.dart';

class UserRequestsPage extends StatefulWidget {
  const UserRequestsPage({super.key});

  @override
  State<UserRequestsPage> createState() => _UserRequestsPageState();
}

class _UserRequestsPageState extends State<UserRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _buildUserRequestsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'User Requests',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Register(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.fRedBright,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fRedBright.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: AppColors.fWhite,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Add New',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fWhite,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.fIconAndLabelText.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.fIconAndLabelText,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search user requests...',
                hintStyle: TextStyle(
                  color: AppColors.fIconAndLabelText,
                  fontSize: 14.sp,
                  fontFamily: 'Mulish',
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: AppColors.fTextH1,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        final allUsers = snapshot.data?.docs ?? [];

        // Filter users to only include those who need verification
        // (isVerified is false or missing/null)
        final unverifiedUsers = allUsers.where((user) {
          final userData = user.data() as Map<String, dynamic>;
          final isVerified = userData['isVerified'];
          // Include users where isVerified is false or missing (null)
          return isVerified == false || isVerified == null;
        }).toList();

        // Filter users based on search query
        final filteredUsers = unverifiedUsers.where((user) {
          final userData = user.data() as Map<String, dynamic>;
          final name = (userData['displayName'] ?? userData['name'] ?? '')
              .toString()
              .toLowerCase();
          final email = (userData['email'] ?? '').toString().toLowerCase();
          final department =
              (userData['department'] ?? '').toString().toLowerCase();

          return name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              department.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return _buildEmptyWidget();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final userData = user.data() as Map<String, dynamic>;

            return _buildUserRequestCard(user.id, userData);
          },
        );
      },
    );
  }

  Widget _buildUserRequestCard(String userId, Map<String, dynamic> userData) {
    final name = userData['displayName'] ?? userData['name'] ?? 'No Name';
    final email = userData['email'] ?? 'No Email';
    final department = userData['department'] ?? 'No Department';
    final role = userData['role'] ?? 'Diner';
    final createdAt = userData['createdAt'] as Timestamp?;

    String timeAgo = 'Unknown';
    if (createdAt != null) {
      final now = DateTime.now();
      final difference = now.difference(createdAt.toDate());

      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.fNameBoxPink,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fRedBright,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fTextH1,
                    fontFamily: 'Mulish',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                // Role Badge - positioned below the name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _getRoleColor(role).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: _getRoleColor(role),
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'Mulish',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  department,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'Mulish',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.fIconAndLabelText.withValues(alpha: 0.7),
                    fontFamily: 'Mulish',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // View Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(
                    userId: userId,
                    userData: userData,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.fRedBright,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fWhite,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.fRedBright;
      case 'planner':
        return const Color(0xFF2196F3); // Blue for planner
      case 'diner':
      default:
        return const Color(0xFF4CAF50); // Green for diner
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.fRedBright,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading user requests...',
            style: TextStyle(
              color: AppColors.fIconAndLabelText,
              fontSize: 14.sp,
              fontFamily: 'Mulish',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.fRedBright,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Requests',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unable to load user requests. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.fIconAndLabelText,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              color: AppColors.fIconAndLabelText,
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              _searchQuery.isEmpty ? 'No Pending Requests' : 'No Results Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _searchQuery.isEmpty
                  ? 'All user requests have been processed.'
                  : 'No user requests match your search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.fIconAndLabelText,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
