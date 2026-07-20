// test/dashboard/tasks_provider_test.dart
//
// Unit tests for TasksProvider using mocktail to mock TasksRepository.
// Tests verify state transitions (loading, error, tasks list) for the core task operations.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/dashboard/data/tasks_repository.dart';
import 'package:frontend/features/dashboard/model/task_model.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockTasksRepository extends Mock implements TasksRepository {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

TaskModel _fakeTask({
  int id = 1,
  String title = 'Test Task',
  String status = 'UPCOMING',
}) {
  final now = DateTime.now();
  return TaskModel(
    id: id,
    title: title,
    description: 'Test description',
    startTime: now,
    deadline: now.add(const Duration(hours: 2)),
    status: status,
    createdAt: now,
    updatedAt: now,
    userId: 1,
    subtasks: const [],
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockTasksRepository mockRepo;
  late TasksProvider provider;

  setUp(() {
    mockRepo = MockTasksRepository();
    provider = TasksProvider(mockRepo);
  });

  // ---------------------------------------------------------------------------
  // fetchTasks()
  // ---------------------------------------------------------------------------
  group('fetchTasks()', () {
    test('populates tasks list and clears loading on success', () async {
      final fakeTasks = [_fakeTask(id: 1), _fakeTask(id: 2)];
      when(() => mockRepo.getTasks()).thenAnswer((_) async => fakeTasks);

      await provider.fetchTasks(refresh: true);

      expect(provider.tasks, hasLength(2));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.hasInitialLoad, isTrue);
    });

    test('sets error and rethrows on failure', () async {
      when(() => mockRepo.getTasks())
          .thenThrow(Exception('Network error'));

      await expectLater(
        () => provider.fetchTasks(refresh: true),
        throwsA(isA<Exception>()),
      );

      expect(provider.tasks, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Network error'));
    });

    test('returns empty list when repository returns nothing', () async {
      when(() => mockRepo.getTasks()).thenAnswer((_) async => []);

      await provider.fetchTasks(refresh: true);

      expect(provider.tasks, isEmpty);
      expect(provider.isLoading, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // deleteTask()
  // ---------------------------------------------------------------------------
  group('deleteTask()', () {
    test('removes task from list on success', () async {
      final fakeTasks = [_fakeTask(id: 1), _fakeTask(id: 2)];
      when(() => mockRepo.getTasks()).thenAnswer((_) async => fakeTasks);
      await provider.fetchTasks(refresh: true);

      when(() => mockRepo.deleteTask(1))
          .thenAnswer((_) async {});

      await provider.deleteTask(1);

      expect(provider.tasks, hasLength(1));
      expect(provider.tasks.first.id, 2);
    });

    test('sets error on delete failure', () async {
      final fakeTasks = [_fakeTask(id: 1)];
      when(() => mockRepo.getTasks()).thenAnswer((_) async => fakeTasks);
      await provider.fetchTasks(refresh: true);

      when(() => mockRepo.deleteTask(1))
          .thenThrow(Exception('Delete failed'));

      await expectLater(
        () => provider.deleteTask(1),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // toggleTaskStatus()
  // ---------------------------------------------------------------------------
  group('toggleTaskStatus()', () {
    test('optimistically toggles status to COMPLETED', () async {
      final fakeTasks = [_fakeTask(id: 1, status: 'UPCOMING')];
      when(() => mockRepo.getTasks()).thenAnswer((_) async => fakeTasks);
      await provider.fetchTasks(refresh: true);

      when(() => mockRepo.updateTaskStatus(
            taskId: any(named: 'taskId'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => _fakeTask(id: 1, status: 'COMPLETED'));

      await provider.toggleTaskStatus(1);

      expect(provider.tasks.first.status, 'COMPLETED');
    });

    test('optimistically toggles COMPLETED task back to PROGRESS', () async {
      final fakeTasks = [_fakeTask(id: 1, status: 'COMPLETED')];
      when(() => mockRepo.getTasks()).thenAnswer((_) async => fakeTasks);
      await provider.fetchTasks(refresh: true);

      when(() => mockRepo.updateTaskStatus(
            taskId: any(named: 'taskId'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => _fakeTask(id: 1, status: 'PROGRESS'));

      await provider.toggleTaskStatus(1);

      expect(provider.tasks.first.status, 'PROGRESS');
    });

    test('does nothing when task id does not exist', () async {
      when(() => mockRepo.getTasks()).thenAnswer((_) async => []);
      await provider.fetchTasks(refresh: true);

      // Should not throw — task id not found is a no-op
      await provider.toggleTaskStatus(999);

      expect(provider.tasks, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // todaysTasks computed getter
  // ---------------------------------------------------------------------------
  group('todaysTasks getter', () {
    test('returns only tasks with a deadline today', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final now = DateTime.now();
      final taskToday = TaskModel(
        id: 1,
        title: 'Today',
        description: '',
        startTime: now,
        deadline: today,
        status: 'UPCOMING',
        createdAt: now,
        updatedAt: now,
        userId: 1,
        subtasks: const [],
      );
      final taskTomorrow = TaskModel(
        id: 2,
        title: 'Tomorrow',
        description: '',
        startTime: now,
        deadline: tomorrow,
        status: 'UPCOMING',
        createdAt: now,
        updatedAt: now,
        userId: 1,
        subtasks: const [],
      );

      when(() => mockRepo.getTasks())
          .thenAnswer((_) async => [taskToday, taskTomorrow]);
      await provider.fetchTasks(refresh: true);

      expect(provider.todaysTasks, hasLength(1));
      expect(provider.todaysTasks.first.title, 'Today');
    });
  });
}
