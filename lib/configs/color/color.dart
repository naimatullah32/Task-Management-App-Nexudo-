import 'package:flutter/material.dart';

class AppColors {

  static const Color primaryBlue = Color(0xFF6B7EFF);
  static const Color primaryPurple = Color(0xFF9B6BFF);
  static const Color teal = Color(0xFF1BBA8F);
  static const Color amber = Color(0xFFF59E0B);
  static const Color dark = Color(0xFF0D0D1A);
  static const Color darkCard = Color(0xFF13132A);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF6B7280);

  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF6200EE);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF000000);

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xFFBB86FC);
  // static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Color(0xFFFFFFFF);

  // Common Colors
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);

  // static const Color primaryBlue = Color(0xFF4A7DFF);
  static const Color lightBlue = Color(0xFF8DAEFF); // For Sign Up button

  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);

  // Text Colors
  // static const Color textDark = Color(0xFF2D3142);
  // static const Color textGrey = Color(0xFF9C9EB9);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Indicators
  static const Color inactiveGrey = Color(0xFFE0E0E0);
}

// splash aur editProfileScreen mai dark aur light mode bhi set karo system based, aur han editProfileScreen sai data edit hoga aur phir jaki supabase mai wo permanently store hoga aur phir profile screen mai fitch hoga wo data, aur han mobile entrance animation nhi chahiye sirf screen slide up+fade animation hona chahiye phone  entrance ka zarorat nhi aur slide up+fade animation dono screen mai hon profile screen, aur editProfileScreen mai bhi