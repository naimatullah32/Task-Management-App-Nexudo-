// import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
//
// abstract class AuthRepository {
//   Future<AuthResponse?> login(String email, String password);
//   Future<AuthResponse?> signUp(String email, String password, String name);
//   Future<void> signInWithGoogle();
//   Future<void> forgotPassword(String email);
//   Future<void> requestOtp(String email);
//   Future<void> verifyOtp(String otp);
//   Future<void> resetPassword(String newPassword);
//   // Future<Map<String, dynamic>> getUserProfile();
//   // Future<void> updateUserProfile(Map<String, dynamic> data);
//   // Future<String> uploadProfileImage(File image);
//   // Future<void> logout();
//   User? get currentUser;
// }

import '../../bloc/auth_bloc/auth_state.dart';

abstract class AuthRepository {
  Future<String> signUp(String name, String email, String password);
  Future<String> login(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> logout();
  Future<String> sendOtp(String email);
  Future<String> verifyOtp(String email, String otp);
  Future<String> resetPassword(String newPassword);
  Future<String> forgotPassword(String email);
  User? get currentUser;
  // Stream<AuthState> get authStateChanges;

// Future<String> sendOtp(String email);
  // Future<String> verifyOtp(String otp);

  // Future<void> logout();
}