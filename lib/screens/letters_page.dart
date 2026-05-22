import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import '../services/stage_service.dart';
import '../services/language_service.dart';
import '../services/audio_service.dart';
import '../widgets/settings_modal.dart';

Map<String, dynamic> _parseLettersJson(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class LetterRule {
  final String text;
  final String? label;

  LetterRule({required this.text, this.label});
}

class LetterData {
  final String char;
  final String small;
  final String name;
  final String phonetic;
  final List<LetterRule> rules;
  final Color color;
  final Color accent;

  LetterData({
    required this.char,
    required this.small,
    required this.name,
    required this.phonetic,
    required this.rules,
    required this.color,
    required this.accent,
  });
}

class LettersPage extends StatefulWidget {
  const LettersPage({super.key});

  @override
  State<LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends State<LettersPage> {
  final StageService _stageService = StageService();
  final LanguageService _langService = LanguageService();
  final AudioService _audioService = AudioService();
  List<LetterData> _letters = [];
  bool _isLoading = true;
  final String _searchQuery = "";
  int? _playingIndex;
  double _audioProgress = 0.0;

  String _getCopticFontFamily(String text) {
    return 'CopticStandard';
  }

  @override
  void initState() {
    super.initState();
    _stageService.addListener(_onStageChanged);
    _langService.addListener(_onLanguageChanged);
    _loadData();
    _audioService.onPositionChanged.listen((p) async {
      final d = await _audioService.getDuration();
      if (d != null && d.inMilliseconds > 0 && mounted) {
        setState(() {
          _audioProgress = p.inMilliseconds / d.inMilliseconds;
        });
      }
    });
    _audioService.setOnComplete(() {
      if (mounted) {
        setState(() {
          _playingIndex = null;
          _audioProgress = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.stop();
    _stageService.removeListener(_onStageChanged);
    _langService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _loadData();
  }

  void _onStageChanged() {
    _loadData();
  }

  final List<Color> _letterColors = const [
    Color(0xFFDC2626), Color(0xFFB45309), Color(0xFF047857), Color(0xFF1D4ED8),
    Color(0xFFE11D48), Color(0xFF334155), Color(0xFFD97706), Color(0xFFC2410C),
    Color(0xFF0F766E), Color(0xFF4338CA), Color(0xFF6B21A8), Color(0xFFBE185D),
    Color(0xFF991B1B), Color(0xFF1E40AF), Color(0xFF92400E), Color(0xFF166534),
    Color(0xFF0E7490), Color(0xFF9F1239), Color(0xFF1E293B), Color(0xFFC2410C),
    Color(0xFF581C87), Color(0xFF4D7C0F), Color(0xFF065F46), Color(0xFF1E3A8A),
    Color(0xFF3730A3), Color(0xFF9A3412), Color(0xFF7C2D12), Color(0xFF44403C),
    Color(0xFF0F172A), Color(0xFF78350F), Color(0xFF14532D), Color(0xFF312E81),
  ];

  Future<void> _loadData() async {
    // Helper to try multiple paths
    Future<String> tryLoad(String path) async {
      try {
        return await rootBundle.loadString(path);
      } catch (_) {
        if (path.startsWith('assets/')) {
          return await rootBundle.loadString(path.replaceFirst('assets/', ''));
        }
        rethrow;
      }
    }

    try {
      if (mounted) setState(() { _isLoading = true; });
      final String jsonPath = _langService.getDataPath('letters');
      final String jsonString = await tryLoad(jsonPath);
      final Map<String, dynamic> jsonResponse = await compute(_parseLettersJson, jsonString);

      final stageId = _stageService.selectedStage.id;
      final List<dynamic> lettersList = (stageId == "nursery" || stageId == "primary12" || stageId == "special_needs_average")
          ? (jsonResponse['juniorLetters'] as List<dynamic>? ?? [])
          : (jsonResponse['fullLetters'] as List<dynamic>? ?? []);

      if (mounted) {
        setState(() {
        _letters = lettersList.asMap().entries.map((entry) {
          final idx = entry.key;
          final data = entry.value;
          return LetterData(
            char: data['char'] ?? '',
            small: data['small'] ?? '',
            name: data['name'] ?? '',
            phonetic: data['phonetic'] ?? '',
            rules: (data['rules'] as List<dynamic>? ?? []).map((r) => LetterRule(
              text: r['text'] ?? '',
              label: r['label'],
            )).toList(),
            color: _letterColors[idx % _letterColors.length],
            accent: _letterColors[idx % _letterColors.length].withValues(alpha: 0.08),
          );
        }).toList();
        _isLoading = false;
      });
      }
    } catch (e) {
      print("Error loading letters: $e");
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _playAudio(int index) async {
    try {
      if (_playingIndex == index) {
        await _audioService.stop();
        if (mounted) {
          setState(() {
            _playingIndex = null;
            _audioProgress = 0.0;
          });
        }
      } else {
        final letter = _letters[index];
        final audioPath = 'audio/letters/$index.mp3';
        
        await _audioService.playAsset(audioPath);
        
        if (mounted) {
          setState(() {
            _playingIndex = index;
            _audioProgress = 0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    final filteredLetters = _letters.where((letter) {
      final query = _searchQuery.trim().toLowerCase();
      return query.isEmpty ||
          letter.name.toLowerCase().contains(query) ||
          letter.phonetic.toLowerCase().contains(query) ||
          letter.char.toLowerCase().contains(query);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFAF9F6).withValues(alpha: 0.4),
            const Color(0xFFF3F4F6).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Responsive Premium Header
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'ⲀⲰ',
                        style: TextStyle(
                          fontFamily: 'CopticStandard',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => SettingsModal.show(
                        context,
                        showVisibilityToggles: false,
                        showImagesToggle: false,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _langService.translate('coptic_letters'),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1C1917),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${_langService.translate('year_2026')} • ${_langService.translate(_stageService.selectedStage.id)}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Streamlined List of Gorgeous Letter Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
              cacheExtent: 500, // Increased for smoother scrolling
              itemCount: filteredLetters.length,
              itemBuilder: (context, index) {
                final letter = filteredLetters[index];
                final letterIdx = _letters.indexOf(letter);
                final isPlaying = _playingIndex == letterIdx;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isPlaying ? Colors.white : const Color(0xFFFDFBF7),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: isPlaying ? letter.color : const Color(0xFFE2E8F0),
                      width: isPlaying ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isPlaying ? letter.color.withValues(alpha: 0.14) : Colors.black.withValues(alpha: 0.04),
                        blurRadius: isPlaying ? 12 : 8,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _playAudio(letterIdx),
                    borderRadius: BorderRadius.circular(36),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Section of Card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _playAudio(letterIdx),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (isPlaying)
                                      SizedBox(
                                        width: 58,
                                        height: 58,
                                        child: CircularProgressIndicator(
                                          value: _audioProgress,
                                          strokeWidth: 3.5,
                                          color: letter.color,
                                          backgroundColor: const Color(0xFFF1F5F9),
                                        ),
                                      ),
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: isPlaying ? letter.color : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                        color: isPlaying ? Colors.white : letter.color,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    letter.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: letter.color,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_langService.translate('pronunciation_label')}: ${letter.phonetic}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Bottom Section: Glyph & Rules
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: letter.rules.map((rule) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              rule.text,
                                              textAlign: TextAlign.right,
                                              textDirection: TextDirection.rtl,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF334155),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: letter.color.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: letter.color.withValues(alpha: 0.2)),
                                            ),
                                            child: Text(
                                              rule.label ?? '•',
                                              style: GoogleFonts.cairo(
                                                color: letter.color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    letter.small,
                                    style: TextStyle(
                                      fontFamily: _getCopticFontFamily(letter.small),
                                      fontFamilyFallback: const ['CopticStandard', 'Antinoou'],
                                      fontSize: 44,
                                      fontWeight: FontWeight.bold,
                                      color: letter.color.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    letter.char,
                                    style: TextStyle(
                                      fontFamily: _getCopticFontFamily(letter.char),
                                      fontFamilyFallback: const ['CopticStandard', 'Antinoou'],
                                      fontSize: 90,
                                      fontWeight: FontWeight.w900,
                                      color: letter.color,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

