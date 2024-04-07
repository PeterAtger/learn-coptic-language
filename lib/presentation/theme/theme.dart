import 'dart:developer';

import 'package:ebty/presentation/blocs/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors({required this.main}) {
    background = main[100]!;
  }

  MaterialColor main = Colors.green;

  Color background = Colors.white;
  Color navColor = Colors.white;
  static Color errorColor = Colors.red;
  Color cardColor = const Color.fromARGB(125, 255, 255, 255);
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
  ThemeData manageState(ThemeState state) {
    log(state.theme.toString());

    switch (state.theme) {
      case Themes.kg:
        AppColors appColors = AppColors(main: Colors.pink);
        return light(appColors);
      case Themes.primary_1:
        AppColors appColors = AppColors(main: Colors.deepPurple);
        return light(appColors);
      case Themes.primary_3:
        AppColors appColors = AppColors(main: Colors.green);
        return light(appColors);
      case Themes.primary_5:
        AppColors appColors = AppColors(main: Colors.blue);
        return light(appColors);
      case Themes.preparatory:
        AppColors appColors = AppColors(main: Colors.lime);
        return light(appColors);
      case Themes.secondary:
        AppColors appColors = AppColors(main: Colors.deepOrange);
        return light(appColors);
    }
  }

  ThemeData light(AppColors appColors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: appColors.main,
        backgroundColor: appColors.background,
      ),
      scaffoldBackgroundColor: appColors.background,
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: appColors.navColor,
          labelTextStyle: const MaterialStatePropertyAll(
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
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            )),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            backgroundColor:
                MaterialStateProperty.all<Color>(appColors.cardColor)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(appColors.cardColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        )),
        side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(color: Colors.black, width: 2),
        ),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            )),
            backgroundColor:
                MaterialStateProperty.all<Color>(appColors.cardColor)),
      ),
    );
  }

  dark() {
    AppColors appColors = AppColors(main: Colors.green);

    return ThemeData(
      primarySwatch: appColors.main,
      scaffoldBackgroundColor: appColors.background,
      fontFamily: 'lato',
      buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0))),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
