import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
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
    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    try {
      final userId = user.uid;

      String? previousOption;
      for (var entry in allVotes.entries) {
        if ((entry.value as List?)?.contains(userId) ?? false) {
          previousOption = entry.key;
          break;
        }
      }

      final hasVotedThisOption = previousOption == option;

      final pollRef =
          FirebaseFirestore.instance.collection('polls').doc(pollId);
      final batch = FirebaseFirestore.instance.batch();

      if (hasVotedThisOption) {
        batch.update(pollRef, {
          'votes.$option': FieldValue.arrayRemove([userId])
        });
      } else {
        if (previousOption != null) {
          batch.update(pollRef, {
            'votes.$previousOption': FieldValue.arrayRemove([userId])
          });
        }

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
    final user = AuthService().currentUser;
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
