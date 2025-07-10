import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/app/app_theme.dart';

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

      String creatorName = user.displayName ?? user.email;

      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, _selectedTime.hour,
          _selectedTime.minute);
      final endTimeMillis = endTime.millisecondsSinceEpoch;

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
        'votes': Map.fromIterables(
            finalOptions, finalOptions.map((_) => <String>[])),
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
        _customOptionControllers.add(TextEditingController());
      }
      _selectedMeals.add(option);
    });
  }

  void _removeOption(int index) {
    setState(() {
      if (_selectedMeals[index] == 'Custom') {
        int controllerIndex = _getCustomControllerIndex(index);
        _customOptionControllers[controllerIndex].dispose();
        _customOptionControllers.removeAt(controllerIndex);
      }
      _selectedMeals.removeAt(index);
    });
  }

  int _getCustomControllerIndex(int optionIndex) {
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
                                  color: AppColors.fWhite,
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
                                        isDense: true,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: 'Option ${index + 1}',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                          border: InputBorder.none,
                                        ),
                                        items: _mealOptions.map((String meal) {
                                          return DropdownMenuItem<String>(
                                            value: meal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  meal == 'Custom'
                                                      ? Icons.edit
                                                      : Icons.restaurant,
                                                  color: _selectedMeals[
                                                              index] ==
                                                          meal
                                                      ? theme
                                                          .colorScheme.primary
                                                      : Colors.grey[400],
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    meal,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: _selectedMeals[
                                                                  index] ==
                                                              meal
                                                          ? theme.colorScheme
                                                              .primary
                                                          : Colors.grey[800],
                                                      fontWeight:
                                                          _selectedMeals[
                                                                      index] ==
                                                                  meal
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                        dropdownColor: AppColors.fWhite,
                                        icon: Icon(
                                          Icons.arrow_drop_down_circle,
                                          color: theme.colorScheme.primary,
                                          size: 20,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        elevation: 8,
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
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'End Time:',
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _selectTime(context),
                          icon: Icon(Icons.access_time_filled,
                              size: 18, color: theme.colorScheme.primary),
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
                        foregroundColor: AppColors.fWhite,
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
