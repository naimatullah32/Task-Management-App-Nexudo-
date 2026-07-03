// import 'dart:io';
//
// import 'package:task_management/repository/profile_repository/profile_repo.dart';
// import 'package:supabase/supabase.dart';
//
// class ProfileRepositoryImpl implements ProfileRepository {
//   final SupabaseClient supabase;
//   ProfileRepositoryImpl(this.supabase);
//
//   @override
//   Future<Map<String, dynamic>> getProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) throw Exception("User not logged in");
//
//     // Try fetching profile, if doesn't exist (e.g. trigger failed), return auth defaults
//     final res = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
//
//     if (res == null) {
//       return {
//         'full_name': user.userMetadata?['full_name'] ?? 'New User',
//         'email': user.email,
//         'avatar_url': user.userMetadata?['avatar_url'],
//       };
//     }
//     return res;
//   }
//
//   @override
//   Future<void> updateProfile(Map<String, dynamic> data) async {
//     final user = supabase.auth.currentUser;
//     if (user == null) throw Exception("User not logged in");
//
//     await supabase.from('profiles').update({
//       'full_name': data['full_name'],
//       'title_role': data['title_role'],
//       'phone': data['phone'],
//       'location': data['location'],
//       'avatar_url': data['avatar_url'],
//       'updated_at': DateTime.now().toIso8601String(),
//     }).eq('id', user.id);
//   }
//
//   @override
//   Future<String> uploadAvatar(File file) async {
//     final user = supabase.auth.currentUser;
//     final path = 'avatars/${user!.id}/profile.png';
//     await supabase.storage.from('avatars').upload(path, file, fileOptions: const FileOptions(upsert: true));
//     return supabase.storage.from('avatars').getPublicUrl(path);
//   }
// }