import 'package:daily_productivity_assistant_server/src/generated/task.dart' show Task;
import 'next_best_task_result.dart';

/// Core intelligence engine for determining the single best task to do next
/// 
/// This engine uses a transparent scoring system with breakdown of each factor,
/// making the decision process explainable and auditable.
class NextBestTaskEngine {
  /// Determines the next best task for the user to work on right now
  ///
  /// Returns a [NextBestTaskResult] with full explainability if a suitable task exists,
  /// or null if no suitable task is available.
  ///
  /// [now] - Current date and time
  /// [pendingTasks] - List of tasks to evaluate (engine will defensively filter to "pending")
  /// [isUserBehindSchedule] - Whether the user is behind on their daily goals
  /// [userEnergyLevel] - User's current energy level ("low", "medium", "high") used for matching
  static NextBestTaskResult? getNextBestTask({
    required DateTime now,
    required List<Task> pendingTasks,
    required bool isUserBehindSchedule,
    required String userEnergyLevel,
  }) {
    // Defensive filter: only consider pending tasks
    final eligibleTasks = pendingTasks.where((t) => t.status.toLowerCase() == 'pending').toList();

    if (eligibleTasks.isEmpty) {
      return null;
    }

    double bestScore = -1;
    Task? bestTask;
    Map<String, double> bestBreakdown = {};

    // Score each task and track the best
    for (final task in eligibleTasks) {
      final breakdown = _calculateScore(
        task: task,
        now: now,
        isUserBehindSchedule: isUserBehindSchedule,
        userEnergyLevel: userEnergyLevel,
      );

      // Aggregate using weighted additive scoring.
      // Intentionally additive: keeps transparency and tunability while
      // allowing dominant factors (priority, urgency) to lead.
      final totalScore = breakdown.values.fold(0.0, (a, b) => a + b);

      if (totalScore > bestScore) {
        bestScore = totalScore;
        bestTask = task;
        bestBreakdown = breakdown;
      }
    }

    if (bestTask == null) {
      return null;
    }

    return NextBestTaskResult(
      taskId: bestTask.id!,
      totalScore: bestScore,
      scoreBreakdown: bestBreakdown,
      explanation: _generateExplanation(bestTask, bestBreakdown),
    );
  }

  // ============== SCORING LOGIC ==============

  /// Calculates scoring breakdown for a single task
  static Map<String, double> _calculateScore({
    required Task task,
    required DateTime now,
    required bool isUserBehindSchedule,
    required String userEnergyLevel,
  }) {
    // Factor weights: priority & urgency dominant; energy secondary; focus conditional.
    final priority = _priorityScore(task.priority); // dominant
    final urgency = _urgencyScore(task.scheduledTime, now); // dominant
    final energy = _energyMatchScore(userEnergyLevel, task.energyLevel); // secondary
    final focus = _focusScore(
      isUserBehindSchedule: isUserBehindSchedule,
      task: task,
      now: now,
    ); // conditional

    return {
      'priority': priority,
      'urgency': urgency,
      'energyMatch': energy,
      'focus': focus,
    };
  }

  /// Scores task based on priority level
  /// - high: 3.0
  /// - medium: 2.0
  /// - low: 1.0
  static double _priorityScore(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3.0;
      case 'medium':
        return 2.0;
      default:
        return 1.0;
    }
  }

  /// Scores task based on MATCH to user's current energy level
  /// Perfect match: strong reward
  /// Adjacent match: moderate reward
  /// Opposite (low vs high): penalty
  static double _energyMatchScore(String userEnergy, String taskEnergy) {
    final u = userEnergy.toLowerCase();
    final t = taskEnergy.toLowerCase();

    if (u == t) return 2.5; // perfect match

    // Adjacent cases
    final adjacent = {
      'high': ['medium'],
      'medium': ['high', 'low'],
      'low': ['medium'],
    };
    if (adjacent[u]?.contains(t) == true) return 1.5;

    // Opposite mismatch (e.g., user low vs task high)
    return -1.0;
  }

  /// Scores task based on urgency and deadline (dominant factor)
  /// - overdue: 3.0
  /// - due within 30 min: 2.0
  /// - due within 2 hours: 1.0
  /// - flexible deadline: 0.5
  static double _urgencyScore(DateTime? scheduled, DateTime now) {
    if (scheduled == null) {
      return 0.5; // No deadline = flexible
    }

    final diff = scheduled.difference(now).inMinutes;

    if (diff <= 0) return 3.0; // Overdue
    if (diff <= 30) return 2.0; // Due soon
    if (diff <= 120) return 1.0; // Due later
    return 0.5; // Far future
  }

  /// Focus score applies only when user is behind schedule.
  /// Boosts urgent/scheduled tasks and penalizes flexible low-priority tasks.
  static double _focusScore({
    required bool isUserBehindSchedule,
    required Task task,
    required DateTime now,
  }) {
    if (!isUserBehindSchedule) return 0.0;

    final hasSchedule = task.scheduledTime != null;
    final urgent = _urgencyScore(task.scheduledTime, now) >= 2.0; // due soon or overdue
    final lowPriority = task.priority.toLowerCase() == 'low';

    if (hasSchedule || urgent) return 1.5; // boost scheduled/urgent tasks
    if (lowPriority) return -0.5; // slight penalty for low priority when behind
    return 0.0;
  }

  // ============== EXPLAINABILITY ==============

  /// Generates human-readable explanation of why this task was chosen
  static String _generateExplanation(
    Task task,
    Map<String, double> breakdown,
  ) {
    // Mention top 2 contributing factors for truthful explainability.
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top1 = sorted.isNotEmpty ? sorted[0].key : null;
    final top2 = sorted.length > 1 ? sorted[1].key : null;

    String factorLabel(String? k) {
      switch (k) {
        case 'priority':
          return 'high priority';
        case 'urgency':
          return 'approaching deadline';
        case 'energyMatch':
          return 'energy fit';
        case 'focus':
          return 'behind-schedule focus';
        default:
          return 'overall score';
      }
    }

    if (top1 == null) {
      return 'Selected: Best overall task based on combined scoring factors.';
    }

    if (top2 == null) {
      return 'Selected due to ${factorLabel(top1)}.';
    }

    return 'Selected due to ${factorLabel(top1)} and ${factorLabel(top2)}.';
  }
}
