import 'package:ebty/presentation/components/hero/hero.dart';
import 'package:ebty/presentation/components/paperOverlay/paper_overlay.dart';
import 'package:ebty/presentation/pages/letters_page/letters_page.dart';
import 'package:ebty/presentation/pages/mahfozat_page/mahfozat_page.dart';
import 'package:ebty/presentation/pages/rules_page/rules_page.dart';
import 'package:ebty/presentation/pages/test_page/test_page.dart';
import 'package:ebty/presentation/pages/words_page/words_page.dart';
import 'package:ebty/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

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
    return PaperOverlay(
      color: Theme.of(context).colorScheme.background,
      child: Scaffold(
          appBar: AppBar(
              title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'تعلم اللغة القبطية',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )),
          backgroundColor: Colors.transparent,
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.book),
                label: 'الحروف',
              ),
              NavigationDestination(
                icon: Icon(Icons.text_fields_outlined),
                label: 'الكلمات',
              ),
              NavigationDestination(
                icon: Icon(Icons.headphones_outlined),
                label: 'المحفوظات',
              ),
              NavigationDestination(
                icon: Icon(Icons.stacked_bar_chart),
                label: 'القواعد',
              ),
              NavigationDestination(
                icon: Icon(Icons.wysiwyg),
                label: 'Test',
              ),
            ],
          ),
          body: <Widget>[
            const MyHero(key: Key('hero')),
            LettersPage(
              key: const Key('Cards'),
            ),
            WordsPage(
              key: const Key('Words'),
            ),
            MahfozatPage(key: const Key('Mahfozat')),
            Rulespage(
              key: const Key('Rules'),
            ),
            TestPage(
              key: const Key('Test'),
            )
          ][currentPageIndex]),
    );
  }
}
