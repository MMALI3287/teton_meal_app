import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/vote_option.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/dialogs/create_poll_dialog.dart';
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
      appBar: AppBar(
        toolbarHeight: 50.h,
        titleSpacing: 8.w,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'Today\'s Lunch Menu',
            style: TextStyle(
              color: AppColors.fTextH1,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        centerTitle: false,
        elevation: 2,
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.fTextH1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        actions: _isAdminOrPlanner
            ? [
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const CreatePollDialog(),
                          );
                        },
                        child: Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: AppColors.fRedBright,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2.92.r,
                                offset: Offset(0, 2.92.h),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child:
                              Icon(Icons.add, color: Colors.white, size: 18.sp),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: 60.w,
                        child: Text(
                          'New Menu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.fTextH2,
                            fontSize: 10.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: FadeTransition(
          opacity: _fadeAnimation,
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
                return _buildErrorWidget(snapshot.error);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingWidget();
              }

              final polls = snapshot.data?.docs ?? [];

              if (polls.isEmpty) {
                return _buildEmptyWidget();
              }

              return _buildPollsList(polls);
            },
          ),
        ),
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
              'There are no active lunch polls at the moment. Check back later for today\'s menu.',
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

  Widget _buildPollsList(List<QueryDocumentSnapshot> polls) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              try {
                final poll = polls[index];
                return PollCard(pollData: poll);
              } catch (e) {
                print('Error building poll card: $e');
                return SizedBox(
                  height: 100.h,
                  child: Card(
                    child: Center(
                      child: Text('Error loading menu item: $e'),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        if (polls.isNotEmpty) _buildBottomSection(polls.first),
      ],
    );
  }

  Widget _buildBottomSection(QueryDocumentSnapshot pollData) {
    final data = pollData.data() as Map<String, dynamic>;
    final int? endTimeMs = data['endTimeMillis'];
    final DateTime? endTime = endTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeMs)
        : null;
    final String formattedEndTime = endTime != null
        ? '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} AM'
        : '10:00 AM';

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 150.h),
      height: 50.h,
      width: 345.w,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _isAdminOrPlanner
            ? () => _showTimePickerDialog(context, endTime, pollData.id)
            : null,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.fNameBoxPink,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.fRedBright,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: GestureDetector(
                onTap: _isAdminOrPlanner
                    ? () => _showTimePickerDialog(context, endTime, pollData.id)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'End Time',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formattedEndTime,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isAdminOrPlanner)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.tertiaryText,
                  size: 20.sp,
                ),
              ),
          ],
        ),
      ),
    );
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
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating end time: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class PollCard extends StatelessWidget {
  final QueryDocumentSnapshot pollData;

  const PollCard({
    super.key,
    required this.pollData,
  });

  bool get _isAdminOrPlanner {
    final userRole = AuthService().currentUser?.role;
    return userRole == 'Admin' || userRole == 'Planner';
  }

  Future<void> _togglePollStatus(BuildContext context) async {
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
          backgroundColor: newStatus ? AppColors.success : AppColors.warning,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating menu: $e'),
          backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    final data = pollData.data() as Map<String, dynamic>;

    final String date = data['date'] ?? 'No Date';

    final String formattedDate = _formatDate(date);
    final int? endTimeMs = data['endTimeMillis'];
    final List<String> options = List<String>.from(data['options'] ?? []);
    final Map<String, dynamic> votes = data['votes'] ?? {};

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isAdminOrPlanner)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 15.r,
                          offset: Offset(2.w, 2.h),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Switch(
                      value: pollData['isActive'] ?? false,
                      activeColor: AppColors.white,
                      activeTrackColor: AppColors.primaryText,
                      inactiveThumbColor: AppColors.white,
                      inactiveTrackColor: AppColors.tertiaryText,
                      onChanged: (value) => _togglePollStatus(context),
                    ),
                  ),
              ],
            ),
          ),
          if (options.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'No options available',
                  style: TextStyle(
                    color: AppColors.tertiaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return VoteOption(
                  option: options[index],
                  pollId: pollData.id,
                  allVotes: votes,
                  endTimeMillis: endTimeMs,
                  isActive: pollData['isActive'] ?? false,
                );
              },
            ),
          Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: _buildTotalVotesRow(votes),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalVotesRow(Map<String, dynamic> votes) {
    int totalVotes = 0;
    for (var entry in votes.entries) {
      totalVotes += (entry.value as List?)?.length ?? 0;
    }

    return Row(
      children: [
        Icon(
          Icons.visibility_outlined,
          size: 20.sp,
          color: AppColors.tertiaryText,
        ),
        SizedBox(width: 8.w),
        Text(
          'Total Orders',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
        const Spacer(),
        Text(
          totalVotes.toString(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.fRedBright,
          ),
        ),
      ],
    );
  }
}
