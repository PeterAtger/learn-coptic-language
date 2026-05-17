import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/hymn_models.dart';
import '../services/stage_service.dart';
import '../services/bookmark_service.dart';

Map<String, dynamic> _parseHymnsJson(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class HymnsPage extends StatefulWidget {
  const HymnsPage({super.key});

  @override
  State<HymnsPage> createState() => _HymnsPageState();
}

class _HymnsPageState extends State<HymnsPage> {
  final StageService _stageService = StageService();
  final BookmarkService _bookmarkService = BookmarkService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, dynamic> _allHymnsJson = {};
  List<HymnItem> _hymns = [];
  bool _isLoading = true;

  bool _showCoptic = true;
  bool _showArabic = true;
  bool _showPhonetic = true;
  int _activeHymnIndex = 0;
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
    _bookmarkService.addListener(_update);
    _loadData();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) _currentlyPlayingNotifier.value = null;
    });
  }

  @override
  void dispose() {
    _stageService.removeListener(_onStageChanged);
    _bookmarkService.removeListener(_update);
    _audioPlayer.dispose();
    _currentlyPlayingNotifier.dispose();
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  void _onStageChanged() {
    _audioPlayer.stop();
    _currentlyPlayingNotifier.value = null;
    _activeHymnIndex = 0;
    if (_allHymnsJson.isNotEmpty) {
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
      final String jsonString = await tryLoad('assets/data/hymns.json');
      _allHymnsJson = await compute(_parseHymnsJson, jsonString);
      _filterForStage();
    } catch (e) {
      print("Error loading hymns data: $e");
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _filterForStage() {
    final stageId = _stageService.selectedStage.id;
    final List<dynamic> stageHymns = _allHymnsJson[stageId] ?? [];

    if (mounted) {
      setState(() {
      _hymns = stageHymns.map((data) => HymnItem(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        stageId: data['stageId'] ?? '',
        isLegacy: data['isLegacy'] ?? false,
        verses: (data['verses'] as List<dynamic>).map((v) {
          String aud = v['audioPath'] ?? '';
          aud = aud.trim();
          if (aud.startsWith('/')) aud = aud.substring(1);
          if (aud.startsWith('assets/')) aud = aud.replaceFirst('assets/', '');

          return HymnVerse(
            id: v['id'] ?? '',
            coptic: v['coptic'] ?? '',
            arabic: v['arabic'] ?? '',
            phonetic: v['phonetic'] ?? '',
            audioPath: aud.isEmpty ? null : aud,
            isLegacy: v['isLegacy'] ?? false,
          );
        }).toList(),
      )).toList();
      _isLoading = false;
    });
    }
  }

  Future<void> _toggleAudio(HymnVerse verse) async {
    if (verse.audioPath == null || verse.audioPath!.isEmpty) return;
    try {
      String cleanPath = verse.audioPath!.trim();
      if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
      if (cleanPath.startsWith('assets/')) cleanPath = cleanPath.replaceFirst('assets/', '');

      if (_currentlyPlayingNotifier.value == verse.id) {
        await _audioPlayer.pause();
        _currentlyPlayingNotifier.value = null;
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(cleanPath));
        _currentlyPlayingNotifier.value = verse.id;
      }
    } catch (e) {
      print("Audio playing error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    if (_hymns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'لا توجد محفوظات حالياً',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      );
    }

    final currentHymn = _activeHymnIndex < _hymns.length ? _hymns[_activeHymnIndex] : _hymns.first;

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
          // Top Header Info
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
                    Icons.headphones_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المحفوظات القبطية',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1C1917),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'سنة ٢٠٢٦ • ${_stageService.selectedStage.name}',
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

          // Level / Hymn Tabs Selector (If there is more than 1 hymn)
          if (_hymns.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // RTL feel
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _hymns.length,
                  itemBuilder: (context, index) {
                    final isSelected = _activeHymnIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _activeHymnIndex = index),
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
                            _hymns[index].title,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Content of Selected Hymn Verses
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
              cacheExtent: 500, // Pre-loads items to eliminate scroll stutter
              itemCount: currentHymn.verses.length,
              itemBuilder: (context, index) {
                final verse = currentHymn.verses[index];
                final isFav = _bookmarkService.isBookmarked(verse);

                return ValueListenableBuilder<String?>(
                    valueListenable: _currentlyPlayingNotifier,
                    builder: (context, playingId, child) {
                      final isPlaying = playingId == verse.id;

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
                        onTap: () => _toggleAudio(verse),
                        borderRadius: BorderRadius.circular(32),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          // Top Actions Bar (Play / Bookmark)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (verse.audioPath != null)
                                GestureDetector(
                                  onTap: () => _toggleAudio(verse),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isPlaying ? Theme.of(context).colorScheme.primary : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isPlaying ? Theme.of(context).colorScheme.primary : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Icon(
                                      isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                                      color: isPlaying ? Colors.white : Theme.of(context).colorScheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(),
                              GestureDetector(
                                onTap: () => _bookmarkService.toggleBookmark(verse),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isFav ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isFav ? const Color(0xFFFFEDD5) : Colors.white.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  child: Icon(
                                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isFav ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Coptic Text
                          if (_showCoptic)
                            Text(
                              verse.coptic,
                              textAlign: TextAlign.right,
                              textDirection: verse.isLegacy ? TextDirection.ltr : TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: _getCopticFontFamily(verse.coptic),
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1C1917),
                                height: 1.35,
                              ),
                            ),

                          // Phonetics
                          if (_showPhonetic) ...[
                            const SizedBox(height: 6),
                            Text(
                              '[ ${verse.phonetic} ]',
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],

                          // Divider Line
                          if ((_showCoptic || _showPhonetic) && _showArabic) ...[
                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Arabic Text
                          if (_showArabic)
                            Text(
                              verse.arabic,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF334155),
                                height: 1.45,
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
           ),
          ),
        ],
      ),
    );
  }

}
