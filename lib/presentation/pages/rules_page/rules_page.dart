import 'package:flutter/material.dart';

class Rulespage extends StatelessWidget {
  Rulespage({super.key});
  final List<Map> images = List.generate(4,
          (index) => {"id": index, "name": "assets/images/Grammar/$index.png"})
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          itemCount: images.length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              margin: const EdgeInsets.all(8),
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(32),
                  child: Image.asset(images[index]["name"]),
                ),
              ),
            );
          }),
    );
  }
}
