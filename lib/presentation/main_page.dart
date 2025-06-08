import 'package:ebty/presentation/blocs/year/year_cubit.dart';
import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:ebty/presentation/components/hero/hero.dart';
import 'package:ebty/presentation/components/paperOverlay/paper_overlay.dart';
import 'package:ebty/presentation/pages/letters_page/letters_page.dart';
import 'package:ebty/presentation/pages/mahfozat_page/mahfozat_page.dart';
import 'package:ebty/presentation/pages/rules_page/rules_page.dart';
import 'package:ebty/presentation/pages/words_page/words_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const hasNoRules = [Years.kg];
const messages = [
  "تم صنع هذا البرنامج بواسطة خدام كنيسة ابي سيفين والشهيدة دميانة بشبرا. أذكرونا فى صلواتكم",
  "أضغط على الحرف لسماع النطق باللغة القبطية",
  "أضغط على الكلمة لسماع النطق باللغة القبطية",
  "أضغط ضغطة قصيرة لسماع نطق المحفوظات باللغة القبطية أو ضغطة طويلة لسماع اللحن",
  "يمكنك استخدام اصبعين لتكبير او تصغير القاعدة",
];

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
    return BlocBuilder<YearCubit, YearState>(
      builder: (context, state) {
        bool skipRule = hasNoRules.contains(state.year);
        return PaperOverlay(
          color: Theme.of(context).colorScheme.background,
          child: Scaffold(
              appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => showCustomDialog(context),
                    tooltip: "مساعدة",
                  ),
                  centerTitle: true,
                  title: Text(
                    'تعلم اللغة القبطية',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
              backgroundColor: Colors.transparent,
              bottomNavigationBar: NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                selectedIndex: currentPageIndex,
                destinations: <Widget>[
                  const NavigationDestination(
                    selectedIcon: Icon(Icons.home),
                    icon: Icon(Icons.home_outlined),
                    label: 'الرئيسية',
                  ),
                  const NavigationDestination(
                    selectedIcon: Icon(Icons.text_fields),
                    icon: Icon(Icons.text_fields_outlined),
                    label: 'الحروف',
                  ),
                  const NavigationDestination(
                    selectedIcon: Icon(Icons.book),
                    icon: Icon(Icons.book_outlined),
                    label: 'الكلمات',
                  ),
                  const NavigationDestination(
                    selectedIcon: Icon(Icons.headphones),
                    icon: Icon(Icons.headphones_outlined),
                    label: 'المحفوظات',
                  ),
                  NavigationDestination(
                    selectedIcon: const Icon(Icons.gavel),
                    icon: const Icon(Icons.gavel_outlined),
                    label: 'القواعد',
                    enabled: !skipRule,
                  ),
                ],
              ),
              body: <Widget>[
                const MyHero(key: Key('hero')),
                const LettersPage(key: Key('Cards')),
                const WordsPage(key: Key('Words')),
                const MahfozatPage(key: Key('Mahfozat')),
                const RulesPage(key: Key('Rules')),
              ][currentPageIndex]),
        );
      },
    );
  }

  Future<dynamic> showCustomDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(messages[currentPageIndex]),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.only(top: 32, left: 32, right: 32),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'أغلاق'),
            child: const Text(
              'أغلاق',
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
