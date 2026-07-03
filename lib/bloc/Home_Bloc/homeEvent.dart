part of 'home_bloc.dart';

abstract class HomeEvent {}

// 1. Home Screen Data Load Event
class HomeLoadStarted extends HomeEvent {}

// 2. Search Text Change Event
class HomeSearchQueried extends HomeEvent {
  final String query;
  HomeSearchQueried(this.query);
}

// 3. Task Checkbox Status Toggle Event (Alag class banegi)
class HomeTaskStatusToggleRequested extends HomeEvent {
  final String taskId;
  final String currentStatus;

  HomeTaskStatusToggleRequested({
    required this.taskId,
    required this.currentStatus,
  });
}