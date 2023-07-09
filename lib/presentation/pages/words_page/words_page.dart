import 'package:ebty/presentation/components/gridCards/grid_cards.dart';
import 'package:flutter/material.dart';

class WordsPage extends StatelessWidget {
  WordsPage({super.key});
  final List<Map> items = List.generate(
      42,
      (index) => {
            "id": index,
            "name": "assets/images/words/$index.png",
            "audio": "audio/words/$index.mp3"
          }).toList();

  @override
  Widget build(BuildContext context) {
    return GridCards(items: items);
  }
}
