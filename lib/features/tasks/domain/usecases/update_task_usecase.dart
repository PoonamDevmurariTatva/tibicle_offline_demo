import '../../domain/repositories/task_repository.dart';
import '../entities/task.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository, );

  Future<void> call(TaskEntity task) async {
    await repository.updateLocalTask(task);


  }
}
