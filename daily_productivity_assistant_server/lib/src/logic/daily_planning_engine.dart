import 'package:daily_productivity_assistant_server/src/generated/task.dart' show Task;
import 'daily_timeline_slot.dart';

/// Engine for generating daily task schedules
/// with scheduled-task enforcement and energy-aware placement.
class DailyPlanningEngine {
  static List<DailyTimelineSlot> generateTimeline({
    required DateTime day,
    required List<Task> tasks,
  }) {
    final timeline = <DailyTimelineSlot>[];

    // Day boundaries: 9 AM to 9 PM
    final dayStart = DateTime(day.year, day.month, day.day, 9, 0);
    final dayEnd = DateTime(day.year, day.month, day.day, 21, 0);

    // Energy windows (soft preferences)
    final highWindowStart = DateTime(day.year, day.month, day.day, 9, 0);
    final highWindowEnd = DateTime(day.year, day.month, day.day, 12, 0);
    final mediumWindowStart = DateTime(day.year, day.month, day.day, 12, 0);
    final mediumWindowEnd = DateTime(day.year, day.month, day.day, 16, 0);
    final lowWindowStart = DateTime(day.year, day.month, day.day, 16, 0);
    final lowWindowEnd = DateTime(day.year, day.month, day.day, 21, 0);

    // Split tasks
    final scheduled = tasks
        .where((t) => t.scheduledTime != null)
        .toList()
      ..sort((a, b) {
        final aStart = a.scheduledTime!;
        final bStart = b.scheduledTime!;

        // Compare by local time first
        final byTime = (aStart.isUtc ? aStart.toLocal() : aStart)
            .compareTo(bStart.isUtc ? bStart.toLocal() : bStart);
        if (byTime != 0) return byTime;

        // If same time, order by priority (high → medium → low)
        final byPriority = _priorityWeight(b.priority) - _priorityWeight(a.priority);
        if (byPriority != 0) return byPriority;

        // Stable fallback: smaller id first (nulls last)
        final aId = a.id ?? 0;
        final bId = b.id ?? 0;
        return aId.compareTo(bId);
      });
    final flexible = tasks
        .where((t) => t.scheduledTime == null)
        .toList();

    // DEBUG: Log task distribution
    print('🔍 DailyPlanningEngine: scheduled=${scheduled.length}, flexible=${flexible.length}');
    for (final t in scheduled) {
      print('  Scheduled task ${t.id}: ${t.title}, scheduledTime=${t.scheduledTime} (isUtc=${t.scheduledTime?.isUtc})');
    }

    // ---------------- PHASE 1: Lock scheduled tasks ----------------
    var cursor = dayStart;
    for (var i = 0; i < scheduled.length; i++) {
      final task = scheduled[i];
      // Convert UTC to local time if needed
      final scheduledTime = task.scheduledTime!;
      final start = scheduledTime.isUtc ? scheduledTime.toLocal() : scheduledTime;
      final end = start.add(Duration(minutes: task.estimatedDuration));

      print('  Processing task ${task.id}: start=$start, end=$end, dayEnd=$dayEnd, fits=${!end.isAfter(dayEnd)}');

      if (end.isAfter(dayEnd)) {
        print('    ❌ Task ${task.id} skipped: end time $end is after dayEnd $dayEnd');
        continue; // skip if it doesn't fit the day
      }

      if (cursor.isBefore(start)) {
        timeline.add(
          DailyTimelineSlot(
            start: cursor,
            end: start,
            taskId: null,
            label: 'Idle Time',
            type: 'idle',
          ),
        );
      }

      timeline.add(
        DailyTimelineSlot(
          start: start,
          end: end,
          taskId: task.id,
          label: task.title,
          type: 'task',
        ),
      );
      cursor = end;

      final nextStart = (i + 1 < scheduled.length) ? scheduled[i + 1].scheduledTime : null;
      final breakMinutes = calculateBreakMinutes(task);
      final breakEnd = cursor.add(Duration(minutes: breakMinutes));
      final boundary = nextStart ?? dayEnd;

      final canInsertBreak = breakMinutes > 0 && breakEnd.isBefore(boundary) && breakEnd.isBefore(dayEnd);
      if (canInsertBreak) {
        timeline.add(
          DailyTimelineSlot(
            start: cursor,
            end: breakEnd,
            taskId: null,
            label: 'Break',
            type: 'break',
          ),
        );
        cursor = breakEnd;
      }

      if (cursor.isBefore(end)) {
        cursor = end;
      }
    }

    // Remove idle slots to free space for flexible placement
    timeline.removeWhere((slot) => slot.type == 'idle');

    // ---------------- PHASE 2: Bucket flexible tasks by energy ----------------
    final highEnergy = flexible.where((t) => t.energyLevel.toLowerCase() == 'high').toList();
    final mediumEnergy = flexible.where((t) => t.energyLevel.toLowerCase() == 'medium').toList();
    final lowEnergy = flexible.where((t) => t.energyLevel.toLowerCase() == 'low').toList();

    _sortBucket(highEnergy);
    _sortBucket(mediumEnergy);
    _sortBucket(lowEnergy);

    // ---------------- PHASE 3: Place tasks by energy windows ----------------
    _placeBucketsInWindow(
      timeline: timeline,
      bucketsInOrder: [highEnergy, mediumEnergy, lowEnergy],
      windowStart: highWindowStart,
      windowEnd: highWindowEnd,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    _placeBucketsInWindow(
      timeline: timeline,
      bucketsInOrder: [mediumEnergy, highEnergy, lowEnergy],
      windowStart: mediumWindowStart,
      windowEnd: mediumWindowEnd,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    _placeBucketsInWindow(
      timeline: timeline,
      bucketsInOrder: [lowEnergy, mediumEnergy, highEnergy],
      windowStart: lowWindowStart,
      windowEnd: lowWindowEnd,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    // ---------------- PHASE 4: Fallback placement ----------------
    final remaining = <Task>[
      ...highEnergy,
      ...mediumEnergy,
      ...lowEnergy,
    ];

    _sortBucket(remaining);

    _placeBucketsInWindow(
      timeline: timeline,
      bucketsInOrder: [remaining],
      windowStart: dayStart,
      windowEnd: dayEnd,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    // Fill any remaining gaps with idle
    _fillIdleGaps(timeline: timeline, dayStart: dayStart, dayEnd: dayEnd);

    timeline.sort((a, b) => a.start.compareTo(b.start));
    return timeline;
  }

  // Higher weight = higher priority
  static int _priorityWeight(String? priority) {
    switch ((priority ?? 'medium').toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }

  static void _placeBucketsInWindow({
    required List<DailyTimelineSlot> timeline,
    required List<List<Task>> bucketsInOrder,
    required DateTime windowStart,
    required DateTime windowEnd,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) {
    var free = _freeIntervals(
      timeline: timeline,
      windowStart: windowStart,
      windowEnd: windowEnd,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    for (final bucket in bucketsInOrder) {
      _sortBucket(bucket);

      var i = 0;
      while (i < free.length && bucket.isNotEmpty) {
        final interval = free[i];
        var cursor = interval.start;

        if (!cursor.isBefore(interval.end)) {
          i += 1;
          continue;
        }

        final task = bucket.first;
        final duration = Duration(minutes: task.estimatedDuration);

        if (cursor.add(duration).isAfter(interval.end)) {
          i += 1;
          continue;
        }

        // Place task
        timeline.add(
          DailyTimelineSlot(
            start: cursor,
            end: cursor.add(duration),
            taskId: task.id,
            label: task.title,
            type: 'task',
          ),
        );
        cursor = cursor.add(duration);
        bucket.removeAt(0);

        // Optional break if it fits inside the interval
        final breakMinutes = calculateBreakMinutes(task);
        final breakEnd = cursor.add(Duration(minutes: breakMinutes));
        if (breakMinutes > 0 && breakEnd.isBefore(interval.end)) {
          timeline.add(
            DailyTimelineSlot(
              start: cursor,
              end: breakEnd,
              taskId: null,
              label: 'Break',
              type: 'break',
            ),
          );
          cursor = breakEnd;
        }

        // Update remaining free time
        free[i] = _FreeInterval(cursor, interval.end);
        if (!free[i].start.isBefore(free[i].end)) {
          i += 1;
        }
      }

      // Recompute free intervals to avoid overlap for next bucket
      free = _freeIntervals(
        timeline: timeline,
        windowStart: windowStart,
        windowEnd: windowEnd,
        dayStart: dayStart,
        dayEnd: dayEnd,
      );
    }
  }

  static List<_FreeInterval> _freeIntervals({
    required List<DailyTimelineSlot> timeline,
    required DateTime windowStart,
    required DateTime windowEnd,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) {
    final start = windowStart.isBefore(dayStart) ? dayStart : windowStart;
    final end = windowEnd.isAfter(dayEnd) ? dayEnd : windowEnd;

    final occupied = timeline
        .where((slot) => slot.type != 'idle')
        .where((slot) => !slot.end.isBefore(start) && !slot.start.isAfter(end))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final free = <_FreeInterval>[];
    var cursor = start;

    for (final slot in occupied) {
      if (slot.start.isAfter(cursor)) {
        free.add(_FreeInterval(cursor, slot.start));
      }
      if (slot.end.isAfter(cursor)) {
        cursor = slot.end.isAfter(end) ? end : slot.end;
      }
      if (!cursor.isBefore(end)) break;
    }

    if (cursor.isBefore(end)) {
      free.add(_FreeInterval(cursor, end));
    }

    return free;
  }

  static void _fillIdleGaps({
    required List<DailyTimelineSlot> timeline,
    required DateTime dayStart,
    required DateTime dayEnd,
  }) {
    final free = _freeIntervals(
      timeline: timeline,
      windowStart: dayStart,
      windowEnd: dayEnd,
      dayStart: dayStart,
      dayEnd: dayEnd,
    );

    for (final gap in free) {
      timeline.add(
        DailyTimelineSlot(
          start: gap.start,
          end: gap.end,
          taskId: null,
          label: 'Idle Time',
          type: 'idle',
        ),
      );
    }
  }

  static void _sortBucket(List<Task> bucket) {
    bucket.sort((a, b) {
      final pDiff = _priorityWeight(b.priority).compareTo(_priorityWeight(a.priority));
      if (pDiff != 0) return pDiff;
      final dDiff = b.estimatedDuration.compareTo(a.estimatedDuration);
      if (dDiff != 0) return dDiff;
      return a.title.compareTo(b.title);
    });
  }

  /// Calculates break minutes based on task energy level and duration
  static int calculateBreakMinutes(Task task) {
    final energy = task.energyLevel.toLowerCase();
    final minutes = task.estimatedDuration;
    switch (energy) {
      case 'low':
        return 5;
      case 'medium':
        return minutes < 60 ? 10 : 15;
      case 'high':
        return minutes < 60 ? 15 : 20;
      default:
        return 10;
    }
  }

}

class _FreeInterval {
  _FreeInterval(this.start, this.end);
  DateTime start;
  DateTime end;
}
