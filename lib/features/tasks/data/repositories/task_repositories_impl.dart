
import 'package:tibicle_offline_demo/features/tasks/domain/entities/task.dart';

import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../task_local_datasources.dart';
import '../task_remote_datasources.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<TaskEntity>> getLocalTasks() async {
    final localTasks = await localDataSource.getAllTasks();

    try {
      final remoteTasks = await remoteDataSource.fetchAll();
      await localDataSource.cacheTasks(remoteTasks); // ✅ sync
      return remoteTasks;
    } catch (_) {
      return localTasks; // fallback offline
    }
  }

  @override
  Future<void> addLocalTask(TaskEntity entity) async {
    final model = TaskModel.fromEntity(entity);

    await localDataSource.cacheTask(
      model.copyWith(isSynced: false),
    );

    try {
      await remoteDataSource.upload(model);
      await localDataSource.cacheTask(
        model.copyWith(isSynced: true),
      );
    } catch (_) {}
  }

  @override
  Future<void> updateLocalTask(TaskEntity entity) async {
    final model = TaskModel.fromEntity(entity);

    await localDataSource.cacheTask(
      model.copyWith(isSynced: false),
    );

    try {
      await remoteDataSource.upload(model);
      await localDataSource.cacheTask(
        model.copyWith(isSynced: true),
      );
    } catch (_) {}
  }

  @override
  Future<void> deleteLocalTask(String id) async {
    await localDataSource.deleteTask(id);

    try {
      await remoteDataSource.delete(id);
    } catch (_) {}
  }

  @override
  Stream<List<TaskEntity>> watchRemoteTasks() {
    return remoteDataSource.streamAll().map(
          (models) {
        localDataSource.cacheTasks(models); // keep offline in sync
        return models.map((m) => m.toEntity()).toList();
      },
    );
  }



  @override
  Future<void> syncPendingTasks() async {
    final localTasks = await localDataSource.getAllTasks();

    for (final task in localTasks) {
      if (!task.isSynced) {
        await remoteDataSource.upload(task);
        final updated = task.copyWith(isSynced: true);
        await localDataSource.cacheTask(updated);
      }
    }

    final remoteTasks = await remoteDataSource.fetchAll();
    for (final remoteTask in remoteTasks) {
      final local = localTasks.firstWhere(
            (t) => t.id == remoteTask.id,
        orElse: () => remoteTask,
      );
      if (remoteTask.lastModifiedAt.isAfter(local.lastModifiedAt)) {
        await localDataSource.cacheTask(remoteTask.copyWith(isSynced: true));
      }
    }
  }
  }



