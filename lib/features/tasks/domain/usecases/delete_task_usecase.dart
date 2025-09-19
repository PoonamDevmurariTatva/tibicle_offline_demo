import '../../domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository, );

  Future<void> call(String id) async {
    await repository.deleteLocalTask(id);
  }
}
