import 'dart:convert';

import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:flutter/services.dart';

enum MahfozatKeys { arabic, coptic, audio, longAudio }

enum MahfozatTypes { level, group, item }

Map<Years, String> mahfozatFiles = {
  Years.kg: "assets/data/mahfozat_kg.json",
  Years.primary_1: "assets/data/mahfozat_primary_1.json",
  Years.primary_3: "assets/data/mahfozat_primary_3.json",
  Years.primary_5: "assets/data/mahfozat_primary_5.json",
  Years.preparatory: "assets/data/mahfozat_prep.json",
  Years.secondary: "assets/data/mahfozat_sec.json",
};

class Mahfozat {
  String fliePath = '';
  List<MahfozatLevel> levels = [];
  int count = 0;
  bool loaded = false;

  Mahfozat({required Years year}) {
    if (!mahfozatFiles.containsKey(year)) {
      throw Exception("Year not found");
    }

    fliePath = mahfozatFiles[year]!;
  }

  Future<Mahfozat> getMahfozatList() async {
    if (loaded) return this;

    final String rawData = await rootBundle.loadString(fliePath);
    final Map<String, dynamic> data = await json.decode(rawData);

    for (String key in data.keys) {
      levels.add(parseLevel(key, data[key]));
      count++;
    }

    loaded = true;

    return this;
  }

  static List<FlatMahfozatItem> toFlatList(Mahfozat mahfozat) {
    List<FlatMahfozatItem> flatList = [];

    for (MahfozatLevel level in mahfozat.levels) {
      flatList.add(FlatMahfozatItem(item: level, type: MahfozatTypes.level));
      for (MahfozatGroup group in level.groups) {
        flatList.add(FlatMahfozatItem(item: group, type: MahfozatTypes.group));
        for (MahfozatItem item in group.items) {
          flatList.add(FlatMahfozatItem(item: item, type: MahfozatTypes.item));
        }
      }
    }

    return flatList;
  }

  static MahfozatLevel parseLevel(String level, Map data) {
    List<MahfozatGroup> groups = [];

    for (String groupKey in data.keys) {
      groups.add(parseGroup(groupKey, data[groupKey]));
    }

    return MahfozatLevel(level: level, groups: groups);
  }

  static MahfozatGroup parseGroup(String key, List data) {
    List<MahfozatItem> items = [];

    for (Map<String, dynamic> item in data) {
      items.add(parseItem(item));
    }

    return MahfozatGroup(name: key, items: items);
  }

  static MahfozatItem parseItem(Map<String, dynamic> data) {
    final String arabic = data[MahfozatKeys.arabic.name] ?? '';
    final String coptic = data[MahfozatKeys.coptic.name] ?? '';
    final String audio = data[MahfozatKeys.audio.name] ?? '';
    final String longAudio = data[MahfozatKeys.longAudio.name] ?? '';

    return MahfozatItem(
        arabic: arabic, coptic: coptic, audio: audio, longAudio: longAudio);
  }
}

class BaseMahfozat {}

class MahfozatLevel extends BaseMahfozat {
  final String level;
  final List<MahfozatGroup> groups;

  MahfozatLevel({required this.level, required this.groups});
}

class MahfozatGroup extends BaseMahfozat {
  final String name;
  final List<MahfozatItem> items;

  MahfozatGroup({required this.name, required this.items});
}

class MahfozatItem extends BaseMahfozat {
  final String arabic;
  final String coptic;
  final String audio;
  final String longAudio;

  MahfozatItem(
      {required this.arabic,
      required this.coptic,
      required this.audio,
      required this.longAudio});
}

class FlatMahfozatItem {
  final BaseMahfozat item;
  final MahfozatTypes type;

  FlatMahfozatItem({required this.item, required this.type});
}
