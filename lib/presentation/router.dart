import 'package:ebty/presentation/pages/error_screen/error_screen.dart';
import 'package:ebty/presentation/pages/letters_screen/letters_screen.dart';
import 'package:ebty/presentation/theme/theme.dart';
import 'package:ebty/presentation/main_page.dart';
import 'package:flutter/material.dart';

class RouterGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => const MyHomePage(
                  title: AppTexts.title,
                ));
      case '/letters':
        return MaterialPageRoute(builder: (_) => const LettersScreen());
      default:
        return MaterialPageRoute(builder: (_) => const ErorrScreen());
    }
  }
}
