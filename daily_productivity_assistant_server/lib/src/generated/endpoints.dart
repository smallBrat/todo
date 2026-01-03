/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/dev_seed_endpoint.dart' as _i2;
import '../endpoints/greeting_endpoint.dart' as _i3;
import '../endpoints/planning_endpoint.dart' as _i4;
import '../endpoints/task_endpoint.dart' as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'devSeed': _i2.DevSeedEndpoint()
        ..initialize(
          server,
          'devSeed',
          null,
        ),
      'greeting': _i3.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'planning': _i4.PlanningEndpoint()
        ..initialize(
          server,
          'planning',
          null,
        ),
      'task': _i5.TaskEndpoint()
        ..initialize(
          server,
          'task',
          null,
        ),
    };
    connectors['devSeed'] = _i1.EndpointConnector(
      name: 'devSeed',
      endpoint: endpoints['devSeed']!,
      methodConnectors: {
        'seedTasks': _i1.MethodConnector(
          name: 'seedTasks',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['devSeed'] as _i2.DevSeedEndpoint)
                  .seedTasks(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i3.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['planning'] = _i1.EndpointConnector(
      name: 'planning',
      endpoint: endpoints['planning']!,
      methodConnectors: {
        'getNextBestTask': _i1.MethodConnector(
          name: 'getNextBestTask',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .getNextBestTask(
                    session,
                    params['userId'],
                  ),
        ),
        'getTodayTimeline': _i1.MethodConnector(
          name: 'getTodayTimeline',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .getTodayTimeline(session),
        ),
        'getDailyPlan': _i1.MethodConnector(
          name: 'getDailyPlan',
          params: {
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['planning'] as _i4.PlanningEndpoint).getDailyPlan(
                    session,
                    params['date'],
                  ),
        ),
        'generateAndSavePlan': _i1.MethodConnector(
          name: 'generateAndSavePlan',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .generateAndSavePlan(
                    session,
                    params['userId'],
                    params['date'],
                  ),
        ),
        'getSavedPlan': _i1.MethodConnector(
          name: 'getSavedPlan',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['planning'] as _i4.PlanningEndpoint).getSavedPlan(
                    session,
                    params['userId'],
                    params['date'],
                  ),
        ),
        'deleteSavedPlan': _i1.MethodConnector(
          name: 'deleteSavedPlan',
          params: {
            'planId': _i1.ParameterDescription(
              name: 'planId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .deleteSavedPlan(
                    session,
                    params['planId'],
                  ),
        ),
        'closeDay': _i1.MethodConnector(
          name: 'closeDay',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['planning'] as _i4.PlanningEndpoint).closeDay(
                    session,
                    params['userId'],
                    params['date'],
                  ),
        ),
        'getDailySummary': _i1.MethodConnector(
          name: 'getDailySummary',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .getDailySummary(
                    session,
                    params['userId'],
                    params['date'],
                  ),
        ),
        'getDailySummaryRange': _i1.MethodConnector(
          name: 'getDailySummaryRange',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'startDate': _i1.ParameterDescription(
              name: 'startDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'endDate': _i1.ParameterDescription(
              name: 'endDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .getDailySummaryRange(
                    session,
                    params['userId'],
                    params['startDate'],
                    params['endDate'],
                  ),
        ),
        'updateTaskStatus': _i1.MethodConnector(
          name: 'updateTaskStatus',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['planning'] as _i4.PlanningEndpoint)
                  .updateTaskStatus(
                    session,
                    params['taskId'],
                    params['status'],
                  ),
        ),
      },
    );
    connectors['task'] = _i1.EndpointConnector(
      name: 'task',
      endpoint: endpoints['task']!,
      methodConnectors: {
        'createTask': _i1.MethodConnector(
          name: 'createTask',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'goalId': _i1.ParameterDescription(
              name: 'goalId',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'scheduledTime': _i1.ParameterDescription(
              name: 'scheduledTime',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'deadline': _i1.ParameterDescription(
              name: 'deadline',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'estimatedDuration': _i1.ParameterDescription(
              name: 'estimatedDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'priority': _i1.ParameterDescription(
              name: 'priority',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'energyLevel': _i1.ParameterDescription(
              name: 'energyLevel',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i5.TaskEndpoint).createTask(
                session,
                params['title'],
                goalId: params['goalId'],
                scheduledTime: params['scheduledTime'],
                deadline: params['deadline'],
                estimatedDuration: params['estimatedDuration'],
                priority: params['priority'],
                energyLevel: params['energyLevel'],
              ),
        ),
        'updateTaskStatus': _i1.MethodConnector(
          name: 'updateTaskStatus',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'newStatus': _i1.ParameterDescription(
              name: 'newStatus',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['task'] as _i5.TaskEndpoint).updateTaskStatus(
                    session,
                    params['taskId'],
                    params['newStatus'],
                  ),
        ),
        'updateTaskDetails': _i1.MethodConnector(
          name: 'updateTaskDetails',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'priority': _i1.ParameterDescription(
              name: 'priority',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'estimatedDuration': _i1.ParameterDescription(
              name: 'estimatedDuration',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'scheduledTime': _i1.ParameterDescription(
              name: 'scheduledTime',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['task'] as _i5.TaskEndpoint).updateTaskDetails(
                    session,
                    params['taskId'],
                    title: params['title'],
                    priority: params['priority'],
                    estimatedDuration: params['estimatedDuration'],
                    scheduledTime: params['scheduledTime'],
                  ),
        ),
        'deleteTask': _i1.MethodConnector(
          name: 'deleteTask',
          params: {
            'taskId': _i1.ParameterDescription(
              name: 'taskId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['task'] as _i5.TaskEndpoint).deleteTask(
                session,
                params['taskId'],
              ),
        ),
      },
    );
  }
}
