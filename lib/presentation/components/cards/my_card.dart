import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  MyCard({Key? key}) : super(key: key);
  final List<Map> myProducts =
      List.generate(100, (index) => {"id": index, "name": "Card $index"})
          .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: Image.asset(
          'assets/images/christ.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
