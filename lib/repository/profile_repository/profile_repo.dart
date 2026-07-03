import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final res = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return res;
  }

  Future<void> upsertProfile(Map<String, dynamic> data) async {
    await _supabase.from('profiles').upsert(data);
  }

  Future<String?> uploadAvatar(String userId, XFile image) async {
    final file = File(image.path);
    final ext = image.path.split('.').last;
    final path = '$userId/avatar.$ext';
    await _supabase.storage.from('avatars').upload(path, file, fileOptions: const FileOptions(cacheControl: '3600'));
    final url = _supabase.storage.from('avatars').getPublicUrl(path);
    // update profile with avatar_url
    await _supabase.from('profiles').update({'avatar_url': url}).eq('id', userId);
    return url;
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? title,
    String? phone,
    String? location,
  }) async  {
    await _supabase.from('profiles').update({
      'name': name,
      'title': title,
      'phone': phone,
      'location': location,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}




// import 'dart:io';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class ProfileRepository {
//   final _client = Supabase.instance.client;
//
//   Future<Map<String, dynamic>> getProfile() async {
//     final user = _client.auth.currentUser;
//     if (user == null) throw 'User not logged in';
//
//     // Database se data lao
//     final data = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
//
//     // Agar database mein data nahi hai (pehli baar login), toh Auth metadata se name/email uthao
//     return {
//       'full_name': data?['full_name'] ?? user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'New User',
//       'title_role': data?['title_role'] ?? 'UI/UX Designer',
//       'phone': data?['phone'] ?? '',
//       'location': data?['location'] ?? 'Not Set',
//       'avatar_url': data?['avatar_url'] ?? '',
//       'email': user.email ?? '',
//     };
//   }
//
//   Future<void> updateProfile(Map<String, dynamic> data) async {
//     final user = _client.auth.currentUser;
//     await _client.from('profiles').upsert({
//       'id': user!.id,
//       ...data,
//       'updated_at': DateTime.now().toIso8601String(),
//     });
//   }
//
//   Future<String> uploadAvatar(File file) async {
//     final user = _client.auth.currentUser;
//     final path = 'public/${user!.id}_${DateTime.now().millisecondsSinceEpoch}.png';
//
//     await _client.storage.from('avatars').upload(path, file);
//     return _client.storage.from('avatars').getPublicUrl(path);
//   }
// }
//
//
//
//
//
//
//
//
//
//
// // import 'dart:io';
// //
// // abstract class ProfileRepository {
// //   Future<Map<String, dynamic>> getProfile();
// //
// //   Future<void> updateProfile(Map<String, dynamic> data);
// //
// //   Future<String> uploadAvatar(File file);
// // }
// //
// // lib/repositories/profile_repository.dart
//
// // import 'dart:io';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../../model/profile_model.dart';
// //
// // class ProfileRepository {
// //   final SupabaseClient _client;
// //
// //   ProfileRepository({SupabaseClient? client})
// //       : _client = client ?? Supabase.instance.client;
// //
// //   // ── Current user shortcut ──────────────────────────────
// //   User get _user {
// //     final u = _client.auth.currentUser;
// //     if (u == null) throw Exception('User not logged in');
// //     return u;
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // FETCH: profile + email in one shot
// //   // ─────────────────────────────────────────────
// //   Future<ProfileModel> fetchProfile() async {
// //     final user = _user;
// //
// //     final data = await _client
// //         .from('profiles')
// //         .select()
// //         .eq('id', user.id)
// //         .single();
// //
// //     // Email: Google login mein user_metadata mein hoti hai,
// //     // ya phir auth.users.email se directly
// //     final email = user.email ??
// //         (user.userMetadata?['email'] as String?) ??
// //         '';
// //
// //     return ProfileModel.fromMap(data, email);
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // UPDATE: name, title, phone, location
// //   // ─────────────────────────────────────────────
// //   Future<ProfileModel> updateProfile({
// //     required String name,
// //     required String title,
// //     String? phone,
// //     String? location,
// //   }) async {
// //     final user = _user;
// //
// //     final updated = await _client
// //         .from('profiles')
// //         .update({
// //       'name':     name.trim(),
// //       'title':    title.trim(),
// //       'phone':    phone?.trim().isEmpty == true ? null : phone?.trim(),
// //       'location': location?.trim().isEmpty == true ? null : location?.trim(),
// //     })
// //         .eq('id', user.id)
// //         .select()
// //         .single();
// //
// //     final email = user.email ??
// //         (user.userMetadata?['email'] as String?) ??
// //         '';
// //
// //     return ProfileModel.fromMap(updated, email);
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // UPLOAD: avatar image → storage → public URL
// //   // ─────────────────────────────────────────────
// //   Future<String> uploadAvatar(File imageFile) async {
// //     final user = _user;
// //     final ext  = imageFile.path.split('.').last.toLowerCase();
// //     final path = '${user.id}/avatar.$ext';
// //
// //     await _client.storage
// //         .from('avatars')
// //         .upload(path, imageFile,
// //         fileOptions: const FileOptions(upsert: true));
// //
// //     final url = _client.storage.from('avatars').getPublicUrl(path);
// //
// //     // Save URL to profile
// //     await _client
// //         .from('profiles')
// //         .update({'avatar_url': url})
// //         .eq('id', user.id);
// //
// //     return url;
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // REALTIME: stream profile changes
// //   // ─────────────────────────────────────────────
// //   Stream<ProfileModel> streamProfile() {
// //     final user = _user;
// //     final email = user.email ??
// //         (user.userMetadata?['email'] as String?) ??
// //         '';
// //
// //     return _client
// //         .from('profiles')
// //         .stream(primaryKey: ['id'])
// //         .eq('id', user.id)
// //         .map((rows) {
// //       if (rows.isEmpty) throw Exception('Profile not found');
// //       return ProfileModel.fromMap(rows.first, email);
// //     });
// //   }
// //
// //   // ─────────────────────────────────────────────
// //   // LOGOUT
// //   // ─────────────────────────────────────────────
// //   Future<void> signOut() => _client.auth.signOut();
// // }