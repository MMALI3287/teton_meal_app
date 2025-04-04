import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/vote_option.dart';
import 'package:teton_meal_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:teton_meal_app/message_stream.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

    // Initialize message handling
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
    // Get options and votes from poll data
    final options = List<String>.from(pollData['options'] ?? []);
    final votes = pollData['votes'] as Map<String, dynamic>? ?? {};
    final question = pollData['question'] as String? ?? 'Unknown Poll Question';
    final date = pollData['date'] as String? ?? 'Unknown Date';

    // Find user's vote
    String selectedOption = "Did not vote";
    for (String option in votes.keys) {
      final votersList = votes[option] as List?;
      if (votersList != null && votersList.contains(userId)) {
        selectedOption = option;
        break;
      }
    }

    // Create canvas and set up painting
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 500));

    // Background with gradient
    final rect = Rect.fromLTWH(0, 0, 400, 500);
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

    // Header rectangle
    final headerPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 80), headerPaint);

    // Draw divider line
    final dividerPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(20, 82), const Offset(380, 82), dividerPaint);

    // Draw receipt background
    final receiptPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final receiptRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 100, 360, 350),
      const Radius.circular(12),
    );
    canvas.drawRRect(receiptRect, receiptPaint);

    // Draw receipt border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(receiptRect, borderPaint);

    // Text styles
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    final subtitleStyle = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 16,
    );

    final headerStyle = TextStyle(
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

    // Draw app title
    final appTitleSpan = TextSpan(text: "TETON MEAL APP", style: titleStyle);
    final appTitlePainter = TextPainter(
      text: appTitleSpan,
      textDirection: TextDirection.ltr,
    );
    appTitlePainter.layout(maxWidth: 360);
    appTitlePainter.paint(canvas, const Offset(20, 20));

    // Draw receipt title
    final receiptSpan = TextSpan(text: "Lunch Receipt", style: subtitleStyle);
    final receiptPainter = TextPainter(
      text: receiptSpan,
      textDirection: TextDirection.ltr,
    );
    receiptPainter.layout(maxWidth: 360);
    receiptPainter.paint(canvas, const Offset(20, 50));

    // Draw date
    final dateSpan = TextSpan(text: "Date: $date", style: detailStyle);
    final datePainter = TextPainter(
      text: dateSpan,
      textDirection: TextDirection.ltr,
    );
    datePainter.layout(maxWidth: 360);
    datePainter.paint(canvas, const Offset(40, 120));

    // Draw menu title
    final menuSpan = TextSpan(text: "Menu:", style: headerStyle);
    final menuPainter = TextPainter(
      text: menuSpan,
      textDirection: TextDirection.ltr,
    );
    menuPainter.layout(maxWidth: 360);
    menuPainter.paint(canvas, const Offset(40, 160));

    // Draw menu question
    final questionSpan = TextSpan(text: question, style: bodyStyle);
    final questionPainter = TextPainter(
      text: questionSpan,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    );
    questionPainter.layout(maxWidth: 320);
    questionPainter.paint(canvas, const Offset(40, 190));

    // Draw separator line
    canvas.drawLine(
      const Offset(40, 250),
      const Offset(360, 250),
      Paint()..color = Colors.white.withOpacity(0.5),
    );

    // Draw order title
    final orderTitleSpan = TextSpan(text: "Your Order:", style: headerStyle);
    final orderTitlePainter = TextPainter(
      text: orderTitleSpan,
      textDirection: TextDirection.ltr,
    );
    orderTitlePainter.layout(maxWidth: 360);
    orderTitlePainter.paint(canvas, const Offset(40, 280));

    // Draw selected option
    final selectedSpan = TextSpan(text: selectedOption, style: bodyStyle);
    final selectedPainter = TextPainter(
      text: selectedSpan,
      textDirection: TextDirection.ltr,
    );
    selectedPainter.layout(maxWidth: 320);
    selectedPainter.paint(canvas, const Offset(40, 320));

    // Draw thank you message
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

    // Convert to image
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
        title: const Text('Today\'s Lunch Menu'),
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Today\'s Menu',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Today\'s Lunch Menu',
                      style: TextStyle(color: theme.colorScheme.primary)),
                  content: const Text(
                    'Place your lunch order by selecting one of the available options. '
                    'You can change your selection at any time before ordering closes. '
                    '\n\nOnce ordering is complete, you can view your lunch receipt by '
                    'tapping the "View Receipt" button.',
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Got it',
                          style: TextStyle(color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
            stream: FirebaseFirestore.instance
                .collection('polls')
                .where('isActive', isEqualTo: true)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _generateLunchReceipt,
        icon: _isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.receipt_long),
        label: Text(_isLoading ? 'Loading...' : 'View Receipt'),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = pollData.data() as Map<String, dynamic>;

    final String question = data['question'] ?? 'No Question';
    final String date = data['date'] ?? 'No Date';
    final int? endTimeMs = data['endTimeMillis'];
    final List<String> options = List<String>.from(data['options'] ?? []);
    final Map<String, dynamic> votes = data['votes'] ?? {};

    // Format end time
    final DateTime? endTime = endTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(endTimeMs)
        : null;

    final String formattedEndTime = endTime != null
        ? '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}'
        : 'Unknown';

    // Calculate time remaining
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
          // Header with poll question, date and timer
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

          // Divider with shadow effect
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

          // Poll options list
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
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
                      );
                    },
                  ),
              ],
            ),
          ),

          // Footer with total orders count
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
    // Calculate total votes
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
