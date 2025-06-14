import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors({required this.main}) {
    background = main[100]!;
  }

  MaterialColor main;

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
  ThemeData manageState(Years year) {
    switch (year) {
      case Years.kg:
        AppColors appColors = AppColors(main: Colors.lightBlue);
        return light(appColors);
      case Years.primary_1:
        AppColors appColors = AppColors(main: Colors.yellow);
        return light(appColors);
      case Years.primary_3:
        AppColors appColors = AppColors(main: Colors.green);
        return light(appColors);
      case Years.primary_5:
        AppColors appColors = AppColors(main: Colors.purple);
        return light(appColors);
      case Years.preparatory:
        AppColors appColors = AppColors(main: Colors.indigo);
        return light(appColors);
      case Years.secondary:
        AppColors appColors = AppColors(main: Colors.orange);
        return light(appColors);
      case Years.college:
        AppColors appColors = AppColors(main: Colors.brown);
        return light(appColors);
      case Years.servants:
        AppColors appColors = AppColors(main: Colors.grey);
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
            labelTextStyle: const WidgetStatePropertyAll(
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
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            )),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            backgroundColor:
                WidgetStateProperty.all<Color>(appColors.cardColor),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(appColors.cardColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )),
          side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: Colors.black, width: 1),
          ),
        )),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(appColors.main[300]!),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
          shape: WidgetStateProperty.all<BeveledRectangleBorder>(
              BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          )),
        )),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: appColors.main[200],
            elevation: 8,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: const BorderSide(color: Colors.black, width: 1))));
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
