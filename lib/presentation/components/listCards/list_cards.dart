import 'package:flutter/material.dart';

class ListCards extends StatelessWidget {
  const ListCards({
    super.key,
    required this.items,
  });

  final List<Map> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          itemCount: items.length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              margin: const EdgeInsets.all(8),
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(32),
                  child: Image.asset(items[index]["name"]),
                ),
              ),
            );
          }),
    );
  }
}
