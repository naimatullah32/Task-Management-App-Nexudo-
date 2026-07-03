part of 'schedule_bloc.dart';

enum ScheduleStatus { initial, loading, loaded, error }

class ScheduleState {
  final ScheduleStatus status;
  final DateTime selectedDate;
  final List<Map<String, dynamic>> tasks;
  final String? errorMessage;

  ScheduleState({
    this.status = ScheduleStatus.initial,
    DateTime? selectedDate,
    this.tasks = const [],
    this.errorMessage,
  }) : selectedDate = selectedDate ?? DateTime.now();

  ScheduleState copyWith({
    ScheduleStatus? status,
    DateTime? selectedDate,
    List<Map<String, dynamic>>? tasks,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
    );
  }
}