import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';
import '../services/language_service.dart';

class SettingsModal extends StatefulWidget {
  /// Which sections to expose. Different pages care about different things.
  final bool showVisibilityToggles; // Coptic / Arabic / Pronunciation
  final bool showImagesToggle;
  final bool showSpeedSection;

  const SettingsModal({
    super.key,
    this.showVisibilityToggles = true,
    this.showImagesToggle = true,
    this.showSpeedSection = true,
  });

  static Future<void> show(
    BuildContext context, {
    bool showVisibilityToggles = true,
    bool showImagesToggle = true,
    bool showSpeedSection = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsModal(
        showVisibilityToggles: showVisibilityToggles,
        showImagesToggle: showImagesToggle,
        showSpeedSection: showSpeedSection,
      ),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final SettingsService _settings = SettingsService();
  final LanguageService _lang = LanguageService();

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  TextStyle _font(double size, FontWeight weight, Color color) {
    return _lang.isArabic
        ? GoogleFonts.cairo(fontSize: size, fontWeight: weight, color: color)
        : GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
  }

  void _showLimit() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _lang.translate('visibility_error'),
          textAlign: _lang.isArabic ? TextAlign.right : TextAlign.left,
          style: _font(13, FontWeight.bold, Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _handleToggle(bool Function(bool) setter, bool newValue) {
    final accepted = setter(newValue);
    if (!accepted) _showLimit();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: _lang.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFAF0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title + close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF64748B),
                  ),
                  Text(
                    _lang.translate('settings_title'),
                    style: _font(20, FontWeight.w900, const Color(0xFF1C1917)),
                  ),
                  const SizedBox(width: 48), // balance the close button
                ],
              ),
              const SizedBox(height: 8),

              if (widget.showSpeedSection) ...[
                _SectionLabel(text: _lang.translate('audio_speed'), font: _font),
                const SizedBox(height: 10),
                _SpeedGrid(
                  speeds: _speeds,
                  currentSpeed: _settings.playbackSpeed,
                  accent: accent,
                  isArabic: _lang.isArabic,
                  naturalLabel: _lang.translate('natural_speed'),
                  onTap: _settings.setPlaybackSpeed,
                  font: _font,
                ),
                const SizedBox(height: 24),
              ],

              if (widget.showVisibilityToggles) ...[
                _ToggleRow(
                  icon: Icons.text_fields_rounded,
                  iconColor: accent,
                  label: _lang.translate('show_coptic_word'),
                  value: _settings.showCoptic,
                  onChanged: (v) => _handleToggle(_settings.setShowCoptic, v),
                  accent: accent,
                  font: _font,
                ),
                const SizedBox(height: 10),
                _ToggleRow(
                  icon: Icons.translate_rounded,
                  iconColor: accent,
                  label: _lang.translate('show_meaning'),
                  value: _settings.showArabic,
                  onChanged: (v) => _handleToggle(_settings.setShowArabic, v),
                  accent: accent,
                  font: _font,
                ),
                const SizedBox(height: 10),
                _ToggleRow(
                  icon: Icons.record_voice_over_rounded,
                  iconColor: accent,
                  label: _lang.translate('show_pronunciation'),
                  value: _settings.showPronunciation,
                  onChanged: (v) => _handleToggle(_settings.setShowPronunciation, v),
                  accent: accent,
                  font: _font,
                ),
              ],
              if (widget.showImagesToggle) ...[
                const SizedBox(height: 10),
                _ToggleRow(
                  icon: Icons.image_rounded,
                  iconColor: accent,
                  label: _lang.translate('show_images'),
                  value: _settings.showImages,
                  onChanged: (v) => _handleToggle(_settings.setShowImages, v),
                  accent: accent,
                  font: _font,
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final TextStyle Function(double, FontWeight, Color) font;
  const _SectionLabel({required this.text, required this.font});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            text,
            style: font(14, FontWeight.w900, const Color(0xFF1C1917)),
          ),
        ],
      ),
    );
  }
}

class _SpeedGrid extends StatelessWidget {
  final List<double> speeds;
  final double currentSpeed;
  final Color accent;
  final bool isArabic;
  final String naturalLabel;
  final ValueChanged<double> onTap;
  final TextStyle Function(double, FontWeight, Color) font;

  const _SpeedGrid({
    required this.speeds,
    required this.currentSpeed,
    required this.accent,
    required this.isArabic,
    required this.naturalLabel,
    required this.onTap,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.0,
      ),
      itemCount: speeds.length,
      itemBuilder: (context, index) {
        final speed = speeds[index];
        final isSelected = (speed - currentSpeed).abs() < 0.01;
        final isNatural = speed == 1.0;
        return GestureDetector(
          onTap: () => onTap(speed),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? accent : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? accent : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${speed}x',
                    style: font(
                      13,
                      FontWeight.w900,
                      isSelected ? Colors.white : const Color(0xFF1C1917),
                    ),
                  ),
                  if (isNatural)
                    Text(
                      naturalLabel,
                      style: font(
                        9,
                        FontWeight.w700,
                        isSelected ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;
  final TextStyle Function(double, FontWeight, Color) font;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.accent,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: font(14, FontWeight.w800, const Color(0xFF1C1917)),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: accent,
          ),
        ],
      ),
    );
  }
}
