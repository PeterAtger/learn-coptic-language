import 'package:ebty/presentation/components/cards/neumorphic.dart';
import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NeumorphicCard(key: Key('start')),
              const SizedBox(
                height: 36,
              ),
              const Text('صفحة فاضية املاها انت بخيالك'),
              Container(
                padding: const EdgeInsets.all(32),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                            vertical: 24, horizontal: 32))),
                    child: const Text('ارجع ورا')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
