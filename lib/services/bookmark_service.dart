import 'package:flutter/material.dart';
import '../models/hymn_models.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();

  factory BookmarkService() => _instance;

  BookmarkService._internal();

  final List<HymnVerse> _bookmarkedVerses = [];

  List<HymnVerse> get bookmarkedVerses => _bookmarkedVerses;

  bool isBookmarked(HymnVerse verse) {
    return _bookmarkedVerses.any((v) => v.id == verse.id);
  }

  void toggleBookmark(HymnVerse verse) {
    if (isBookmarked(verse)) {
      _bookmarkedVerses.removeWhere((v) => v.id == verse.id);
    } else {
      _bookmarkedVerses.add(verse);
    }
    notifyListeners();
  }
}
