import 'package:hive/hive.dart';
import 'models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<void> cacheTask(TaskModel task);   // add/update single
  Future<void> cacheTasks(List<TaskModel> tasks); // batch sync
  Future<void> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box _box;
  TaskLocalDataSourceImpl(this._box);

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final list = _box.values
        .map((e) => TaskModel.fromHiveMap(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    await _box.put(task.id, task.toHiveMap());
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _box.put(task.id, task.toHiveMap());
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}
