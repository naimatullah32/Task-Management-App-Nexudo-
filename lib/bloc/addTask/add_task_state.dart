part of 'add_task_bloc.dart';

enum AddTaskStatus { initial, loading, success, failure }

class AddTaskState {
  final AddTaskStatus status;
  final String category;
  final String priority;
  final DateTime? dueDate;
  final String? startTime;
  final String? endTime;
  final String? errorMessage;

  const AddTaskState({
    this.status = AddTaskStatus.initial,
    this.category = 'Design',
    this.priority = 'Medium',
    this.dueDate,
    this.startTime,
    this.endTime,
    this.errorMessage,
  });

  AddTaskState copyWith({
    AddTaskStatus? status, String? category, String? priority,
    DateTime? dueDate, String? startTime, String? endTime, String? errorMessage,
  }) {
    return AddTaskState(
      status: status ?? this.status, category: category ?? this.category,
      priority: priority ?? this.priority, dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime, endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}