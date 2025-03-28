import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:teton_meal_app/services/auth_service.dart";
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MenusPage extends StatefulWidget {
  const MenusPage({super.key});

  @override
  _MenusPageState createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> with TickerProviderStateMixin {
  bool _isGridView = true;
  final Map<String, bool> _expandedCategories = {};
  Map<DateTime, List<QueryDocumentSnapshot>> _events = {};
  DateTime _selectedDay = DateTime.now();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();

    // Setup animation controller for FAB
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.title ?? 'New update'),
          ),
        );
      }
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
    Fluttertoast.showToast(
      msg: _isGridView ? "Switched to Calendar View" : "Switched to List View",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      _expandedCategories[category] = !(_expandedCategories[category] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lunch Menu'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _isGridView ? Icons.calendar_month : Icons.grid_view,
                  key: ValueKey<bool>(_isGridView),
                ),
              ),
              onPressed: _toggleView,
              tooltip: _isGridView
                  ? 'Switch to Calendar View'
                  : 'Switch to List View',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: _isGridView ? _buildGridView() : _buildCalendarView(),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const CreatePollDialog(),
            );
          },
          icon: const Icon(Icons.restaurant_menu),
          label: const Text('Create Menu'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('polls')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get all polls
        final polls = snapshot.data!.docs;

        // Sort polls by active status first, then by createdAt date
        polls.sort((a, b) {
          // First sort by active status
          final aActive = a['isActive'] as bool;
          final bActive = b['isActive'] as bool;

          if (aActive != bActive) {
            // Active polls first
            return aActive ? -1 : 1;
          }

          // Then sort by createdAt date
          final aCreatedAt =
              (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bCreatedAt =
              (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          // Sort descending (newer first)
          return bCreatedAt.compareTo(aCreatedAt);
        });

        final Map<String, Map<String, List<QueryDocumentSnapshot>>>
            categorizedPolls = {};

        for (var poll in polls) {
          try {
            // Parse date safely handling both formats (YYYY-MM-DD and DD/MM/YYYY)
            final dateStr = poll['date'] as String;
            DateTime date;

            if (dateStr.contains('/')) {
              // DD/MM/YYYY format
              final parts = dateStr.split('/');
              if (parts.length == 3) {
                try {
                  date = DateTime(
                    int.parse(parts[2]), // Year
                    int.parse(parts[1]), // Month
                    int.parse(parts[0]), // Day
                  );
                } catch (e) {
                  // If there's an error parsing, use current date as fallback
                  print('Error parsing date $dateStr: $e');
                  date = DateTime.now();
                }
              } else {
                // If format doesn't have exactly 3 parts, use current date
                date = DateTime.now();
              }
            } else {
              // YYYY-MM-DD format (old format)
              try {
                date = DateTime.parse(dateStr);
              } catch (e) {
                // If there's an error parsing, use current date as fallback
                print('Error parsing date $dateStr: $e');
                date = DateTime.now();
              }
            }

            final year = date.year.toString();
            final month = DateFormat('MMMM').format(date);

            if (!categorizedPolls.containsKey(year)) {
              categorizedPolls[year] = {};
            }
            if (!categorizedPolls[year]!.containsKey(month)) {
              categorizedPolls[year]![month] = [];
            }
            categorizedPolls[year]![month]!.add(poll);
          } catch (e) {
            print('Error processing poll: $e');
            // Continue to next poll if there's an error with this one
          }
        }

        final now = DateTime.now();
        final currentYear = now.year.toString();
        final currentMonth = DateFormat('MMMM').format(now);
        final currentCategory = '$currentYear-$currentMonth';

        return ListView(
          children: categorizedPolls.entries.map((yearEntry) {
            return ExpansionTile(
              title: Text(yearEntry.key),
              initiallyExpanded: yearEntry.key == currentYear,
              children: yearEntry.value.entries.map((monthEntry) {
                final category = '${yearEntry.key}-${monthEntry.key}';
                return ExpansionTile(
                  title: Text(monthEntry.key),
                  initiallyExpanded: _expandedCategories[category] ??
                      category == currentCategory,
                  onExpansionChanged: (expanded) => _toggleCategory(category),
                  children: monthEntry.value.map((poll) {
                    return MenuPollCard(pollData: poll);
                  }).toList(),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('polls')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get all polls
        final polls = snapshot.data!.docs;

        // Sort polls by active status first, then by createdAt date
        polls.sort((a, b) {
          // First sort by active status
          final aActive = a['isActive'] as bool;
          final bActive = b['isActive'] as bool;

          if (aActive != bActive) {
            // Active polls first
            return aActive ? -1 : 1;
          }

          // Then sort by createdAt date
          final aCreatedAt =
              (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bCreatedAt =
              (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          // Sort descending (newer first)
          return bCreatedAt.compareTo(aCreatedAt);
        });

        _events = {};

        for (var poll in polls) {
          try {
            // Parse date safely handling both formats (YYYY-MM-DD and DD/MM/YYYY)
            final dateStr = poll['date'] as String;
            DateTime date;

            if (dateStr.contains('/')) {
              // DD/MM/YYYY format
              final parts = dateStr.split('/');
              if (parts.length == 3) {
                try {
                  date = DateTime(
                    int.parse(parts[2]), // Year
                    int.parse(parts[1]), // Month
                    int.parse(parts[0]), // Day
                  );
                } catch (e) {
                  // If there's an error parsing, use current date as fallback
                  print('Error parsing date $dateStr: $e');
                  date = DateTime.now();
                }
              } else {
                // If format doesn't have exactly 3 parts, use current date
                date = DateTime.now();
              }
            } else {
              // YYYY-MM-DD format (old format)
              try {
                date = DateTime.parse(dateStr);
              } catch (e) {
                // If there's an error parsing, use current date as fallback
                print('Error parsing date $dateStr: $e');
                date = DateTime.now();
              }
            }

            final day = DateTime(date.year, date.month, date.day);

            if (!_events.containsKey(day)) {
              _events[day] = [];
            }
            _events[day]!.add(poll);
          } catch (e) {
            print('Error processing poll: $e');
            // Continue to next poll if there's an error with this one
          }
        }

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                final compareDay = DateTime(day.year, day.month, day.day);
                return _events[compareDay] ?? [];
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildPollsListForSelectedDay(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPollsListForSelectedDay() {
    final selectedDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    final polls = _events[selectedDate] ?? [];

    if (polls.isEmpty) {
      return const Center(child: Text('No lunch menu available for this date'));
    }

    return ListView.builder(
      itemCount: polls.length,
      itemBuilder: (context, index) {
        return MenuPollCard(pollData: polls[index]);
      },
    );
  }
}

class PollsByDatePage extends StatelessWidget {
  final List<QueryDocumentSnapshot> polls;

  const PollsByDatePage({super.key, required this.polls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders by Date'),
      ),
      body: ListView.builder(
        itemCount: polls.length,
        itemBuilder: (context, index) {
          return MenuPollCard(pollData: polls[index]);
        },
      ),
    );
  }
}

class MenuPollCard extends StatelessWidget {
  final QueryDocumentSnapshot pollData;

  const MenuPollCard({super.key, required this.pollData});

  Future<void> _togglePollStatus(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollData.id)
          .update({'isActive': !pollData['isActive']});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating menu: $e')),
      );
    }
  }

  Future<void> _deletePoll(BuildContext context) async {
    // Show confirmation dialog before deleting
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this menu? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollData.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting menu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = pollData['isActive'] ?? false;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive
              ? theme.colorScheme.secondary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: isActive ? 1 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and active switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.secondary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isActive
                            ? theme.colorScheme.secondary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        pollData['date'],
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? theme.colorScheme.secondary
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  activeColor: theme.colorScheme.secondary,
                  onChanged: (value) => _togglePollStatus(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Menu question
            Text(
              pollData['question'],
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 24),

            // Menu options
            ...pollData['options']
                .map<Widget>(
                  (option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 16),
            const Divider(height: 8),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PollVotesPage(pollData: pollData),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.visibility_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: Text(
                      'View Orders',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                  // Show Edit button for active polls, Delete button for inactive polls
                  isActive
                      ? TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  EditPollDialog(pollData: pollData),
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: theme.colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            'Edit',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.secondary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () => _deletePoll(context),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

    // Calculate vote counts for stats
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
          // Header Card with Menu details
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

          // Orders list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Order summary card
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
                                'Order Summary',
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_totalVotes orders',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._voteCounts.entries.map((entry) {
                            final percentage = _totalVotes > 0
                                ? (entry.value / _totalVotes * 100).round()
                                : 0;
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
                                      ),
                                    ),
                                    Text(
                                      '${entry.value} ($percentage%)',
                                      style: theme.textTheme.bodyMedium,
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
                          '${optionVotes.length}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: optionVotes.map<Widget>((voterId) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(voterId)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const ListTile(
                                leading: CircularProgressIndicator(),
                                title: Text('Loading...'),
                              );
                            }

                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            String displayName = userData?['displayName'] ??
                                userData?['email'] ??
                                'Unknown User';

                            // Get first letter for avatar
                            String initial = displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.secondary
                                    .withOpacity(0.2),
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(displayName),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () =>
                                    _removeVote(context, voterId, option),
                                tooltip: 'Remove Order',
                              ),
                            );
                          },
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

class CreatePollDialog extends StatefulWidget {
  const CreatePollDialog({super.key});

  @override
  CreatePollDialogState createState() => CreatePollDialogState();
}

class CreatePollDialogState extends State<CreatePollDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _customOptionControllers = [];
  final List<String> _mealOptions = [
    'Beef Khichuri',
    'Fried Rice',
    'Fried Egg with Rice',
    'Custom',
  ];
  final List<String> _selectedMeals = [];
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yy - EEEE').format(now);
    _questionController.text = '$formattedDate - Food menu';
    _selectedMeals.addAll(['Beef Khichuri', 'Fried Rice']);
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;

    // Check for duplicates in all selected options (including both dropdown and custom fields)
    final List<String> allOptions = [];
    int customIndex = 0;

    for (int i = 0; i < _selectedMeals.length; i++) {
      String optionValue;
      if (_selectedMeals[i] == 'Custom') {
        optionValue = _customOptionControllers[customIndex].text;
        customIndex++;
      } else {
        optionValue = _selectedMeals[i];
      }

      if (allOptions.contains(optionValue)) {
        // Show dialog alert instead of toast (so it will be visible on top of the menu dialog)
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Duplicate Options'),
              content: const Text(
                  'Duplicate meal options found. Please ensure all options are unique.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
      allOptions.add(optionValue);
    }

    try {
      final user = AuthService().currentUser;
      if (user == null) return;

      String creatorName = user.displayName ?? user.email ?? user.uid;

      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, _selectedTime.hour,
          _selectedTime.minute);
      final endTimeMillis = endTime.millisecondsSinceEpoch;

      // Fixed: track custom index separately for correct mapping
      int customIndex = 0;
      final List<String> finalOptions = _selectedMeals.map((meal) {
        if (meal == 'Custom') {
          final text = _customOptionControllers[customIndex].text;
          customIndex++;
          return text;
        }
        return meal;
      }).toList();

      await FirebaseFirestore.instance.collection('polls').add({
        'question': _questionController.text,
        'options': finalOptions,
        'votes': {},
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': {
          'uid': user.uid,
          'name': creatorName,
        },
        'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
        'endTimeMillis': endTimeMillis,
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error creating menu: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addOption(String option) {
    setState(() {
      if (option == 'Custom') {
        // Add a new controller with empty text
        _customOptionControllers.add(TextEditingController());
      }
      _selectedMeals.add(option);
    });
  }

  void _removeOption(int index) {
    setState(() {
      if (_selectedMeals[index] == 'Custom') {
        // Remove the corresponding controller
        int controllerIndex = _getCustomControllerIndex(index);
        _customOptionControllers[controllerIndex].dispose();
        _customOptionControllers.removeAt(controllerIndex);
      }
      _selectedMeals.removeAt(index);
    });
  }

  int _getCustomControllerIndex(int optionIndex) {
    // Instead of counting custom options before the current index,
    // just return the index of this custom option in the list
    int customIndex = 0;
    for (int i = 0; i <= optionIndex; i++) {
      if (_selectedMeals[i] == 'Custom') {
        if (i == optionIndex) {
          return customIndex;
        }
        customIndex++;
      }
    }
    return customIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant_menu,
                        color: theme.colorScheme.secondary),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Menu',
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Menu Title',
                    prefixIcon: Icon(Icons.title_outlined,
                        color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter a menu title'
                      : null,
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: theme.colorScheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.dinner_dining,
                                color: theme.colorScheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Menu Options',
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_selectedMeals.length, (index) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.2)),
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(11),
                                          bottomLeft: Radius.circular(11),
                                        ),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedMeals[index],
                                        decoration: InputDecoration(
                                          labelText: 'Option ${index + 1}',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          border: InputBorder.none,
                                        ),
                                        items: _mealOptions.map((String meal) {
                                          return DropdownMenuItem<String>(
                                            value: meal,
                                            child: Text(meal),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            if (_selectedMeals[index] ==
                                                'Custom') {
                                              _customOptionControllers.removeAt(
                                                  _getCustomControllerIndex(
                                                      index));
                                            }
                                            _selectedMeals[index] = value!;
                                            if (value == 'Custom') {
                                              _customOptionControllers.insert(
                                                  _getCustomControllerIndex(
                                                      index),
                                                  TextEditingController());
                                            }
                                          });
                                        },
                                        validator: (value) =>
                                            value?.isEmpty ?? true
                                                ? 'Please select an option'
                                                : null,
                                        dropdownColor: Colors.white,
                                      ),
                                    ),
                                    if (_selectedMeals.length > 2)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.redAccent),
                                        onPressed: () => _removeOption(index),
                                      ),
                                  ],
                                ),
                              ),
                              if (_selectedMeals[index] == 'Custom')
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 16, left: 36),
                                  child: TextFormField(
                                    controller: _customOptionControllers[
                                        _getCustomControllerIndex(index)],
                                    decoration: InputDecoration(
                                      labelText: 'Custom Option',
                                      hintText: 'Enter your custom menu option',
                                      prefixIcon: Icon(Icons.edit,
                                          color: theme.colorScheme.secondary),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Please enter a custom option'
                                        : null,
                                  ),
                                ),
                            ],
                          );
                        }),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => _addOption('Beef Khichuri'),
                            icon: Icon(Icons.add_circle_outline,
                                color: theme.colorScheme.secondary),
                            label: Text('Add Option',
                                style: TextStyle(
                                    color: theme.colorScheme.secondary)),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.secondary.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // End Time Selection
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'End Time:',
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _selectTime(context),
                          icon: Icon(Icons.access_time_filled,
                              size: 16, color: theme.colorScheme.primary),
                          label: Text(
                            _selectedTime.format(context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            shape: StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _createPoll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Create Menu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _customOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class EditPollDialog extends StatefulWidget {
  final QueryDocumentSnapshot pollData;

  const EditPollDialog({super.key, required this.pollData});

  @override
  EditPollDialogState createState() => EditPollDialogState();
}

class EditPollDialogState extends State<EditPollDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();

    _questionController =
        TextEditingController(text: widget.pollData['question']);
    _optionControllers = List.generate(
      (widget.pollData['options'] as List).length,
      (index) => TextEditingController(
        text: (widget.pollData['options'] as List)[index],
      ),
    );

    final endTimeMillis = widget.pollData['endTimeMillis'] as int;
    final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
    _selectedTime = TimeOfDay(hour: endTime.hour, minute: endTime.minute);
  }

  Future<void> _updatePoll() async {
    if (!_formKey.currentState!.validate()) return;

    // Check for duplicate options
    final List<String> allOptions = [];
    for (var controller in _optionControllers) {
      String optionValue = controller.text;

      if (allOptions.contains(optionValue)) {
        // Show dialog alert for duplicate options
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Duplicate Options'),
              content: const Text(
                  'Duplicate meal options found. Please ensure all options are unique.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
      allOptions.add(optionValue);
    }

    try {
      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, _selectedTime.hour,
          _selectedTime.minute);
      final endTimeMillis = endTime.millisecondsSinceEpoch;

      await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollData.id)
          .update({
        'question': _questionController.text,
        'options':
            _optionControllers.map((controller) => controller.text).toList(),
        'endTimeMillis': endTimeMillis,
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        // Use dialog instead of SnackBar to ensure visibility
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error updating menu: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A poll must have at least 2 options')),
      );
      return;
    }

    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: theme.colorScheme.secondary),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Menu',
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Menu Title',
                    prefixIcon: Icon(Icons.title_outlined,
                        color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter a menu title'
                      : null,
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  color: theme.colorScheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.restaurant_menu,
                                color: theme.colorScheme.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Menu Options',
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_optionControllers.length, (index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      bottomLeft: Radius.circular(11),
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextFormField(
                                      controller: _optionControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Option ${index + 1}',
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16),
                                      ),
                                      validator: (value) =>
                                          value?.isEmpty ?? true
                                              ? 'Please enter an option'
                                              : null,
                                    ),
                                  ),
                                ),
                                if (_optionControllers.length > 2)
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.redAccent),
                                    onPressed: () => _removeOption(index),
                                    tooltip: 'Remove option',
                                  ),
                              ],
                            ),
                          );
                        }),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _optionControllers.add(TextEditingController());
                              });
                            },
                            icon: Icon(Icons.add_circle_outline,
                                color: theme.colorScheme.secondary),
                            label: Text('Add Option',
                                style: TextStyle(
                                    color: theme.colorScheme.secondary)),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.secondary.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // End Time Selection
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'End Time:',
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _selectTime(context),
                          icon: Icon(Icons.access_time_filled,
                              size: 16, color: theme.colorScheme.primary),
                          label: Text(
                            _selectedTime.format(context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updatePoll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
