import 'package:audioplayers/audioplayers.dart';
import 'package:ebty/Model/word_model.dart';
import 'package:flutter/material.dart';

class ListCardV2 extends StatelessWidget {
  ListCardV2({super.key, required this.items, this.hasAudio = false});
  final player = AudioPlayer();
  final List<Map<MahfozatKeys, String>> items;
  final bool hasAudio;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        itemCount: items.length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Material(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: Colors.transparent,
                child: OutlinedButton(
                  onPressed: () => {},
                  child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            items[index][MahfozatKeys.coptic] ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Avva_Shenouda',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            items[index][MahfozatKeys.arabic] ?? "",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ])),
                )),
          );
        });
  }
}
