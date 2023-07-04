import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 200,
              child: Image(image: AssetImage('assets/images/coptic_cross.png')),
            ),
            const Text(
              AppTexts.title,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32),
              child: ElevatedButton(
                  onPressed: () {
                    final player = AudioPlayer();
                    player.play(AssetSource('/audio/ding.mp3'));
                    Navigator.pushNamed(context, '/letters');
                  },
                  style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 24, horizontal: 32))),
                  child: const Text('متدوسش هتولع فالبرنامج')),
            )
          ],
        ),
      ),
    );
  }
}
