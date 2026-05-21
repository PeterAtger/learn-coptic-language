import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// A singleton service to manage audio playback across the entire app.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  double _speed = 1.0;
  void Function()? _onCompleteCallback;

  AudioService._internal() {
    _player.onPlayerComplete.listen((_) {
      _onCompleteCallback?.call();
    });
  }

  AudioPlayer get player => _player;

  /// audioplayers position stream — drop-in for just_audio's positionStream.
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  /// audioplayers gives duration async, not as a sync getter.
  Future<Duration?> getDuration() => _player.getDuration();

  void setOnComplete(void Function() callback) {
    _onCompleteCallback = callback;
  }

  /// Play an asset. Accepts paths with or without leading `/` or `assets/`.
  Future<void> playAsset(String path) async {
    String cleanPath = path.trim();
    if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    if (cleanPath.startsWith('assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/', '');
    }

    try {
      await _player.stop();
      await _player.setPlaybackRate(_speed);
      await _player.play(AssetSource(cleanPath));
    } catch (e) {
      final errorStr = e.toString();
      // Rapid taps can race; ignore those benign errors.
      if (errorStr.contains('interrupted') || errorStr.contains('aborted')) {
        return;
      }
      debugPrint("AudioService Error playing $cleanPath: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint("AudioService stop Error: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint("AudioService pause Error: $e");
    }
  }

  double get playbackSpeed => _speed;

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    try {
      await _player.setPlaybackRate(speed);
    } catch (e) {
      debugPrint("AudioService setSpeed Error: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
