import 'package:ebty/presentation/components/gridCards/grid_cards.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});
  final List<Map> items = List.generate(
      32,
      (index) => {
            "id": index,
            "name": "assets/images/Alphabet/$index.png",
            "audio": "audio/letters/$index.mp3"
          }).toList();

  @override
  Widget build(BuildContext context) {
    return GridCards(items: items);
  }
}
