import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/auth_repository/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.signup));
      try {
        final message = await repository.signUp(
          event.name,
          event.email,
          event.password,
        );
        emit(AuthSuccess(message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.login));
      try {
        final message = await repository.login(event.email, event.password);
        emit(AuthSuccess(message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<GoogleLoginRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.google));

      try {
        await repository.signInWithGoogle();

        // ❌ DON'T EMIT SUCCESS HERE
        // Google login not finished yet

      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.logout));

      try {
        await repository.logout();

        emit(AuthSuccess("Logged out successfully"));

      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.forgot));

      try {
        final message = await repository.forgotPassword(event.email);
        emit(AuthSuccess(message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.otp));

      try {
        final message = await repository.sendOtp(event.email);
        emit(AuthSuccess(message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.otpVerify));

      try {
        final message = await repository.verifyOtp(event.email, event.otp);

        emit(AuthSuccess(message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading(AuthAction.resetPassword));
      try {
        final message = await repository.resetPassword(event.newPassword);
        emit(AuthSuccess(message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}

// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../repository/auth_repository/profile_repo.dart';
// import 'auth_event.dart';
// import 'auth_state.dart';
//
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository authRepo;
//
//   AuthBloc(this.authRepo) : super(AuthInitial()) {
//
//     /// LOGIN
//     on<LoginEvent>((event, emit) async {
//       emit(LoginLoading());
//
//       try {
//         await authRepo.login(event.email, event.password);
//
//         emit(AuthSuccess("Login successful"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//
//     /// SIGNUP
//     on<SignUpEvent>((event, emit) async {
//       emit(SignupLoading());
//
//       try {
//         await authRepo.signUp(
//           event.email,
//           event.password,
//           event.username,
//         );
//
//         emit(AuthSuccess("Account created successfully"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//
//     /// GOOGLE LOGIN
//     on<GoogleLoginEvent>((event, emit) async {
//       emit(GoogleLoading());
//
//       try {
//         await authRepo.signInWithGoogle();
//
//         emit(AuthSuccess("Google login successful"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//
//     // ---------------- FORGOT PASSWORD ----------------
//     on<ForgotPasswordEvent>((event, emit) async {
//       emit(ForgotPasswordLoading());
//
//       try {
//         await authRepo.forgotPassword(event.email);
//         emit(AuthSuccess("OTP sent to email"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//
//
//     /// REQUEST OTP
//     on<RequestOtpEvent>((event, emit) async {
//       emit(OtpLoading());
//
//       try {
//         await authRepo.requestOtp(event.email);
//
//         emit(AuthSuccess("OTP sent to your email"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//
//     /// VERIFY OTP
//     // ---------------- VERIFY OTP ----------------
//     on<VerifyOtpEvent>((event, emit) async {
//       emit(OtpLoading());
//
//       try {
//         await authRepo.verifyOtp(event.otp);
//         emit(AuthSuccess("OTP verified successfully"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//
//     // ---------------- RESET PASSWORD ----------------
//     on<ResetPasswordEvent>((event, emit) async {
//       emit(ResetPasswordLoading());
//
//       try {
//         await authRepo.resetPassword(event.newPassword);
//         emit(AuthSuccess("Password reset successfully"));
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//     //
//
//     on<LogoutEvent>((event, emit) async {
//       emit(LogoutLoading());
//
//       try {
//         await authRepo.logout();
//
//         emit(AuthSuccess("Logged out successfully"));
//
//         emit(AuthInitial());
//
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     });
//   }
// }
