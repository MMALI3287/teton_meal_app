import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VotersDialog extends StatefulWidget {
  final QueryDocumentSnapshot pollData;

  const VotersDialog({super.key, required this.pollData});

  @override
  _VotersDialogState createState() => _VotersDialogState();
}

class _VotersDialogState extends State<VotersDialog> {
  Future<void> _removeVote(String voterId, String option) async {
    try {
      final pollRef = FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollData.id);

      // Remove the vote for the user from the option
      await pollRef.update({
        'votes.$option': FieldValue.arrayRemove([voterId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing vote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> votes =
        widget.pollData['votes'] as Map<String, dynamic>;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vote Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('polls')
                    .doc(widget.pollData.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final updatedPollData = snapshot.data!;
                  Map<String, dynamic> updatedVotes =
                      updatedPollData['votes'] as Map<String, dynamic>;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.pollData['options'].length,
                    itemBuilder: (context, index) {
                      String option = widget.pollData['options'][index];
                      List<dynamic> optionVotes = updatedVotes[option] ?? [];

                      return ExpansionTile(
                        title: Text(option),
                        subtitle: Text('${optionVotes.length} votes'),
                        children: optionVotes.map<Widget>((voterId) {
                          // Fetch voter details from Firestore using the authentication UID
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection(
                                    'users') // Access the `users` collection
                                .doc(
                                    voterId) // Use the voter's UID as the document ID
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const ListTile(
                                  title: Text('Loading...'),
                                );
                              }

                              // Retrieve user details from Firestore
                              var userData = snapshot.data!.data()
                                  as Map<String, dynamic>?;

                              // Handle cases where user data might not exist
                              String displayName = userData?['displayName'] ??
                                  userData?['email'] ??
                                  'Unknown User';

                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(displayName),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeVote(voterId, option),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
