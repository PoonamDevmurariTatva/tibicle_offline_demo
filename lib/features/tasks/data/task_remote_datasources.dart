import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> fetchAll();
  Future<void> upload(TaskModel task);
  Future<void> delete(String id);
  Stream<List<TaskModel>> streamAll();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  TaskRemoteDataSourceImpl(this.firestore);

  CollectionReference get _collection => firestore.collection('tasks');

  @override
  Future<List<TaskModel>> fetchAll() async {
    final snap = await _collection.get();
    return snap.docs.map((d) => TaskModel.fromFirestore(d)).toList();
  }

  @override
  Future<void> upload(TaskModel task) async {
    await _collection.doc(task.id).set(task.toFirestore());
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Stream<List<TaskModel>> streamAll() {
    return _collection.snapshots().map((snap) =>
        snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }
}
