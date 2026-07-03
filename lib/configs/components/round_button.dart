import 'package:flutter/material.dart';
import '../color/color.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final Color buttonColor;
  final Color textColor;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPress,
    this.buttonColor = AppColors.primaryBlue,
    this.textColor = AppColors.textWhite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }
}