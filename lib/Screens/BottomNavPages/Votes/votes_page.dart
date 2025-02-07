// votes_page.dart
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/vote_option.dart';
import 'package:teton_meal_app/Screens/BottomNavPages/Votes/voters_dialog.dart';

class VotesPage extends StatelessWidget {
  const VotesPage({super.key});

  Future<QueryDocumentSnapshot?> _getLatestDeactivatedPoll() async {
    try {
      // Fetch the most recent deactivated poll (isActive: false)
      final snapshot = await FirebaseFirestore.instance
          .collection('polls')
          .where('isActive', isEqualTo: false)
          .orderBy('createdAt',
              descending: true) // Assuming 'date' is a field with the timestamp
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
    } catch (e) {
      print("Error fetching deactivated poll: $e");
    }
    return null; // Return null if no poll is found
  }

  Future<Uint8List> _generateTokenImage(
      Map<String, dynamic> pollData, String userId) async {
    // Get the user's vote from the poll
    final options = List<String>.from(pollData['options'] ?? []);
    final votes = pollData['votes'] as Map<String, dynamic>? ?? {};

    // Find the option the user voted for
    String selectedOption = "No vote"; // Default message if no vote found
    for (var option in options) {
      if ((votes[option] as List?)?.contains(userId) == true) {
        selectedOption = option;
        break;
      }
    }

    // Create an image (as a placeholder, we'll use a simple text-based image)
    final recorder = PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(400, 400)));

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(color: Colors.black, fontSize: 16);
    final textSpan = TextSpan(
        text: "Your Vote Token:\n\nMeal Option: $selectedOption",
        style: textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));

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
          content: Image.memory(imageData), // Show the generated token image
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .where('isActive', isEqualTo: true)
            .snapshots(), // Removed orderBy temporarily for testing
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in StreamBuilder: ${snapshot.error}'); // Debug print
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final polls = snapshot.data?.docs ?? [];

          if (polls.isEmpty) {
            return const Center(child: Text('No active polls'));
          }

          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              try {
                final poll = polls[index];
                // Safely access data with null checks
                return PollCard(pollData: poll);
              } catch (e) {
                print('Error building poll card: $e'); // Debug print
                return const SizedBox(); // Skip invalid polls
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Fetch the latest deactivated poll
          final pollData = await _getLatestDeactivatedPoll();

          if (pollData != null) {
            // Get the current user
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please sign in to generate a token')),
              );
              return;
            }

            // Generate the token image for the current user
            final imageData = await _generateTokenImage(
                pollData.data() as Map<String, dynamic>, userId);

            // Show the token image in a dialog
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
      // Safely access data with null checks
      final data = pollData.data() as Map<String, dynamic>;
      final createdBy = data['createdBy'] as Map<String, dynamic>? ?? {};
      final options = List<String>.from(data['options'] ?? []);
      final votes = data['votes'] as Map<String, dynamic>? ?? {};

      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poll creator and date
              Row(
                children: [
                  CircleAvatar(
                    child: Text(createdBy['name']
                            ?.toString()
                            .substring(0, 1)
                            .toUpperCase() ??
                        '?'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(createdBy['name']?.toString() ?? 'Unknown'),
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
              // Options list
              // Inside PollCard build method, replace the options mapping with:
              ...options
                  .map((option) => VoteOption(
                        option: option,
                        pollId: pollData.id,
                        allVotes: votes, // Pass the entire votes map
                      ))
                  .toList(),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error in PollCard: $e'); // Debug print
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Error loading poll'),
        ),
      );
    }
  }
}
