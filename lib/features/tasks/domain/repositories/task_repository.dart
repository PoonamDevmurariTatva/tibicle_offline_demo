import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getLocalTasks();
  Future<void> addLocalTask(TaskEntity task);
  Future<void> updateLocalTask(TaskEntity task);
  Future<void> deleteLocalTask(String id);

  Future<void> syncPendingTasks();
  Stream<List<TaskEntity>> watchRemoteTasks();
}
