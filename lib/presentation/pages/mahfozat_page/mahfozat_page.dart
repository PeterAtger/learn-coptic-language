import 'package:ebty/presentation/components/listCards/list_cards.dart';
import 'package:flutter/material.dart';

class MahfozatPage extends StatelessWidget {
  MahfozatPage({super.key});
  final List<Map> ayat = List.generate(
      4,
      (index) => {
            "id": index,
            "name": "assets/images/Mahfozat/Ayat/$index.png"
          }).toList();
  final List<Map> alnoor = List.generate(
      13,
      (index) => {
            "id": index,
            "name": "assets/images/Mahfozat/OmAlnwr/$index.png"
          }).toList();

  @override
  Widget build(BuildContext context) {
    return ListCards(items: alnoor);
  }
}
