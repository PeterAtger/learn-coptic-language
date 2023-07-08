import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.navColor,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.commute),
            label: 'Commute',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
        ],
      ),
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
            Text('You\'re on page number $currentPageIndex'),
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
