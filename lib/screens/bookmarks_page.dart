import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hymn_models.dart';
import '../services/bookmark_service.dart';
import '../services/audio_service.dart';
import '../services/language_service.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final BookmarkService _bookmarkService = BookmarkService();
  final AudioService _audioService = AudioService();
  final LanguageService _langService = LanguageService();
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    _bookmarkService.addListener(_update);
    _langService.addListener(_update);
    _audioService.setOnComplete(() {
      if (mounted) setState(() => _currentlyPlayingId = null);
    });
  }

  @override
  void dispose() {
    _audioService.stop();
    _bookmarkService.removeListener(_update);
    _langService.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  String _getCopticFontFamily(String text) {
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if ((code >= 0x2C80 && code <= 0x2CFF) || (code >= 0x03E2 && code <= 0x03EF)) {
        return 'CopticStandard';
      }
    }
    return 'AbraamLegacy';
  }

  Future<void> _toggleAudio(HymnVerse verse) async {
    if (verse.audioPath == null || verse.audioPath!.isEmpty) return;
    try {
      if (_currentlyPlayingId == verse.id) {
        await _audioService.pause();
        setState(() => _currentlyPlayingId = null);
      } else {
        await _audioService.stop();
        // Remove leading slash if it exists
        String path = verse.audioPath!;
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
        await _audioService.playAsset(path);
        setState(() => _currentlyPlayingId = verse.id);
        
        // Re-attach completion listener in case it was overwritten
        _audioService.setOnComplete(() {
          if (mounted) setState(() => _currentlyPlayingId = null);
        });
      }
    } catch (e) {
      debugPrint("Audio playing error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarked = _bookmarkService.bookmarkedVerses;

    return Column(
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
                  Icons.star_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _langService.translate('bookmarks_title'),
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1C1917),
                    ),
                  ),
                  Text(
                    '${_langService.translate('year_2026')} • ${_langService.translate('bookmarks_subtitle')}',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: bookmarked.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
                  itemCount: bookmarked.length,
                  itemBuilder: (context, index) {
                    final verse = bookmarked[index];
                    final isPlaying = _currentlyPlayingId == verse.id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.white : Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: isPlaying ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.55),
                          width: isPlaying ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isPlaying 
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _toggleAudio(verse),
                        borderRadius: BorderRadius.circular(36),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Actions Row
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
                                          color: isPlaying ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.55),
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
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFFFEDD5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFD97706),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Coptic Text
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
                            if (verse.phonetic.isNotEmpty) ...[
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
                            if (verse.arabic.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Arabic Text
                            if (verse.arabic.isNotEmpty)
                              Text(
                                verse.arabic,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF475569),
                                  height: 1.45,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_border_rounded, size: 64, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(
                        _langService.translate('bookmarks_empty'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
