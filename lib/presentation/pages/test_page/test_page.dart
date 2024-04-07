import 'dart:developer';

import 'package:ebty/presentation/blocs/theme/theme_cubit.dart';
import 'package:ebty/presentation/blocs/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:ebty/Model/word_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});
  final List<Map<MahfozatKeys, String>> items = MahfozatList.getWordList();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return FilledButton(
            onPressed: () {
              log(state.theme.index.toString());
              Themes theme = state.theme;
              context.read<ThemeCubit>().changeTheme(
                  Themes.values[(theme.index + 1) % (Themes.values.length)]);
            },
            child: const Text('Switch Theme'),
          );
        },
      ),
    );
  }
}
