# Plan-Aware NextBestTask Implementation

## Summary

The `getNextBestTask` endpoint is now **plan-aware** - it only recommends tasks from today's saved DailyPlan, filtered by time eligibility.

## Key Changes

### 1. Updated `PlanningEndpoint.getNextBestTask()`

**Location:** [lib/src/endpoints/planning_endpoint.dart](lib/src/endpoints/planning_endpoint.dart)

**New Signature:**
```dart
Future<NextBestTaskResult?> getNextBestTask(
  Session session,
  int userId,  // NEW: requires userId parameter
)
```

**Logic Flow:**
1. ✅ Fetch today's saved DailyPlan from database
2. ✅ Extract eligible task IDs from plan slots (time-gated)
3. ✅ Filter pending tasks to only those in eligible set
4. ✅ Pass filtered tasks to NextBestTaskEngine
5. ✅ Return result with plan-aware explanation

### 2. Plan-Aware Rules Implemented

#### 🧠 Rule 1: Plan Defines Candidate Set
- Only considers tasks that appear in today's DailyPlan slots
- Tasks not in plan are **completely ignored**, even if pending

#### ⏱ Rule 2: Time-Gated Eligibility
- Formula: `slot.startTime <= now + 15 minutes`
- Grace window allows natural flow and early starts
- Future slots are filtered out

#### ⚖️ Rule 3: Scoring Decides Winner
- Among eligible tasks, NextBestTaskEngine runs normally
- Priority, urgency, energy match, and focus still apply
- Plan order is **not absolute** - engine decides best

#### 🧩 Rule 4: Plan-Aware Explanations
- Enhanced explanation: `"This task is scheduled in your plan and <original explanation>"`
- Maintains explainability transparency

### 3. Architecture Principles Followed

✅ **NextBestTaskEngine stays pure** - no plan logic inside engine
✅ **Orchestration in endpoint** - filtering happens in `PlanningEndpoint`
✅ **Plan = intent, Engine = advisor** - clean separation of concerns
✅ **No plan mutation** - read-only access to plan data

## Code Structure

### Modified Files
1. **[lib/src/endpoints/planning_endpoint.dart](lib/src/endpoints/planning_endpoint.dart)**
   - Updated `getNextBestTask()` method (lines ~14-130)
   - Added userId parameter
   - Implemented plan-aware filtering
   - Enhanced explanations

### Unchanged (By Design)
- **[lib/src/logic/next_best_task_engine.dart](lib/src/logic/next_best_task_engine.dart)** - remains pure
- **[lib/src/logic/next_best_task_result.dart](lib/src/logic/next_best_task_result.dart)** - no changes needed
- All planning engine logic - orthogonal concerns

## Testing

### New Integration Test: `plan_aware_next_best_task_test.dart`

**Location:** [test/integration/plan_aware_next_best_task_test.dart](test/integration/plan_aware_next_best_task_test.dart)

**Test Cases:**
1. ✅ Returns null when no plan exists
2. ✅ Returns null when all task slots are in future (beyond grace window)
3. ✅ Returns task when slot is eligible (started or imminent)
4. ✅ Ignores tasks not in plan (even if high priority)
5. ✅ Respects 15-minute grace window for imminent tasks

**All 5 tests passing** ✓

### Regression Tests
- ✅ `next_best_task_engine_test.dart` - engine still works correctly
- ✅ `task_endpoint_test.dart` - task status updates work

## Usage Examples

### Scenario 1: No Plan → No Recommendation
```dart
// No saved plan for today
final result = await endpoint.getNextBestTask(session, userId);
// result == null
```

### Scenario 2: Plan Exists, Tasks Eligible
```dart
// Plan has tasks starting now or within 15 min
final result = await endpoint.getNextBestTask(session, userId);
// result = NextBestTaskResult(taskId: 42, explanation: "This task is scheduled...")
```

### Scenario 3: Plan Exists, No Eligible Tasks
```dart
// Plan exists but all tasks start > 15 minutes from now
final result = await endpoint.getNextBestTask(session, userId);
// result == null
```

### Scenario 4: Ignores Non-Plan Tasks
```dart
// Task A (pending, high priority) - NOT in plan
// Task B (pending, medium priority) - IN plan, eligible
final result = await endpoint.getNextBestTask(session, userId);
// result.taskId == Task B (ignores Task A completely)
```

## Migration Guide

### Breaking Change: Method Signature
**Before:**
```dart
Future<NextBestTaskResult?> getNextBestTask(Session session)
```

**After:**
```dart
Future<NextBestTaskResult?> getNextBestTask(Session session, int userId)
```

### Client Code Updates Required
Flutter clients must pass `userId` when calling this endpoint:

```dart
// Before
final result = await client.planning.getNextBestTask();

// After  
final result = await client.planning.getNextBestTask(userId: currentUserId);
```

## System Behavior

### When No Plan Exists
- Returns `null` immediately
- User should be prompted to generate a plan first
- No fallback to unplanned tasks (by design)

### When Plan Exists
- Only plan tasks are candidates
- Time-gating filters by start time
- Engine scoring decides the best among eligible
- Explanation mentions plan context

### Task Lifecycle Integration
```
1. User creates tasks → pending status
2. DailyPlanningEngine generates plan → slots with taskId
3. Plan is saved → DailyPlan + DailyPlanSlot entities
4. getNextBestTask() → filters eligible slots
5. NextBestTaskEngine → scores eligible tasks
6. User completes task → updateTaskStatus
7. Next call to getNextBestTask() → excludes completed
```

## Edge Cases Handled

1. **No plan for today** → Returns null
2. **Plan exists but empty** → Returns null
3. **All slots are future** → Returns null
4. **All planned tasks completed** → Returns null (status filter)
5. **Task in plan but deleted from DB** → Gracefully skipped
6. **Multiple eligible tasks** → Engine decides winner by scoring
7. **Grace window boundary** → Task at exactly +15 min is eligible

## Configuration

### Grace Window
**Current:** 15 minutes  
**Location:** [planning_endpoint.dart](lib/src/endpoints/planning_endpoint.dart#L48)
```dart
final graceWindow = Duration(minutes: 15);
```

To adjust, modify this value. Suggested range: 10-30 minutes.

### Behind Schedule Threshold
**Current:** 50% completion  
**Location:** [planning_endpoint.dart](lib/src/endpoints/planning_endpoint.dart#L99)
```dart
final isUserBehindSchedule = totalTasks > 0 && 
    completedTasks < (totalTasks * 0.5);
```

## Future Enhancements (Out of Scope)

❌ **Not Implemented:**
- Dynamic plan reordering
- Auto-slot completion
- Task auto-skipping based on time
- Backlog pulling when plan exhausted
- Plan mutation APIs

These would violate "plan = intent, engine = advisor" principle.

## Verification Checklist

- ✅ NextBestTaskEngine unchanged (stays pure)
- ✅ Plan-aware filtering in endpoint
- ✅ Time-gate with 15-min grace window
- ✅ Only plan tasks considered
- ✅ Scoring still decides winner
- ✅ Plan-aware explanations
- ✅ 5 integration tests passing
- ✅ No compilation errors
- ✅ No regression in existing tests

## Technical Debt / TODOs

1. **User energy level** - currently hardcoded to 'medium'
   ```dart
   // TODO: Replace with real user energy level from context/profile
   userEnergyLevel: 'medium',
   ```

2. **Authentication** - userId passed as parameter, should use session.auth in production
   ```dart
   // Production: final userId = await session.auth.authenticatedUserId;
   ```

3. **Grace window configuration** - could be moved to user preferences

---

## Questions & Answers

**Q: What if I want to recommend backlog tasks when plan is exhausted?**  
A: That's a future feature. Would need explicit "pull from backlog" mode with clear UX indication.

**Q: Can the plan be auto-updated based on actual progress?**  
A: No. Plan = intent, not reality. User should regenerate plan if needed.

**Q: What if a task takes longer than planned?**  
A: Plan doesn't auto-adjust. getNextBestTask will recommend next eligible task from plan.

**Q: Can I force a specific task order?**  
A: No. Among eligible tasks, engine scoring decides. Plan defines candidates, not order.

---

**Status:** ✅ Complete and tested  
**Version:** Serverpod 3.1.0  
**Date:** December 20, 2025
