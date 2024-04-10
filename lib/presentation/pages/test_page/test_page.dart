import 'dart:developer';

import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/cards/list_card_v2.dart';
import 'package:flutter/material.dart';
import 'package:ebty/Model/word_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});
  final List<Map<MahfozatKeys, String>> items = MahfozatList.getWordList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: ListCardV2(items: items)),
        Align(
          alignment: Alignment.topCenter,
          child: BlocBuilder<YearCubit, YearState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: () {
                  log(state.year.index.toString());
                  Years theme = state.year;
                  context.read<YearCubit>().changeTheme(
                      Years.values[(theme.index + 1) % (Years.values.length)]);
                },
                child: const Text('Switch Theme'),
              );
            },
          ),
        )
      ],
    );
  }
}
