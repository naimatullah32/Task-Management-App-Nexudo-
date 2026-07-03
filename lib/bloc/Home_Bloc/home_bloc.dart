import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/notification_service/notification_service.dart';

part 'homeEvent.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allTodayTasks = [];


  HomeBloc() : super(const HomeState()) {
    on<HomeLoadStarted>(_onLoad);
    on<HomeSearchQueried>(_onSearch);
    on<HomeTaskStatusToggleRequested>(_onStatusToggle);
  }

  Future<void> _onLoad(HomeLoadStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      String name = 'Khan';
      String? avatar;
      try {
        final profileRes = await supabase.from('profiles').select('name, avatar_url').eq('id', user.id).maybeSingle();
        if (profileRes != null) {
          name = profileRes['name'] ?? 'Jawad';
          avatar = profileRes['avatar_url'];
        }
      } catch (_) {}

      // Fetch all tasks for dynamic tracking
      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> rawData = response as List<dynamic>;
      _allTodayTasks = rawData.map((e) => e as Map<String, dynamic>).toList();

      // 🔥 Dynamic progress bars updates instantly based on tasks statuses
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var task in _allTodayTasks) {
        final cat = task['category'] ?? 'Other';
        grouped.putIfAbsent(cat, () => []).add(task);
      }

      final List<Map<String, dynamic>> calculatedCategories = grouped.entries.map((e) {
        final total = e.value.length;
        final completed = e.value.where((t) => t['status'] == 'Completed').length;
        return {
          'name': e.key,
          'taskCount': total,
          'progress': total == 0 ? 0.0 : (completed / total),
        };
      }).toList();

      emit(state.copyWith(
        status: HomeStatus.loaded,
        userName: name,
        avatarUrl: avatar,
        categories: calculatedCategories,
        todayTasks: _allTodayTasks,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.toString()));
    }
  }

  // 🔥 Database update method
  // 🔥 Optimistic Update for Instant UI Reaction
  Future<void> _onStatusToggle(HomeTaskStatusToggleRequested event, Emitter<HomeState> emit) async {
    final targetStatus = event.currentStatus == 'Completed' ? 'To Do' : 'Completed';

    // 🔥 Agar task complete ho gaya hai toh aaj ka Streak Reminder cancel kar do
    if (targetStatus == 'Completed') {
      NotificationService().cancelStreakWarning();
    }

    // 1. Instantly update local tasks list (Bina database ka wait kiye)
    final updatedTasks = state.todayTasks.map((task) {
      if (task['id'] == event.taskId) {
        return {...task, 'status': targetStatus};
      }
      return task;
    }).toList();

    // 2. Instantly recalculate categories progress
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var task in updatedTasks) {
      final cat = task['category'] ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(task);
    }
    final calculatedCategories = grouped.entries.map((e) {
      final total = e.value.length;
      final completed = e.value.where((t) => t['status'] == 'Completed').length;
      return {
        'name': e.key,
        'taskCount': total,
        'progress': total == 0 ? 0.0 : (completed / total),
      };
    }).toList();

    // 3. Foran UI ko naya data bhej dein (0.0 seconds delay)
    emit(state.copyWith(todayTasks: updatedTasks, categories: calculatedCategories));

    // 4. Background mein Supabase update hone dein silently
    try {
      await supabase.from('tasks').update({'status': targetStatus}).eq('id', event.taskId);
    } catch (e) {
      // Agar internet issue ki wajah se save fail ho jaye toh user ko error dikhayein
      emit(state.copyWith(errorMessage: "Failed to sync status. Check connection."));
    }
  }

  void _onSearch(HomeSearchQueried event, Emitter<HomeState> emit) {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      emit(state.copyWith(todayTasks: _allTodayTasks, searchQuery: query));
      return;
    }
    final filtered = _allTodayTasks.where((task) {
      final title = (task['title'] ?? '').toString().toLowerCase();
      return title.contains(query);
    }).toList();
    emit(state.copyWith(todayTasks: filtered, searchQuery: query));
  }
}