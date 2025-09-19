import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

class GetTasksUseCase {
  final TaskRepository repo;
  GetTasksUseCase(this.repo);
  Future<List<TaskEntity>> call() async => repo.getLocalTasks();
}
