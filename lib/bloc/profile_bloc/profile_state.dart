part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  saving,
  error,
  loggedOut,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? errorMessage;
  final String userId;
  final String name;
  final String title;
  final String email;
  final String? phone;
  final String? location;
  final String? avatarUrl;
  final String localTime;
  final int projects;
  final int followers;
  final int pending;
  final String? highlightedStat;
  final bool isMenuOpen;
  final bool isSaving;
  final String? successMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.errorMessage,
    this.userId = '',
    this.name = '',
    this.title = '',
    this.email = '',
    this.phone,
    this.location,
    this.avatarUrl,
    this.localTime = '',
    this.projects = 0,
    this.followers = 0,
    this.pending = 0,
    this.highlightedStat,
    this.isMenuOpen = false,
    this.isSaving = false,
    this.successMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? errorMessage,
    String? userId,
    String? name,
    String? title,
    String? email,
    String? phone,
    String? location,
    String? avatarUrl,
    String? localTime,
    int? projects,
    int? followers,
    int? pending,
    String? highlightedStat,
    bool? isMenuOpen,
    bool? isSaving,
    String? successMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localTime: localTime ?? this.localTime,
      projects: projects ?? this.projects,
      followers: followers ?? this.followers,
      pending: pending ?? this.pending,
      highlightedStat: highlightedStat ?? this.highlightedStat,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  Map<String, String?> toEditMap() => {
    'name': name,
    'title': title,
    'phone': phone,
    'location': location,
    'email': email,
  };

  ProfileState clearMessages() {
    return copyWith(successMessage: null, errorMessage: null);
  }

  static String currentLocalTime() {
    return _formatTime(DateTime.now());
  }

  static String _formatTime(DateTime now) {
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }



  @override
  List<Object?> get props => [
    status, errorMessage, userId, name, title, email, phone, location,
    avatarUrl, localTime, projects, followers, pending, highlightedStat,
    isMenuOpen, isSaving,
  ];
}

class AuthSuccess extends AuthState {
  final String message;

  AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}











// // lib/bloc/profile_bloc/profile_state.dart
// part of 'profile_bloc.dart';
//
// enum ProfileStatus { initial, loading, loaded, saving, error, loggedOut }
//
// class ProfileState {
//   final ProfileStatus status;
//   final bool isMenuOpen;
//   final String? highlightedStat;
//   final String? errorMessage;
//   final bool isSaving;
//
//   final String id;
//   final String name;
//   final String title;
//   final String? phone;       // null  →  UI mein hide
//   final String? location;
//   final String? avatarUrl;
//   final String email;
//   final int projects;
//   final int followers;
//   final int pending;
//   final String localTime;    // device-based, auto-refresh
//
//   const ProfileState({
//     this.status          = ProfileStatus.initial,
//     this.isMenuOpen      = false,
//     this.highlightedStat,
//     this.errorMessage,
//     this.isSaving        = false,
//     this.id              = '',
//     this.name            = '',
//     this.title           = '',
//     this.phone,
//     this.location,
//     this.avatarUrl,
//     this.email           = '',
//     this.projects        = 0,
//     this.followers       = 0,
//     this.pending         = 0,
//     this.localTime       = '',
//   });
//
//   // ProfileModel → ProfileState
//   factory ProfileState.fromModel(
//       ProfileModel model, {
//         ProfileStatus status          = ProfileStatus.loaded,
//         bool isMenuOpen               = false,
//         String? highlightedStat,
//         String? existingLocalTime,    // preserve current clock value
//       }) {
//     return ProfileState(
//       status:          status,
//       isMenuOpen:      isMenuOpen,
//       highlightedStat: highlightedStat,
//       id:              model.id,
//       name:            model.name,
//       title:           model.title,
//       phone:           model.phone,
//       location:        model.location,
//       avatarUrl:       model.avatarUrl,
//       email:           model.email,
//       projects:        model.projects,
//       followers:       model.followers,
//       pending:         model.pending,
//       localTime:       existingLocalTime ?? _buildLocalTime(),
//     );
//   }
//
//   // Edit screen ko dena
//   Map<String, String?> toEditMap() => {
//     'name':     name,
//     'title':    title,
//     'phone':    phone,
//     'location': location,
//     'email':    email,
//   };
//
//   ProfileState copyWith({
//     ProfileStatus? status,
//     bool? isMenuOpen,
//     String? highlightedStat,
//     bool clearHighlight  = false,
//     String? errorMessage,
//     bool clearError      = false,
//     bool? isSaving,
//     String? name,
//     String? title,
//     String? phone,
//     bool clearPhone      = false,
//     String? location,
//     bool clearLocation   = false,
//     String? avatarUrl,
//     int? projects,
//     int? followers,
//     int? pending,
//     String? localTime,
//   }) {
//     return ProfileState(
//       status:          status          ?? this.status,
//       isMenuOpen:      isMenuOpen      ?? this.isMenuOpen,
//       highlightedStat: clearHighlight  ? null : (highlightedStat ?? this.highlightedStat),
//       errorMessage:    clearError      ? null : (errorMessage    ?? this.errorMessage),
//       isSaving:        isSaving        ?? this.isSaving,
//       id:              id,
//       email:           email,
//       name:            name            ?? this.name,
//       title:           title           ?? this.title,
//       phone:           clearPhone      ? null : (phone    ?? this.phone),
//       location:        clearLocation   ? null : (location ?? this.location),
//       avatarUrl:       avatarUrl       ?? this.avatarUrl,
//       projects:        projects        ?? this.projects,
//       followers:       followers       ?? this.followers,
//       pending:         pending         ?? this.pending,
//       localTime:       localTime       ?? this.localTime,
//     );
//   }
//
//   // "Apr 24 · 15:30"
//   static String _buildLocalTime() {
//     final now = DateTime.now();
//     const m = ['','Jan','Feb','Mar','Apr','May','Jun',
//       'Jul','Aug','Sep','Oct','Nov','Dec'];
//     final h = now.hour.toString().padLeft(2, '0');
//     final min = now.minute.toString().padLeft(2, '0');
//     return '${m[now.month]} ${now.day} · $h:$min';
//   }
//
//   // expose for bloc
//   static String currentLocalTime() => _buildLocalTime();
// }