import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/confirmation_delete_dialog.dart';

class PollVotesPage extends StatefulWidget {
  final QueryDocumentSnapshot pollData;

  const PollVotesPage({super.key, required this.pollData});

  @override
  _PollVotesPageState createState() => _PollVotesPageState();
}

class _PollVotesPageState extends State<PollVotesPage> {
  DocumentSnapshot? pollSnapshot;
  bool _isLoading = true;
  Map<String, int> _voteCounts = {};
  int _totalVotes = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, bool> _expandedItems =
      {}; // Track expanded state for each menu item

  @override
  void initState() {
    super.initState();
    _fetchPollData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _userCache[userId] = userData;
        return userData;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
    return null;
  }

  bool _matchesSearch(Map<String, dynamic>? userData, String userId) {
    if (_searchQuery.isEmpty) return true;

    final query = _searchQuery.toLowerCase();

    if (userData != null) {
      final name = (userData['displayName'] ?? userData['name'] ?? '')
          .toString()
          .toLowerCase();
      final email = (userData['email'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          userId.toLowerCase().contains(query);
    }

    return userId.toLowerCase().contains(query);
  }

  // Check if a menu item has any users matching the search query
  Future<bool> _hasMatchingUsers(List<dynamic> optionVotes) async {
    if (_searchQuery.isEmpty) return true;

    for (final userId in optionVotes) {
      final userData = await _getUserData(userId);
      if (_matchesSearch(userData, userId)) {
        return true;
      }
    }
    return false;
  }

  // Filter menu items to only show those with matching users
  Future<List<MapEntry<String, List<dynamic>>>> _getFilteredVotes(
      Map<String, dynamic> votes) async {
    final filteredEntries = <MapEntry<String, List<dynamic>>>[];

    for (final entry in votes.entries) {
      final hasMatching = await _hasMatchingUsers(entry.value);
      if (hasMatching) {
        filteredEntries.add(MapEntry(entry.key, entry.value));
      }
    }

    return filteredEntries;
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
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date: $e');
      }
    }
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

  Future<void> _fetchPollData() async {
    pollSnapshot = await FirebaseFirestore.instance
        .collection('polls')
        .doc(widget.pollData.id)
        .get();

    if (pollSnapshot != null) {
      final votes = pollSnapshot!['votes'] as Map<String, dynamic>;
      _voteCounts = {};
      _totalVotes = 0;

      votes.forEach((option, voters) {
        final count = (voters as List).length;
        _voteCounts[option] = count;
        _totalVotes += count;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeVote(
      BuildContext context, String voterId, String option) async {
    try {
      final pollRef = FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollData.id);

      await pollRef.update({
        'votes.$option': FieldValue.arrayRemove([voterId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order removed successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      await _fetchPollData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing order: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, String userName, String userId, String option) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDeleteDialog(
          title: 'Remove Order',
          message: 'Are you sure you want to remove',
          itemName: '$userName\'s order',
          onDelete: () {
            _removeVote(context, userId, option);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.fWhiteBackground,
        appBar: AppBar(
          backgroundColor: AppColors.fWhiteBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.fTextH1,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.fWhite,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Details',
                style: TextStyle(
                  color: AppColors.fTextH1,
                  fontSize: 18.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.fRedBright,
          ),
        ),
      );
    }

    if (pollSnapshot == null) {
      return Scaffold(
        backgroundColor: AppColors.fWhiteBackground,
        appBar: AppBar(
          backgroundColor: AppColors.fWhiteBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.fTextH1,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.fWhite,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Details',
                style: TextStyle(
                  color: AppColors.fTextH1,
                  fontSize: 18.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Text(
            'Error loading menu data',
            style: TextStyle(
              color: AppColors.fRed2,
              fontSize: 16.sp,
            ),
          ),
        ),
      );
    }

    final votes = pollSnapshot!['votes'] as Map<String, dynamic>;
    final dateText = pollSnapshot!['date'] as String;

    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.fWhiteBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.fTextH1,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.fWhite,
                  size: 18.sp,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Order Details',
                  style: TextStyle(
                    color: AppColors.fTextH1,
                    fontSize: 18.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 36.w), // Balance the left close button
          ],
        ),
      ),
      body: Column(
        children: [
          // Date header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              _formatDate(dateText),
              style: TextStyle(
                color: AppColors.fYellow,
                fontSize: 14.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Search bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fTextH1.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search with employee name here',
                      hintStyle: TextStyle(
                        color: AppColors.fIconAndLabelText,
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: TextStyle(
                      color: AppColors.fTextH1,
                      fontSize: 14.sp,
                      fontFamily: 'Inter',
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
          ),
          // Orders list
          Expanded(
            child: votes.isEmpty
                ? Center(
                    child: Text(
                      'No orders yet',
                      style: TextStyle(
                        color: AppColors.fIconAndLabelText,
                        fontSize: 16.sp,
                        fontFamily: 'Inter',
                      ),
                    ),
                  )
                : FutureBuilder<List<MapEntry<String, List<dynamic>>>>(
                    future: _getFilteredVotes(votes),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.fRedBright,
                          ),
                        );
                      }

                      final filteredVotes = snapshot.data ?? [];

                      if (filteredVotes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64.sp,
                                color: AppColors.fIconAndLabelText,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No Results Found',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.fTextH1,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'No menu items have users matching your search',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.fIconAndLabelText,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: filteredVotes.map((entry) {
                          String option = entry.key;
                          List<dynamic> optionVotes = entry.value;
                          return _buildOrderSection(option, optionVotes);
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(String option, List<dynamic> optionVotes) {
    // Initialize collapsed state for new items
    if (!_expandedItems.containsKey(option)) {
      _expandedItems[option] = false; // Start collapsed
    }

    // Auto-expand when searching to show filtered users, or use manual state when not searching
    final isExpanded =
        _searchQuery.isNotEmpty || (_expandedItems[option] ?? false);

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.fTextH1.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food item header (clickable) - Only allow manual toggle when not searching
          InkWell(
            onTap: _searchQuery.isEmpty
                ? () {
                    setState(() {
                      _expandedItems[option] =
                          !(_expandedItems[option] ?? false);
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Food icon
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: AppColors.fYellow,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.fWhite,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Food name
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: AppColors.fTextH1,
                        fontSize: 16.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Order count badge and dropdown arrow
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.fRedBright.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.fRedBright.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${optionVotes.length} order${optionVotes.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: AppColors.fRedBright,
                            fontSize: 12.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Only show dropdown arrow when not searching
                      if (_searchQuery.isEmpty) ...[
                        SizedBox(width: 8.w),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.fIconAndLabelText,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (isExpanded) ...[
            // Progress bar with percentage on the right
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Progress bar
                  Expanded(
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.fLineaAndLabelBox,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _totalVotes > 0
                            ? optionVotes.length / _totalVotes
                            : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.fRedBright,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Percentage
                  Text(
                    '${_totalVotes > 0 ? ((optionVotes.length / _totalVotes) * 100).toStringAsFixed(0) : 0}%',
                    style: TextStyle(
                      color: AppColors.fRedBright,
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Divider
            if (optionVotes.isNotEmpty)
              Container(
                height: 1.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                color: AppColors.fLineaAndLabelBox,
              ),
            // User list
            ...optionVotes.asMap().entries.map((entry) {
              final index = entry.key;
              final userId = entry.value;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(userId),
                builder: (context, snapshot) {
                  final userData = snapshot.data;
                  final userName = userData?['displayName'] ??
                      userData?['name'] ??
                      'Unknown User';
                  // Filter based on search
                  if (!_matchesSearch(userData, userId)) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        // User avatar
                        Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: _getAvatarColor(index),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: AppColors.fWhite,
                                fontSize: 14.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // User name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  color: AppColors.fTextH1,
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (userData != null && userData['email'] != null)
                                Text(
                                  userData['email'],
                                  style: TextStyle(
                                    color: AppColors.fIconAndLabelText,
                                    fontSize: 12.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Remove button
                        InkWell(
                          onTap: () {
                            _showDeleteConfirmation(
                                context, userName, userId, option);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.fRedBright.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color:
                                    AppColors.fRedBright.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: AppColors.fRedBright,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      AppColors.fNameBoxGreen,
      AppColors.fNameBoxYellow,
      AppColors.fNameBoxPink,
      AppColors.fIconAndLabelText,
    ];
    return colors[index % colors.length];
  }
}
