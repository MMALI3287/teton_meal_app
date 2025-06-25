import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../services/auth_service.dart';

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

  final List<String> _mealOptions = [
    'Beef Khichuri',
    'Fried Rice',
    'Fried Egg with Rice',
    'Custom',
  ];

  late List<String> _optionTypes;

  @override
  void initState() {
    super.initState();

    _questionController =
        TextEditingController(text: widget.pollData['question']);

    final options = widget.pollData['options'] as List;
    _optionControllers = List.generate(
      options.length,
      (index) => TextEditingController(text: options[index].toString()),
    );

    _optionTypes = List.generate(options.length, (index) {
      final option = options[index].toString();
      return _mealOptions.contains(option) && option != 'Custom'
          ? 'standard'
          : 'custom';
    });

    final endTimeMillis = widget.pollData['endTimeMillis'] as int;
    final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
    _selectedTime = TimeOfDay(hour: endTime.hour, minute: endTime.minute);
  }

  Future<void> _updatePoll() async {
    if (!_formKey.currentState!.validate()) return;

    final List<String> allOptions = [];
    for (var controller in _optionControllers) {
      if (allOptions.contains(controller.text)) {
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
      allOptions.add(controller.text);
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
        'options': _optionControllers.map((ctrl) => ctrl.text).toList(),
        'endTimeMillis': endTimeMillis,
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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

  void _toggleOptionType(int index, String type) {
    setState(() {
      _optionTypes[index] = type;

      if (type == 'standard') {
        _optionControllers[index].text = _mealOptions.first;
      }
    });
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
      _optionTypes.removeAt(index);
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
                          final isStandard = _optionTypes[index] == 'standard';
                          final currentText = _optionControllers[index].text;
                          final isExistingOption =
                              _mealOptions.contains(currentText) &&
                                  currentText != 'Custom';

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
                                    child: isStandard || isExistingOption
                                        ? DropdownButtonFormField<String>(
                                            value: isStandard
                                                ? currentText
                                                : _mealOptions.first,
                                            isDense: true,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              labelText: 'Option ${index + 1}',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 0),
                                            ),
                                            items: _mealOptions
                                                .where((m) => m != 'Custom')
                                                .map((String meal) {
                                              return DropdownMenuItem<String>(
                                                value: meal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.restaurant,
                                                      color: currentText == meal
                                                          ? theme.colorScheme
                                                              .primary
                                                          : Colors.grey[400],
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        meal,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: currentText ==
                                                                  meal
                                                              ? theme
                                                                  .colorScheme
                                                                  .primary
                                                              : Colors
                                                                  .grey[800],
                                                          fontWeight:
                                                              currentText ==
                                                                      meal
                                                                  ? FontWeight
                                                                      .bold
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
                                              _optionControllers[index].text =
                                                  value!;
                                            },
                                            validator: (value) =>
                                                value?.isEmpty ?? true
                                                    ? 'Please select an option'
                                                    : null,
                                            dropdownColor: Colors.white,
                                            icon: Icon(
                                              Icons.arrow_drop_down_circle,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            elevation: 8,
                                          )
                                        : TextFormField(
                                            controller:
                                                _optionControllers[index],
                                            decoration: InputDecoration(
                                                labelText:
                                                    'Custom Option ${index + 1}',
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.menu_book,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                  onPressed: () =>
                                                      _toggleOptionType(
                                                          index, 'standard'),
                                                  tooltip:
                                                      'Switch to standard options',
                                                )),
                                            validator: (value) =>
                                                value?.isEmpty ?? true
                                                    ? 'Please enter an option'
                                                    : null,
                                          ),
                                  ),
                                ),
                                if (isStandard || isExistingOption)
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () =>
                                        _toggleOptionType(index, 'custom'),
                                    tooltip: 'Switch to custom input',
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
                                _optionTypes.add('custom');
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
                        elevation: 0,
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
