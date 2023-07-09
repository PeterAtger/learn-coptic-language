import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class ListCards extends StatelessWidget {
  ListCards({super.key, required this.items, this.hasAudio = false});
  final player = AudioPlayer();
  final List<Map> items;
  final bool hasAudio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          itemCount: items.length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                child: TextButton(
                  onPressed: hasAudio
                      ? () {
                          if (index != 0) {
                            player.play(AssetSource(items[index - 1]["audio"]));
                          }
                        }
                      : null,
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
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
          }),
    );
  }
}
