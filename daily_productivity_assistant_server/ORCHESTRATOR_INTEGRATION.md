<!-- markdownlint-disable MD022 MD031 MD032 MD040 -->
# DailyPlanningOrchestrator Integration Guide

## Overview

`DailyPlanningOrchestrator` is a service layer that coordinates:
- Logic engines (pure Dart, no Serverpod)
- Database operations (Task queries, plan persistence)
- DTO mapping (DB models ↔ protocol DTOs)

## Architecture Layers

```
┌─────────────────────────────────────┐
│   Endpoints (API Layer)             │  ← planning_endpoint.dart
│   - Validate input                  │
│   - Call orchestrator               │
│   - Return DTOs                     │
└─────────────────────────────────────┘
                ↓
┌─────────────────────────────────────┐
│   Services (Orchestration)          │  ← daily_planning_orchestrator.dart
│   - Fetch from DB                   │
│   - Map models                      │
│   - Call engines                    │
│   - Persist results                 │
└─────────────────────────────────────┘
                ↓
┌─────────────────────────────────────┐
│   Logic (Pure Planning Engines)     │  ← daily_planning_engine.dart
│   - No Serverpod imports            │     next_best_task_engine.dart
│   - Pure functions                  │
│   - Return logic models             │
└─────────────────────────────────────┘
```

## Usage Examples

### 1. Generate Daily Plan

**Before (endpoint calling engine directly):**
```dart
// ❌ DON'T: Endpoint calling engine + DB
Future<proto.DailyPlanResponse> generatePlan(Session session, int userId, DateTime date) async {
  final tasks = await proto.Task.db.find(...);
  final timeline = DailyPlanningEngine.generateTimeline(...);
  // Manual DTO mapping...
  // Manual persistence...
}
```

**After (using orchestrator):**
```dart
// ✅ DO: Use orchestrator
Future<proto.DailyPlanResponse> generatePlan(Session session, int userId, DateTime date) async {
  return await DailyPlanningOrchestrator.generateAndSaveDailyPlan(
    session,
    userId,
    date,
  );
}
```

### 2. Get Next Best Task

**Before:**
```dart
// ❌ DON'T: Complex logic in endpoint
Future<proto.NextBestTaskResult?> getNextTask(Session session, int userId) async {
  final tasks = await proto.Task.db.find(...);
  final pending = tasks.where(...).toList();
  final eligible = pending.where(...).toList();
  final isUserBehind = ...; // Complex calculation
  final result = NextBestTaskEngine.getNextBestTask(...);
  // Manual DTO mapping...
}
```

**After:**
```dart
// ✅ DO: Use orchestrator
Future<proto.NextBestTaskResult?> getNextTask(Session session, int userId) async {
  return await DailyPlanningOrchestrator.getNextBestTaskRecommendation(
    session,
    userId,
    DateTime.now(),
    userEnergyLevel: 'medium', // From user profile/context
  );
}
```

### 3. Fetch Tasks for Date

**Before:**
```dart
// ❌ DON'T: Duplicate filtering logic
final tasks = await proto.Task.db.find(session, where: (t) => t.goalId.equals(userId));
final startOfDay = DateTime(...);
final endOfDay = DateTime(...);
final filtered = tasks.where((t) {
  if (t.scheduledTime == null) return true;
  final s = t.scheduledTime!.toLocal();
  return !s.isBefore(startOfDay) && !s.isAfter(endOfDay);
}).toList();
```

**After:**
```dart
// ✅ DO: Use orchestrator helper
final tasks = await DailyPlanningOrchestrator.fetchTasksForDate(
  session,
  userId,
  date,
  includeCompleted: true, // or false
);
```

## Key Benefits

### 1. Separation of Concerns
- **Endpoints**: Thin API layer, just validate & respond
- **Orchestrator**: Business logic coordination
- **Engines**: Pure algorithms, testable in isolation

### 2. Reusability
- Same orchestrator methods used by multiple endpoints
- No duplicate DB queries or mapping logic
- Engines remain framework-agnostic

### 3. Testability
```dart
// Test engine without DB
test('DailyPlanningEngine generates correct timeline', () {
  final tasks = [Task(...)];
  final result = DailyPlanningEngine.generateTimeline(
    day: DateTime(2025, 12, 24),
    tasks: tasks,
  );
  expect(result.length, 5);
});

// Test orchestrator with mock DB
test('Orchestrator maps results correctly', () async {
  final mockSession = ...;
  final result = await DailyPlanningOrchestrator.generateAndSaveDailyPlan(
    mockSession, 1, DateTime.now(),
  );
  expect(result.slots.length, greaterThan(0));
});
```

### 4. Maintainability
- Change engine logic → no endpoint changes
- Change DTO structure → update orchestrator mapping only
- Add new orchestration methods → no engine changes

## Rules Enforced

### 1. DateTime Handling
✅ **All times are LOCAL** - no UTC conversion
```dart
final scheduled = task.scheduledTime!.toLocal(); // Always convert from DB
final now = DateTime.now(); // Local time
```

### 2. Engine Purity
✅ **Engines NEVER import Serverpod**
```dart
// logic/daily_planning_engine.dart
import 'package:daily_productivity_assistant_server/src/generated/task.dart'; // ✅ OK
import 'package:serverpod/serverpod.dart'; // ❌ FORBIDDEN
```

### 3. Engine Output Fields
✅ **suggestedStart, scores are NOT user-editable**
```dart
// Only orchestrator can set these:
await DailyPlanningOrchestrator.updateTaskSuggestedStart(
  session, taskId, suggestedStart,
);
// User endpoints CANNOT modify these fields
```

### 4. DB Writes Ownership
✅ **Orchestrator owns planning-related DB writes**
```dart
// Orchestrator writes:
// - DailyPlan records
// - DailyPlanSlotEntity records
// - Task.suggestedStart updates
// - Task.updatedAt timestamps

// Task endpoint writes:
// - Task.status updates
// - Task.completedAt timestamps
```

## Migration Path

### Phase 1: Add orchestrator calls alongside existing code
```dart
Future<proto.DailyPlanResponse> generatePlan(...) async {
  // Old logic (keep for now)
  final tasks = await proto.Task.db.find(...);
  final timeline = DailyPlanningEngine.generateTimeline(...);
  
  // New orchestrator (run in parallel for validation)
  final orchestratorResult = await DailyPlanningOrchestrator.generateAndSaveDailyPlan(...);
  
  // Compare results, log differences
  _compareResults(oldResult, orchestratorResult);
  
  return oldResult; // Keep using old for now
}
```

### Phase 2: Switch to orchestrator, keep old as fallback
```dart
Future<proto.DailyPlanResponse> generatePlan(...) async {
  try {
    return await DailyPlanningOrchestrator.generateAndSaveDailyPlan(...);
  } catch (e) {
    session.log('Orchestrator failed, using fallback: $e');
    // Fallback to old logic
  }
}
```

### Phase 3: Remove old logic entirely
```dart
Future<proto.DailyPlanResponse> generatePlan(...) async {
  return await DailyPlanningOrchestrator.generateAndSaveDailyPlan(...);
}
```

## Debugging

### Enable orchestrator logging
```dart
// In planning_endpoint.dart:
final result = await DailyPlanningOrchestrator.generateAndSaveDailyPlan(
  session,
  userId,
  date,
);
// Check server logs for:
// 🎯 Orchestrator: Fetched X tasks for user Y
// 📅 Orchestrator: X tasks relevant for date
// ⏱️ Orchestrator: Generated X timeline slots
// 💾 Orchestrator: Persisted plan with X slots
```

### Verify DB persistence
```sql
-- Check created plans
SELECT * FROM daily_plan WHERE user_id = 1 ORDER BY created_at DESC LIMIT 5;

-- Check timeline slots
SELECT * FROM daily_plan_slot_entity 
WHERE plan_id = (SELECT id FROM daily_plan WHERE user_id = 1 ORDER BY created_at DESC LIMIT 1);
```

### Test engine output directly
```dart
// In Dart console or test:
final tasks = [
  Task(id: 1, title: 'Test', scheduledTime: DateTime(2025,12,24,10,0), ...),
];
final timeline = DailyPlanningEngine.generateTimeline(
  day: DateTime(2025,12,24),
  tasks: tasks,
);
print(timeline); // Debug engine output
```
