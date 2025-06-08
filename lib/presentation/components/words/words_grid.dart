import 'package:audioplayers/audioplayers.dart';
import 'package:ebty/Model/words_model.dart';
import 'package:ebty/presentation/components/Text/sheouda_text.dart';
import 'package:flutter/material.dart';

class WordsGrid extends StatefulWidget {
  const WordsGrid({super.key, required this.items, required this.audioFolder});

  final String audioFolder;
  final List<Word> items;
  final String imageLocation = "assets/images/wordsV3/";
  final String audioLocation = "audio/wordsV2/";

  @override
  State<WordsGrid> createState() => _WordsGridState();
}

class _WordsGridState extends State<WordsGrid> {
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
          return Stack(
            children: [
              Positioned(
                top: 16.0,
                right: 16.0,
                child: ShenoudaText(text: widget.items[index].gender),
              ),
              GridTile(
                child: Material(
                  color: Colors.transparent,
                  child: OutlinedButton(
                    onPressed: () {
                      player.play(AssetSource(
                          '${widget.audioLocation}${widget.audioFolder}/${widget.items[index].audio}'));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: Image.asset(
                          widget.imageLocation + widget.items[index].image),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
