part of 'add_task_bloc.dart';

abstract class AddTaskEvent {}
class AddTaskCategorySelected extends AddTaskEvent { final String category; AddTaskCategorySelected(this.category); }
class AddTaskPrioritySelected extends AddTaskEvent { final String priority; AddTaskPrioritySelected(this.priority); }
class AddTaskDateSelected extends AddTaskEvent { final DateTime date; AddTaskDateSelected(this.date); }
class AddTaskStartTimeSelected extends AddTaskEvent { final String time; AddTaskStartTimeSelected(this.time); }
class AddTaskEndTimeSelected extends AddTaskEvent { final String time; AddTaskEndTimeSelected(this.time); }
class AddTaskReset extends AddTaskEvent {}
class AddTaskSubmitted extends AddTaskEvent {
  final String title; final String description;
  AddTaskSubmitted({required this.title, required this.description});
}