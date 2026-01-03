import 'package:flutter/material.dart';
import 'package:daily_productivity_assistant_client/daily_productivity_assistant_client.dart';
import '../../serverpod.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

/// Combines historical summaries with a live (today) snapshot
class _SummaryView {
  final DateTime date;
  final double completionRatio; // 0..1
  final int totalFocusedMinutes;
  final bool isLive;

  const _SummaryView({
    required this.date,
    required this.completionRatio,
    required this.totalFocusedMinutes,
    required this.isLive,
  });
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<List<_SummaryView>> _summariesFuture;
  int _rangeDays = 14;

  @override
  void initState() {
    super.initState();
    _summariesFuture = _loadSummaries();
  }

  Future<_SummaryView?> _loadTodayProgress() async {
    final todayPlan = await client.planning.getDailyPlan(DateTime.now());
    if (todayPlan.slots.isEmpty) return null;

    final taskSlots = todayPlan.slots.where((s) => s.type == 'task').toList();
    if (taskSlots.isEmpty) return null;

    int completed = 0;
    int focusedMinutes = 0;
    for (final slot in taskSlots) {
      final status = slot.status?.toLowerCase();
      final isDone = status == 'completed' || status == 'done';
      if (isDone) {
        completed++;
        focusedMinutes += slot.durationMinutes.toInt();
      }
    }

    final total = taskSlots.length;
    final ratio = total > 0 ? completed / total : 0.0;

    return _SummaryView(
      date: DateTime.now(),
      completionRatio: ratio,
      totalFocusedMinutes: focusedMinutes,
      isLive: true,
    );
  }

  Future<List<_SummaryView>> _loadSummaries() async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _rangeDays - 1));

    final summaries = await client.planning.getDailySummaryRange(1, start, now);
    final historical = summaries
        .map((s) => _SummaryView(
              date: s.date,
              completionRatio: s.completionRatio,
              totalFocusedMinutes: s.totalFocusedMinutes,
              isLive: false,
            ))
        .toList();

    final live = await _loadTodayProgress();
    if (live != null) {
      historical.removeWhere((h) => _sameDay(h.date, live.date));
      historical.add(live);
    }

    historical.sort((a, b) => a.date.compareTo(b.date));
    return historical;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _setRange(int days) {
    setState(() {
      _rangeDays = days;
      _summariesFuture = _loadSummaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: FutureBuilder<List<_SummaryView>>(
        future: _summariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load analytics: ${snapshot.error}'),
              ),
            );
          }

          final summaries = snapshot.data ?? [];
          if (summaries.isEmpty) {
            return _EmptyState(onReload: () {
              setState(() => _summariesFuture = _loadSummaries());
            });
          }

          final completionAvg = summaries
                  .map((s) => s.completionRatio)
                  .fold<double>(0, (a, b) => a + b) /
              summaries.length;

          final focusedMinutes = summaries
              .map((s) => s.totalFocusedMinutes)
              .fold<int>(0, (a, b) => a + b);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _summariesFuture = _loadSummaries());
              await _summariesFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Range', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RangeChip(
                      label: '7d',
                      selected: _rangeDays == 7,
                      onTap: () => _setRange(7),
                    ),
                    _RangeChip(
                      label: '14d',
                      selected: _rangeDays == 14,
                      onTap: () => _setRange(14),
                    ),
                    _RangeChip(
                      label: '30d',
                      selected: _rangeDays == 30,
                      onTap: () => _setRange(30),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(
                      title: 'Avg Completion',
                      value: '${(completionAvg * 100).toStringAsFixed(1)}%',
                      subtitle: 'Across ${summaries.length} days',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      title: 'Focused Minutes',
                      value: focusedMinutes.toString(),
                      subtitle: 'Total in range',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _BarChart(summaries: summaries),
                const SizedBox(height: 16),
                _ListView(summaries: summaries),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<_SummaryView> summaries;

  const _BarChart({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = summaries.map((s) => s.completionRatio * 100).toList();
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b).clamp(1, 100) : 100;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 220,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = (constraints.maxWidth - 16) / (values.length.clamp(1, 30));
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < summaries.length; i++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${values[i].toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: (values[i] / maxVal) * (constraints.maxHeight - 48),
                        width: barWidth.clamp(12, 28),
                        decoration: BoxDecoration(
                          color: summaries[i].isLive ? Colors.blueAccent : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summaries[i].isLive ? 'Today' : _shortDate(summaries[i].date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _shortDate(DateTime date) => '${date.month}/${date.day}';
}

class _ListView extends StatelessWidget {
  final List<_SummaryView> summaries;

  const _ListView({required this.summaries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final s = summaries[index];
        return Card(
          child: ListTile(
            title: Text(s.isLive ? 'Today (live)' : '${s.date.month}/${s.date.day}/${s.date.year}'),
            subtitle: Text(
              '${(s.completionRatio * 100).toStringAsFixed(1)}% completion • ${s.totalFocusedMinutes} focused mins',
            ),
            trailing: s.isLive
                ? const Icon(Icons.bolt, color: Colors.blueAccent)
                : const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReload;

  const _EmptyState({required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 48),
            const SizedBox(height: 12),
            const Text('No summaries yet'),
            const SizedBox(height: 6),
            const Text(
              'Close a day to create a summary or view live progress for today.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onReload,
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
