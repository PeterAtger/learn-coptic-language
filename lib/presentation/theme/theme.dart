import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  const AppColors();

  static final Color background = Colors.pink[200]!;
  static const Color navColor = Color(0xFFf5efef);
  static const Color errorColor = Colors.red;
}

class AppTexts {
  static const title = 'تعلم اللغة القبطية';
  static const errorMessage =
      'فيه حاجة حصلت غلط مش عارف اوى هى ايه بس هوصلها متقلقش';
  static const youClicked = 'لقد نقرت على النقر عدد نقرات:';
  static const homePageheading = 'اللغة القبطية';
  static const homePageSub = 'كنيسة الشهيدين ابى سيفين ودميانة';
}

class AppTheme {
  light() {
    return ThemeData(
      primarySwatch: Colors.pink,
      scaffoldBackgroundColor: AppColors.background,
      navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: AppColors.navColor,
          labelTextStyle: MaterialStatePropertyAll(
              TextStyle(letterSpacing: 0, fontSize: 11))),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarBrightness: Brightness.dark)),
      fontFamily: 'lato',
      buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0))),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  dark() {
    return ThemeData(
      primarySwatch: Colors.pink,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'lato',
      buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0))),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
