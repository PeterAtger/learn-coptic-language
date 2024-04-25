import 'package:flutter/material.dart';

class PaperOverlay extends StatelessWidget {
  const PaperOverlay({super.key, required this.child, required this.color});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: Container(
        color: color,
      )),
      Positioned.fill(
          child: Image(
        image: const AssetImage('assets/images/paper.png'),
        repeat: ImageRepeat.repeat,
        colorBlendMode: BlendMode.multiply,
        color: color,
      )),
      child
    ]);
  }
}
