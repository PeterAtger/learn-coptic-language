import 'package:flutter/material.dart';
import 'audio_service.dart';

/// App-wide UI/audio preferences (playback speed + per-card visibility toggles).
/// Singleton; widgets `addListener` to rebuild on change.
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  double _playbackSpeed = 1.0;
  bool _showCoptic = true;
  bool _showArabic = true;
  bool _showPronunciation = true;
  bool _showImages = true;

  double get playbackSpeed => _playbackSpeed;
  bool get showCoptic => _showCoptic;
  bool get showArabic => _showArabic;
  bool get showPronunciation => _showPronunciation;
  bool get showImages => _showImages;

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    AudioService().setSpeed(speed);
    notifyListeners();
  }

  /// At least one of the four visibility toggles must stay on. Returns true
  /// if the change was accepted, false if it was blocked.
  bool _wouldLeaveAtLeastOneOn({bool? coptic, bool? arabic, bool? pronunciation, bool? images}) {
    return (coptic ?? _showCoptic) ||
        (arabic ?? _showArabic) ||
        (pronunciation ?? _showPronunciation) ||
        (images ?? _showImages);
  }

  bool setShowCoptic(bool value) {
    if (_showCoptic == value) return true;
    if (!_wouldLeaveAtLeastOneOn(coptic: value)) {
      notifyListeners(); // re-snap Switch back to true
      return false;
    }
    _showCoptic = value;
    notifyListeners();
    return true;
  }

  bool setShowArabic(bool value) {
    if (_showArabic == value) return true;
    if (!_wouldLeaveAtLeastOneOn(arabic: value)) {
      notifyListeners();
      return false;
    }
    _showArabic = value;
    notifyListeners();
    return true;
  }

  bool setShowPronunciation(bool value) {
    if (_showPronunciation == value) return true;
    if (!_wouldLeaveAtLeastOneOn(pronunciation: value)) {
      notifyListeners();
      return false;
    }
    _showPronunciation = value;
    notifyListeners();
    return true;
  }

  bool setShowImages(bool value) {
    if (_showImages == value) return true;
    if (!_wouldLeaveAtLeastOneOn(images: value)) {
      notifyListeners();
      return false;
    }
    _showImages = value;
    notifyListeners();
    return true;
  }
}
