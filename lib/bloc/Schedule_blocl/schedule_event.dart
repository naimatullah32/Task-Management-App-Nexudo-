part of 'schedule_bloc.dart';

abstract class ScheduleEvent {}

class ScheduleLoadStarted extends ScheduleEvent {}

class ScheduleDateSelected extends ScheduleEvent {
  final DateTime date;
  ScheduleDateSelected(this.date);
}