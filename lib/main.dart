import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/router.dart';
import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => YearCubit()..loadData(),
      child: BlocSelector<YearCubit, YearState, Years>(
        selector: (state) {
          return state.year;
        },
        builder: (context, year) {
          return MaterialApp(
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
            title: 'Learn Coptic Language',
            themeMode: ThemeMode.light,
            theme: AppTheme().manageState(year),
            darkTheme: AppTheme().dark(),
            onGenerateRoute: RouterGenerator.generateRoute,
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
