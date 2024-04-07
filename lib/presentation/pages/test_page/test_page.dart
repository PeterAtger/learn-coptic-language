import 'package:ebty/presentation/components/cards/list_card_v2.dart';
import 'package:flutter/material.dart';
import 'package:ebty/Model/word_model.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});
  final List<Map<MahfozatKeys, String>> items = MahfozatList.getWordList();

  @override
  Widget build(BuildContext context) {
    return ListCardV2(items: items);
  }
}
