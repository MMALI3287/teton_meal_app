import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/pages/create_new_menu_page.dart';
import 'package:teton_meal_app/Styles/colors.dart';

class VotesPage extends StatefulWidget {
  const VotesPage({super.key});

  @override
  State<VotesPage> createState() => _VotesPageState();
}

class _VotesPageState extends State<VotesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _isAdminOrPlanner {
    final userRole = AuthService().currentUser?.role;
    return userRole == 'Admin' || userRole == 'Planner';
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // F_WhiteBackground
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _isAdminOrPlanner
                      ? FirebaseFirestore.instance
                          .collection('polls')
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('polls')
                          .where('isActive', isEqualTo: true)
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Error in StreamBuilder: ${snapshot.error}');
                      print(
                          'Query: ${_isAdminOrPlanner ? "Admin/Planner - Latest poll" : "Diner - Active polls only"}');
                      return _buildErrorWidget(snapshot.error);
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingWidget();
                    }

                    final polls = snapshot.data?.docs ?? [];
                    print(
                        'Loaded ${polls.length} polls for ${_isAdminOrPlanner ? "Admin/Planner" : "Diner"}');

                    if (polls.isEmpty) {
                      return _buildEmptyWidget();
                    }

                    // Debug: Print poll info
                    if (polls.isNotEmpty) {
                      final pollData =
                          polls.first.data() as Map<String, dynamic>;
                      print(
                          'Active poll - Date: ${pollData['date']}, Options: ${pollData['options']}, Active: ${pollData['isActive']}');
                    }

                    return _buildPollContent(polls.first);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Today\'s Lunch Menu',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF383A3F), // F_Text_H1
                letterSpacing: -0.12,
              ),
            ),
          ),
          if (_isAdminOrPlanner)
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateNewMenuPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3951), // F_Red_Bright
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2.92.r,
                          offset: Offset(0, 2.92.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'New Menu',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF585F6A), // F_Text_H2
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading today\'s lunch menu...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Menu',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We couldn\'t load the lunch menu. Please try again later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'Error: ${error.toString()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.tertiaryText,
                  ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
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
        padding: EdgeInsets.all(30.w),
        margin: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 15.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant,
              color: AppColors.tertiaryText,
              size: 72.sp,
            ),
            SizedBox(height: 24.h),
            Text(
              'No Active Lunch Menu',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16.h),
            Text(
              _isAdminOrPlanner
                  ? 'No polls found. Create a new menu to get started.'
                  : 'There are no active lunch polls at the moment. Check back later for today\'s menu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollContent(QueryDocumentSnapshot pollData) {
    final data = pollData.data() as Map<String, dynamic>;
    final String date = data['date'] ?? 'No Date';
    final String formattedDate = _formatDate(date);
    final List<String> options = List<String>.from(data['options'] ?? []);
    final Map<String, dynamic> votes = data['votes'] ?? {};
    final int? endTimeMs = data['endTimeMillis'];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _buildMainCard(pollData, formattedDate, options, votes),
          SizedBox(height: 16.h),
          _buildTotalOrdersCard(votes),
          SizedBox(height: 16.h),
          _buildIllustration(),
          SizedBox(height: 16.h),
          _buildEndTimeCard(endTimeMs, pollData.id),
          SizedBox(height: 100.h), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildMainCard(QueryDocumentSnapshot pollData, String formattedDate,
      List<String> options, Map<String, dynamic> votes) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_White
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with date and toggle
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFEF9F27), // F_Yellow
                    letterSpacing: -0.36,
                  ),
                ),
                if (_isAdminOrPlanner)
                  Switch(
                    value: pollData['isActive'] ?? false,
                    activeColor: const Color(0xFF383A3F), // F_Text_H1
                    inactiveThumbColor: const Color(0xFFFFFFFF), // F_White
                    inactiveTrackColor:
                        const Color(0xFF7A869A), // F_Icon& Label_Text
                    onChanged: (value) => _togglePollStatus(pollData),
                  ),
              ],
            ),
          ),
          // Options list
          if (options.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'No options available',
                  style: TextStyle(
                    color: const Color(0xFF7A869A), // F_Icon& Label_Text
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (context, index) => Container(
                height: 1.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
              ),
              itemBuilder: (context, index) {
                return _buildVoteOption(
                  options[index],
                  pollData.id,
                  votes,
                  pollData['endTimeMillis'],
                  pollData['isActive'] ?? false,
                  index,
                );
              },
            ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildVoteOption(
      String option,
      String pollId,
      Map<String, dynamic> allVotes,
      int? endTimeMillis,
      bool isActive,
      int index) {
    final currentUser = AuthService().currentUser;
    final List<String> optionVotes = List<String>.from(allVotes[option] ?? []);
    final bool hasUserVoted =
        currentUser != null && optionVotes.contains(currentUser.uid);

    // Calculate total votes for percentage
    int totalVotes = 0;
    for (var entry in allVotes.entries) {
      totalVotes += (entry.value as List?)?.length ?? 0;
    }

    final double percentage =
        totalVotes > 0 ? (optionVotes.length / totalVotes) * 100 : 0;

    // Food images mapping
    const Map<String, String> foodImages = {
      'Egg Khichuri': 'assets/images/egg.png',
      'Beef & Rice': 'assets/images/beef.png',
      'Chicken Khichuri': 'assets/images/chicken.png',
    };

    print(
        'Vote option - Option: $option, isActive: $isActive, hasUserVoted: $hasUserVoted, currentUser: ${currentUser?.uid}');

    return GestureDetector(
      onTap: isActive && currentUser != null
          ? () {
              print('Vote option tapped: $option');
              _voteForOption(option, pollId);
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isActive ? Colors.transparent : Colors.grey.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Vote icon (plus or checkmark) - matching Figma design
                Container(
                  width: 16.w,
                  height: 16.h,
                  child: hasUserVoted
                      ? Icon(
                          Icons.check_circle,
                          color: const Color(0xFF383A3F), // F_Text_H1
                          size: 16.sp,
                        )
                      : Icon(
                          Icons.add_circle_outline,
                          color: isActive
                              ? const Color(0xFF7A869A) // F_Icon& Label_Text
                              : Colors.grey,
                          size: 16.sp,
                        ),
                ),
                SizedBox(width: 12.w),
                // Food image - using specific images or fallback
                Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF), // F_White
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: foodImages.containsKey(option)
                        ? Image.asset(
                            foodImages[option]!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFoodIcon(option),
                          )
                        : _buildFoodIcon(option),
                  ),
                ),
                SizedBox(width: 12.w),
                // Option name and vote count in the exact Figma layout
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF585F6A) // F_Text_H2
                                : Colors.grey,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${optionVotes.length} order',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                const Color(0xFF7A869A), // F_Icon& Label_Text
                            letterSpacing: -0.24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isActive)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Poll is closed',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (currentUser == null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Please log in to vote',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: 16.h),
            // Progress bar and percentage - exact Figma positioning
            Row(
              children: [
                SizedBox(width: 28.w), // Indent to align with text
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 3.h,
                        width: 283.w, // Fixed width from Figma
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      Container(
                        height: 3.h,
                        width: (percentage / 100) *
                            283.w, // Fixed width from Figma
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7686), // F_Red_2
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 20.w,
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF9F27), // F_Yellow
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalOrdersCard(Map<String, dynamic> votes) {
    int totalVotes = 0;
    for (var entry in votes.entries) {
      totalVotes += (entry.value as List?)?.length ?? 0;
    }

    return Container(
      width: 307.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_White
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 12.h,
            child: Icon(
              Icons.visibility_outlined,
              size: 12.sp,
              color: const Color(0xFF7A869A), // F_Icon& Label_Text
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Total Orders',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF585F6A), // F_Text_H2
              letterSpacing: -0.28,
            ),
          ),
          const Spacer(),
          Text(
            totalVotes.toString(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFF7686), // F_Red_2
              letterSpacing: -0.28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 158.h,
      width: 341.w,
      child: Center(
        child: Container(
          height: 118.h,
          width: 177.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              'assets/images/man_confused_lunch.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 60.sp,
                    color: const Color(0xFF7A869A)
                        .withOpacity(0.5), // F_Icon& Label_Text with opacity
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndTimeCard(int? endTimeMs, String pollId) {
    final DateTime? endTime = endTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeMs)
        : null;
    final String formattedEndTime = endTime != null
        ? '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} ${endTime.hour < 12 ? 'AM' : 'PM'}'
        : '10:00 AM';

    return Container(
      width: 345.w,
      height: 47.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_White
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _isAdminOrPlanner
            ? () => _showTimePickerDialog(context, endTime, pollId)
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                width: 29.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0), // Light red background
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.access_time,
                    color: const Color(0xFFFF3951), // F_Red_Bright
                    size: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'End Time',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A869A), // F_Icon& Label_Text
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      formattedEndTime,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF383A3F), // F_Text_H1
                        letterSpacing: -0.24,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isAdminOrPlanner)
                Icon(
                  Icons.keyboard_arrow_down,
                  color: const Color(0xFF7A869A), // F_Icon& Label_Text
                  size: 14.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _togglePollStatus(QueryDocumentSnapshot pollData) async {
    try {
      final currentStatus = pollData['isActive'] ?? false;
      final newStatus = !currentStatus;

      await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollData.id)
          .update({'isActive': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus
              ? 'Menu is now open for orders'
              : 'Menu is now closed for orders'),
          backgroundColor: newStatus
              ? const Color(0xFF4CAF50)
              : const Color(0xFFEF9F27), // Success green or warning yellow
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating menu: $e'),
          backgroundColor: const Color(0xFFFF3951), // F_Red_Bright
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];

        String dayWithSuffix = _getDayWithSuffix(day);
        String monthName = monthNames[month - 1];

        return '$dayWithSuffix $monthName, $year';
      }
    } catch (e) {}
    return dateString;
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  Future<void> _showTimePickerDialog(
      BuildContext context, DateTime? currentEndTime, String pollId) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentEndTime != null
          ? TimeOfDay.fromDateTime(currentEndTime)
          : TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final newEndTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      try {
        await FirebaseFirestore.instance
            .collection('polls')
            .doc(pollId)
            .update({'endTimeMillis': newEndTime.millisecondsSinceEpoch});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('End time updated to ${picked.format(context)}'),
            backgroundColor: const Color(0xFF4CAF50), // Success green
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating end time: $e'),
            backgroundColor: const Color(0xFFFF3951), // F_Red_Bright
          ),
        );
      }
    }
  }

  Widget _buildFoodIcon(String option) {
    // Map food names to appropriate icons
    IconData iconData = Icons.restaurant;
    if (option.toLowerCase().contains('egg')) {
      iconData = Icons.egg_outlined;
    } else if (option.toLowerCase().contains('beef') ||
        option.toLowerCase().contains('meat')) {
      iconData = Icons.dining_outlined;
    } else if (option.toLowerCase().contains('chicken')) {
      iconData = Icons.set_meal_outlined;
    }

    return Center(
      child: Icon(
        iconData,
        color: const Color(0xFF7A869A), // F_Icon& Label_Text
        size: 20.sp,
      ),
    );
  }

  Future<void> _voteForOption(String option, String pollId) async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to vote'),
          backgroundColor: Color(0xFFFF3951), // F_Red_Bright
        ),
      );
      return;
    }

    print('Attempting to vote for: $option by user: ${currentUser.uid}');

    try {
      final pollRef =
          FirebaseFirestore.instance.collection('polls').doc(pollId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final pollSnapshot = await transaction.get(pollRef);

        if (!pollSnapshot.exists) {
          throw Exception('Poll not found');
        }

        final data = pollSnapshot.data() as Map<String, dynamic>;
        print('Poll data: $data');

        // Initialize votes structure if it doesn't exist
        Map<String, dynamic> currentVotes =
            Map<String, dynamic>.from(data['votes'] ?? {});

        // Get all available options from the poll
        final List<String> allOptions =
            List<String>.from(data['options'] ?? []);

        // Initialize empty vote arrays for all options if they don't exist
        for (String optionKey in allOptions) {
          if (!currentVotes.containsKey(optionKey)) {
            currentVotes[optionKey] = <String>[];
          }
        }

        print('Current votes before update: $currentVotes');

        // Remove user's previous vote from all options
        for (String optionKey in currentVotes.keys) {
          final List<String> voters =
              List<String>.from(currentVotes[optionKey] ?? []);
          voters.remove(currentUser.uid);
          currentVotes[optionKey] = voters;
        }

        // Add user's vote to the selected option
        final List<String> optionVoters =
            List<String>.from(currentVotes[option] ?? []);
        if (!optionVoters.contains(currentUser.uid)) {
          optionVoters.add(currentUser.uid);
          currentVotes[option] = optionVoters;
        }

        print('Current votes after update: $currentVotes');

        // Update the document with the new votes
        transaction.update(pollRef, {'votes': currentVotes});
      });

      print('Vote successfully cast for $option');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voted for $option'),
          backgroundColor: const Color(0xFF4CAF50), // Success green
        ),
      );
    } catch (e) {
      print('Error voting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error voting: $e'),
          backgroundColor: const Color(0xFFFF3951), // F_Red_Bright
        ),
      );
    }
  }

  // ...existing methods...
}
