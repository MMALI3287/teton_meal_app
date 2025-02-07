import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MenusPage extends StatefulWidget {
  const MenusPage({super.key});

  @override
  _MenusPageState createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  bool _isGridView = true;
  final Map<String, bool> _expandedCategories = {};
  Map<DateTime, List<QueryDocumentSnapshot>> _events = {};
  DateTime _selectedDay = DateTime.now();

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
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
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.calendar_today : Icons.grid_view),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: _isGridView ? _buildGridView() : _buildCalendarView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreatePollDialog(),
          );
        },
        child: const Icon(Icons.add),
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
        final Map<String, Map<String, List<QueryDocumentSnapshot>>>
            categorizedPolls = {};

        for (var poll in polls) {
          final date = DateTime.parse(poll['date']);
          final year = date.year.toString();
          final month = DateFormat('MMMM').format(date);

          if (!categorizedPolls.containsKey(year)) {
            categorizedPolls[year] = {};
          }
          if (!categorizedPolls[year]!.containsKey(month)) {
            categorizedPolls[year]![month] = [];
          }
          categorizedPolls[year]![month]!.add(poll);
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

        final polls = snapshot.data!.docs;
        _events = {};

        for (var poll in polls) {
          final date = DateTime.parse(poll['date']);
          final day = DateTime(date.year, date.month, date.day);
          if (!_events.containsKey(day)) {
            _events[day] = [];
          }
          _events[day]!.add(poll);
        }

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => _events[day] ?? [],
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
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.twoWeeks: '2 weeks',
                CalendarFormat.week: 'Week',
              },
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
    final polls = _events[_selectedDay] ?? [];
    if (polls.isEmpty) {
      return const Center(child: Text('No polls for this date'));
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
        title: const Text('Polls by Date'),
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
        SnackBar(content: Text('Error updating poll: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pollData['date'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: pollData['isActive'],
                  onChanged: (value) => _togglePollStatus(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(pollData['question']),
            const SizedBox(height: 8),
            ...pollData['options']
                .map<Widget>(
                  (option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $option'),
                  ),
                )
                .toList(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollVotesPage(pollData: pollData),
                      ),
                    );
                  },
                  child: const Text('View votes'),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditPollDialog(pollData: pollData),
                    );
                  },
                  child: const Text('Edit'),
                ),
              ],
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
        const SnackBar(content: Text('Vote removed successfully')),
      );

      await _fetchPollData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing vote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pollSnapshot == null) {
      return const Center(child: Text('Error loading poll data'));
    }

    final votes = pollSnapshot!['votes'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            pollSnapshot!['question'],
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...votes.entries.map((entry) {
            String option = entry.key;
            List<dynamic> optionVotes = entry.value;

            return ExpansionTile(
              title: Text(option),
              subtitle: Text('${optionVotes.length} votes'),
              children: optionVotes.map<Widget>((voterId) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(voterId)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    String displayName = userData?['displayName'] ??
                        userData?['email'] ??
                        'Unknown User';

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(displayName),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeVote(context, voterId, option),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }).toList(),
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
    final formattedDate = DateFormat('MM/dd/yy - EEEE').format(now);
    _questionController.text = '$formattedDate - Food menu';
    _selectedMeals.addAll(['Beef Khichuri', 'Fried Rice']);
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String creatorName = user.displayName ?? user.email ?? user.uid;

      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, _selectedTime.hour,
          _selectedTime.minute);
      final endTimeMillis = endTime.millisecondsSinceEpoch;

      final List<String> finalOptions = _selectedMeals.map((meal) {
        if (meal == 'Custom') {
          int index = _getCustomControllerIndex(_selectedMeals.indexOf(meal));
          return _customOptionControllers[index].text;
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
        'date': DateTime.now().toString().split(' ')[0],
        'endTimeMillis': endTimeMillis,
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating poll: $e')),
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
      _selectedMeals.add(option);
      if (option == 'Custom') {
        _customOptionControllers.add(TextEditingController());
      }
    });
  }

  void _removeOption(int index) {
    setState(() {
      if (_selectedMeals[index] == 'Custom') {
        _customOptionControllers.removeAt(_getCustomControllerIndex(index));
      }
      _selectedMeals.removeAt(index);
    });
  }

  int _getCustomControllerIndex(int optionIndex) {
    int customCount = 0;
    for (int i = 0; i < optionIndex; i++) {
      if (_selectedMeals[i] == 'Custom') customCount++;
    }
    return customCount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create New Poll',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a question' : null,
                ),
                const SizedBox(height: 16),
                ...List.generate(_selectedMeals.length, (index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMeals[index],
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                border: const UnderlineInputBorder(),
                              ),
                              items: _mealOptions.map((String meal) {
                                return DropdownMenuItem<String>(
                                  value: meal,
                                  child: Text(meal),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (_selectedMeals[index] == 'Custom') {
                                    _customOptionControllers.removeAt(
                                        _getCustomControllerIndex(index));
                                  }
                                  _selectedMeals[index] = value!;
                                  if (value == 'Custom') {
                                    _customOptionControllers.insert(
                                        _getCustomControllerIndex(index),
                                        TextEditingController());
                                  }
                                });
                              },
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please select an option'
                                  : null,
                            ),
                          ),
                          if (_selectedMeals.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeOption(index),
                            ),
                        ],
                      ),
                      if (_selectedMeals[index] == 'Custom')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: _customOptionControllers[
                                _getCustomControllerIndex(index)],
                            decoration: const InputDecoration(
                              labelText: 'Custom Option',
                              border: UnderlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter a custom option'
                                : null,
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('End Time:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _selectTime(context),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _addOption('Beef Khichuri'),
                  child: const Text('Add Option'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _createPoll,
                      child: const Text('Create'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating poll: $e')),
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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Poll',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a question' : null,
              ),
              const SizedBox(height: 16),
              ...List.generate(_optionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const UnderlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an option'
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('End Time:'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text(_selectedTime.format(context)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _optionControllers.add(TextEditingController());
                  });
                },
                child: const Text('Add Option'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _updatePoll,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
