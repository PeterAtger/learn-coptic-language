import 'dart:convert';

import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:flutter/services.dart';

enum WordsKeys { image, gender, audio }

Map<Years, String> audioFolderMap = {
  Years.kg: 'kg',
  Years.primary_1: 'primary_1',
  Years.primary_3: 'primary_3',
  Years.primary_5: 'primary_5',
  Years.preparatory: 'prep',
  Years.secondary: 'sec',
};

Map<Years, String> wordsFiles = {
  Years.kg: "assets/data/words_kg.json",
  Years.primary_1: "assets/data/words_primary_1.json",
  Years.primary_3: "assets/data/words_primary_3.json",
  Years.primary_5: "assets/data/words_primary_5.json",
  Years.preparatory: "assets/data/words_prep.json",
  Years.secondary: "assets/data/words_sec.json",
};

class Words {
  String fliePath = '';
  List<Word> words = [];
  bool loaded = false;

  Words({required Years year}) {
    if (!wordsFiles.containsKey(year)) {
      throw Exception("Year not found");
    }

    fliePath = wordsFiles[year]!;
  }

  Future<Words> getWordsList() async {
    if (loaded) return this;

    final String rawData = await rootBundle.loadString(fliePath);
    final List data = await json.decode(rawData);

    for (int i = 0; i < data.length; i++) {
      words.add(parseWord(data[i]));
    }

    loaded = true;

    return this;
  }

  static Word parseWord(Map data) {
    return Word(
      image: data[WordsKeys.image.name],
      gender: data[WordsKeys.gender.name],
      audio: data[WordsKeys.audio.name],
    );
  }
}

class Word {
  final String image;
  final String gender;
  final String audio;

  Word({required this.image, required this.audio, required this.gender});
}
