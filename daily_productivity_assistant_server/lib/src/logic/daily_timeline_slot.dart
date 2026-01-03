/// Represents a single time slot in a daily schedule
/// 
/// Can represent a task, break, or idle time block.
class DailyTimelineSlot {
  /// Start time of this slot
  final DateTime start;

  /// End time of this slot
  final DateTime end;

  /// Associated task ID, if this slot is for a task
  final int? taskId;

  /// Human-readable label (task title, "Break", "Idle", etc.)
  final String label;

  /// Type of slot: "task", "break", "idle"
  final String type;

  DailyTimelineSlot({
    required this.start,
    required this.end,
    required this.taskId,
    required this.label,
    required this.type,
  });

  /// Duration of this slot in minutes
  int get durationMinutes => end.difference(start).inMinutes;

  /// Formatted time string (e.g., "09:30 - 10:00")
  String get timeRange {
    final startStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }

  @override
  String toString() => '$timeRange | $label ($type)';
}
