import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_management/view/SplashScreen/splash_screen.dart';

import '../Welcome_screen/welcome_screen.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onComplete: () {
        // After splash finishes, navigate to your WelcomeScreen
        // Using a post-frame callback ensures the navigation happens after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        });
      },
    );
  }
}