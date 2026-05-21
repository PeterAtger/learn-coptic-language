import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import '../services/stage_service.dart';
import '../services/language_service.dart';
import '../services/audio_service.dart';

Map<String, dynamic> _parseWordsJson(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class WordData {
  final String id;
  final String letter;
  final String coptic;
  final String pronunciation;
  final String meaning;
  final String? imagePath;
  final String? audioPath;
  final String? gender;
  final String color;

  WordData({
    required this.id,
    required this.letter,
    required this.coptic,
    required this.pronunciation,
    required this.meaning,
    this.imagePath,
    this.audioPath,
    this.gender,
    this.color = '#000000',
  });
}

class WordsPage extends StatefulWidget {
  const WordsPage({super.key});

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  final StageService _stageService = StageService();
  final LanguageService _langService = LanguageService();
  final AudioService _audioService = AudioService();
  Map<String, dynamic> _allWordsJson = {};
  List<WordData> _words = [];
  bool _isLoading = true;
  String _selectedLetter = "all";
  final String _searchQuery = "";
  bool _showCoptic = true;
  bool _showArabic = true;
  bool _showPronunciation = true;
  final ValueNotifier<String?> _currentlyPlayingNotifier = ValueNotifier<String?>(null);

  String _getCopticFontFamily(String text) {
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if ((code >= 0x2C80 && code <= 0x2CFF) || (code >= 0x03E2 && code <= 0x03EF)) {
        return 'CopticStandard';
      }
    }
    return 'AbraamLegacy';
  }

  @override
  void initState() {
    super.initState();
    _stageService.addListener(_onStageChanged);
    _langService.addListener(_onLanguageChanged);
    _loadData();
    _audioService.setOnComplete(() {
      if (mounted) _currentlyPlayingNotifier.value = null;
    });
  }

  @override
  void dispose() {
    _audioService.stop();
    _stageService.removeListener(_onStageChanged);
    _langService.removeListener(_onLanguageChanged);
    _currentlyPlayingNotifier.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    _loadData();
  }

  void _onStageChanged() {
    if (_allWordsJson.isNotEmpty) {
      _filterForStage();
    }
  }

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
      final String jsonPath = _langService.getDataPath('words');
      final String jsonString = await tryLoad(jsonPath);
      _allWordsJson = await compute(_parseWordsJson, jsonString);
      _filterForStage();
    } catch (e) {
      print("Error loading words: $e");
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _filterForStage() {
    final stageId = _stageService.selectedStage.id;
    final List<dynamic> stageWords = _allWordsJson[stageId] ?? [];

    if (mounted) {
      setState(() {
        _words = stageWords.map<WordData>((data) {
          String img = data['imagePath'] ?? '';
          if (img.startsWith('/')) img = img.substring(1);

          String aud = data['audioPath'] ?? '';
          aud = aud.trim();
          if (aud.startsWith('/')) aud = aud.substring(1);
          if (aud.startsWith('assets/')) aud = aud.replaceFirst('assets/', '');
          
          return WordData(
            id: data['id'] ?? '',
            letter: data['letter'] ?? '',
            coptic: data['coptic'] ?? '',
            pronunciation: data['pronunciation'] ?? '',
            meaning: data['meaning'] ?? '',
            imagePath: img.isEmpty ? null : img,
            audioPath: aud.isEmpty ? null : aud,
            color: data['color'] ?? '#000000',
            gender: data['gender'],
          );
        }).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAudio(WordData word) async {
    if (word.audioPath == null || word.audioPath!.isEmpty) return;
    try {
      if (_currentlyPlayingNotifier.value == word.id) {
        await _audioService.stop();
        _currentlyPlayingNotifier.value = null;
      } else {
        await _audioService.playAsset(word.audioPath!);
        _currentlyPlayingNotifier.value = word.id;
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

    // Horizontal category list (alphabet unique letters for current stage + all)
    final List<String> alphabet = ["all", ..._words.map((w) => w.letter).toSet().toList()];

    // Filtered words
    final filteredWords = _words.where((word) {
      final matchesLetter = _selectedLetter == "all" || word.letter == _selectedLetter;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          word.coptic.toLowerCase().contains(query) ||
          word.meaning.toLowerCase().contains(query) ||
          word.pronunciation.toLowerCase().contains(query);
      return matchesLetter && matchesSearch;
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
          // Top Header
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _langService.translate('coptic_words'),
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

          // Alphabet Horizontal Selector Scrollable List
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: _langService.isArabic, // RTL feel when Arabic
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: alphabet.length,
                itemBuilder: (context, idx) {
                  final letter = alphabet[idx];
                  final isSelected = _selectedLetter == letter;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedLetter = letter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.55),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          letter == "all" ? _langService.translate('all_filter') : letter,
                          style: isSelected
                              ? GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                )
                              : (letter == "all"
                                  ? GoogleFonts.cairo(
                                      color: const Color(0xFF475569),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    )
                                  : TextStyle(
                                      fontFamily: _getCopticFontFamily(letter),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF475569),
                                    )),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Dynamic Words Listing
          Expanded(
            child: filteredWords.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
                    cacheExtent: 500, // Increased cache extent for smoother scrolling
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      final word = filteredWords[index];

                      return ValueListenableBuilder<String?>(
                          valueListenable: _currentlyPlayingNotifier,
                          builder: (context, playingId, child) {
                            final isPlaying = playingId == word.id;

                            return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isPlaying ? Colors.white : const Color(0xFFFDFBF7),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: isPlaying ? Theme.of(context).colorScheme.primary : const Color(0xFFE2E8F0),
                                width: isPlaying ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isPlaying 
                                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _toggleAudio(word),
                              borderRadius: BorderRadius.circular(32),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Row(
                                  children: [
                                // Play Button
                                if (word.audioPath != null)
                                  GestureDetector(
                                    onTap: () => _toggleAudio(word),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isPlaying ? Theme.of(context).colorScheme.primary : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isPlaying ? Theme.of(context).colorScheme.primary : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Icon(
                                        isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                        color: isPlaying ? Colors.white : Theme.of(context).colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 48),

                                const SizedBox(width: 14),

                                // Image or Alphabet initial
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: word.imagePath != null
                                        ? Image.asset(
                                            word.imagePath!,
                                            fit: BoxFit.contain,
                                            cacheWidth: 160,
                                            cacheHeight: 160,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  word.letter,
                                                  style: TextStyle(
                                                    fontFamily: _getCopticFontFamily(word.letter),
                                                    fontSize: 34,
                                                    fontWeight: FontWeight.w900,
                                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            child: Text(
                                              word.letter,
                                              style: TextStyle(
                                                fontFamily: _getCopticFontFamily(word.letter),
                                                fontSize: 34,
                                                fontWeight: FontWeight.w900,
                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Info Column (RTL text)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (_showCoptic)
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            word.coptic,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: _getCopticFontFamily(word.coptic),
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF1C1917),
                                            ),
                                          ),
                                        ),
                                      if (_showCoptic && (_showPronunciation || _showArabic))
                                        const SizedBox(height: 2),
                                      if (_showPronunciation)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '(${word.pronunciation})',
                                                textAlign: TextAlign.end,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFD97706),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (_showPronunciation && _showArabic)
                                        const SizedBox(height: 4),
                                      if (_showArabic)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if (word.gender != null)
                                              Container(
                                                margin: const EdgeInsets.only(right: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getGenderColor(word.gender).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: _getGenderColor(word.gender).withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: Text(
                                                  word.gender!,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getGenderColor(word.gender),
                                                  ),
                                                ),
                                              ),
                                            Flexible(
                                              child: Text(
                                                word.meaning,
                                                textAlign: TextAlign.end,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: const Color(0xFF334155),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        );
                       },
                      );
                    },
                   )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          _langService.translate('no_words_found'),
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getGenderColor(String? gender) {
    switch (gender) {
      case 'مذكر':
      case 'Masculine':
        return const Color(0xFF2563EB); // Blue
      case 'مؤنث':
      case 'Feminine':
        return const Color(0xFFDB2777); // Pink
      case 'فعل':
      case 'Verb':
        return const Color(0xFF059669); // Green
      case 'اسم علم':
      case 'Proper Name':
      case 'Name':
        return const Color(0xFF7C3AED); // Purple
      case 'عدد':
      case 'Number':
        return const Color(0xFFD97706); // Amber
      default:
        return const Color(0xFF475569); // Slate
    }
  }

}
