import 'package:flutter/material.dart';

import '../../serverpod.dart';
import 'add_task_sheet.dart';
import '../analytics/analytics_screen.dart';

enum TaskStatus { todo, inProgress, done }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    this.priority,
    this.estimatedDuration,
    this.scheduledTime,
    this.deadline,
  });

  final int id;
  final String title;
  final TaskStatus status;
  final String? priority;
  final int? estimatedDuration;
  final DateTime? scheduledTime;
  final DateTime? deadline;

  Task copyWith({
    TaskStatus? status,
    String? title,
    String? priority,
    int? estimatedDuration,
    DateTime? scheduledTime,
    DateTime? deadline,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deadline: deadline ?? this.deadline,
    );
  }
}

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  late Future<List<Task>> _tasksFuture;
  List<Task> _tasks = const [];
  bool _isRefreshing = false;
  NextBestTaskResult? _nextBestTask;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadTasks().then((tasks) {
      setState(() {
        _tasks = tasks;
      });
      // Load next best task recommendation after tasks are loaded
      _loadNextBestTask();
      return tasks;
    });
  }

  // ignore: unused_element
  Future<void> _refreshTasks() async {
    final tasks = await _loadTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _tasksFuture = Future.value(tasks);
    });
  }

  /// Show bottom sheet to add new task
  /// 
  /// Re-fetches daily plan from backend if task was created successfully
  Future<void> _showAddTaskSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // Allow sheet to expand with keyboard
      backgroundColor: Colors.transparent, // Custom background in sheet
      builder: (_) => AddTaskSheet(selectedDate: DateTime.now()),
    );

    // If task was created (result == true), refresh the task list
    if (result == true && mounted) {
      setState(() {
        _tasksFuture = _loadTasks().then((tasks) {
          setState(() {
            _tasks = tasks;
          });
          return tasks;
        });
      });
    }
  }

  Future<void> _refreshPlan() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final today = DateTime.now();
      await client.planning.generateAndSavePlan(1, today);
      final tasks = await _loadTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _tasksFuture = Future.value(tasks);
      });
      // Refresh next best task after plan refresh
      await _loadNextBestTask();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan refreshed')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _cycleStatus(int index) {
    final current = _tasks[index].status;
    final next = switch (current) {
      TaskStatus.todo => TaskStatus.inProgress,
      TaskStatus.inProgress => TaskStatus.done,
      TaskStatus.done => TaskStatus.todo,
    };

    final taskId = _tasks[index].id;
    final previousStatus = _tasks[index].status;

    // Optimistic update
    setState(() {
      _tasks[index] = _tasks[index].copyWith(status: next);
    });

    // Persist to backend
    _persistStatusChange(index, taskId, next, previousStatus);
  }

  Future<void> _persistStatusChange(
    int index,
    int taskId,
    TaskStatus newStatus,
    TaskStatus previousStatus,
  ) async {
    try {
      final statusString = _statusToString(newStatus);
      debugPrint('💾 Saving task $taskId: ${newStatus.name} → backend="${statusString}"');
      
      await client.task.updateTaskStatus(taskId, statusString);
      
      debugPrint('✅ Task $taskId status saved successfully');
      
      // Refresh next best task after status change
      await _loadNextBestTask();
    } catch (e) {
      // Revert on error
      setState(() {
        _tasks[index] = _tasks[index].copyWith(status: previousStatus);
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e')),
        );
      }
    }
  }

  String _statusToString(TaskStatus status) {
    return switch (status) {
      TaskStatus.todo => 'pending',
      TaskStatus.inProgress => 'in_progress',
      TaskStatus.done => 'completed',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _formatToday();
    final taskCount = _tasks.length;
    final completedCount = _tasks.where((t) => t.status == TaskStatus.done).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Analytics',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TodayPlanHeader(
              dateLabel: dateText,
              taskCount: taskCount,
              completedCount: completedCount,
            ),
            const SizedBox(height: 12),
            // Next best task recommendation banner
            if (_nextBestTask != null)
              NextBestTaskBanner(
                recommendation: _nextBestTask!,
                tasks: _tasks,
                onTaskTap: () {
                  // Find the recommended task and scroll to it
                  final recommendedIndex = _tasks
                      .indexWhere((t) => t.id == _nextBestTask!.taskId);
                  if (recommendedIndex != -1) {
                    debugPrint('🎯 Scrolling to recommended task index: $recommendedIndex');
                    // TODO: Implement scroll behavior if using Scrollable widget
                  }
                },
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAddTaskSheet,
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add task'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isRefreshing ? null : _refreshPlan,
                    icon: _isRefreshing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isRefreshing ? 'Refreshing...' : 'Refresh plan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const _EmptyState();
                  }

                  final hasTasks = _tasks.isNotEmpty;
                  if (!hasTasks) {
                    return const _EmptyState();
                  }

                  return ListView.separated(
                    itemCount: _tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return _TaskRow(
                        task: task,
                        onToggle: () => _cycleStatus(index),
                        onEdit: () => _editTask(task, index),
                        onDelete: () => _deleteTask(task, index),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTask(Task task, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistic remove
    final removed = _tasks[index];
    setState(() {
      _tasks = List.of(_tasks)..removeAt(index);
    });

    try {
      await client.task.deleteTask(task.id);
    } catch (e) {
      // revert
      if (!mounted) return;
      setState(() {
        _tasks = List.of(_tasks)..insert(index, removed);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  Future<void> _editTask(Task task, int index) async {
    final titleController = TextEditingController(text: task.title);
    final durationController =
        TextEditingController(text: task.estimatedDuration?.toString() ?? '');
    String priority = task.priority ?? 'medium';
    DateTime scheduledDateTime = task.scheduledTime ?? DateTime.now();
    TimeOfDay scheduledTime = TimeOfDay.fromDateTime(scheduledDateTime);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: scheduledDateTime,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );
              if (picked != null) {
                setStateDialog(() => scheduledDateTime = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      scheduledTime.hour,
                      scheduledTime.minute,
                    ));
              }
            }

            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: scheduledTime,
              );
              if (picked != null) {
                setStateDialog(() {
                  scheduledTime = picked;
                  scheduledDateTime = DateTime(
                    scheduledDateTime.year,
                    scheduledDateTime.month,
                    scheduledDateTime.day,
                    picked.hour,
                    picked.minute,
                  );
                });
              }
            }

            return AlertDialog(
              title: const Text('Edit task'),
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
                    Text(
                      'Schedule',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickDate,
                            icon: const Icon(Icons.event),
                            label: Text(_formatScheduledDateTime(scheduledDateTime)),
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final newTitle = titleController.text.trim();
    final newDuration = int.tryParse(durationController.text);

    // Optimistic update
    setState(() {
      _tasks[index] = _tasks[index].copyWith(
        title: newTitle.isEmpty ? task.title : newTitle,
        priority: priority,
        estimatedDuration: newDuration ?? task.estimatedDuration,
        scheduledTime: scheduledDateTime,
      );
    });

    try {
      await client.task.updateTaskDetails(
        task.id,
        title: newTitle.isEmpty ? task.title : newTitle,
        priority: priority,
        estimatedDuration: newDuration ?? task.estimatedDuration,
        scheduledTime: scheduledDateTime,
      );
    } catch (e) {
      // revert and notify
      if (!mounted) return;
      setState(() {
        _tasks[index] = task;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Future<List<Task>> _loadTasks() async {
    final plan = await client.planning.getSavedPlan(1, DateTime.now());
    if (plan == null) return const [];

    debugPrint('🔄 Loading ${plan.slots.length} slots from backend');

    return plan.slots
        .where((slot) => slot.taskId != null && slot.type == 'task')
        .map((slot) {
      // Map backend status to UI enum
      final statusString = slot.status ?? 'pending';
      final taskStatus = _statusFromString(statusString);
      
      // 🔍 DEBUG: Log each task's status from backend
      debugPrint('📋 Task ${slot.taskId}: "${slot.title}" → backend="${statusString}" → UI=${taskStatus.name}');
      
      // Convert UTC startTime to local time for display
      final localScheduledTime = slot.startTime.isUtc ? slot.startTime.toLocal() : slot.startTime;
      
      return Task(
        id: slot.taskId!,
        title: slot.title,
        status: taskStatus,
        priority: slot.priority,
        estimatedDuration: slot.durationMinutes.toInt(),
        scheduledTime: localScheduledTime,
        deadline: null, // TODO: Map from backend when available
      );
    }).toList();
  }

  Future<void> _loadNextBestTask() async {
    try {
      final result = await client.planning.getNextBestTask(1);
      if (!mounted) return;
      setState(() {
        _nextBestTask = result;
      });
      if (result != null) {
        debugPrint('💡 Next best task: Task ${result.taskId}');
      }
    } catch (e) {
      // Silently skip if recommendation fails (non-blocking)
      if (mounted) {
        setState(() {
          _nextBestTask = null;
        });
      }
    }
  }

  TaskStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.todo;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.done;
      case 'skipped':
      case 'missed':
        // Treat skipped/missed as todo for UI purposes
        return TaskStatus.todo;
      default:
        // Log unexpected status but default to todo
        debugPrint('⚠️ Unexpected task status: $status, defaulting to pending');
        return TaskStatus.todo;
    }
  }

  String _formatToday() {
    final now = DateTime.now();
    final weekday = _weekdayName(now.weekday);
    final month = _monthAbbrev(now.month);
    return '$weekday, ${now.day} $month';
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

  String _weekdayName(int weekday) {
    const names = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return names[(weekday - 1) % names.length];
  }

  String _monthAbbrev(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1) % months.length];
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusStyle = _statusChipStyle(context, task.status);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: task.status == TaskStatus.done,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: task.status == TaskStatus.done
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : task.priority == 'high'
                                ? Colors.red.shade600
                                : theme.colorScheme.onSurface,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    if (task.estimatedDuration != null || task.scheduledTime != null || task.deadline != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (task.scheduledTime != null) ...[
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    TimeOfDay.fromDateTime(task.scheduledTime!).format(context),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (task.estimatedDuration != null) ...[
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.estimatedDuration}m',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (task.deadline != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDeadline(task.deadline!),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusPill(
                label: statusStyle.label,
                background: statusStyle.background,
                foreground: statusStyle.foreground,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusStyle _statusChipStyle(BuildContext context, TaskStatus status) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      TaskStatus.done => _StatusStyle(
          label: 'Completed',
          background: Colors.green.shade100,
          foreground: Colors.green.shade800,
        ),
      TaskStatus.inProgress => _StatusStyle(
          label: 'In Progress',
          background: Colors.blue.shade600,
          foreground: Colors.white,
        ),
      TaskStatus.todo => _StatusStyle(
          label: 'To Do',
          background: scheme.surfaceVariant,
          foreground: scheme.onSurface,
        ),
    };
  }

  /// Format deadline as "Due Today" or date string
  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);

    if (deadlineDate == today) {
      return 'Due Today';
    } else if (deadlineDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return 'Due ${deadline.month}/${deadline.day}';
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

class TodayPlanHeader extends StatelessWidget {
  const TodayPlanHeader({
    super.key,
    required this.dateLabel,
    required this.taskCount,
    required this.completedCount,
  });

  final String dateLabel;
  final int taskCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = '$dateLabel • $taskCount task${taskCount == 1 ? '' : 's'}';

    return Container(
      // subtle separation without heavy chrome
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Plan",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    height: 1.1,
                  ),
                ),
              ),
              DailyProgressBadge(
                completed: completedCount,
                total: taskCount,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyProgressBadge extends StatelessWidget {
  const DailyProgressBadge({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Tasks completed today',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$completed / $total',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

/// Widget to display the next best task recommendation from backend
/// 
/// Resolves the recommended task from the task list and displays:
/// - Task title (prominent)
/// - Estimated duration (if available)
/// - Backend explanation
/// - Score percentage (0-100%)
/// 
/// Hides if the recommended task cannot be found in the task list (defensive UI).
class NextBestTaskBanner extends StatelessWidget {
  const NextBestTaskBanner({
    super.key,
    required this.recommendation,
    required this.tasks,
    required this.onTaskTap,
  });

  final NextBestTaskResult recommendation;
  final List<Task> tasks;
  final VoidCallback onTaskTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Resolve the recommended task from the task list
    Task? recommendedTask;
    try {
      recommendedTask = tasks.firstWhere(
        (t) => t.id == recommendation.taskId,
      );
    } catch (e) {
      // Task not found in list
      recommendedTask = null;
    }
    
    // Hide if task not found (defensive UI)
    if (recommendedTask == null) {
      return const SizedBox.shrink();
    }
    
    // Format duration display
    final durationText = recommendedTask.estimatedDuration != null
        ? '${recommendedTask.estimatedDuration} min'
        : null;
    
    // Clamp score to 0-100%
    final scorePercentage = (recommendation.totalScore * 100)
        .clamp(0, 100)
        .toStringAsFixed(0);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: GestureDetector(
        onTap: onTaskTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + task title + score
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Text(
                        'Suggested next task',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Task title (prominent)
                      Text(
                        recommendedTask.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Duration (if available)
                      if (durationText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          durationText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Score badge on the right
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Recommendation score',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$scorePercentage%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Footer hint
            const SizedBox(height: 8),
            Text(
              'Tap to focus →',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rtl,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks planned for today',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Your daily plan will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
