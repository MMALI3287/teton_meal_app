import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        const SnackBar(content: Text('Please sign in to place your order')),
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
        SnackBar(content: Text('Unable to place order: $e')),
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

    return Card(
      elevation: hasVotedThisOption ? 2 : 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasVotedThisOption 
              ? Theme.of(context).colorScheme.primary 
              : Colors.grey.withOpacity(0.2),
          width: hasVotedThisOption ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _handleVote(context);
          if (!hasVotedThisOption) {
            Fluttertoast.showToast(
              msg: "Placing your order...",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  hasVotedThisOption ? Icons.check_circle : Icons.circle_outlined,
                  color: hasVotedThisOption 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: hasVotedThisOption ? FontWeight.bold : FontWeight.normal,
                    color: hasVotedThisOption 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasVotedThisOption 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$voteCount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasVotedThisOption 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
