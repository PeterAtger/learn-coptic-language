import 'package:ebty/Data/words.dart';

const String filePath = "assets/data/words.json";

enum MahfozatKeys { id, arabic, coptic }

class MahfozatList {
  static List<Map<MahfozatKeys, String>> getWordList() {
    List<Map<String, String>> items = words;

    List<Map<MahfozatKeys, String>> data = [];

    for (var element in items) {
      data.add({
        MahfozatKeys.id: element["id"]!,
        MahfozatKeys.arabic: element["arabic"]!,
        MahfozatKeys.coptic: element["coptic"]!,
      });
    }

    return data;
  }
}
