import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/notification_service/notification_service.dart';

part 'add_task_event.dart';
part 'add_task_state.dart';

class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
  final SupabaseClient supabase = Supabase.instance.client;

  AddTaskBloc() : super(const AddTaskState()) {
    on<AddTaskCategorySelected>((event, emit) => emit(state.copyWith(category: event.category)));
    on<AddTaskPrioritySelected>((event, emit) => emit(state.copyWith(priority: event.priority)));
    on<AddTaskDateSelected>((event, emit) => emit(state.copyWith(dueDate: event.date)));
    on<AddTaskStartTimeSelected>((event, emit) => emit(state.copyWith(startTime: event.time)));
    on<AddTaskEndTimeSelected>((event, emit) => emit(state.copyWith(endTime: event.time)));
    on<AddTaskReset>((event, emit) => emit(const AddTaskState()));
    on<AddTaskSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(AddTaskSubmitted event, Emitter<AddTaskState> emit) async {
    emit(state.copyWith(status: AddTaskStatus.loading));

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Task ko database mein save karein
      await supabase.from('tasks').insert({
        'user_id': user.id,
        'title': event.title,
        'description': event.description,
        'category': state.category,
        'priority': state.priority,
        'due_date': state.dueDate?.toIso8601String(),
        'start_time': state.startTime ?? '10:00 AM', // Real start time
        'end_time': state.endTime ?? '11:00 AM',     // Real end time
        'status': 'To Do',                           // Default status
        'created_at': DateTime.now().toIso8601String(),
      });

      // 🔥 2. NOTIFICATION LOGIC: Agar Due Date hai, toh reminder schedule karein
      if (state.dueDate != null) {
        // Ek unique ID generate karein taake notifications clash na hon
        int notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService().scheduleTaskReminder(
            notifId,
            event.title,
            state.dueDate!
        );
      }

      // 3. Success state emit karein
      emit(state.copyWith(status: AddTaskStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AddTaskStatus.failure, errorMessage: e.toString()));
    }
  }
}



// import 'package:bloc/bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// part 'add_task_event.dart';
// part 'add_task_state.dart';
//
// class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
//   final SupabaseClient supabase = Supabase.instance.client;
//
//   AddTaskBloc() : super(const AddTaskState()) {
//     on<AddTaskCategorySelected>((event, emit) => emit(state.copyWith(category: event.category)));
//     on<AddTaskPrioritySelected>((event, emit) => emit(state.copyWith(priority: event.priority)));
//     on<AddTaskDateSelected>((event, emit) => emit(state.copyWith(dueDate: event.date)));
//     on<AddTaskStartTimeSelected>((event, emit) => emit(state.copyWith(startTime: event.time)));
//     on<AddTaskEndTimeSelected>((event, emit) => emit(state.copyWith(endTime: event.time)));
//     on<AddTaskReset>((event, emit) => emit(const AddTaskState()));
//     on<AddTaskSubmitted>(_onSubmit);
//   }
//
//
//
//   Future<void> _onSubmit(AddTaskSubmitted event, Emitter<AddTaskState> emit) async {
//     emit(state.copyWith(status: AddTaskStatus.loading));
//
//     try {
//       final user = supabase.auth.currentUser;
//       if (user == null) throw Exception('User not logged in');
//
//       await supabase.from('tasks').insert({
//         'user_id': user.id,
//         'title': event.title,
//         'description': event.description,
//         'category': state.category,
//         'priority': state.priority,
//         'due_date': state.dueDate?.toIso8601String(),
//         'start_time': state.startTime ?? '10:00 AM', // Real start time
//         'end_time': state.endTime ?? '11:00 AM',     // Real end time
//         'status': 'To Do',                           // Default status
//         'created_at': DateTime.now().toIso8601String(),
//       });
//
//
//       emit(state.copyWith(status: AddTaskStatus.success));
//     } catch (e) {
//       emit(state.copyWith(status: AddTaskStatus.failure, errorMessage: e.toString()));
//     }
//   }
// }