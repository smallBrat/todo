import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Service for persisting daily plans and their slots to the database
class DailyPlanPersistenceService {
  /// Saves a DailyPlanResponse to the database
  ///
  /// Creates a DailyPlan record and all associated DailyPlanSlotEntity records.
  /// Returns the saved DailyPlan with populated id.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user who owns this plan
  /// [planResponse] - The plan response to persist
  static Future<DailyPlan> saveDailyPlan(
    Session session,
    int userId,
    DailyPlanResponse planResponse,
  ) async {
    // STEP 1: Create the parent DailyPlan record
    final dailyPlan = DailyPlan(
      userId: userId,
      date: planResponse.date,
      totalTaskMinutes: planResponse.totalTaskMinutes,
      totalBreakMinutes: planResponse.totalBreakMinutes,
      freeMinutes: planResponse.freeMinutes,
      createdAt: DateTime.now(),
    );

    // STEP 2: Insert the DailyPlan into the database
    final savedPlan = await DailyPlan.db.insertRow(session, dailyPlan);

    // STEP 3: Insert all slots associated with this plan
    if (planResponse.slots.isNotEmpty) {
      final slotEntities = planResponse.slots.map((slot) {
        return DailyPlanSlotEntity(
          planId: savedPlan.id!,
          startTime: slot.startTime,
          endTime: slot.endTime,
          durationMinutes: slot.durationMinutes,
          type: slot.type,
          title: slot.title,
          taskId: slot.taskId,
          energyLevel: slot.energyLevel,
          priority: slot.priority,
        );
      }).toList();

      // Insert all slots in batch
      await DailyPlanSlotEntity.db.insert(session, slotEntities);
    }

    return savedPlan;
  }

  /// Retrieves an existing plan for the day or creates a new one if none exists.
  ///
  /// This enforces idempotency for plan creation.
  static Future<DailyPlan> getOrCreateDailyPlan(
    Session session,
    int userId,
    DailyPlanResponse planResponse,
  ) async {
    // Normalize date to midnight for lookup
    final date = DateTime(
      planResponse.date.year,
      planResponse.date.month,
      planResponse.date.day,
    );

    // Check if plan already exists
    final existingPlan = await getDailyPlan(session, userId, date);
    if (existingPlan != null) {
      return existingPlan;
    }

    // Create new plan if none exists
    return await saveDailyPlan(session, userId, planResponse);
  }

  /// Retrieves a daily plan for a user on a specific date
  ///
  /// Returns null if no plan exists for that date.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve the plan for
  static Future<DailyPlan?> getDailyPlan(
    Session session,
    int userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final plans = await DailyPlan.db.find(
      session,
      where: (plan) =>
          (plan.userId.equals(userId)) &
          (plan.date >= startOfDay) &
          (plan.date <= endOfDay),
      limit: 1,
    );

    return plans.isNotEmpty ? plans.first : null;
  }

  /// Retrieves all slots for a specific daily plan
  ///
  /// [session] - Serverpod session for database access
  /// [planId] - ID of the daily plan
  static Future<List<DailyPlanSlotEntity>> getPlanSlots(
    Session session,
    int planId,
  ) async {
    return await DailyPlanSlotEntity.db.find(
      session,
      where: (slot) => slot.planId.equals(planId),
      orderBy: (slot) => slot.startTime,
    );
  }

  /// Retrieves a complete daily plan with all its slots
  ///
  /// Returns a DailyPlanResponse reconstructed from database records.
  /// Returns null if no plan exists for that date.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve the plan for
  static Future<DailyPlanResponse?> getCompleteDailyPlan(
    Session session,
    int userId,
    DateTime date,
  ) async {
    // Get the plan
    final plan = await getDailyPlan(session, userId, date);
    if (plan == null) return null;

    // Get all slots for this plan
    final slotEntities = await getPlanSlots(session, plan.id!);

    // Convert slot entities back to DailyPlanSlot DTOs
    final slots = slotEntities.map((entity) {
      return DailyPlanSlot(
        startTime: entity.startTime,
        endTime: entity.endTime,
        type: entity.type,
        title: entity.title,
        durationMinutes: entity.durationMinutes,
        taskId: entity.taskId,
        energyLevel: entity.energyLevel,
        priority: entity.priority,
      );
    }).toList();

    // Return reconstructed response
    return DailyPlanResponse(
      date: plan.date,
      slots: slots,
      totalTaskMinutes: plan.totalTaskMinutes,
      totalBreakMinutes: plan.totalBreakMinutes,
      freeMinutes: plan.freeMinutes,
    );
  }

  /// Deletes a daily plan and all its associated slots
  ///
  /// [session] - Serverpod session for database access
  /// [planId] - ID of the plan to delete
  static Future<void> deleteDailyPlan(
    Session session,
    int planId,
  ) async {
    // Delete all slots first (child records)
    await DailyPlanSlotEntity.db.deleteWhere(
      session,
      where: (slot) => slot.planId.equals(planId),
    );

    // Delete the plan itself
    await DailyPlan.db.deleteWhere(
      session,
      where: (plan) => plan.id.equals(planId),
    );
  }
}
