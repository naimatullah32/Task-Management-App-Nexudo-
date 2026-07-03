import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_management/repository/auth_repository/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../repository/auth_repository/auth_repo.dart';
import '../../repository/profile_repository/profile_repo.dart';
import '../auth_bloc/auth_state.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepo;
  final ProfileRepository profileRepo;
  late final StreamSubscription _timeSubscription;


  ProfileBloc({required this.authRepo, required this.profileRepo})
      : super(const ProfileState()) {
    on<ProfileLoadStarted>(_onLoad);
    on<ProfileSaveRequested>(_onSave);
    on<ProfileAvatarUpdateRequested>(_onAvatarUpdate);
    on<ProfileLogoutRequested>(_onLogout);
    on<ProfileMenuToggled>(_onMenuToggle);
    on<ProfileMenuClosed>(_onMenuClose);
    on<ProfileStatTapped>(_onStatTap);
    on<_TimeUpdateEvent>(_onTimeUpdate);

    // Auto-update local time every minute
    _timeSubscription = Stream.periodic(const Duration(seconds: 60), (_) => ProfileState.currentLocalTime())
        .listen((time) {
      if (state.status == ProfileStatus.loaded && !isClosed) {
        add(_TimeUpdateEvent(time));
      }
    });
  }

  // Internal event for time updates (not exposed outside)
  void _onTimeUpdate(_TimeUpdateEvent event, Emitter<ProfileState> emit) {
    if (state.status == ProfileStatus.loaded) {
      emit(state.copyWith(localTime: event.time));
    }
  }

  // @override
  // void onEvent(ProfileEvent event) {
  //   if (event is _TimeUpdateEvent) {
  //     _onTimeUpdate(event, );
  //   } else {
  //     super.onEvent(event);
  //   }
  // }

  Future<void> _onLoad(ProfileLoadStarted event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final user = authRepo.currentUser;
    if (user == null) {
      emit(state.copyWith(status: ProfileStatus.loggedOut));
      return;
    }

    try {
      Map<String, dynamic> profile = await profileRepo.fetchProfile(user.id) ?? {};

      // If profile is empty, create default row
      if (profile.isEmpty) {
        final defaultProfile = {
          'id': user.id,
          'name': user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'User',
          'title': '',
          'phone': null,
          'location': null,
          'avatar_url': null,
          'projects': 0,
          'followers': 0,
          'pending': 0,
        };
        await profileRepo.upsertProfile(defaultProfile);
        profile = defaultProfile;
      }

      // 🔥 NEW LOGIC: REAL-TIME TASKS COUNT FETCH
      // Supabase se live tasks ka status fetch karein
      final tasksResponse = await Supabase.instance.client
          .from('tasks')
          .select('status')
          .eq('user_id', user.id);

      final List<dynamic> allTasks = tasksResponse as List<dynamic>;

      // Status ke hisaab se counting
      final int totalTasks = allTasks.length;
      final int completedTasks = allTasks.where((t) => t['status'] == 'Completed').length;
      final int pendingTasks = totalTasks - completedTasks;

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        userId: user.id,
        email: user.email ?? '',
        name: profile['name'] ?? '',
        title: profile['title'] ?? '',
        phone: profile['phone'],
        location: profile['location'],
        avatarUrl: profile['avatar_url'],

        // 🔥 UPDATE: Purane 0 ki jagah live task counting map kar di gayi hai
        projects: totalTasks,       // Ye UI mein 'Total Tasks' dikhayega
        followers: completedTasks,  // Ye UI mein 'Completed' dikhayega
        pending: pendingTasks,      // Ye UI mein 'Pending' dikhayega

        localTime: ProfileState.currentLocalTime(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSave(ProfileSaveRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isSaving: true, successMessage: null, errorMessage: null));
    if (state.userId.isEmpty) {
      emit(state.copyWith(isSaving: false, errorMessage: "User not authenticated"));
      return;
    }
    try {
      await profileRepo.updateProfile(
        userId: state.userId,
        name: event.name,
        title: event.title,
        phone: event.phone,
        location: event.location,
      );
      emit(state.copyWith(
        name: event.name,
        title: event.title,
        phone: event.phone,
        location: event.location,
        isSaving: false,
        successMessage: "Profile updated successfully!",
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: "Failed to update profile: ${e.toString()}",
      ));
    }

  }



  Future<void> _onAvatarUpdate(ProfileAvatarUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isSaving: true));
    try {
      final XFile image = XFile(event.imagePath);
      final url = await profileRepo.uploadAvatar(state.userId, image);
      emit(state.copyWith(avatarUrl: url, isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  void _onLogout(ProfileLogoutRequested event, Emitter<ProfileState> emit) async {
    await authRepo.logout();
    emit(state.copyWith(status: ProfileStatus.loggedOut));
  }

  void _onMenuToggle(ProfileMenuToggled event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isMenuOpen: !state.isMenuOpen));
  }

  void _onMenuClose(ProfileMenuClosed event, Emitter<ProfileState> emit) {
    emit(state.copyWith(isMenuOpen: false));
  }

  void _onStatTap(ProfileStatTapped event, Emitter<ProfileState> emit) {
    emit(state.copyWith(highlightedStat: event.key));
  }

  // on<ProfileMessageShown>((event, emit) {
  // emit(state.clearMessages());
  // });

  @override
  Future<void> close() {
    _timeSubscription.cancel();
    return super.close();
  }
}

/// Internal event for updating time without triggering other side effects.
class _TimeUpdateEvent extends ProfileEvent {
  final String time;
  const _TimeUpdateEvent(this.time);
  @override
  List<Object?> get props => [time];
}








// // lib/bloc/profile_bloc/profile_bloc.dart
// import 'dart:async';
// import 'dart:io';
//
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
//
// import '../../model/profile_model.dart';
// import '../../repository/profile_repository/profile_repo.dart';
//
// part 'profile_event.dart';
// part 'profile_state.dart';
//
// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   final ProfileRepository _repo;
//   StreamSubscription<ProfileModel>? _realtimeSub;
//   Timer? _clockTimer;
//
//   ProfileBloc({ProfileRepository? repository})
//       : _repo = repository ?? ProfileRepository(),
//         super(const ProfileState()) {
//     on<ProfileLoadStarted>            (_onLoad);
//     on<ProfileMenuToggled>            (_onMenuToggled);
//     on<ProfileMenuClosed>             (_onMenuClosed);
//     on<ProfileStatTapped>             (_onStatTapped);
//     on<ProfileSaveRequested>          (_onSave);
//     on<ProfileAvatarUpdateRequested>  (_onAvatarUpdate);
//     on<ProfileLogoutRequested>        (_onLogout);
//     on<_ProfileStreamUpdated>         (_onStreamUpdated);
//     on<_ClockTicked>                  (_onClockTicked);
//   }
//
//   // ─────────────────────────────────────────
//   // LOAD
//   // ─────────────────────────────────────────
//   Future<void> _onLoad(
//       ProfileLoadStarted event, Emitter<ProfileState> emit) async {
//     emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
//
//     try {
//       final profile = await _repo.fetchProfile();
//       emit(ProfileState.fromModel(profile,
//           status:          ProfileStatus.loaded,
//           existingLocalTime: ProfileState.currentLocalTime()));
//
//       // Realtime listener
//       await _realtimeSub?.cancel();
//       _realtimeSub = _repo.streamProfile().listen(
//             (p) => add(_ProfileStreamUpdated(p)),
//         onError: (_) {}, // silent — we already have data
//       );
//
//       // Clock — minute by minute
//       _clockTimer?.cancel();
//       _clockTimer = Timer.periodic(
//         const Duration(minutes: 1),
//             (_) => add(const _ClockTicked()),
//       );
//     } on Exception catch (e) {
//       emit(state.copyWith(
//         status: ProfileStatus.error,
//         errorMessage: _friendly(e),
//       ));
//     }
//   }
//
//   // ─────────────────────────────────────────
//   // REALTIME UPDATE (from Supabase stream)
//   // ─────────────────────────────────────────
//   void _onStreamUpdated(
//       _ProfileStreamUpdated event, Emitter<ProfileState> emit) {
//     emit(ProfileState.fromModel(
//       event.profile,
//       status:           ProfileStatus.loaded,
//       isMenuOpen:       state.isMenuOpen,
//       highlightedStat:  state.highlightedStat,
//       existingLocalTime: state.localTime,
//     ));
//   }
//
//   // ─────────────────────────────────────────
//   // CLOCK
//   // ─────────────────────────────────────────
//   void _onClockTicked(_ClockTicked event, Emitter<ProfileState> emit) {
//     emit(state.copyWith(localTime: ProfileState.currentLocalTime()));
//   }
//
//   // ─────────────────────────────────────────
//   // MENU
//   // ─────────────────────────────────────────
//   void _onMenuToggled(
//       ProfileMenuToggled event, Emitter<ProfileState> emit) =>
//       emit(state.copyWith(isMenuOpen: !state.isMenuOpen));
//
//   void _onMenuClosed(
//       ProfileMenuClosed event, Emitter<ProfileState> emit) =>
//       emit(state.copyWith(isMenuOpen: false));
//
//   // ─────────────────────────────────────────
//   // STAT TAP
//   // ─────────────────────────────────────────
//   void _onStatTapped(
//       ProfileStatTapped event, Emitter<ProfileState> emit) {
//     if (state.highlightedStat == event.statKey) {
//       emit(state.copyWith(clearHighlight: true));
//     } else {
//       emit(state.copyWith(highlightedStat: event.statKey));
//     }
//   }
//
//   // ─────────────────────────────────────────
//   // SAVE
//   // ─────────────────────────────────────────
//   Future<void> _onSave(
//       ProfileSaveRequested event, Emitter<ProfileState> emit) async {
//     emit(state.copyWith(status: ProfileStatus.saving, isSaving: true));
//
//     try {
//       final updated = await _repo.updateProfile(
//         name:     event.name,
//         title:    event.title,
//         phone:    event.phone,
//         location: event.location,
//       );
//       emit(ProfileState.fromModel(
//         updated,
//         status:           ProfileStatus.loaded,
//         existingLocalTime: state.localTime,
//       ));
//     } on Exception catch (e) {
//       emit(state.copyWith(
//         status:       ProfileStatus.error,
//         isSaving:     false,
//         errorMessage: _friendly(e),
//       ));
//     }
//   }
//
//   // ─────────────────────────────────────────
//   // AVATAR
//   // ─────────────────────────────────────────
//   Future<void> _onAvatarUpdate(
//       ProfileAvatarUpdateRequested event,
//       Emitter<ProfileState> emit) async {
//     emit(state.copyWith(isSaving: true));
//     try {
//       final url = await _repo.uploadAvatar(File(event.imagePath));
//       emit(state.copyWith(isSaving: false, avatarUrl: url));
//     } on Exception catch (e) {
//       emit(state.copyWith(
//           isSaving: false, errorMessage: _friendly(e)));
//     }
//   }
//
//   // ─────────────────────────────────────────
//   // LOGOUT
//   // ─────────────────────────────────────────
//   Future<void> _onLogout(
//       ProfileLogoutRequested event, Emitter<ProfileState> emit) async {
//     _clockTimer?.cancel();
//     await _realtimeSub?.cancel();
//     await _repo.signOut();
//     emit(state.copyWith(status: ProfileStatus.loggedOut));
//   }
//
//   @override
//   Future<void> close() async {
//     _clockTimer?.cancel();
//     await _realtimeSub?.cancel();
//     return super.close();
//   }
//
//   String _friendly(Object e) {
//     final s = e.toString().toLowerCase();
//     if (s.contains('network') || s.contains('socket') ||
//         s.contains('connection')) return 'No internet connection';
//     if (s.contains('permission') || s.contains('rls') ||
//         s.contains('policy'))    return 'Permission denied';
//     if (s.contains('not found'))  return 'Profile not found';
//     return 'Something went wrong. Please try again.';
//   }
// }