import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/stage_service.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateTo;

  const HomePage({super.key, required this.onNavigateTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StageService _stageService = StageService();


  @override
  void initState() {
    super.initState();
    _stageService.addListener(_updateState);
  }

  @override
  void dispose() {
    _stageService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/2$phone");
    try {
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallbackUrl = Uri.parse("whatsapp://send?phone=2$phone");
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        final fallbackUrl = Uri.parse("whatsapp://send?phone=2$phone");
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } catch (__) {
        // Fallback or debug print if needed
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrl(params, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(params);
      } catch (__) {
        // Fallback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(), // Spacer
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showContactDialog(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                      ),
                      child: const Icon(Icons.phone_rounded, color: Color(0xFF64748B), size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showInfoDialog(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 22),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // Logo without white background or shadows
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  width: 210,
                  child: Image.asset(
                    'assets/images/logo.webp',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.auto_awesome_rounded, size: 72, color: Theme.of(context).colorScheme.primary);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'منهج القبطي - مهرجان الكرازة المرقسية',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1c1917),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'سنة ٢٠٢٦',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),



          // Premium Grid with slim aspect ratio for mobile compactness
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemCount: _stageService.stages.length,
            itemBuilder: (context, index) {
              final stage = _stageService.stages[index];
              final isSelected = _stageService.selectedStage.id == stage.id;
              final accent = stage.accent;
              final bg = stage.color;

              return GestureDetector(
                onTap: () {
                  _stageService.setSelectedStage(stage);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent
                        : bg.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.white.withValues(alpha: 0.5) : accent.withValues(alpha: 0.3),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                          ? accent.withValues(alpha: 0.4)
                          : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (isSelected)
                        const Positioned(
                          top: 0,
                          left: 0,
                          child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          stage.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : const Color(0xFF1C1917),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: Colors.white.withValues(alpha: 0.85),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            title: Text(
              'عن التطبيق',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
            ),
            content: Text(
              'هذا التطبيق تم بكل حب ومودة من أجلكم\nبواسطة خدام كنيسة الشهيد العظيم أبي سيفين والشهيدة دميانة بشبرا\n\nمهرجان الكرازة ٢٠٢٦',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, height: 1.5, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إغلاق', style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900)),
              )
            ],
          ),
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AlertDialog(
            backgroundColor: Colors.white.withValues(alpha: 0.92),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: const BorderSide(color: Colors.white, width: 1.5),
            ),
            title: Text(
              'للتواصل معنا',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: const Color(0xFF1C1917),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModernContactCard(
                    name: 'م. مينا چوزيف',
                    phone: '01098734124',
                  ),
                  const SizedBox(height: 12),
                  _buildModernContactCard(
                    name: 'م. فيلوباتير چوزيف',
                    phone: '01210826678',
                  ),
                  const SizedBox(height: 12),
                  _buildModernEmailCard(
                    email: 'philopater41@gmail.com',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'إغلاق',
                  style: GoogleFonts.cairo(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernContactCard({
    required String name,
    required String phone,
  }) {
    return InkWell(
      onTap: () => _launchWhatsApp(phone),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Color(0xFF25D366),
                size: 20,
              ),
            ),
            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: const Color(0xFF1C1917),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEmailCard({
    required String email,
  }) {
    return InkWell(
      onTap: () => _launchEmail(email),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mail_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            Expanded(
              child: Text(
                email,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

