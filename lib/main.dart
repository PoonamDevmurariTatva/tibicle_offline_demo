import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tibicle_offline_demo/features/tasks/domain/usecases/sync_task_usecase.dart';
import 'features/tasks/data/repositories/task_repositories_impl.dart';
import 'features/tasks/data/task_local_datasources.dart';
import 'features/tasks/data/task_remote_datasources.dart';
import 'features/tasks/domain/usecases/add_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_task_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'features/tasks/presentation/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final box = await Hive.openBox('tasksBox');

  await Firebase.initializeApp();
// Local + Remote Data Sources
  final localDataSource = TaskLocalDataSourceImpl(box);
  final remoteDataSource = TaskRemoteDataSourceImpl(FirebaseFirestore.instance);

  // Repository
  final repository = TaskRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final TaskRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>(
          create: (_) => TaskCubit(
            addTask: AddTaskUseCase(repository),
            updateTask: UpdateTaskUseCase(repository),
            deleteTask: DeleteTaskUseCase(repository),
            getTasks: GetTasksUseCase(repository), syncTasks: SyncTasksUseCase(repository),
          )..fetchTasks(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      ),
    );
  }
}
