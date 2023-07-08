import 'package:flutter/material.dart';

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

class AppTheme {
  light() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'lato',
      buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0))),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  dark() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'lato',
      buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0))),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
