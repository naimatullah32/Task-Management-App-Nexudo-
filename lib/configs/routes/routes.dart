import 'package:flutter/material.dart';

import 'package:task_management/configs/routes/routes_name.dart';

import 'package:task_management/view/Home/home_screen.dart';
import 'package:task_management/view/NavigationBar/Navigation.dart';
import 'package:task_management/view/Profile/profileView.dart';
import 'package:task_management/view/SplashScreen/splash_screen.dart';
import 'package:task_management/view/Welcome_screen/welcome_screen.dart';

import 'package:task_management/view/auth_views/forgot_password/OTP_view.dart';
import 'package:task_management/view/auth_views/forgot_password/forgot_pass.dart';
import 'package:task_management/view/auth_views/forgot_password/reset_pass.dart';
import 'package:task_management/view/auth_views/forgot_password/password_success_screen.dart';

import 'package:task_management/view/auth_views/login/login_view.dart';
import 'package:task_management/view/auth_views/signUp/sign_up.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.welcome:
        return MaterialPageRoute(
          builder: (BuildContext context) => const WelcomeScreen(),
        );

      case RoutesName.splash:
        return MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen(),
        );

      case RoutesName.login:
        return MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        );

      case RoutesName.signup:
        return MaterialPageRoute(
          builder: (BuildContext context) => const SignUpScreen(),
        );

      case RoutesName.home:
        return MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        );

      case RoutesName.forgotPassword:
        return MaterialPageRoute(
          builder: (BuildContext context) => const ForgotPasswordScreen(),
        );

      case RoutesName.otpView:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => VerifyOTPScreen(
            email: args["email"],
            message: args["message"],
          ),
        );

      case RoutesName.resetPassword:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (BuildContext context) => ResetPasswordScreen(
            email: args['email'],
            otp: args['otp'],
          ),
        );

      case RoutesName.navBar:
        return MaterialPageRoute(
          builder: (BuildContext context) => DashboardScreen(
            message: settings.arguments as String?,
          ),
        );

      case RoutesName.passwordSuccess:
        return MaterialPageRoute(
          builder: (BuildContext context) => const ResetSuccessScreen(),
        );

      case RoutesName.profileView:
        return MaterialPageRoute(
          builder: (BuildContext context) => const ProfileScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) {
            return const Scaffold(
              body: Center(
                child: Text('No route defined'),
              ),
            );
          },
        );
    }
  }
}