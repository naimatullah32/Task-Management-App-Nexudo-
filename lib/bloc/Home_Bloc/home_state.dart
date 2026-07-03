part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final String userName;
  final String? avatarUrl;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> todayTasks;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = 'Jawad',
    this.avatarUrl,
    this.categories = const [],
    this.todayTasks = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    String? avatarUrl,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? todayTasks,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      categories: categories ?? this.categories,
      todayTasks: todayTasks ?? this.todayTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}