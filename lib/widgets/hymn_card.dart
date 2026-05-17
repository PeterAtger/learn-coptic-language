import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/hymn_models.dart';
import '../services/bookmark_service.dart';

class HymnCard extends StatefulWidget {
  final HymnVerse verse;
  final bool showCoptic;
  final bool showArabic;
  final bool showPhonetic;
  final bool isPlaying;
  final VoidCallback? onPlay;

  const HymnCard({
    super.key,
    required this.verse,
    this.showCoptic = true,
    this.showArabic = true,
    this.showPhonetic = true,
    this.isPlaying = false,
    this.onPlay,
  });

  @override
  State<HymnCard> createState() => _HymnCardState();
}

class _HymnCardState extends State<HymnCard> {
  final BookmarkService _bookmarkService = BookmarkService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _localIsPlaying = false;

  @override
  void initState() {
    super.initState();
    _bookmarkService.addListener(_update);
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_update);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleAudio() async {
    if (widget.verse.audioPath == null || widget.verse.audioPath!.isEmpty) return;
    try {
      if (_localIsPlaying) {
        await _audioPlayer.pause();
        setState(() => _localIsPlaying = false);
      } else {
        // Remove leading slash if it exists
        String path = widget.verse.audioPath!;
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
        await _audioPlayer.play(AssetSource(path));
        setState(() => _localIsPlaying = true);
        
        _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) setState(() => _localIsPlaying = false);
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _bookmarkService.isBookmarked(widget.verse);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC).withValues(alpha: 0.95),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.verse.audioPath != null)
                      GestureDetector(
                        onTap: _toggleAudio,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9a1515).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _localIsPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: const Color(0xFF9a1515),
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                    IconButton(
                      onPressed: () => _bookmarkService.toggleBookmark(widget.verse),
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isFav ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.showCoptic) ...[
                  Text(
                    widget.verse.coptic,
                    textAlign: TextAlign.right,
                    textDirection: widget.verse.isLegacy ? TextDirection.ltr : TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: widget.verse.isLegacy ? 'AbraamLegacy' : null,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (widget.showPhonetic) ...[
                  Text(
                    '[${widget.verse.phonetic}]',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFd97706),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if ((widget.showCoptic || widget.showPhonetic) && widget.showArabic)
                  Divider(color: Colors.grey.withValues(alpha: 0.3), thickness: 1),
                if (widget.showArabic) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.verse.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ],
            ),
        ),
      ),
    );
  }
}
