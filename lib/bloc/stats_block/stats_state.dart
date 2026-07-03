part of 'stats_bloc.dart';

enum StatsStatus { initial, loading, loaded, error }

class StatsState {
  final StatsStatus status;
  final double overallCompletionRate;
  final int currentStreak;
  final List<int> weeklyTasksCount; // Last 7 days completed tasks
  final Map<String, double> categoryDistribution;
  final String? errorMessage;

  const StatsState({
    this.status = StatsStatus.initial,
    this.overallCompletionRate = 0.0,
    this.currentStreak = 0,
    this.weeklyTasksCount = const [0, 0, 0, 0, 0, 0, 0],
    this.categoryDistribution = const {},
    this.errorMessage,
  });

  StatsState copyWith({
    StatsStatus? status, double? overallCompletionRate, int? currentStreak,
    List<int>? weeklyTasksCount, Map<String, double>? categoryDistribution, String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      overallCompletionRate: overallCompletionRate ?? this.overallCompletionRate,
      currentStreak: currentStreak ?? this.currentStreak,
      weeklyTasksCount: weeklyTasksCount ?? this.weeklyTasksCount,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}