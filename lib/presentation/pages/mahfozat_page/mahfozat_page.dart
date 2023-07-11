import 'package:ebty/presentation/components/listCards/list_cards.dart';
import 'package:flutter/material.dart';

class MahfozatPage extends StatelessWidget {
  MahfozatPage({super.key});
  final List<Map> ayat = List.generate(
      5,
      (index) => {
            "id": index,
            "name": "assets/images/Mahfozat/Ayat/$index.png",
            "audio": "audio/Ayat/$index.mp3"
          }).toList();
  final List<Map> alnoor = List.generate(
      18,
      (index) => {
            "id": index,
            "name": "assets/images/Mahfozat/OmAlnwr/$index.png",
            "audio": "audio/OmAlnwr/$index.mp3"
          }).toList();

  @override
  Widget build(BuildContext context) {
    return <Widget>[
      ListCards(
        items: alnoor,
        hasAudio: true,
      ),
      const Divider(
        height: 32,
      ),
      ListCards(
        items: ayat,
        hasAudio: true,
      ),
    ][0];
  }
}
