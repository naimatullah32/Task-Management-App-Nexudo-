import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final SupabaseClient supabase = Supabase.instance.client;

  StatsBloc() : super(const StatsState()) {
    on<StatsLoadStarted>(_onLoad);
  }

  Future<void> _onLoad(StatsLoadStarted event, Emitter<StatsState> emit) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Fetch all tasks for this user
      final response = await supabase.from('tasks').select().eq('user_id', user.id);
      final List<Map<String, dynamic>> allTasks = (response as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();

      if (allTasks.isEmpty) {
        emit(state.copyWith(status: StatsStatus.loaded));
        return;
      }

      // 1. Overall Completion Rate
      final completedTasks = allTasks.where((t) => t['status'] == 'Completed').toList();
      final completionRate = completedTasks.length / allTasks.length;

      // 2. Weekly Tasks Count (Last 7 Days)
      List<int> weeklyCount = List.filled(7, 0);
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final targetDate = today.subtract(Duration(days: 6 - i));
        final dateString = DateFormat('yyyy-MM-dd').format(targetDate);

        final count = completedTasks.where((t) {
          if (t['due_date'] == null) return false;
          return t['due_date'].toString().startsWith(dateString);
        }).length;
        weeklyCount[i] = count;
      }

      // 3. Category Distribution (For Pie Chart)
      final Map<String, double> categories = {};
      for (var task in completedTasks) {
        final cat = task['category'] ?? 'Other';
        categories[cat] = (categories[cat] ?? 0) + 1;
      }

      // 4. Calculate Streak (Simplified: checking consecutive days backwards)
      int streak = 0;
      for (int i = 0; i < 30; i++) { // Check up to 30 days back
        final targetDate = today.subtract(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(targetDate);
        bool hasCompletedTask = completedTasks.any((t) => t['due_date'] != null && t['due_date'].toString().startsWith(dateString));
        if (hasCompletedTask) {
          streak++;
        } else if (i > 0) { // Allow 0 streak if today is missed, but break if yesterday missed
          break;
        }
      }

      emit(state.copyWith(
        status: StatsStatus.loaded,
        overallCompletionRate: completionRate,
        weeklyTasksCount: weeklyCount,
        categoryDistribution: categories,
        currentStreak: streak,
      ));
    } catch (e) {
      emit(state.copyWith(status: StatsStatus.error, errorMessage: e.toString()));
    }
  }
}