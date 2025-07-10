import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/create_menu_screen.dart';
import 'package:teton_meal_app/app/app_theme.dart';

/*
 * DATABASE MIGRATION NOTE:
 * Existing polls in the database may not have the 'adminOverride' field.
 * The code safely handles this by using null-aware operators (?? false).
 * New polls created through the app will automatically include this field.
 * 
 * If needed, you can run this one-time migration in Firebase Console:
 * 
 * polls.where('adminOverride', '==', null).get().then(snapshot => {
 *   snapshot.docs.forEach(doc => {
 *     doc.ref.update({ adminOverride: false });
 *   });
 * });
 */

class VotesPage extends StatefulWidget {
  const VotesPage({super.key});

  @override
  State<VotesPage> createState() => _VotesPageState();
}

class _VotesPageState extends State<VotesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Vote optimization: cache and debouncing
  Timer? _voteTimer;
  final Map<String, String?> _pendingVotes = {}; // pollId -> optionVoted
  final Duration _votingDelay = const Duration(milliseconds: 300);
  final Set<String> _autoDisabledPolls =
      {}; // Track polls that have been auto-disabled
  final Set<String> _adminOverriddenPolls =
      {}; // Track polls manually overridden by admin

  bool get _isAdminOrPlanner {
    final userRole = AuthService().currentUser?.role;
    return userRole == 'Admin' || userRole == 'Planner';
  }

  bool get _canControlToggle {
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
    _voteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // F_fWhiteBackground
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
                      color: AppColors.fWhite,
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
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.fRedBright,
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
              color: AppColors.fRed2,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Menu',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.fRed2,
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
                    color: AppColors.fIconAndLabelText,
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
                backgroundColor: AppColors.fRedBright,
                foregroundColor: AppColors.fWhite,
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
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.fRedBright,
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
              color: AppColors.fIconAndLabelText,
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
                backgroundColor: AppColors.fRedBright,
                foregroundColor: AppColors.fWhite,
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

    return Column(
      children: [
        // Main scrollable content - takes up available space minus end time card
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                _buildMainCard(pollData, formattedDate, options, votes),
                SizedBox(height: 16.h),
                _buildIllustration(),
                SizedBox(
                    height: 20.h), // Reduced padding since card is now in flow
              ],
            ),
          ),
        ),
        // Fixed end time card at bottom with consistent spacing
        Container(
          margin: EdgeInsets.fromLTRB(
              16.w, 0, 16.w, 10.h), // Same horizontal margin and bottom space
          child: _buildEndTimeCard(endTimeMs, pollData.id),
        ),
      ],
    );
  }

  Widget _buildMainCard(QueryDocumentSnapshot pollData, String formattedDate,
      List<String> options, Map<String, dynamic> votes) {
    final data = pollData.data() as Map<String, dynamic>;
    final int? endTimeMs = data['endTimeMillis'];
    final bool isTimeUp =
        endTimeMs != null && DateTime.now().millisecondsSinceEpoch > endTimeMs;
    final bool isManuallyActive = data['isActive'] ?? false;
    final bool adminOverride = data['adminOverride'] ?? false;

    // Auto-disable toggle when time is up
    _autoDisableToggleIfTimeUp(pollData, isTimeUp, isManuallyActive);

    // For voting: allow if manually active AND (time not up OR admin override is set)
    final bool effectiveActiveState =
        isManuallyActive && (!isTimeUp || adminOverride);
    // For UI display: show time up message only if time is up AND toggle is off AND no admin override
    final bool showTimeUpMessage =
        isTimeUp && !isManuallyActive && !adminOverride;
    // Show admin override message if voting is active after time up due to admin override
    final bool showAdminOverrideMessage =
        isTimeUp && isManuallyActive && adminOverride;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_fWhite
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
            child: Column(
              children: [
                Row(
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
                    // Only show toggle for Admin and Planner users
                    if (_canControlToggle)
                      Switch(
                        value:
                            isManuallyActive, // Show the actual database state, not effective state
                        activeColor: const Color(0xFF383A3F), // F_Text_H1
                        inactiveThumbColor: const Color(0xFFFFFFFF), // F_fWhite
                        inactiveTrackColor:
                            const Color(0xFF7A869A), // F_Icon& Label_Text
                        onChanged: (value) => _togglePollStatus(
                            pollData, value), // Pass the new value
                      ),
                  ],
                ),
                // Time up indicator - show only when time has passed AND toggle is off AND no admin override
                if (showTimeUpMessage)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          color: const Color(0xFFFF3951), // F_Red_Bright
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Voting time has ended',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFFFF3951), // F_Red_Bright
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Admin override indicator - show when voting is extended by admin
                if (showAdminOverrideMessage)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: const Color(0xFF4CAF50), // Success green
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'Voting extended by admin - employees can still vote',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF4CAF50), // Success green
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Options list
          if (options.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: const Text(
                  'No options available',
                  style: TextStyle(
                    color: Color(0xFF7A869A), // F_Icon& Label_Text
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else ...[
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
                  effectiveActiveState, // Use effective state instead of direct isActive
                  index,
                );
              },
            ),
            // Add separator before Total Orders
            Container(
              height: 1.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
            ),
          ],
          // Total Orders section inside main card (always show)
          _buildTotalOrdersSection(votes),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive && currentUser != null
            ? () => _voteForOption(option, pollId)
            : null,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: hasUserVoted
                ? const Color(0xFFF0F8FF)
                : (isActive
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Vote icon with smooth animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey(hasUserVoted),
                      width: 16.w,
                      height: 16.h,
                      child: hasUserVoted
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF4CAF50),
                              size: 16.sp,
                            )
                          : Icon(
                              Icons.add_circle_outline,
                              color: isActive
                                  ? const Color(0xFF7A869A)
                                  : Colors.grey,
                              size: 16.sp,
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Food image
                  Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
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
                  // Option name and vote count
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
                                  ? const Color(0xFF585F6A)
                                  : Colors.grey,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: hasUserVoted
                                ? const Color(0xFFE8F5E8)
                                : const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${optionVotes.length} order${optionVotes.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: hasUserVoted
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF7A869A),
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
              // Animated progress bar
              Row(
                children: [
                  SizedBox(width: 28.w),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 3.h,
                          width: 283.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 3.h,
                          width: (percentage / 100) * 283.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7686),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 20.w,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        key: ValueKey(percentage),
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF9F27),
                          letterSpacing: -0.24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalOrdersSection(Map<String, dynamic> votes) {
    int totalVotes = 0;
    for (var entry in votes.entries) {
      totalVotes += (entry.value as List?)?.length ?? 0;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_fWhite
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
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
      height: 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_fWhite
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

  /*
   * DATABASE MIGRATION NOTE:
   * Existing polls in the database may not have the 'adminOverride' field.
   * The code safely handles this by using null-aware operators (?? false).
   * New polls created through the app will automatically include this field.
   * 
   * If needed, you can run this one-time migration in Firebase Console:
   * 
   * polls.where('adminOverride', '==', null).get().then(snapshot => {
   *   snapshot.docs.forEach(doc => {
   *     doc.ref.update({ adminOverride: false });
   *   });
   * });
   */

  // Auto-disable toggle when time expires
  void _autoDisableToggleIfTimeUp(
      QueryDocumentSnapshot pollData, bool isTimeUp, bool isManuallyActive) {
    final data = pollData.data() as Map<String, dynamic>;
    final bool adminOverride = data['adminOverride'] ?? false;

    // Don't auto-disable if:
    // 1. Admin has overridden this poll (database flag)
    // 2. Poll was already auto-disabled
    // 3. Time is not up
    // 4. Poll is already inactive
    if (isTimeUp &&
        isManuallyActive &&
        !adminOverride && // Check database adminOverride flag
        !_autoDisabledPolls.contains(pollData.id) &&
        !_adminOverriddenPolls.contains(pollData.id)) {
      // Mark as auto-disabled to prevent multiple calls
      _autoDisabledPolls.add(pollData.id);

      // Schedule the toggle to be disabled after the current build cycle
      // Add a small delay to prevent interference with manual toggles
      Future.delayed(const Duration(milliseconds: 100), () {
        // Double-check that admin hasn't manually overridden in the meantime
        if (!_adminOverriddenPolls.contains(pollData.id)) {
          _disablePollToggle(pollData.id);
        } else {
          // Remove from auto-disabled since admin has taken control
          _autoDisabledPolls.remove(pollData.id);
        }
      });
    }
  }

  Future<void> _disablePollToggle(String pollId) async {
    try {
      await FirebaseFirestore.instance.collection('polls').doc(pollId).update({
        'isActive': false,
        'adminOverride': false, // Clear admin override when auto-disabling
      });
    } catch (e) {
      // Remove from auto-disabled set on error so it can be retried
      _autoDisabledPolls.remove(pollId);
    }
  }

  Future<void> _togglePollStatus(
      QueryDocumentSnapshot pollData, bool newStatus) async {
    try {
      // Clear auto-disabled tracking immediately when admin manually toggles
      _autoDisabledPolls.remove(pollData.id);

      // Check if admin is enabling after time expiry
      final int? endTimeMs = pollData['endTimeMillis'];
      final bool isTimeUp = endTimeMs != null &&
          DateTime.now().millisecondsSinceEpoch > endTimeMs;

      // Prepare the update data
      Map<String, dynamic> updateData = {'isActive': newStatus};

      // Handle admin override logic
      if (newStatus && isTimeUp) {
        // Admin is enabling voting after time expiry - set admin override
        updateData['adminOverride'] = true;
        _adminOverriddenPolls.add(pollData.id);
      } else if (!newStatus) {
        // Admin is disabling voting - clear admin override
        updateData['adminOverride'] = false;
        _adminOverriddenPolls.remove(pollData.id);
      } else if (newStatus && !isTimeUp) {
        // Admin is enabling voting before time expiry - ensure no override flag
        updateData['adminOverride'] = false;
      }

      // Update the database with both isActive and adminOverride
      await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollData.id)
          .update(updateData);

      if (mounted) {
        String message = newStatus
            ? (isTimeUp
                ? 'Menu reopened with admin override - voting extended beyond end time'
                : 'Menu is now open for orders')
            : 'Menu is now closed for orders';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: newStatus
                ? const Color(0xFF4CAF50)
                : const Color(0xFFEF9F27), // Success green or warning yellow
            duration:
                Duration(milliseconds: isTimeUp && newStatus ? 3000 : 2000),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating menu: $e'),
            backgroundColor: const Color(0xFFFF3951), // F_Red_Bright
          ),
        );
      }
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

  // Optimized fast voting implementation
  Future<void> _voteForOption(String option, String pollId) async {
    final currentUser = AuthService().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to vote'),
          backgroundColor: Color(0xFFFF3951),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Check if there's a pending vote for this pollId
    if (_pendingVotes.containsKey(pollId)) {
      // If the pending vote is the same as the new vote, cancel the operation
      if (_pendingVotes[pollId] == option) return;
      // Otherwise, remove the pending vote (user is changing their vote)
      _pendingVotes.remove(pollId);
    }

    // Add or update the pending vote
    _pendingVotes[pollId] = option;

    // Cancel the previous timer if it exists
    _voteTimer?.cancel();

    // Start a new timer
    _voteTimer = Timer(_votingDelay, () async {
      try {
        // Use direct field update with FieldValue operations for speed
        final pollRef =
            FirebaseFirestore.instance.collection('polls').doc(pollId);

        // Get current poll data once
        final pollDoc = await pollRef.get();
        if (!pollDoc.exists) return;

        final data = pollDoc.data() as Map<String, dynamic>;
        final allOptions = List<String>.from(data['options'] ?? []);
        final currentVotes = Map<String, dynamic>.from(data['votes'] ?? {});

        // Find user's current vote
        String? currentUserVote;
        for (String optionKey in allOptions) {
          final voters = List<String>.from(currentVotes[optionKey] ?? []);
          if (voters.contains(currentUser.uid)) {
            currentUserVote = optionKey;
            break;
          }
        }

        // Prepare batch updates for atomic operation
        final batch = FirebaseFirestore.instance.batch();
        final updates = <String, dynamic>{};

        // Remove from previous option if exists
        if (currentUserVote != null && currentUserVote != option) {
          final prevVoters =
              List<String>.from(currentVotes[currentUserVote] ?? []);
          prevVoters.remove(currentUser.uid);
          updates['votes.$currentUserVote'] = prevVoters;
        }

        // Add to new option (or toggle off if same option)
        if (currentUserVote != option) {
          final newVoters = List<String>.from(currentVotes[option] ?? []);
          if (!newVoters.contains(currentUser.uid)) {
            newVoters.add(currentUser.uid);
          }
          updates['votes.$option'] = newVoters;
        }

        // Apply updates if any changes needed
        if (updates.isNotEmpty) {
          batch.update(pollRef, updates);
          await batch.commit();

          // Quick success feedback
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentUserVote == option
                  ? 'Vote removed'
                  : 'Voted for $option'),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(milliseconds: 800),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to vote. Please try again.'),
            backgroundColor: Color(0xFFFF3951),
            duration: Duration(seconds: 1),
          ),
        );
      } finally {
        // Remove the pollId from pending votes after the operation
        _pendingVotes.remove(pollId);
      }
    });
  }

  // ...existing methods...
}
