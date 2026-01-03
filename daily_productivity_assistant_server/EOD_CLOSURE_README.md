# End-of-Day (EOD) Closure Implementation

## Summary

The EOD closure system provides a mechanism to mark pending tasks as "missed" at day end (9 PM cutoff) and generate a historical DailySummary snapshot.

## Key Features

### 🕘 Rule 1: Fixed Cutoff Time
- **Day ends at 9:00 PM** (21:00) - fixed, not dynamic
- Defined in `DailyClosureService.eodHour = 21`
- Can be adjusted by changing constant

### 📦 Rule 2: DailyPlan is Frozen Forever
- At cutoff, DailyPlan **remains unchanged**
- DailyPlanSlots **remain unchanged**
- No regeneration or mutation
- Plan becomes historical record

### 🧾 Rule 3: Task Status at EOD
Action taken on tasks at day end:

| Task Status | Action |
|-------------|--------|
| `completed` | Leave as is |
| `skipped` | Leave as is (user explicitly skipped) |
| `pending` | Mark as `missed` (ran out of time) |

**New Status Added:** `missed`
- Critical differentiation: "user explicitly skipped" vs "user ran out of time"
- Enables accountability, weekly reflection, smarter future planning
- **Do not reuse `skipped` for this**

### 📊 Rule 4: DailySummary Generation
At day end, compute and persist:
- `totalTasksPlanned` - Total tasks in plan
- `completedCount` - Completed tasks
- `skippedCount` - Explicitly skipped
- `missedCount` - Marked as missed (were pending)
- `completionRatio` - Percentage complete (completed/total)
- `totalFocusedMinutes` - Sum of completed task durations
- `createdAt` - Timestamp of closure

**Important:** This is **derived data**, not editable.

## Architecture

### Files Created/Modified

1. **[lib/src/protocol/daily_summary.yaml](lib/src/protocol/daily_summary.yaml)**
   - Updated DailySummary entity with all required fields
   - Added unique index on (userId, date)

2. **[lib/src/protocol/task.yaml](lib/src/protocol/task.yaml)**
   - Documented 'missed' status in comments
   - No schema change (status stored as String)

3. **[lib/src/services/daily_closure_service.dart](lib/src/services/daily_closure_service.dart)**
   - New service handling EOD closure logic
   - Methods: `closeDay`, `getDailySummary`, `getDailySummaryRange`

4. **[lib/src/endpoints/planning_endpoint.dart](lib/src/endpoints/planning_endpoint.dart)**
   - Added `closeDay` endpoint method
   - Added `getDailySummary` endpoint method
   - Added `getDailySummaryRange` endpoint method

5. **[test/integration/eod_closure_test.dart](test/integration/eod_closure_test.dart)**
   - Comprehensive integration tests
   - 4 test cases covering all EOD scenarios

## How EOD is Triggered

**IMPORTANT:** Not automatic (yet)

❌ **NOT automatic cron** (for now)
❌ **NOT implicit on app open**
✅ **Explicit backend call**

### Endpoint Method

```dart
Future<DailySummary?> closeDay(
  Session session,
  int userId,
  DateTime? date, // Optional, defaults to today
)
```

**Usage:**
```dart
// Close today for user
final summary = await client.planning.closeDay(userId: 1, date: null);

// Close specific date
final summary = await client.planning.closeDay(
  userId: 1, 
  date: DateTime(2025, 12, 19),
);
```

**Later:**
- Flutter can call it (e.g., user taps "End Day" button)
- Schedule it via cron or task scheduler
- Auto-trigger at 9 PM via background service

## DailyClosureService Logic

### Flow

1. **Check if already closed** - idempotent
   - Query for existing DailySummary(userId, date)
   - If exists, return it (no-op)

2. **Find today's DailyPlan**
   - Query for DailyPlan(userId, date)
   - If no plan, create empty summary

3. **Extract task IDs from plan slots**
   - Filter slots where `taskId != null`
   - Build set of task IDs

4. **Mark pending → missed**
   - Query for tasks in plan
   - Filter where `status == 'pending'`
   - Update to `status = 'missed'`
   - Set `updatedAt = now`

5. **Compute statistics**
   - Count: completed, skipped, missed
   - Calculate: completion ratio
   - Sum: focused minutes (completed only)

6. **Persist DailySummary**
   - Create DailySummary entity
   - Insert into database
   - Return to caller

### Code Reference

**[lib/src/services/daily_closure_service.dart](lib/src/services/daily_closure_service.dart)**
```dart
static Future<DailySummary?> closeDay(
  Session session,
  int userId,
  DateTime date,
) async {
  // 1. Normalize date
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  // 2. Check existing (idempotent)
  final existingSummary = await DailySummary.db.findFirstRow(...);
  if (existingSummary != null) return existingSummary;
  
  // 3. Find plan
  final plan = await DailyPlan.db.findFirstRow(...);
  
  // 4. Extract task IDs
  final slots = await DailyPlanSlotEntity.db.find(...);
  final taskIds = slots.where(...).map(...).toSet();
  
  // 5. Fetch tasks
  final tasks = await Task.db.find(where: (t) => t.id.inSet(taskIds));
  
  // 6. Mark pending → missed
  for (final task in pendingTasks) {
    await Task.db.updateRow(session, task.copyWith(status: 'missed'));
  }
  
  // 7. Compute statistics
  final completionRatio = completedCount / totalPlanned;
  final totalFocusedMinutes = completedTasks.fold(...);
  
  // 8. Persist summary
  return await DailySummary.db.insertRow(session, summary);
}
```

## Testing

### Test File: [test/integration/eod_closure_test.dart](test/integration/eod_closure_test.dart)

**Test Cases:**
1. ✅ Marks pending tasks as missed and creates summary
2. ✅ Is idempotent - can be called multiple times safely
3. ✅ Handles empty plan - creates zero summary
4. ✅ Plan and slots remain unchanged after closure

**All 4 tests passing** ✓

### Test Scenario Example

```dart
// Given: 1 completed, 1 skipped, 2 pending
final summary = await endpoint.closeDay(session, userId, today);

// Then:
expect(summary.totalTasksPlanned, equals(4));
expect(summary.completedCount, equals(1));
expect(summary.skippedCount, equals(1));
expect(summary.missedCount, equals(2)); // Pending → missed
expect(summary.completionRatio, equals(0.25));
expect(summary.totalFocusedMinutes, equals(30));

// Verify tasks marked
final refetched = await Task.db.findById(session, pendingTaskId);
expect(refetched.status, equals('missed'));
```

## Database Schema

### DailySummary Table

```sql
CREATE TABLE daily_summary (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  date TIMESTAMP NOT NULL,
  total_tasks_planned INTEGER NOT NULL,
  completed_count INTEGER NOT NULL,
  skipped_count INTEGER NOT NULL,
  missed_count INTEGER NOT NULL,
  completion_ratio DOUBLE PRECISION NOT NULL,
  total_focused_minutes INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL,
  CONSTRAINT daily_summary_user_date_idx UNIQUE (user_id, date)
);
```

**Migration:** [migrations/20251220032731145](migrations/20251220032731145)
- Drops old columns: `completedTasks`, `missedTasks`, `insights`
- Adds new columns: `userId`, `totalTasksPlanned`, etc.
- Recreates table (safe for test environment)

### Task Status Values

No schema change - `status` remains `String` type.

**Valid values:**
- `'pending'` - Not yet done
- `'completed'` - Finished by user
- `'skipped'` - Explicitly skipped by user
- `'missed'` - Was pending at day end (9 PM)

## Usage Examples

### Scenario 1: End Today's Day

```dart
// User taps "End Day" button in Flutter
final summary = await client.planning.closeDay(
  userId: currentUserId,
  date: null, // Defaults to today
);

print('You completed ${summary.completedCount} tasks!');
print('Completion rate: ${(summary.completionRatio * 100).toStringAsFixed(1)}%');
print('Focused time: ${summary.totalFocusedMinutes} minutes');
```

### Scenario 2: View Weekly Summary

```dart
// Get last 7 days
final startDate = DateTime.now().subtract(Duration(days: 7));
final endDate = DateTime.now();

final summaries = await client.planning.getDailySummaryRange(
  userId: currentUserId,
  startDate: startDate,
  endDate: endDate,
);

// Calculate weekly stats
final weeklyCompleted = summaries.fold(0, (sum, s) => sum + s.completedCount);
final weeklyFocused = summaries.fold(0, (sum, s) => sum + s.totalFocusedMinutes);
final avgCompletion = summaries.map((s) => s.completionRatio).average;
```

### Scenario 3: Idempotent Re-Close

```dart
// Call closeDay multiple times - safe
final summary1 = await client.planning.closeDay(userId: 1, date: today);
final summary2 = await client.planning.closeDay(userId: 1, date: today);

// summary1.id == summary2.id (same record returned)
// Tasks only marked once (not double-processed)
```

## Edge Cases Handled

1. **No plan exists** → Creates empty summary (all zeros)
2. **Plan has no tasks** → Creates empty summary
3. **Day already closed** → Returns existing summary (idempotent)
4. **Task deleted from DB but in plan** → Gracefully skipped
5. **Multiple calls** → Only first call creates summary, subsequent return existing
6. **All tasks already completed/skipped** → missedCount = 0

## What This Does NOT Do

❌ **Does NOT auto-carry tasks forward** to next day
❌ **Does NOT regenerate tomorrow's plan**
❌ **Does NOT delete anything** (tasks, plans, slots)
❌ **Does NOT mutate the plan** (plan is frozen)
❌ **Does NOT auto-trigger** (requires explicit call)

## Future Enhancements (Out of Scope)

1. **Automatic scheduling** - Cron job at 9 PM
2. **Carry forward missed tasks** - Optional feature to auto-add to next day
3. **Push notification** - Remind user to end day
4. **Insights generation** - AI-generated recommendations based on summary
5. **Configurable cutoff time** - Per-user EOD time preference
6. **Weekly/monthly rollups** - Aggregate summaries for longer periods

## Integration with Existing Features

### With NextBestTaskEngine
- Pending tasks eligible for recommendation until EOD
- After EOD, missed tasks excluded from recommendations
- Engine filters on `status == 'pending'`

### With DailyPlan
- Plan remains frozen after EOD
- No regeneration or auto-adjustment
- User must manually create new plan for next day

### With TaskEndpoint
- Tasks can still be updated after EOD
- If user completes a "missed" task later, it stays missed in summary
- Summary is historical snapshot, not live

## Verification Checklist

- ✅ DailySummary entity created with all fields
- ✅ 'missed' status documented in task.yaml
- ✅ DailyClosureService implemented
- ✅ closeDay endpoint added
- ✅ getDailySummary endpoint added
- ✅ getDailySummaryRange endpoint added
- ✅ Migration created and applied
- ✅ 4 integration tests passing
- ✅ Zero compilation errors
- ✅ Idempotent behavior verified
- ✅ Plan remains frozen verified

## Configuration

### EOD Cutoff Time

**Location:** [lib/src/services/daily_closure_service.dart](lib/src/services/daily_closure_service.dart#L18)

```dart
static const eodHour = 21; // 9 PM
```

To adjust:
1. Change `eodHour` constant
2. No migration needed
3. Affects future closures only

**Recommended range:** 20-23 (8 PM to 11 PM)

## Technical Debt / TODOs

1. **Automatic scheduling** - Need cron/scheduler integration
2. **Push notifications** - Remind users to end day
3. **Batch closure** - Close multiple users at once (performance optimization)
4. **Soft delete summary** - Allow re-opening day if needed
5. **Audit trail** - Track who/when closed day (for multi-user workspaces)

---

## Questions & Answers

**Q: What if user forgets to close the day?**
A: Day remains unclosed. Can close retrospectively. Late closure is acceptable.

**Q: Can user reopen a closed day?**
A: Not currently supported. Summary is immutable. Would need soft-delete feature.

**Q: What if task was completed but marked missed?**
A: Summary reflects state at EOD time. If completed after EOD, summary won't update.

**Q: Can I change the cutoff time per user?**
A: Not yet. Currently global 9 PM. Would need user preference table.

**Q: Do missed tasks disappear?**
A: No. Tasks remain in database with `status = 'missed'`. User can still view/update them.

---

**Status:** ✅ Complete and tested
**Version:** Serverpod 3.1.0
**Date:** December 20, 2025
