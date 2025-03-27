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
import 'package:teton_meal_app/message_stream.dart'; // Add this import

class VotesPage extends StatefulWidget {
  const VotesPage({super.key});

  @override
  State<VotesPage> createState() => _VotesPageState();
}

class _VotesPageState extends State<VotesPage> {
  String _lastMessage = '';
  _VotesPageState() {
    messageStreamController.listen((message) {
      // Use the exported controller
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
    final question = pollData['question'] as String? ?? 'Unknown Menu';

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
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 400));

    // Background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 400), bgPaint);

    // Text styles
    final titleStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final bodyStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
    );

    // Draw title (menu question)
    final titleSpan = TextSpan(text: question, style: titleStyle);
    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: 380);
    titlePainter.paint(canvas, const Offset(10, 20));

    // Draw vote information
    final voteSpan = TextSpan(
      text: '\n\nYour Vote: $selectedOption',
      style: bodyStyle,
    );
    final votePainter = TextPainter(
      text: voteSpan,
      textDirection: TextDirection.ltr,
    );
    votePainter.layout(maxWidth: 380);
    votePainter.paint(canvas, Offset(10, titlePainter.height + 40));

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 400);
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showTokenDialog(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your Vote Token'),
          content: Transform(
            transform: Matrix4.rotationX(3.14159), // Flip the image vertically
            alignment: Alignment.center,
            child: Image.memory(imageData),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('polls')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error in StreamBuilder: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final polls = snapshot.data?.docs ?? [];
            print('Fetched ${polls.length} active polls'); // Debug print

            if (polls.isEmpty) {
              return const Center(child: Text('No active polls'));
            }

            return ListView.builder(
              itemCount: polls.length,
              itemBuilder: (context, index) {
                try {
                  final poll = polls[index];
                  print('Poll data: ${poll.data()}'); // Debug print

                  return PollCard(pollData: poll);
                } catch (e) {
                  print('Error building poll card: $e');
                  return const SizedBox();
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pollData = await _getLatestDeactivatedPoll();

          if (pollData != null) {
            final userId = AuthService().currentUser?.uid;
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please sign in to generate a token')),
              );
              return;
            }

            final imageData = await _generateTokenImage(
                pollData.data() as Map<String, dynamic>, userId);

            _showTokenDialog(context, imageData);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No deactivated polls available')),
            );
          }
        },
        child: const Icon(Icons.token),
      ),
    );
  }
}

class PollCard extends StatelessWidget {
  final QueryDocumentSnapshot pollData;

  const PollCard({super.key, required this.pollData});

  @override
  Widget build(BuildContext context) {
    try {
      final data = pollData.data() as Map<String, dynamic>;
      final createdBy = data['createdBy'] as Map<String, dynamic>? ?? {};
      final options = List<String>.from(data['options'] ?? []);
      final votes = data['votes'] as Map<String, dynamic>? ?? {};
      final creatorName = createdBy['name']?.toString() ?? 'Unknown';

      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      creatorName.isNotEmpty
                          ? creatorName.substring(0, 1).toUpperCase()
                          : '?',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(creatorName),
                      Text(
                        data['date']?.toString() ?? 'No date',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                data['question']?.toString() ?? 'No question',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...options
                  .map((option) => VoteOption(
                        option: option,
                        pollId: pollData.id,
                        allVotes: votes,
                      ))
                  .toList(),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error in PollCard: $e');
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Error loading poll'),
        ),
      );
    }
  }
}
