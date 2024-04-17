import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class GridCards extends StatefulWidget {
  const GridCards({
    super.key,
    required this.items,
  });

  final List<Map> items;

  @override
  State<GridCards> createState() => _GridCardsState();
}

class _GridCardsState extends State<GridCards> {
  final player = AudioPlayer();

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 2 / 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 8),
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, index) {
          return GridTile(
            child: Material(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: Colors.transparent,
              child: OutlinedButton(
                onPressed: () {
                  player.play(AssetSource(widget.items[index]["audio"]));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Image.asset(widget.items[index]["name"]),
                ),
              ),
            ),
          );
        });
  }
}
