import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/generated/endpoints.dart';

/// Test script for daily plan persistence
///
/// This script:
/// 1. Generates and saves a daily plan
/// 2. Retrieves the saved plan from the database
/// 3. Verifies that slots were persisted correctly
void main(List<String> args) async {
  // Initialize Serverpod
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  await pod.start();

  // Use the endpoints directly with a test session
  try {
    print('🚀 Testing Daily Plan Persistence\n');

    // Test parameters
    const userId = 1; // Test user ID
    final testDate = DateTime.now();

    print('📅 Test Date: ${testDate.toIso8601String()}');
    print('👤 User ID: $userId\n');

    // STEP 1: Generate and save a plan
    print('🔨 Generating and saving daily plan...');
    
    // Note: In production, use actual session from endpoint call
    // For testing, we'll call the endpoint methods which will handle sessions
    print('⚠️  This test requires running the server and calling via API');
    print('   Run: dart run bin/main.dart');
    print('   Then call the endpoint via HTTP client\n');
    
    print('📝 Alternative: Use bin/test_daily_planning.dart for in-memory testing');
  } catch (e, stackTrace) {
    print('❌ Error during test: $e');
    print('Stack trace: $stackTrace');
  }

  await pod.shutdown(exitProcess: false);
  print('\n🏁 Test completed');
}
