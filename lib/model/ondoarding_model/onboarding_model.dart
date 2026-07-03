import 'dart:ui';

import 'package:flutter/cupertino.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color primary;
  final Color secondary;
  final IconData icon;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.primary,
    required this.secondary,
    required this.icon,
  });
}