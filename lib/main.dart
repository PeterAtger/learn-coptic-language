import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'screens/letters_page.dart';
import 'screens/words_page.dart';
import 'screens/hymns_page.dart';
import 'screens/grammar_page.dart';
import 'screens/grammar_en_page.dart';
import 'screens/bookmarks_page.dart';
import 'services/stage_service.dart';
import 'services/language_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Android 15 (targetSdk 35+) draws apps edge-to-edge by default.
  // Make the system bars transparent and ensure icons stay readable on the
  // parchment background.
  // Edge-to-edge makes the system bars transparent automatically; setting
  // statusBarColor / systemNavigationBarColor explicitly triggers Android 15
  // deprecation warnings, so we only configure icon brightness here.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light, // iOS
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LanguageService(), StageService()]),
      builder: (context, _) {
        final accent = StageService().selectedStage.accent;
        return MaterialApp(
          title: LanguageService().translate('app_title'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: accent).copyWith(
              primary: accent,
            ),
            useMaterial3: true,
            textTheme: LanguageService().isArabic
                ? GoogleFonts.cairoTextTheme()
                : GoogleFonts.poppinsTextTheme(),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final StageService _stageService = StageService();
  final LanguageService _langService = LanguageService();

  @override
  void initState() {
    super.initState();
    _stageService.addListener(_onStageChanged);
    _langService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _stageService.removeListener(_onStageChanged);
    _langService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  void _onStageChanged() {
    // If the currently selected tab becomes hidden, switch to Home (0)
    final stage = _stageService.selectedStage;
    bool currentIsHidden = false;
    if (_selectedIndex == 1 && stage.hideLetters) currentIsHidden = true;
    if (_selectedIndex == 2 && stage.hideWords) currentIsHidden = true;
    if (_selectedIndex == 4 && stage.hideGrammar) currentIsHidden = true;

    if (currentIsHidden) {
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stageService.selectedStage;
    final accent = Theme.of(context).colorScheme.primary;

    final List<Widget> widgetOptions = <Widget>[
      HomePage(onNavigateTo: _onItemTapped),
      const LettersPage(),
      const WordsPage(),
      const HymnsPage(),
      _langService.isArabic ? const GrammarPage() : const GrammarEnPage(),
      const BookmarksPage(),
    ];

    // Define all possible items
    final allItems = [
      {'index': 0, 'icon': Icons.home_rounded, 'label': _langService.translate('main_page'), 'hide': false},
      {'index': 1, 'icon': Icons.sort_by_alpha_rounded, 'label': _langService.translate('letters'), 'hide': stage.hideLetters},
      {'index': 2, 'icon': Icons.menu_book_rounded, 'label': _langService.translate('words'), 'hide': stage.hideWords},
      {'index': 3, 'icon': Icons.headphones_rounded, 'label': _langService.translate('hymns'), 'hide': false},
      {'index': 4, 'icon': Icons.gavel_rounded, 'label': _langService.translate('grammar'), 'hide': stage.hideGrammar},
      {'index': 5, 'icon': Icons.star_rounded, 'label': _langService.translate('bookmarks'), 'hide': false},
    ];

    final visibleItems = allItems.where((item) => !(item['hide'] as bool)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0), // Parchment Light Background
      body: Stack(
        children: [
          // Background Mesh — tinted by the selected stage accent
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: BackgroundPainter(accent: accent),
              ),
            ),
          ),

          // Core Content
          SafeArea(
            bottom: false,
            child: widgetOptions.elementAt(_selectedIndex),
          ),

          // Bottom Navigation Bar — lift above the gesture/nav bar inset
          Align(
            alignment: Alignment.bottomCenter,
            child: RepaintBoundary(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 16.0 + MediaQuery.of(context).viewPadding.bottom,
                  left: 16.0,
                  right: 16.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                    child: Container(
                      height: 66,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                          )
                        ]
                      ),
                      child: Row(
                        children: visibleItems.map((item) => Expanded(
                          child: _buildNavItem(
                            item['index'] as int,
                            item['icon'] as IconData,
                            item['label'] as String,
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final activeColor = Theme.of(context).colorScheme.primary;
    const inactiveColor = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: isSelected ? 25 : 22,
              child: Center(
                child: index == 1
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'ⲀⲰ',
                          style: TextStyle(
                            fontFamily: 'CopticStandard',
                            fontSize: isSelected ? 19 : 17,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                      )
                    : Icon(
                        icon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: isSelected ? 25 : 22,
                      ),
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: _langService.isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? activeColor : inactiveColor,
                      )
                    : GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color accent;

  // Two warm fixed pops keep the background cheerful even on cool accents.
  static const _sunny = Color(0xFFFACC15);
  static const _peach = Color(0xFFFDBA74);

  const BackgroundPainter({required this.accent});

  void _blob(Canvas canvas, Rect rect, Size size, Color color,
      double cx, double cy, double scale, double alpha) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: alpha), Colors.transparent],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * cx, size.height * cy),
        width: size.width * scale,
        height: size.height * scale,
      ));
    canvas.drawRect(rect, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Derive a small palette from the stage accent so the whole background
    // visibly shifts when the user picks a new grade.
    final hsl = HSLColor.fromColor(accent);
    final lighter = hsl
        .withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();
    final analogousWarm = hsl
        .withHue((hsl.hue + 30) % 360)
        .withLightness((hsl.lightness + 0.05).clamp(0.0, 1.0))
        .toColor();
    final analogousCool = hsl
        .withHue((hsl.hue - 30 + 360) % 360)
        .withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0))
        .toColor();
    final complement = hsl
        .withHue((hsl.hue + 180) % 360)
        .withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0))
        .toColor();

    // Warm cream base
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFAF0));

    // Strong corners in the stage accent
    _blob(canvas, rect, size, accent,        0.10, 0.08, 1.5, 0.46);
    _blob(canvas, rect, size, analogousWarm, 0.92, 0.05, 1.4, 0.40);

    // Mid-screen — analogous shades for cohesion
    _blob(canvas, rect, size, lighter,       0.05, 0.42, 1.3, 0.34);
    _blob(canvas, rect, size, analogousCool, 0.95, 0.45, 1.3, 0.34);
    _blob(canvas, rect, size, complement,    0.55, 0.30, 1.2, 0.24);

    // Bottom band — accent echoes + warm pops so cool stages still feel happy
    _blob(canvas, rect, size, lighter,       0.15, 0.92, 1.4, 0.34);
    _blob(canvas, rect, size, _peach,        0.50, 0.95, 1.2, 0.24);
    _blob(canvas, rect, size, accent,        0.88, 0.92, 1.3, 0.40);

    // Tiny sunny pop top-center
    _blob(canvas, rect, size, _sunny,        0.45, 0.02, 0.9, 0.20);

    // Soft white wash for content legibility
    _blob(canvas, rect, size, Colors.white,  0.50, 0.55, 2.0, 0.36);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
