import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

class CardsPage extends StatelessWidget {
  CardsPage({super.key});
  final List<Map> myProducts =
      List.generate(1, (index) => {"id": index, "name": "Card $index"})
          .toList();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.builder(
          padding: const EdgeInsets.only(bottom: 32),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          itemCount: myProducts.length,
          itemBuilder: (BuildContext ctx, index) {
            return Material(
              elevation: 8,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.navColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Text(myProducts[index]["name"]),
              ),
            );
          }),
    );
  }
}
