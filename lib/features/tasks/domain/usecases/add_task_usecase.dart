import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository, );

  Future<void> call(TaskEntity task) async {
    await repository.addLocalTask(task);

  }
}
