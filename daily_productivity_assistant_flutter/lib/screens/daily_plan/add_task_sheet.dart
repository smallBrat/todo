import 'package:flutter/material.dart';
import 'package:daily_productivity_assistant_client/daily_productivity_assistant_client.dart';
import 'package:daily_productivity_assistant_flutter/serverpod.dart';

/// Bottom sheet for creating multiple tasks at once
/// Features:
/// - Add multiple tasks with title, priority, duration, deadline
/// - Each task shows in a list with ability to edit/delete
/// - All tasks submitted together to backend
/// - Backend arranges them optimally
/// - Time selection respects backend work hours (9 AM - 9 PM)
class AddTaskSheet extends StatefulWidget {
  final DateTime selectedDate;

  const AddTaskSheet({
    super.key,
    required this.selectedDate,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _TaskToAdd {
  String title;
  String priority;
  int? estimatedDuration;
  DateTime? deadlineDate;
  bool isDueToday;
  DateTime? scheduledTime; // Now nullable for flexible tasks

  _TaskToAdd({
    required this.title,
    this.priority = 'medium',
    this.estimatedDuration,
    this.deadlineDate,
    this.isDueToday = true,
    this.scheduledTime, // No longer required
  });
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  // Work hours constants (from backend: 9 AM - 9 PM)
  static const int workDayStartHour = 9;
  static const int workDayEndHour = 21;

  // Controllers
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _durationController = TextEditingController();

  // State
  List<_TaskToAdd> _tasksToAdd = [];
  String _selectedPriority = 'medium';
  bool _isDueToday = true;
  DateTime? _deadlineDate;
  int? _estimatedDuration;
  bool _isSubmitting = false;
  bool _hasScheduledTime = false; // NEW: Toggle for scheduled time
  late DateTime _scheduledDate;
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _scheduledDate = widget.selectedDate;
    _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Ensures a DateTime is in local time (not UTC)
  /// This fixes timezone mismatch issues where times were being interpreted as UTC
  DateTime _ensureLocalTime(DateTime dateTime) {
    if (dateTime.isUtc) {
      debugPrint('⚠️  Converting UTC time to local: $dateTime → ${dateTime.toLocal()}');
      return dateTime.toLocal();
    }
    return dateTime;
  }

  void _updateDuration(String value) {
    final parsed = int.tryParse(value);
    setState(() {
      _estimatedDuration = parsed;
    });
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadlineDate = picked);
    }
  }

  Future<void> _pickScheduledDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickScheduledTime() async {
    // Clamp initial time to work hours
    final clampedInitialTime = _clampTimeToWorkHours(_scheduledTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: clampedInitialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      // Validate and clamp the selected time to work hours
      final clampedTime = _clampTimeToWorkHours(picked);
      
      setState(() => _scheduledTime = clampedTime);
      
      // Show snackbar if time was adjusted
      if (clampedTime != picked && mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Time adjusted to work hours (9 AM - 9 PM)',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Clamps a TimeOfDay to work hours (9 AM - 9 PM)
  TimeOfDay _clampTimeToWorkHours(TimeOfDay time) {
    if (time.hour < workDayStartHour) {
      return TimeOfDay(hour: workDayStartHour, minute: 0);
    } else if (time.hour >= workDayEndHour) {
      return TimeOfDay(hour: workDayEndHour, minute: 0);
    }
    return time;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';
    return '${date.month}/${date.day}';
  }

  String _formatScheduledDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayLabel;
    if (dateOnly == today) {
      dayLabel = 'Today';
    } else if (dateOnly == tomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = '${dateTime.month}/${dateTime.day}';
    }

    final timeLabel = TimeOfDay.fromDateTime(dateTime).format(context);
    return '$dayLabel · $timeLabel';
  }

  DateTime _combineScheduledDateTime(DateTime date, TimeOfDay time) {
    // Create as LOCAL time (not UTC)
    // This ensures the time stays as the user intended
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return _ensureLocalTime(combined);
  }

  void _addTaskToList() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    // Only create scheduled time if user enabled it
    final DateTime? scheduledDateTime = _hasScheduledTime
        ? _combineScheduledDateTime(_scheduledDate, _scheduledTime)
        : null;

    // Validate that task won't exceed work day end (9 PM = 21:00) - only if scheduled
    if (_hasScheduledTime && scheduledDateTime != null && _estimatedDuration != null && _estimatedDuration! > 0) {
      final endTime = scheduledDateTime.add(Duration(minutes: _estimatedDuration!));
      final workDayEnd = DateTime(
        scheduledDateTime.year,
        scheduledDateTime.month,
        scheduledDateTime.day,
        workDayEndHour,
        0,
      );

      if (endTime.isAfter(workDayEnd)) {
        final availableMinutes = workDayEnd.difference(scheduledDateTime).inMinutes;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task would end at ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} (after 9 PM).\n'
              'Only $availableMinutes minutes available.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final task = _TaskToAdd(
      title: title,
      priority: _selectedPriority,
      estimatedDuration: _estimatedDuration,
      deadlineDate: _isDueToday ? null : _deadlineDate,
      isDueToday: _isDueToday,
      scheduledTime: scheduledDateTime,
    );

    setState(() {
      _tasksToAdd.add(task);
      _titleController.clear();
      _durationController.clear();
      _selectedPriority = 'medium';
      _isDueToday = true;
      _deadlineDate = null;
      _estimatedDuration = null;
      _hasScheduledTime = false; // Reset to flexible
      _scheduledDate = widget.selectedDate;
      _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
      _titleFocusNode.requestFocus();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Added "$title" (${_tasksToAdd.length} total)'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _removeTask(int index) {
    setState(() {
      _tasksToAdd.removeAt(index);
    });
  }

  Future<void> _editTask(int index) async {
    final task = _tasksToAdd[index];

    final titleController = TextEditingController(text: task.title);
    final durationController =
        TextEditingController(text: task.estimatedDuration?.toString() ?? '');

    String priority = task.priority;
    bool isDueToday = task.isDueToday;
    DateTime? deadlineDate = task.deadlineDate;
    bool hasScheduledTime = task.scheduledTime != null;
    DateTime scheduledDate = task.scheduledTime ?? widget.selectedDate;
    TimeOfDay scheduledTime = task.scheduledTime != null 
        ? TimeOfDay.fromDateTime(task.scheduledTime!)
        : const TimeOfDay(hour: 9, minute: 0);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: scheduledDate,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) {
                setStateDialog(() => scheduledDate = picked);
              }
            }

            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: scheduledTime,
              );
              if (picked != null) {
                setStateDialog(() => scheduledTime = picked);
              }
            }

            Future<void> pickDeadline() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: deadlineDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) {
                setStateDialog(() => deadlineDate = picked);
              }
            }

            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Low'),
                          selected: priority == 'low',
                          onSelected: (_) => setStateDialog(() => priority = 'low'),
                        ),
                        ChoiceChip(
                          label: const Text('Medium'),
                          selected: priority == 'medium',
                          onSelected: (_) => setStateDialog(() => priority = 'medium'),
                        ),
                        ChoiceChip(
                          label: const Text('High'),
                          selected: priority == 'high',
                          onSelected: (_) => setStateDialog(() => priority = 'high'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: hasScheduledTime,
                      onChanged: (value) {
                        setStateDialog(() => hasScheduledTime = value ?? false);
                      },
                      title: const Text('Set specific time'),
                      subtitle: Text(
                        hasScheduledTime 
                            ? 'Scheduled at specific time'
                            : 'Placed flexibly by planner',
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (hasScheduledTime) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: pickDate,
                              icon: const Icon(Icons.event),
                              label: Text(_formatScheduledDateTime(
                                _combineScheduledDateTime(scheduledDate, scheduledTime),
                              )),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: pickTime,
                            icon: const Icon(Icons.schedule),
                            label: Text(scheduledTime.format(context)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: isDueToday,
                      onChanged: (value) {
                        setStateDialog(() {
                          isDueToday = value ?? true;
                          if (isDueToday) {
                            deadlineDate = null;
                          }
                        });
                      },
                      title: const Text('Due today'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!isDueToday)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: pickDeadline,
                          icon: const Icon(Icons.event_available),
                          label: Text(deadlineDate == null
                              ? 'Set deadline'
                              : _formatDate(deadlineDate!)),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final newTitle = titleController.text.trim();
                    if (newTitle.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task title cannot be empty')),
                      );
                      return;
                    }

                    final updatedDuration = int.tryParse(durationController.text);
                    final DateTime? newScheduled = hasScheduledTime
                        ? _combineScheduledDateTime(scheduledDate, scheduledTime)
                        : null;

                    setState(() {
                      _tasksToAdd[index] = _TaskToAdd(
                        title: newTitle,
                        priority: priority,
                        estimatedDuration: updatedDuration,
                        deadlineDate: isDueToday ? null : deadlineDate,
                        isDueToday: isDueToday,
                        scheduledTime: newScheduled,
                      );
                    });

                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitAllTasks() async {
    if (_tasksToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one task')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int successCount = 0;
      for (final task in _tasksToAdd) {
        // Handle scheduled time - only apply if task has one, otherwise send null
        final DateTime? localTime = task.scheduledTime != null 
            ? _ensureLocalTime(task.scheduledTime!)
            : null;
        
        debugPrint(
          '📤 Sending task "${task.title}" with '
          'scheduledTime=${localTime != null ? "$localTime (isUtc=${localTime.isUtc})" : "null (flexible)"}',
        );
        
        await client.task.createTask(
          task.title,
          goalId: 1,
          scheduledTime: localTime, // Can be null for flexible tasks
          priority: task.priority,
          estimatedDuration: task.estimatedDuration,
        );
        successCount++;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Created $successCount task(s)')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create tasks: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.add_task, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Tasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_tasksToAdd.isNotEmpty)
                      Text(
                        '${_tasksToAdd.length} task(s) ready',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Task title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Priority',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _PriorityChip(
                              label: 'Low',
                              value: 'low',
                              selected: _selectedPriority == 'low',
                              onTap: () => setState(() => _selectedPriority = 'low'),
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _PriorityChip(
                              label: 'Medium',
                              value: 'medium',
                              selected: _selectedPriority == 'medium',
                              onTap: () => setState(() => _selectedPriority = 'medium'),
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _PriorityChip(
                              label: 'High',
                              value: 'high',
                              selected: _selectedPriority == 'high',
                              onTap: () => setState(() => _selectedPriority = 'high'),
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Duration (optional)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _durationController,
                                decoration: InputDecoration(
                                  hintText: 'Minutes',
                                  suffixText: 'min',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: _updateDuration,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _DurationButton(
                              label: '15m',
                              onTap: () {
                                _durationController.text = '15';
                                _updateDuration('15');
                              },
                            ),
                            const SizedBox(width: 8),
                            _DurationButton(
                              label: '30m',
                              onTap: () {
                                _durationController.text = '30';
                                _updateDuration('30');
                              },
                            ),
                            const SizedBox(width: 8),
                            _DurationButton(
                              label: '60m',
                              onTap: () {
                                _durationController.text = '60';
                                _updateDuration('60');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _hasScheduledTime,
                          onChanged: (value) {
                            setState(() => _hasScheduledTime = value ?? false);
                          },
                          title: Text(
                            'Set specific time',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          subtitle: Text(
                            _hasScheduledTime 
                                ? 'Task will be scheduled at specific time'
                                : 'Task will be placed flexibly by planner',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (_hasScheduledTime) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickScheduledDate,
                                  icon: const Icon(Icons.event),
                                  label: Text(
                                    _formatScheduledDateTime(
                                      _combineScheduledDateTime(
                                        _scheduledDate,
                                        _scheduledTime,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _pickScheduledTime,
                                icon: const Icon(Icons.schedule),
                                label: Text(TimeOfDay(
                                  hour: _scheduledTime.hour,
                                  minute: _scheduledTime.minute,
                                ).format(context)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Work hours: 9 AM - 9 PM',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Deadline',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: _isDueToday,
                                onChanged: (value) {
                                  setState(() {
                                    _isDueToday = value ?? true;
                                    if (_isDueToday) {
                                      _deadlineDate = null;
                                    }
                                  });
                                },
                                title: const Text('Due today'),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                            if (!_isDueToday)
                              InkWell(
                                onTap: _pickDeadline,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event,
                                        size: 16,
                                        color: theme.colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _deadlineDate != null
                                            ? _formatDate(_deadlineDate!)
                                            : 'Set deadline',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _titleController.text.trim().isEmpty
                                ? null
                                : _addTaskToList,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('+ Add to List'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_tasksToAdd.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Tasks to Add',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tasksToAdd.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final task = _tasksToAdd[index];
                          final priorityColor = task.priority == 'high'
                              ? Colors.red
                              : task.priority == 'medium'
                                  ? Colors.orange
                                  : Colors.blue;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: priorityColor.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: priorityColor.withOpacity(0.05),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: priorityColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              task.priority.toUpperCase(),
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: priorityColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (task.estimatedDuration != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              '${task.estimatedDuration}m',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.scheduledTime != null
                                            ? 'Scheduled: ${_formatScheduledDateTime(task.scheduledTime!)}'
                                            : 'Flexible (no specific time)',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        task.isDueToday
                                            ? 'Due today'
                                            : task.deadlineDate != null
                                                ? 'Due ${_formatDate(task.deadlineDate!)}'
                                                : 'Deadline not set',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _editTask(index),
                                  icon: const Icon(Icons.edit_outlined),
                                  color: theme.colorScheme.primary,
                                  iconSize: 20,
                                ),
                                IconButton(
                                  onPressed: () => _removeTask(index),
                                  icon: const Icon(Icons.delete_outline),
                                  color: theme.colorScheme.error,
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submitAllTasks,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text('Save All (${_tasksToAdd.length})'),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Create tasks to add them to your plan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _PriorityChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected ? color : theme.colorScheme.outline.withOpacity(0.5),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? color : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DurationButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
