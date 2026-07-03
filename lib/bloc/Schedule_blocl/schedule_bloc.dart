import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final SupabaseClient supabase = Supabase.instance.client;

  ScheduleBloc() : super(ScheduleState()) {
    on<ScheduleLoadStarted>(_onLoad);
    on<ScheduleDateSelected>(_onDateSelected);
  }

  Future<void> _onLoad(ScheduleLoadStarted event, Emitter<ScheduleState> emit) async {
    await _fetchTasksForDate(state.selectedDate, emit);
  }

  Future<void> _onDateSelected(ScheduleDateSelected event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(selectedDate: event.date));
    await _fetchTasksForDate(event.date, emit);
  }

  Future<void> _fetchTasksForDate(DateTime date, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Date ki start aur end range nikal lein taake sirf usi din ke tasks aayein
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .gte('due_date', startOfDay)
          .lte('due_date', endOfDay)
          .order('due_date', ascending: true);

      // Convert response to List of Maps
      final List<Map<String, dynamic>> fetchedTasks = List<Map<String, dynamic>>.from(response);

      emit(state.copyWith(status: ScheduleStatus.loaded, tasks: fetchedTasks));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.error, errorMessage: e.toString()));
    }
  }
}