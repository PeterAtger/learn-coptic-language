import 'package:ebty/Presentation/Pages/error_screen/error_screen.dart';
import 'package:ebty/Presentation/Theme/theme.dart';
import 'package:ebty/Presentation/main_page.dart';
import 'package:flutter/material.dart';

class RouterGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const MyHomePage(
                  title: AppTexts.title,
                ));
      default:
        return MaterialPageRoute(builder: (_) => const ErorrScreen());
    }
  }
}
