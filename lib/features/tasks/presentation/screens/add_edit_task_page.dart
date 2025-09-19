import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../cubit/task_cubit.dart';

class AddEditTaskPage extends StatefulWidget {
  final TaskEntity? task;
  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _due;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title.text = widget.task!.title;
      _desc.text = widget.task!.description;
      _due = widget.task!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Task' : 'Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(_due == null ? 'Pick due date' : _due.toString()),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Update' : 'Save'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _due ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_due ?? DateTime.now()));
    if (time == null) return;
    setState(() {
      _due = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final title = _title.text.trim();
    final desc = _desc.text.trim();
    if (title.isEmpty || _due == null) return;

    final now = DateTime.now();
    if (widget.task == null) {
      final task = TaskEntity(
        id: const Uuid().v4(),
        title: title,
        description: desc,
        dueDate: _due!,
        isCompleted: false,
        isSynced: false,
        lastModifiedAt: now,
      );
      context.read<TaskCubit>().addTask(task);
    } else {
      final task = widget.task!.copyWith(
        title: title,
        description: desc,
        dueDate: _due!,
        lastModifiedAt: now,
      );
      context.read<TaskCubit>().updateTask(task);
    }
    Navigator.pop(context);
  }
}
