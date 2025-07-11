import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/authentication/presentation/screens/admin_registration_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/user_request_details_screen.dart';

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
            color: AppColors.fTextH1.withValues(alpha: 0.05),
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
          if (_searchQuery.isNotEmpty)
            InkWell(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.clear,
                  color: AppColors.fIconAndLabelText,
                  size: 18.sp,
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
    final profileImageUrl = userData['profileImageUrl'] as String?;

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

    return GestureDetector(
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
            // User Avatar with actual profile image (same as user list)
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
                image: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileImageUrl == null || profileImageUrl.isEmpty
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
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fTextH1,
                      fontFamily: 'Mulish',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.fIconAndLabelText,
                      fontFamily: 'Mulish',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Department badge (same as user list)
                  if (department != 'No Department') ...[
                    SizedBox(height: 4.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.fCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        department,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fCyan,
                          fontFamily: 'Mulish',
                        ),
                      ),
                    ),
                  ],
                  // Time ago (unique to request cards)
                  SizedBox(height: 4.h),
                  Text(
                    'Requested $timeAgo',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.fIconAndLabelText.withValues(alpha: 0.7),
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
            ),
            // Role Badge (same styling as user list)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: _getRoleColor(role),
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
              color: AppColors.fTextH1.withValues(alpha: 0.05),
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
              color: AppColors.fTextH1.withValues(alpha: 0.05),
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
