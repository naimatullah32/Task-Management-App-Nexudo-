import 'package:equatable/equatable.dart';

enum AuthAction { login, signup, google, reset, otpVerify, otp, forgot, forgotPassword, resetPassword, logout }

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final AuthAction action;

  AuthLoading(this.action);

  @override
  List<Object?> get props => [action];
}

class AuthSuccess extends AuthState {
  final String message;

   AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends AuthState {
  final String message;

   AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}




































// // import 'package:equatable/equatable.dart';
// //
// // abstract class AuthState extends Equatable {
// //   const AuthState();
// //
// //   @override
// //   List<Object?> get props => [];
// // }
// //
// // /// INITIAL
// // class AuthInitial extends AuthState {}
// //
// // /// LOGIN LOADING
// // class LoginLoading extends AuthState {}
// //
// // /// SIGNUP LOADING
// // class SignupLoading extends AuthState {}
// //
// // /// GOOGLE LOADING
// // class GoogleLoading extends AuthState {}
// //
// // /// Forgot password LOADING
// // class ForgotPasswordLoading extends AuthState {}
// //
// // /// OTP LOADING
// // class OtpLoading extends AuthState {}
// //
// // /// RESET PASSWORD LOADING
// // class ResetPasswordLoading extends AuthState {}
// //
// // /// SUCCESS
// // class AuthSuccess extends AuthState {
// //   final String message;
// //
// //   const AuthSuccess(this.message);
// //
// //   @override
// //   List<Object?> get props => [message];
// // }
// //
// // /// ERROR
// // class AuthError extends AuthState {
// //   final String message;
// //
// //   const AuthError(this.message);
// //
// //   @override
// //   List<Object?> get props => [message];
// // }
//
//
// abstract class AuthState {}
//
// class AuthInitial extends AuthState {}
//
// class AuthLoading extends AuthState {
//   final AuthAction action;
//   AuthLoading(this.action);
// }
//
// class AuthSuccess extends AuthState {
//   final String message;
//   AuthSuccess(this.message);
// }
//
// class AuthFailure extends AuthState {
//   final String message;
//   AuthFailure(this.message);
// }
//
//
// // Action
// enum AuthAction {
//   login,
//   signup,
//   google,
//   forgotPassword,
//   otpVerify,
//   resetPassword,
// }