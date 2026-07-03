import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

extension FlushBarMessage on BuildContext {
  void flushBarSuccessMessage({required String message}) {
    showFlushbar(
      context: this,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut, // Exit animation smooth karne ke liye
        shouldIconPulse: false, // Stats ke waqt blinking issues nahi aayenge
        isDismissible: true,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(20),
        messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(20),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.greenAccent.shade700],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 15,
          )
        ],
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
        ),
      )..show(this),
    );
  }

  // Error Message
  void flushBarErrorMessage({required String message}) {
    showFlushbar(
      context: this,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        shouldIconPulse: false,
        isDismissible: true,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(20),
        messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(20),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundGradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.orange.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 15,
          )
        ],
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 28),
        ),
      )..show(this),
    );
  }
}