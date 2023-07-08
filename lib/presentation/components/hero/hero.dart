import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

class MyHero extends StatelessWidget {
  const MyHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Text(
            AppTexts.homePageheading,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            AppTexts.homePageSub,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image(image: AssetImage('assets/images/christ.png')),
            ),
          ),
        ],
      ),
    );
  }
}
