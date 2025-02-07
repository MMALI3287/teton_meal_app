import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VoteOption extends StatelessWidget {
  final String option;
  final String pollId;
  final Map<String, dynamic> allVotes;

  const VoteOption({
    super.key,
    required this.option,
    required this.pollId,
    required this.allVotes,
  });

  Future<void> _handleVote(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    try {
      final userId = user.uid;

      // Find the current option the user has voted for, if any
      String? previousOption;
      for (var entry in allVotes.entries) {
        if ((entry.value as List?)?.contains(userId) ?? false) {
          previousOption = entry.key;
          break;
        }
      }

      final hasVotedThisOption = previousOption == option;

      // Update the votes in Firestore
      final pollRef =
          FirebaseFirestore.instance.collection('polls').doc(pollId);
      final batch = FirebaseFirestore.instance.batch();

      if (hasVotedThisOption) {
        // Withdraw vote if the user clicks the same option again
        batch.update(pollRef, {
          'votes.$option': FieldValue.arrayRemove([userId])
        });
      } else {
        // Remove the previous vote, if any
        if (previousOption != null) {
          batch.update(pollRef, {
            'votes.$previousOption': FieldValue.arrayRemove([userId])
          });
        }

        // Register the new vote
        batch.update(pollRef, {
          'votes.$option': FieldValue.arrayUnion([userId])
        });
      }

      await batch.commit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final hasVotedThisOption = user != null &&
        (allVotes[option] != null &&
            (allVotes[option] as List).contains(user.uid));
    final voteCount = (allVotes[option] as List?)?.length ?? 0;

    return InkWell(
      onTap: () => _handleVote(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: hasVotedThisOption
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(
              hasVotedThisOption ? Icons.check_circle : Icons.circle_outlined,
              color: hasVotedThisOption ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(option)),
            Text('$voteCount'),
          ],
        ),
      ),
    );
  }
}
