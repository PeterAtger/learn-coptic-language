import 'package:ebty/presentation/components/listCards/list_cards.dart';
import 'package:flutter/material.dart';

class Rulespage extends StatelessWidget {
  Rulespage({super.key});
  final List<Map> rules = List.generate(4,
          (index) => {"id": index, "name": "assets/images/Grammar/$index.png"})
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListCards(items: rules);
  }
}
