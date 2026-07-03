



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../color/color.dart';

class ThemeConfig {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.white,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
      bodyMedium: const TextStyle(color: AppColors.textGrey)
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    // TextTheme apply karne se sare text colors brightness ke hisab se adjust ho jate hain
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(
        color: Colors.white, // Dark mode mein white color
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: const TextStyle(
        color: Colors.white70, // Thoda light grey/white subtitle ke liye
      ),
    ),
  );
}


// import 'package:flutter/material.dart';
//
// class ThemeConfig {
//
//   static const primaryColor = Color(0xff115CCD);
//   static const darkBackColor = Color(0xff141A1F);
//
//   static const textColo151152 = Color(0xff151152);
//   static const dividerColor = Color(0xffECEAEA);
//   static const borderColorLight = Color(0xff151152);
//   static const borderColorDark = Color(0xffFEFEFE);
//
//   static const textColorBCBFC2 = Color(0xffBCBFC2);
//   static const textColor6B698E = Color(0xff6B698E);
//
//   static const alertColorFE373D = Color(0xffFE373D);
//   static const textColorEFECEC = Color(0xffEFECEC);
//   static const textColorFAFAFA = Color(0xffFAFAFA);
//
//   static const textColor141A1F = Color(0xff141A1F);
//   static const textColor202934 = Color(0xff202934);
//
//   static const textColor151152 = Color(0xff151152);
//   static const textColorF6F8F8 = Color(0xffF6F8F8);
//   static const textColor0F0425 = Color(0xff0F0425);
//
//   static const textColor808080 = Color(0xff808080);
//   static const textColorDCE8E8 = Color(0xffDCE8E8);
//   static const textColor37C9EE = Color(0xff37C9EE);
//
//   /// fonts family
//   static const pangramRegular = 'Pangram Regular';
//   static const pangramMedium = 'Pangram Medium';
//   static const pangramBold = 'Pangram Bold';
//   static const pangramExtraBold = 'Pangram Extra Bold';
//   static const pangramLight = 'Pangram Light';
//
// }
