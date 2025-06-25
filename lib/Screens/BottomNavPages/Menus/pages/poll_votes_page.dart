import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchPollData();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lunch Orders'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (pollSnapshot == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lunch Orders'),
        ),
        body: Center(
          child: Text(
            'Error loading menu data',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }

    final votes = pollSnapshot!['votes'] as Map<String, dynamic>;
    final isActive = pollSnapshot!['isActive'] as bool;
    final dateText = pollSnapshot!['date'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Orders'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.secondary.withOpacity(0.1)
                              : theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: isActive
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'Active' : 'Inactive',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: isActive
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateText,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pollSnapshot!['question'],
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Orders: $_totalVotes',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_totalVotes > 0)
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Orders Distribution',
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_totalVotes ${_totalVotes == 1 ? 'order' : 'orders'}',
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._voteCounts.entries.map((entry) {
                            final percent = _totalVotes > 0
                                ? (entry.value / _totalVotes * 100)
                                    .toStringAsFixed(1)
                                : '0';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: theme.textTheme.bodyMedium!
                                            .copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${entry.value} (${percent}%)',
                                      style: theme.textTheme.bodySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _totalVotes > 0
                                        ? entry.value / _totalVotes
                                        : 0,
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                Text(
                  'Orders by Choice',
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (votes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...votes.entries.map((entry) {
                  String option = entry.key;
                  List<dynamic> optionVotes = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      childrenPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        option,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        '${optionVotes.length} ${optionVotes.length == 1 ? 'order' : 'orders'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          optionVotes.length.toString(),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: optionVotes.map<Widget>((voterId) {
                        return ListTile(
                          title: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(voterId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData &&
                                  snapshot.data!.exists) {
                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                return Text(
                                  userData['name'] ?? 'Unknown User',
                                  style: theme.textTheme.bodyMedium,
                                );
                              }
                              return Text(
                                voterId,
                                style: theme.textTheme.bodyMedium,
                              );
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () =>
                                _removeVote(context, voterId, option),
                            tooltip: 'Remove order',
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
