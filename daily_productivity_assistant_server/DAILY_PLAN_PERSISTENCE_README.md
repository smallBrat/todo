# Daily Plan Persistence Implementation

This implementation adds database persistence for daily plans and their time slots to the Serverpod 3.1.0 backend.

## Files Created/Modified

### Protocol Files (YAML)
- `lib/src/protocol/daily_plan.yaml` - DailyPlan table definition
- `lib/src/protocol/daily_plan_slot_entity.yaml` - DailyPlanSlotEntity table definition

### Service Layer
- `lib/src/services/daily_plan_persistence_service.dart` - Persistence logic for plans and slots

### Endpoint Updates
- `lib/src/endpoints/planning_endpoint.dart` - Added persistence methods

### Test Scripts
- `bin/test_plan_persistence.dart` - Test script for persistence functionality

## Database Schema

### `daily_plan` Table
- `id` - bigint, PK, auto-increment
- `user_id` - bigint, FK to users
- `date` - timestamp, the plan date
- `total_task_minutes` - integer
- `total_break_minutes` - integer  
- `free_minutes` - integer
- `created_at` - timestamp, default now()
- Index on `(user_id, date)`

### `daily_plan_slot` Table
- `id` - bigint, PK, auto-increment
- `plan_id` - bigint, FK to daily_plan
- `start_time` - timestamp
- `end_time` - timestamp
- `duration_minutes` - integer
- `type` - varchar (task/break/idle)
- `title` - varchar
- `task_id` - bigint, nullable, FK to task
- `energy_level` - varchar, nullable
- `priority` - varchar, nullable
- Index on `plan_id`

## Setup Instructions

### 1. Run Serverpod Code Generation
```bash
serverpod generate
```

If you get errors, make sure:
- All protocol YAML files use `scope=serverOnly` instead of deprecated `database=serial`
- Run `dart pub get` first if needed

This will:
- Generate `lib/src/generated/daily_plan.dart`
- Generate `lib/src/generated/daily_plan_slot_entity.dart`
- Update `lib/src/generated/protocol.dart`
- Create database migration files

### 2. Create Database Migration
```bash
serverpod create-migration
```

This creates a new migration in the `migrations/` folder.

### 3. Apply Migration to Database
Make sure your PostgreSQL database is running in Docker, then:

```bash
# Development database
serverpod migrate --mode development

# Or apply manually via Docker
docker exec -i serverpod-postgres psql -U postgres -d daily_productivity_assistant < migrations/XXXXXX/migration.sql
```

### 4. Verify Tables Created
```bash
docker exec -it serverpod-postgres psql -U postgres -d daily_productivity_assistant

# In psql:
\dt              # List all tables
\d daily_plan    # Describe daily_plan table
\d daily_plan_slot  # Describe daily_plan_slot table
```

## API Usage

### Generate and Save a Plan
```dart
final plan = await planningEndpoint.generateAndSavePlan(
  session,
  userId: 1,
  date: DateTime.now(),
);
```

### Retrieve a Saved Plan
```dart
final plan = await planningEndpoint.getSavedPlan(
  session,
  userId: 1,
  date: DateTime.now(),
);
```

### Delete a Plan
```dart
await planningEndpoint.deleteSavedPlan(
  session,
  planId: 123,
);
```

## Testing

**Note**: The test script has been simplified. To test persistence:

### Option 1: Start the server and use API calls
```bash
# Terminal 1: Start the server
dart run bin/main.dart

# Terminal 2: Use curl or HTTP client to call endpoints
curl -X POST http://localhost:8080/planning/generateAndSavePlan \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "date": "2025-12-17T00:00:00.000Z"}'
```

### Option 2: Use existing test scripts
```bash
# Test the planning logic (in-memory)
dart run bin/test_daily_planning.dart
```

### Manual Database Verification
```bash
docker exec -it serverpod-postgres psql -U postgres -d daily_productivity_assistant

SELECT * FROM daily_plan;
SELECT * FROM daily_plan_slot ORDER BY start_time;
```

## Key Features

✅ **Serverpod 3 Idioms** - Uses ORM methods (insert, find, deleteWhere)  
✅ **Session-Based Access** - All DB operations use Serverpod session  
✅ **Clean Separation** - Parent DailyPlan + child DailyPlanSlotEntity  
✅ **Foreign Key Relations** - Proper FK constraints with indexes  
✅ **Nullable Fields** - taskId, energyLevel, priority are optional  
✅ **No Core Table Manipulation** - Only custom tables  
✅ **Batch Inserts** - Efficient slot persistence  
✅ **Timestamps** - Automatic createdAt tracking  

## Architecture Notes

- **DailyPlanResponse** - DTO for client communication (no table)
- **DailyPlan** - Database entity for persisted plans
- **DailyPlanSlot** - DTO for time slots in responses
- **DailyPlanSlotEntity** - Database entity for persisted slots
- **DailyPlanPersistenceService** - Service layer for all DB operations
- **PlanningEndpoint** - Endpoint methods for plan CRUD operations

## Edge Cases Handled

1. **Empty Slots** - Plan with zero slots still creates DailyPlan record
2. **Null taskId** - Properly handled for break/idle slots
3. **Null energyLevel/priority** - Optional fields stored as NULL
4. **Multiple Plans Per Day** - Allowed (no unique constraint on user_id + date)
5. **Cascade Deletes** - Service deletes slots before plan

## Next Steps

1. Add user authentication integration
2. Add plan update functionality
3. Add pagination for historical plans
4. Add analytics queries (completed vs planned)
5. Add soft deletes with `deleted_at` timestamp
