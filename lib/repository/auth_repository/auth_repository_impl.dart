import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repo.dart';

// import 'auth_repo.dart';


class AuthRepositoryImpl implements AuthRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<String> signUp(String name, String email, String password) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (res.user == null) {
        return "Signup failed.";
      }

      return "Account created successfully.";
    } catch (e) {
      throw AuthExceptionHandler.handle(e);
    }
  }

  @override
  Future<String> login(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        return "Login failed.";
      }

      return "Login successful.";
    } catch (e) {
      throw AuthExceptionHandler.handle(e);
    }
  }

  // ✅ GOOGLE SIGN-IN (NATIVE PICKER)
  @override
  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception("Logout failed: ${e.toString()}");
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      await supabase.auth.signInWithOtp(email: email);
      return "OTP sent to your email";
    } on AuthException catch (e) {
      throw Exception(handleForgotPassowrdError(e));
    }
  }

  @override
  Future<String> sendOtp(String email) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
      );
      return "OTP sent to your email.";
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    try {
      await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      return "OTP verified successfully";
    } catch (e) {
      throw Exception("Invalid OTP");
    }
  }

  @override
  Future<String> resetPassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return "Password updated successfully";
    } on AuthException catch (e) {
      throw Exception(handleForgotPassowrdError(e));
    }
  }

  @override
  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      supabase.auth.onAuthStateChange;

}







//-------------------------Message Handling-------------------------------------------

String _handleError(dynamic e) {
  final msg = e.toString().toLowerCase();

  if (msg.contains("invalid")) return "Invalid request.";
  if (msg.contains("rate")) return "Too many attempts. Try later.";
  if (msg.contains("network")) return "No internet connection.";

  return "Something went wrong.";
}


class AuthExceptionHandler {
  static String handle(dynamic error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return "Incorrect email or password.";
      }

      if (msg.contains('email not confirmed')) {
        return "Please verify your email before logging in.";
      }

      if (msg.contains('user already registered')) {
        return "This email is already registered.";
      }

      if (msg.contains('invalid email')) {
        return "Please enter a valid email address.";
      }

      if (msg.contains('password')) {
        return "Password should be at least 6 characters.";
      }

      if (msg.contains('rate limit')) {
        return "Too many attempts. Please try again later.";
      }

      return error.message;
    }

    if (error.toString().contains('SocketException')) {
      return "No internet connection.";
    }

    return "Something went wrong. Please try again.";
  }
}


String handleForgotPassowrdError(AuthException e) {
  final msg = e.message.toLowerCase();

  if (e.message.toLowerCase().contains("token has expired")) {
    throw Exception("OTP has expired");
  }
  if (e.message.toLowerCase().contains("invalid token")) {
    throw Exception("Invalid OTP");
  }
  if (msg.contains("user not found")) {
    return "No account found with this email";
  } else if (msg.contains("invalid login credentials")) {
    return "Incorrect email or password";
  } else if (msg.contains("rate limit")) {
    return "Too many attempts. Try again later";
  } else {
    return e.message;
  }
}




















// // import 'dart:io';
// // import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'profile_repo.dart';
// //
// // class AuthRepositoryImpl implements AuthRepository {
// //   final SupabaseClient _supabase = Supabase.instance.client;
// //
// //   /// STORE EMAIL TEMP (OTP FLOW)
// //   String? _tempEmail;
// //
// //
//    @override
//    User? get currentUser => supabase.auth.currentUser;
// //
// //   // Internet Check Helper
// //   Future<void> _checkConnectivity() async {
// //     final result = await Connectivity().checkConnectivity();
// //     if (result == ConnectivityResult.none) {
// //       throw "No internet connection. Please check your network.";
// //     }
// //   }
// //
// //   // LOGIN
// //   @override
// //   Future<AuthResponse?> login(String email, String password) async {
// //     await _checkConnectivity();
// //
// //     try {
// //       final response = await _supabase.auth.signInWithPassword(
// //         email: email,
// //         password: password,
// //       );
// //
// //       return response;
// //     } on AuthException catch (e) {
// //       throw _handleSupabaseError(e);
// //     } catch (_) {
// //       throw "Login failed. Please try again.";
// //     }
// //   }
// //
// //   // SIGNUP
// //   @override
// //   Future<AuthResponse?> signUp(
// //       String email,
// //       String password,
// //       String name,
// //       ) async {
// //     await _checkConnectivity();
// //
// //     try {
// //       final response = await _supabase.auth.signUp(
// //         email: email,
// //         password: password,
// //         data: {'full_name': name},
// //       );
// //
// //       if (response.user != null) {
// //         await _supabase.from('profiles').upsert({
// //           'id': response.user!.id,
// //           'name': name,
// //           'email': email,
// //           'updated_at': DateTime.now().toIso8601String(),
// //         });
// //       }
// //
// //       return response;
// //     } on AuthException catch (e) {
// //       throw _handleSupabaseError(e);
// //     } catch (_) {
// //       throw "Signup failed. Please try again.";
// //     }
// //   }
// //
// //   // GOOGLE LOGIN
// //   @override
// //   Future<void> signInWithGoogle() async {
// //     await _checkConnectivity();
// //     try {
// //       await _supabase.auth.signInWithOAuth(OAuthProvider.google);
// //     } catch (e) {
// //       throw "Google Sign-In failed.";
// //     }
// //   }
// //
// //   // ----------------------------
// //   // 1. FORGOT PASSWORD (SEND OTP)
// //   // ----------------------------
// //   @override
// //   Future<void> forgotPassword(String email) async {
// //     try {
// //
// //       _tempEmail = email;
// //
// //       await _supabase.auth.resetPasswordForEmail(
// //         email,
// //       );
// //
// //     } on AuthException catch (e) {
// //       throw e.message;
// //     } catch (_) {
// //       throw "Failed to send OTP";
// //     }
// //   }
// //
// //   // REQUEST OTP (Forgot Password)
// //   @override
// //   Future<void> requestOtp(String email) async {
// //     await _checkConnectivity();
// //
// //     try {
// //       await _supabase.auth.resetPasswordForEmail(email);
// //     } on AuthException catch (e) {
// //       throw _handleSupabaseError(e);
// //     } catch (_) {
// //       throw "Failed to send reset email.";
// //     }
// //   }
// //   // ----------------------------
// //   // 2. VERIFY OTP
// //   // ----------------------------
// //   @override
// //   Future<void> verifyOtp(String otp) async {
// //     try {
// //
// //       await _supabase.auth.verifyOTP(
// //         type: OtpType.email,
// //         token: otp,
// //         email: _tempEmail,
// //       );
// //
// //     } on AuthException catch (e) {
// //       throw e.message;
// //     } catch (_) {
// //       throw "Invalid OTP";
// //     }
// //   }
// //
// //   // ----------------------------
// //   // 3. RESET PASSWORD
// //   // ----------------------------
// //   @override
// //   Future<void> resetPassword(String newPassword) async {
// //     try {
// //
// //       await _supabase.auth.updateUser(
// //         UserAttributes(password: newPassword),
// //       );
// //
// //     } on AuthException catch (e) {
// //       throw e.message;
// //     } catch (_) {
// //       throw "Password reset failed";
// //     }
// //   }
// // }
// //
// //   // GET PROFILE
// //   @override
// //   // Future<Map<String, dynamic>> getUserProfile() async {
// //   //   final user = currentUser;
// //   //   if (user == null) throw "User not logged in";
// //   //
// //   //   try {
// //   //     final data = await _supabase
// //   //         .from('profiles') // Supabase mein profiles table behtar hai
// //   //         .select()
// //   //         .eq('id', user.id)
// //   //         .maybeSingle();
// //   //
// //   //     if (data != null) return data;
// //   //
// //   //     // Default data if no record exists
// //   //     return {
// //   //       "name": user.userMetadata?['full_name'] ?? "User Name",
// //   //       "email": user.email ?? "",
// //   //       "image": "",
// //   //       "subtitle": "Professional Title",
// //   //       "location": "Set Location",
// //   //       "phone": "Add Phone",
// //   //       "projects_done": 0,
// //   //       "projects_pending": 0,
// //   //     };
// //   //   } catch (e) {
// //   //     throw "Failed to load profile.";
// //   //   }
// //   // }
// //   //
// //   // // UPDATE PROFILE
// //   // @override
// //   // Future<void> updateUserProfile(Map<String, dynamic> data) async {
// //   //   final user = currentUser;
// //   //   if (user == null) throw "User not logged in";
// //   //   try {
// //   //     await _supabase.from('profiles').upsert({...data, 'id': user.id});
// //   //   } catch (e) {
// //   //     throw "Failed to update profile.";
// //   //   }
// //   // }
// //   //
// //   // // UPLOAD PROFILE IMAGE
// //   // @override
// //   // Future<String> uploadProfileImage(File image) async {
// //   //   await _checkConnectivity();
// //   //   try {
// //   //     final user = currentUser;
// //   //     if (user == null) throw "User not logged in";
// //   //
// //   //     final String path = "${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";
// //   //
// //   //     // Upload to Supabase Storage (Bucket: profile_images)
// //   //     await _supabase.storage.from('profile_images').upload(
// //   //       path,
// //   //       image,
// //   //       fileOptions: const FileOptions(upsert: true),
// //   //     );
// //   //
// //   //     // Get Public URL
// //   //     return _supabase.storage.from('profile_images').getPublicUrl(path);
// //   //   } catch (e) {
// //   //     throw "Image upload failed.";
// //   //   }
// //   // }
// //   //
// //   // @override
// //   // Future<void> logout() async {
// //   //   await _supabase.auth.signOut();
// //   // }
// //
// //   // --- ERROR HANDLING HELPER ---
// //   String _handleSupabaseError(AuthException e) {
// //     if (e.message.contains("Invalid login credentials")) {
// //       return "Incorrect email or password.";
// //     } else if (e.message.contains("already registered")) {
// //       return "This email is already in use.";
// //     } else if (e.message.contains("User not found")) {
// //       return "No account found with this email.";
// //     } else if (e.message.contains("network")) {
// //       return "Network error. Please try again.";
// //     }
// //     return e.message;
// //   }
//
// import 'profile_repo.dart';
//
// class AuthRepoImpl implements AuthRepository {
//   @override
//   Future<String> login(String email, String password) async {
//     try {
//       // API CALL
//       return "Login successful";
//     } catch (e) {
//       throw Exception("Login failed");
//     }
//   }
//
//   @override
//   Future<String> signUp(String username, String email, String password) async {
//     try {
//       // IMPORTANT FIX:
//       // only success if account created, NOT email sent confusion
//       return "Account created successfully. Please login.";
//     } catch (e) {
//       throw Exception("Signup failed");
//     }
//   }
//
//   @override
//   Future<String> googleLogin() async {
//     try {
//       // FIX GOOGLE FLOW HERE
//       // ensure token returned
//       return "Google login successful";
//     } catch (e) {
//       throw Exception("Google login failed");
//     }
//   }
//
//   @override
//   Future<String> sendOtp(String email) async {
//     try {
//       return "OTP sent to email";
//     } catch (e) {
//       throw Exception("Failed to send OTP");
//     }
//   }
//
//   @override
//   Future<String> verifyOtp(String otp) async {
//     try {
//       return "OTP verified successfully";
//     } catch (e) {
//       throw Exception("Invalid OTP");
//     }
//   }
//
//   @override
//   Future<void> logout() async {
//     // clear token
//   }
// }
