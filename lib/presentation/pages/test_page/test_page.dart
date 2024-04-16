import 'package:ebty/Model/words_model.dart';
import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/words/words_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late Future<Words> items;

  Future<Words> getWords(Years year) async {
    Words words = Words(year: year);
    await words.getWordsList();

    return words;
  }

  @override
  void initState() {
    Years year = context.read<YearCubit>().state.year;
    items = getWords(year);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: items,
        builder: (BuildContext context, AsyncSnapshot<Words> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return renderData(snapshot.data);
        });
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
