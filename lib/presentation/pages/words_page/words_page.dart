import 'package:ebty/Model/audio_model.dart';
import 'package:ebty/Model/words_model.dart';
import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/words/words_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordsPage extends StatefulWidget {
  const WordsPage({super.key});

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YearCubit, YearState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return renderData(state.words);
        }
      },
    );
  }

  Widget renderData(Words? data) {
    Years year = context.read<YearCubit>().state.year;

    if (data == null) {
      return const SizedBox(
        child: Text('No data'),
      );
    }

    return WordsGrid(
      items: data.words,
      audioFolder: audioFolderMap[year] ?? "",
    );
  }
}
