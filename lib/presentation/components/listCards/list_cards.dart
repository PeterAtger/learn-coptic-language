import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class ListCards extends StatelessWidget {
  ListCards({super.key, required this.items, this.hasAudio = false});
  final player = AudioPlayer();
  final List<Map> items;
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
                onPressed: hasAudio
                    ? () {
                        if (index != 0 && index != 13) {
                          player.play(AssetSource(items[index - 1]["audio"]));
                        }
                      }
                    : null,
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ))),
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Image.asset(items[index]["name"]),
                ),
              ),
            ),
          );
        });
  }
}
