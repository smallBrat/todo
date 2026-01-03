/// Rich result object with full explainability
/// 
/// This class provides complete transparency into why a task was recommended,
/// including breakdown of all scoring factors.
class NextBestTaskResult {
  /// The ID of the recommended task
  final int taskId;

  /// Total composite score (sum of all factors)
  final double totalScore;

  /// Breakdown of scoring by factor
  /// Keys: 'priority', 'energy', 'urgency', 'focus'
  /// Values: Individual factor scores
  final Map<String, double> scoreBreakdown;

  /// Human-readable explanation of the recommendation
  final String explanation;

  NextBestTaskResult({
    required this.taskId,
    required this.totalScore,
    required this.scoreBreakdown,
    required this.explanation,
  });

  @override
  String toString() => 'NextBestTaskResult(taskId: $taskId, score: $totalScore)';
}
