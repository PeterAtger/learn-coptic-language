import 'package:ebty/presentation/components/cards/my_card.dart';
import 'package:flutter/material.dart';

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyCard(key: const Key('start')),
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
