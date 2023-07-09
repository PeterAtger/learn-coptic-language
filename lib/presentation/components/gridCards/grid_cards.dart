import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class GridCards extends StatelessWidget {
  GridCards({
    super.key,
    required this.items,
  });

  final List<Map> items;
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 2 / 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 8),
        itemCount: items.length,
        itemBuilder: (BuildContext ctx, index) {
          return Material(
            elevation: 8,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: TextButton(
              onPressed: () {
                player.play(AssetSource(items[index]["audio"]));
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ))),
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Image.asset(items[index]["name"]),
              ),
            ),
          );
        });
  }
}
