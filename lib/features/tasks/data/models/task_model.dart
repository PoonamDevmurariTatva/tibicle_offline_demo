import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.isCompleted,
    required super.isSynced,
    required super.lastModifiedAt,
  });

  /// 🔹 From Domain
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      isSynced: entity.isSynced,
      lastModifiedAt: entity.lastModifiedAt,
    );
  }

  /// 🔹 To Domain
  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate,
    isCompleted: isCompleted,
    isSynced: isSynced,
    lastModifiedAt: lastModifiedAt,
  );

  /// 🔹 Hive Serialization
  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isSynced': isSynced,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromHiveMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: map['isCompleted'] as bool,
      isSynced: map['isSynced'] as bool,
      lastModifiedAt: DateTime.parse(map['lastModifiedAt'] as String),
    );
  }

  /// 🔹 Firestore Serialization
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'isSynced': isSynced,
      'lastModifiedAt': Timestamp.fromDate(lastModifiedAt),
    };
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: data['id'] ?? doc.id, // fallback to Firestore doc id
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      isSynced: data['isSynced'] ?? true,
      lastModifiedAt: (data['lastModifiedAt'] as Timestamp).toDate(),
    );
  }

  /// 🔹 CopyWith (for updates)
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isSynced,
    DateTime? lastModifiedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isSynced: isSynced ?? this.isSynced,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }
}
