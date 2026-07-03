import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  SignUpRequested(this.name, this.email, this.password);
}

class LoginRequested extends AuthEvent {
  final String email, password;

  LoginRequested(this.email, this.password);
}

class GoogleLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String email;
  SendOtpRequested(this.email);
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  VerifyOtpRequested(this.email, this.otp);
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}
































// // import 'package:equatable/equatable.dart';
// //
// //  class AuthEvent extends Equatable {
// //   @override
// //   List<Object?> get props => [];
// // }
// //
// // /// SIGN IN
// // class LoginEvent extends AuthEvent {
// //   final String email;
// //   final String password;
// //
// //   LoginEvent(this.email, this.password);
// // }
// //
// // /// SIGN UP
// // class SignUpEvent extends AuthEvent {
// //   final String username;
// //   final String email;
// //   final String password;
// //
// //   SignUpEvent(this.username, this.email, this.password);
// // }
// //
// // /// GOOGLE LOGIN
// // class GoogleLoginEvent extends AuthEvent {}
// //
// // /// FORGOT PASSWORD (SEND OTP)
// // class ForgotPasswordEvent extends AuthEvent {
// //   final String email;
// //
// //   ForgotPasswordEvent(this.email);
// //
// //   @override
// //   List<Object?> get props => [email];
// // }
// //
// // /// REQUEST OTP
// // class RequestOtpEvent extends AuthEvent {
// //   final String email;
// //
// //   RequestOtpEvent(this.email);
// // }
// //
// // /// VERIFY OTP
// // class VerifyOtpEvent extends AuthEvent {
// //   final String otp;
// //
// //   VerifyOtpEvent(this.otp);
// //
// //   @override
// //   List<Object?> get props => [otp];
// // }
// //
// // /// RESET PASSWORD
// // class ResetPasswordEvent extends AuthEvent {
// //   final String newPassword;
// //
// //   ResetPasswordEvent(this.newPassword);
// //
// //   @override
// //   List<Object?> get props => [newPassword];
// // }
// //
// // /// LOGOUT
// // class LogoutEvent extends AuthEvent {}
//
//
//
// abstract class AuthEvent {}
//
// class LoginRequested extends AuthEvent {
//   final String email;
//   final String password;
//
//   LoginRequested(this.email, this.password);
// }
//
// class SignUpRequested extends AuthEvent {
//   final String username;
//   final String email;
//   final String password;
//
//   SignUpRequested(this.username, this.email, this.password);
// }
//
// class GoogleLoginRequested extends AuthEvent {}
//
// class ForgotPasswordRequested extends AuthEvent {
//   final String email;
//   ForgotPasswordRequested(this.email);
// }
//
// class VerifyOtpRequested extends AuthEvent {
//   final String otp;
//   VerifyOtpRequested(this.otp);
// }
//
// class LogoutRequested extends AuthEvent {}