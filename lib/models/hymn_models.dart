class HymnVerse {
  final String id;
  final String coptic;
  final String arabic;
  final String phonetic;
  final String? audioPath;
  final bool isLegacy;

  const HymnVerse({
    required this.id,
    required this.coptic,
    required this.arabic,
    required this.phonetic,
    this.audioPath,
    this.isLegacy = false,
  });
}

class HymnItem {
  final String id;
  final String title;
  final String stageId;
  final List<HymnVerse> verses;
  final bool isLegacy;

  const HymnItem({
    required this.id,
    required this.title,
    required this.stageId,
    required this.verses,
    this.isLegacy = false,
  });
}
