import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/vote_option.dart';
import 'package:flutter/foundation.dart';
import 'package:teton_meal_app/services/message_stream.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Menus/dialogs/create_poll_dialog.dart';
import 'package:teton_meal_app/Styles/colors.dart';

class VotesPage extends StatefulWidget {
  const VotesPage({super.key});

  @override
  State<VotesPage> createState() => _VotesPageState();

  String _formatTime(int? endTimeMillis) {
    if (endTimeMillis == null) return 'unknown time';
    final date = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _VotesPageState extends State<VotesPage>
    with SingleTickerProviderStateMixin {
  String _lastMessage = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Helper method to check if current user is admin or planner
  bool get _isAdminOrPlanner {
    final userRole = AuthService().currentUser?.role;
    return userRole == 'Admin' || userRole == 'Planner';
  }

  // Helper method to check if current user is diner
  bool get _isDiner {
    final userRole = AuthService().currentUser?.role;
    return userRole == 'Diner';
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

    _initializeMessageHandling();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeMessageHandling() {
    messageStreamController.listen((message) {
      setState(() {
        if (message.notification != null) {
          _lastMessage = 'Received a notification message:'
              '\nTitle=${message.notification?.title},'
              '\nBody=${message.notification?.body},'
              '\nData=${message.data}';
        } else {
          _lastMessage = 'Received a data message: ${message.data}';
        }
      });
    });
  }

  Future<QueryDocumentSnapshot?> _getLatestDeactivatedPoll() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('polls')
          .where('isActive', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
    } catch (e) {
      print("Error fetching deactivated poll: $e");
    }
    return null;
  }

  Future<Uint8List> _generateTokenImage(
      Map<String, dynamic> pollData, String userId) async {
    final options = List<String>.from(pollData['options'] ?? []);
    final votes = pollData['votes'] as Map<String, dynamic>? ?? {};
    final question = pollData['question'] as String? ?? 'Unknown Poll Question';
    final date = pollData['date'] as String? ?? 'Unknown Date';

    String selectedOption = "Did not vote";
    for (String option in votes.keys) {
      final votersList = votes[option] as List?;
      if (votersList != null && votersList.contains(userId)) {
        selectedOption = option;
        break;
      }
    }

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 500));

    const rect = Rect.fromLTWH(0, 0, 400, 500);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1565C0).withOpacity(0.9),
        const Color(0xFF1976D2).withOpacity(0.8),
      ],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final headerPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 80), headerPaint);

    final dividerPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(20, 82), const Offset(380, 82), dividerPaint);

    final receiptPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final receiptRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 100, 360, 350),
      const Radius.circular(12),
    );
    canvas.drawRRect(receiptRect, receiptPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(receiptRect, borderPaint);

    const titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    final subtitleStyle = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 16,
    );

    const headerStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    final bodyStyle = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 18,
    );

    final detailStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 16,
    );

    final appTitleSpan = TextSpan(text: "TETON MEAL APP", style: titleStyle);
    final appTitlePainter = TextPainter(
      text: appTitleSpan,
      textDirection: TextDirection.ltr,
    );
    appTitlePainter.layout(maxWidth: 360);
    appTitlePainter.paint(canvas, const Offset(20, 20));

    final receiptSpan = TextSpan(text: "Lunch Receipt", style: subtitleStyle);
    final receiptPainter = TextPainter(
      text: receiptSpan,
      textDirection: TextDirection.ltr,
    );
    receiptPainter.layout(maxWidth: 360);
    receiptPainter.paint(canvas, const Offset(20, 50));

    final dateSpan = TextSpan(text: "Date: $date", style: detailStyle);
    final datePainter = TextPainter(
      text: dateSpan,
      textDirection: TextDirection.ltr,
    );
    datePainter.layout(maxWidth: 360);
    datePainter.paint(canvas, const Offset(40, 120));

    final menuSpan = TextSpan(text: "Menu:", style: headerStyle);
    final menuPainter = TextPainter(
      text: menuSpan,
      textDirection: TextDirection.ltr,
    );
    menuPainter.layout(maxWidth: 360);
    menuPainter.paint(canvas, const Offset(40, 160));

    final questionSpan = TextSpan(text: question, style: bodyStyle);
    final questionPainter = TextPainter(
      text: questionSpan,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    );
    questionPainter.layout(maxWidth: 320);
    questionPainter.paint(canvas, const Offset(40, 190));

    canvas.drawLine(
      const Offset(40, 250),
      const Offset(360, 250),
      Paint()..color = Colors.white.withOpacity(0.5),
    );

    final orderTitleSpan = TextSpan(text: "Your Order:", style: headerStyle);
    final orderTitlePainter = TextPainter(
      text: orderTitleSpan,
      textDirection: TextDirection.ltr,
    );
    orderTitlePainter.layout(maxWidth: 360);
    orderTitlePainter.paint(canvas, const Offset(40, 280));

    final selectedSpan = TextSpan(text: selectedOption, style: bodyStyle);
    final selectedPainter = TextPainter(
      text: selectedSpan,
      textDirection: TextDirection.ltr,
    );
    selectedPainter.layout(maxWidth: 320);
    selectedPainter.paint(canvas, const Offset(40, 320));

    final thanksSpan = TextSpan(
      text: "Thank you for dining with us!",
      style: detailStyle.copyWith(fontStyle: FontStyle.italic),
    );
    final thanksPainter = TextPainter(
      text: thanksSpan,
      textDirection: TextDirection.ltr,
    );
    thanksPainter.layout(maxWidth: 320);
    thanksPainter.paint(canvas, const Offset(40, 380));

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 500);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showTokenDialog(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(imageData),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLoadingToast() {
    Fluttertoast.showToast(
      msg: "Loading your lunch receipt...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.blue.withOpacity(0.9),
      textColor: Colors.white,
    );
  }

  Future<void> _generateLunchReceipt() async {
    setState(() => _isLoading = true);

    try {
      _showLoadingToast();
      final pollData = await _getLatestDeactivatedPoll();

      if (pollData != null) {
        final userId = AuthService().currentUser?.uid;
        if (userId == null) {
          Fluttertoast.showToast(
            msg: "Please sign in to view your lunch receipt",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).colorScheme.error,
            textColor: Colors.white,
          );
          return;
        }

        final imageData = await _generateTokenImage(
            pollData.data() as Map<String, dynamic>, userId);

        Fluttertoast.showToast(
          msg: "Lunch receipt generated!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        _showTokenDialog(context, imageData);
      } else {
        Fluttertoast.showToast(
          msg: "No completed lunch orders found",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error generating receipt: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.h, // Set custom height using ScreenUtil
        titleSpacing: 8.w, // Add left padding to title
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h), // Add vertical padding
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.background,
            ],
          ),
        ),
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
      // Removed floatingReceipt button to prevent overlap with bottom nav
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
          const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Menu',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t load the lunch menu. Please try again later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${error.toString()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
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
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant,
              color: Colors.grey[400],
              size: 72,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Lunch Menu',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'There are no active lunch polls at the moment. Check back later for today\'s menu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollsList(List<QueryDocumentSnapshot> polls) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: polls.length,
      itemBuilder: (context, index) {
        try {
          final poll = polls[index];
          return PollCard(pollData: poll);
        } catch (e) {
          print('Error building poll card: $e');
          return SizedBox(
            height: 100,
            child: Card(
              child: Center(
                child: Text('Error loading menu item: $e'),
              ),
            ),
          );
        }
      },
    );
  }
}

class PollCard extends StatelessWidget {
  final QueryDocumentSnapshot pollData;

  const PollCard({
    super.key,
    required this.pollData,
  });

  // Helper method to check if current user is admin or planner
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

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus
              ? 'Menu is now open for orders'
              : 'Menu is now closed for orders'),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating menu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = pollData.data() as Map<String, dynamic>;

    final String question = data['question'] ?? 'No Question';
    final String date = data['date'] ?? 'No Date';
    final int? endTimeMs = data['endTimeMillis'];
    final List<String> options = List<String>.from(data['options'] ?? []);
    final Map<String, dynamic> votes = data['votes'] ?? {};

    final DateTime? endTime = endTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeMs)
        : null;

    final String formattedEndTime = endTime != null
        ? '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}'
        : 'Unknown';

    final now = DateTime.now();
    final bool isPollActive = endTime != null && endTime.isAfter(now);
    final difference =
        endTime != null ? endTime.difference(now) : const Duration(minutes: 0);
    final hoursRemaining = difference.inHours;
    final minutesRemaining = difference.inMinutes % 60;
    final String timeRemainingText = isPollActive
        ? 'Closes in ${hoursRemaining > 0 ? '$hoursRemaining hr ' : ''}${minutesRemaining} min'
        : 'Ordering closed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPollActive
                            ? Colors.white.withOpacity(0.2)
                            : Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPollActive ? Icons.timer : Icons.timer_off,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeRemainingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Until $formattedEndTime',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menu Options',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (_isAdminOrPlanner)
                        Switch(
                          value: pollData['isActive'] ?? false,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (value) => _togglePollStatus(context),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (options.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No options available',
                        style: TextStyle(
                          color: Colors.grey[600],
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              'Total Orders:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            totalVotes.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
