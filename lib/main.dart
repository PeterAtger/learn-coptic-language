import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'screens/letters_page.dart';
import 'screens/words_page.dart';
import 'screens/hymns_page.dart';
import 'screens/grammar_page.dart';
import 'screens/bookmarks_page.dart';
import 'services/stage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StageService _stageService = StageService();

  @override
  void initState() {
    super.initState();
    _stageService.addListener(_onStageChanged);
  }

  @override
  void dispose() {
    _stageService.removeListener(_onStageChanged);
    super.dispose();
  }

  void _onStageChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accent = _stageService.selectedStage.accent;
    return MaterialApp(
      title: 'منهج القبطي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: accent).copyWith(
          primary: accent,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      home: const MainScreen(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final List<Widget> widgetOptions = <Widget>[
      HomePage(onNavigateTo: _onItemTapped),
      const LettersPage(),
      const WordsPage(),
      const HymnsPage(),
      const GrammarPage(),
      const BookmarksPage(),
    ];

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

          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
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
                        children: [
                          Expanded(child: _buildNavItem(0, Icons.home_rounded, 'الرئيسية')),
                          Expanded(child: _buildNavItem(1, Icons.sort_by_alpha_rounded, 'الحروف')),
                          Expanded(child: _buildNavItem(2, Icons.menu_book_rounded, 'الكلمات')),
                          Expanded(child: _buildNavItem(3, Icons.headphones_rounded, 'المحفوظات')),
                          Expanded(child: _buildNavItem(4, Icons.gavel_rounded, 'القواعد')),
                          Expanded(child: _buildNavItem(5, Icons.star_rounded, 'المحفوظة')),
                        ],
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
            index == 1
                ? Text(
                    'ⲀⲰ',
                    style: TextStyle(
                      fontFamily: 'CopticStandard',
                      fontSize: isSelected ? 19 : 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  )
                : Icon(
                    icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: isSelected ? 25 : 22,
                  ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
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

  // Two warm fixed pops keep the background from going monochrome on cool
  // accents (blue/indigo/teal stages).
  static const _sunny = Color(0xFFFACC15);   // warm yellow
  static const _peach = Color(0xFFFDBA74);   // peach

  const BackgroundPainter({required this.accent});

  void _blob(Canvas canvas, Rect rect, Size size, Color color, double cx, double cy, double scale, double alpha) {
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

    // Derive a small palette from the stage accent using HSL so the whole
    // background visibly shifts when the user picks a new grade.
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
    _blob(canvas, rect, size, accent,         0.10, 0.08, 1.5, 0.46);
    _blob(canvas, rect, size, analogousWarm,  0.92, 0.05, 1.4, 0.40);

    // Mid-screen — analogous shades for cohesion
    _blob(canvas, rect, size, lighter,        0.05, 0.42, 1.3, 0.34);
    _blob(canvas, rect, size, analogousCool,  0.95, 0.45, 1.3, 0.34);
    _blob(canvas, rect, size, complement,     0.55, 0.30, 1.2, 0.24);

    // Bottom band — accent echoes + a fixed warm pop so cool stages still feel happy
    _blob(canvas, rect, size, lighter,        0.15, 0.92, 1.4, 0.34);
    _blob(canvas, rect, size, _peach,         0.50, 0.95, 1.2, 0.24);
    _blob(canvas, rect, size, accent,         0.88, 0.92, 1.3, 0.40);

    // Tiny sunny pop top-center keeps even dark stages from feeling heavy
    _blob(canvas, rect, size, _sunny,         0.45, 0.02, 0.9, 0.20);

    // Soft white wash through the middle for content legibility
    // Lower alpha so the colored blobs actually pop through.
    _blob(canvas, rect, size, Colors.white,   0.50, 0.55, 2.0, 0.36);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
