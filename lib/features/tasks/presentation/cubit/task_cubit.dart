import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tibicle_offline_demo/features/tasks/presentation/cubit/task_state.dart';
import '../../../../services/notification_services.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_task_usecase.dart';
import '../../domain/usecases/sync_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase getTasks;
  final AddTaskUseCase addTask;
  final UpdateTaskUseCase updateTask;
  final DeleteTaskUseCase deleteTask;
  final SyncTasksUseCase syncTasks;

  TaskCubit({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.syncTasks,
  }) : super(TaskInitial());

  /// ✅ Alias for main.dart
  Future<void> fetchTasks() async => loadTasks();

  Future<void> loadTasks() async {
    emit(TaskLoading());
    final tasks = await getTasks();
    emit(TaskLoaded(tasks));
  }

  /// Add Task + Notification
  Future<void> createTask(TaskEntity task) async {
    await addTask(task);

    // Schedule notification if due date is in future
    if (task.dueDate.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskNotification(
        id: task.hashCode,
        title: task.title,
        body: task.description,
        dueDate: task.dueDate,
      );
    }

    await loadTasks();
  }

  /// Update Task + Notification
  Future<void> modifyTask(TaskEntity task) async {
    await updateTask(task);

    // If task is completed → cancel notification
    if (task.isCompleted) {
      await NotificationService.cancelNotification(task.hashCode);
    } else if (task.dueDate.isAfter(DateTime.now())) {
      // Reschedule updated due date
      await NotificationService.cancelNotification(task.hashCode);
      await NotificationService.scheduleTaskNotification(
        id: task.hashCode,
        title: task.title,
        body: task.description,
        dueDate: task.dueDate,
      );
    }

    await loadTasks();
  }

  /// Delete Task + Cancel Notification
  Future<void> removeTask(String id, int hashCode) async {
    await deleteTask(id);
    await NotificationService.cancelNotification(hashCode);
    await loadTasks();
  }
}
