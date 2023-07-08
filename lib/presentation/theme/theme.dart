import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  const AppFonts();
  static final TextStyle heading1 = GoogleFonts.lato(
      fontSize: 101, fontWeight: FontWeight.w300, letterSpacing: -1.5);

  static final TextStyle heading2 =
      GoogleFonts.lato(fontSize: 63, fontWeight: FontWeight.w300);

  static final TextStyle heading3 =
      GoogleFonts.lato(fontSize: 50, fontWeight: FontWeight.w400);

  static final TextStyle heading4 = GoogleFonts.lato(
      fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0.25);

  static final TextStyle heading5 =
      GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.w400);

  static final TextStyle heading6 = GoogleFonts.lato(
      fontSize: 21, fontWeight: FontWeight.w500, letterSpacing: 0.15);

  static final TextStyle button = GoogleFonts.lato(
      fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 1.25);

  static final TextStyle bodyText1 = GoogleFonts.lato(
      fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0.5);

  static final TextStyle captionText = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.4);
}

class AppColors {
  const AppColors();

  static final Color background = Colors.blue[100]!;
  static final Color navColor = Colors.blue[50]!;
  static const Color errorColor = Colors.red;
}

class AppTexts {
  static const title = 'تعلم اللغة القبطية';
  static const errorMessage =
      'فيه حاجة حصلت غلط مش عارف اوى هى ايه بس هوصلها متقلقش';
  static const youClicked = 'لقد نقرت على النقر عدد نقرات:';
}
