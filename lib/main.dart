import 'package:ebty/presentation/router.dart';
import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'PhiloDem Coptic Teacher',
      themeMode: ThemeMode.light,
      theme: AppTheme().light(),
      darkTheme: AppTheme().dark(),
      onGenerateRoute: RouterGenerator.generateRoute,
      initialRoute: '/',
    );
  }
}
