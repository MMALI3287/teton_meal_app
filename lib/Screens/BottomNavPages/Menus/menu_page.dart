import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/menu_poll_card.dart';
import 'dialogs/create_poll_dialog.dart';
import 'pages/polls_by_date_page.dart';
import "pages/poll_votes_page.dart";

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

        final polls = snapshot.data!.docs;

        polls.sort((a, b) {
          final aActive = a['isActive'] as bool;
          final bActive = b['isActive'] as bool;

          if (aActive != bActive) {
            return aActive ? -1 : 1;
          }

          final aCreatedAt =
              (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bCreatedAt =
              (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;

          return bCreatedAt.compareTo(aCreatedAt);
        });

        final Map<String, Map<String, List<QueryDocumentSnapshot>>>
            categorizedPolls = {};

        for (var poll in polls) {
          try {
            final dateStr = poll['date'] as String;
            DateTime date;

            if (dateStr.contains('/')) {
              final parts = dateStr.split('/');
              if (parts.length == 3) {
                try {
                  date = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                } catch (e) {
                  print('Error parsing date $dateStr: $e');
                  date = DateTime.now();
                }
              } else {
                date = DateTime.now();
              }
            } else {
              try {
                date = DateTime.parse(dateStr);
              } catch (e) {
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
          }
        }

        final now = DateTime.now();
        final currentYear = now.year.toString();
        final currentMonth = DateFormat('MMMM').format(now);
        final currentCategory = '$currentYear-$currentMonth';

        return ListView(
          padding: EdgeInsets.only(bottom: 80.h),
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

        final polls = snapshot.data!.docs;

        polls.sort((a, b) {
          final aActive = a['isActive'] as bool;
          final bActive = b['isActive'] as bool;

          if (aActive != bActive) {
            return aActive ? -1 : 1;
          }

          final aCreatedAt =
              (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final bCreatedAt =
              (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;

          return bCreatedAt.compareTo(aCreatedAt);
        });

        _events = {};

        for (var poll in polls) {
          try {
            final dateStr = poll['date'] as String;
            DateTime date;

            if (dateStr.contains('/')) {
              final parts = dateStr.split('/');
              if (parts.length == 3) {
                try {
                  date = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                } catch (e) {
                  print('Error parsing date $dateStr: $e');
                  date = DateTime.now();
                }
              } else {
                date = DateTime.now();
              }
            } else {
              try {
                date = DateTime.parse(dateStr);
              } catch (e) {
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
      padding: EdgeInsets.only(bottom: 80.h),
      itemCount: polls.length,
      itemBuilder: (context, index) {
        return MenuPollCard(pollData: polls[index]);
      },
    );
  }
}
