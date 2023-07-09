import 'package:ebty/presentation/components/gridCards/grid_cards.dart';
import 'package:flutter/material.dart';

class CardsPage extends StatelessWidget {
  CardsPage({super.key});
  final List<Map> items = List.generate(
      32,
      (index) => {
            "id": index,
            "name": "assets/images/Alphabet/$index.png",
            "audio": "audio/letters/$index.mp3"
          }).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridCards(items: items),
    );
  }
}
