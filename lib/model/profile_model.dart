// lib/models/profile_model.dart

class ProfileModel {
  final String id;
  final String name;
  final String title;      // Role / designation
  final String? phone;     // null jab set na ho — UI mein hide hoga
  final String? location;
  final String? avatarUrl;
  final String email;      // auth.users se aata hai
  final int projects;
  final int followers;
  final int pending;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.title,
    this.phone,
    this.location,
    this.avatarUrl,
    required this.email,
    this.projects = 0,
    this.followers = 0,
    this.pending = 0,
    required this.updatedAt,
  });

  /// Supabase row + email se banao
  factory ProfileModel.fromMap(Map<String, dynamic> map, String email) {
    return ProfileModel(
      id:         map['id'] as String,
      name:       (map['name'] as String?)?.trim().isEmpty == true
          ? email.split('@').first
          : (map['name'] as String?) ?? email.split('@').first,
      title:      (map['title'] as String?) ?? '',
      phone:      (map['phone'] as String?)?.trim().isEmpty == true
          ? null
          : map['phone'] as String?,
      location:   (map['location'] as String?)?.trim().isEmpty == true
          ? null
          : map['location'] as String?,
      avatarUrl:  map['avatar_url'] as String?,
      email:      email,
      projects:   (map['projects'] as int?) ?? 0,
      followers:  (map['followers'] as int?) ?? 0,
      pending:    (map['pending'] as int?) ?? 0,
      updatedAt:  DateTime.parse(
          map['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Supabase update ke liye — sirf changed fields
  Map<String, dynamic> toUpdateMap() => {
    'name':     name,
    'title':    title,
    'phone':    phone?.trim().isEmpty == true ? null : phone,
    'location': location?.trim().isEmpty == true ? null : location,
  };

  ProfileModel copyWith({
    String? name,
    String? title,
    String? phone,
    String? location,
    String? avatarUrl,
    int? projects,
    int? followers,
    int? pending,
  }) {
    return ProfileModel(
      id:         id,
      name:       name ?? this.name,
      title:      title ?? this.title,
      phone:      phone,                    // null allowed (to clear)
      location:   location,
      avatarUrl:  avatarUrl ?? this.avatarUrl,
      email:      email,
      projects:   projects ?? this.projects,
      followers:  followers ?? this.followers,
      pending:    pending ?? this.pending,
      updatedAt:  DateTime.now(),
    );
  }
}