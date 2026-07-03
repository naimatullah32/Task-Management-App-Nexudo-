part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadStarted extends ProfileEvent {}
class ProfileMessageShown extends ProfileEvent {}

class ProfileSaveRequested extends ProfileEvent {
  final String name;
  final String title;
  final String? phone;
  final String? location;
  const ProfileSaveRequested({
    required this.name,
    required this.title,
    this.phone,
    this.location,
  });
}

class ProfileAvatarUpdateRequested extends ProfileEvent {
  final String imagePath; // local file path
  const ProfileAvatarUpdateRequested(this.imagePath);
}

class ProfileLogoutRequested extends ProfileEvent {}

class ProfileMenuToggled extends ProfileEvent {}
class ProfileMenuClosed extends ProfileEvent {}
class ProfileStatTapped extends ProfileEvent {
  final String key;
  const ProfileStatTapped(this.key);
}







// // lib/bloc/profile_bloc/profile_event.dart
// part of 'profile_bloc.dart';
//
// abstract class ProfileEvent {}
//
// class ProfileLoadStarted extends ProfileEvent {}
//
// class ProfileMenuToggled extends ProfileEvent {}
//
// class ProfileMenuClosed extends ProfileEvent {}
//
// class ProfileStatTapped extends ProfileEvent {
//   final String statKey;
//   ProfileStatTapped(this.statKey);
// }
//
// class ProfileSaveRequested extends ProfileEvent {
//   final String name;
//   final String title;
//   final String? phone;
//   final String? location;
//
//   ProfileSaveRequested({
//     required this.name,
//     required this.title,
//     this.phone,
//     this.location,
//   });
// }
//
// class ProfileAvatarUpdateRequested extends ProfileEvent {
//   final String imagePath;
//   ProfileAvatarUpdateRequested(this.imagePath);
// }
//
// class ProfileLogoutRequested extends ProfileEvent {}
//
// // ── Internal only ──────────────────────────────────────────────
// class _ProfileStreamUpdated extends ProfileEvent {
//   final ProfileModel profile;
//   _ProfileStreamUpdated(this.profile);
// }
//
// class _ClockTicked extends ProfileEvent {
//    _ClockTicked();
// }