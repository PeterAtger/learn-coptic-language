import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import '../services/stage_service.dart';
import '../services/language_service.dart';

Map<String, dynamic> _parseGrammarJson(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class GrammarSection {
  final String type;
  final String? title;
  final String? content;
  final List<dynamic>? examples;
  final Map<String, dynamic>? table;
  final Map<String, dynamic>? tree;
  final List<dynamic>? gridItems;
  final bool? isLegacy;

  GrammarSection({
    required this.type,
    this.title,
    this.content,
    this.examples,
    this.table,
    this.tree,
    this.gridItems,
    this.isLegacy,
  });
}

class GrammarLesson {
  final String id;
  final String title;
  final List<GrammarSection> sections;

  GrammarLesson({
    required this.id,
    required this.title,
    required this.sections,
  });
}

class PositionedCell {
  final String text;
  final int row;
  final int col;
  final int rowSpan;
  final int colSpan;

  PositionedCell({
    required this.text,
    required this.row,
    required this.col,
    required this.rowSpan,
    required this.colSpan,
  });
}

class GrammarPage extends StatefulWidget {
  const GrammarPage({super.key});

  @override
  State<GrammarPage> createState() => _GrammarPageState();
}

class _GrammarPageState extends State<GrammarPage> {
  final StageService _stageService = StageService();
  final LanguageService _langService = LanguageService();
  final Map<String, dynamic> _allGrammarJson = {};
  List<GrammarLesson> _lessons = [];
  bool _isLoading = true;
  String? _activeLessonId;

  static final RegExp _copticPattern = RegExp(r"[a-zA-Z`\\\[\]:;'\/?\><|~{}\u2C80-\u2CFF\u0370-\u03FF\u03E2-\u03EF\u0300-\u036F]");
  static final RegExp _arabicRegex = RegExp(r'[\u0600-\u06FF]');

  @override
  void initState() {
    super.initState();
    _stageService.addListener(_onStageChanged);
    _langService.addListener(_onLanguageChanged);
    _loadData();
  }

  @override
  void dispose() {
    _stageService.removeListener(_onStageChanged);
    _langService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _loadData();
  }

  void _onStageChanged() {
    _loadData();
  }

  String _getCopticFontFamily(String text) {
    return 'AbraamLegacy';
  }

  Widget _buildTextWithMixedFonts(String text, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = 1.5,
    TextAlign textAlign = TextAlign.right,
    bool isLegacy = false,
  }) {
    if (text.isEmpty) return const SizedBox();

    final List<InlineSpan> spans = [];
    final RegExp tagRegex = RegExp(r'\[c\](.*?)\[/c\]', dotAll: true);
    int lastMatchEnd = 0;
    
    // Logic to add spans for Coptic text (handling mixed Unicode/Legacy)
    void addCopticSpans(String subtext) {
      if (subtext.isEmpty) return;

      String current = '';
      bool? currentIsUnicode; // true for Unicode, false for Legacy

      for (int i = 0; i < subtext.length; i++) {
        final char = subtext[i];
        final bool isUnicode = RegExp(r'[\u2C80-\u2CFF\u0370-\u03FF\u03E2-\u03EF\u0300-\u036F]').hasMatch(char);
        
        if (currentIsUnicode == null) {
          current = char;
          currentIsUnicode = isUnicode;
        } else if (currentIsUnicode == isUnicode) {
          current += char;
        } else {
          // Flush
          String processedText = current;
          processedText = '\u202A$processedText\u202C';
          spans.add(TextSpan(
            text: processedText,
            style: TextStyle(
              fontFamily: 'AbraamLegacy',
              fontFamilyFallback: const ['AbraamLegacy', 'Antinoou', 'CopticStandard'],
              fontSize: fontSize >= 16 ? fontSize + 2 : 17,
              fontWeight: fontWeight,
              color: color,
              height: height,
            ),
          ));
          current = char;
          currentIsUnicode = isUnicode;
        }
      }

      if (current.isNotEmpty) {
        String processedText = current;
        processedText = '\u202A$processedText\u202C';
        spans.add(TextSpan(
          text: processedText,
          style: TextStyle(
            fontFamily: 'AbraamLegacy',
            fontFamilyFallback: const ['AbraamLegacy', 'Antinoou', 'CopticStandard'],
            fontSize: fontSize >= 16 ? fontSize + 2 : 17,
            fontWeight: fontWeight,
            color: color,
            height: height,
          ),
        ));
      }
    }

    // Auto-detection logic for text outside [c] tags
    void addAutoDetectedSpans(String subtext) {
      if (subtext.isEmpty) return;

      bool isCopticChar(String char) {
        if (RegExp(r'[\u2C80-\u2CFF\u0370-\u03FF\u03E2-\u03EF\u0300-\u036F]').hasMatch(char)) return true;
        return RegExp(r"[a-zA-Z`\\\[\]:;'\/?\><|~{}]").hasMatch(char);
      }

      bool hasCopticMatch = false;
      bool hasArabicMatch = false;
      for (int i = 0; i < subtext.length; i++) {
        if (isCopticChar(subtext[i])) hasCopticMatch = true;
        if (_arabicRegex.hasMatch(subtext[i])) hasArabicMatch = true;
      }

      // If purely standard text (no Coptic/Arabic)
      if (!hasCopticMatch && !hasArabicMatch) {
        spans.add(TextSpan(
          text: subtext,
          style: GoogleFonts.cairo(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            height: height,
          ),
        ));
        return;
      }

      // If purely Coptic
      if (!hasArabicMatch && hasCopticMatch) {
        addCopticSpans(subtext);
        return;
      }

      String current = '';
      bool currentIsCoptic = false;

      for (int i = 0; i < subtext.length; i++) {
        final char = subtext[i];
        final bool isArabicChar = _arabicRegex.hasMatch(char);
        final bool isCopticLetter = isCopticChar(char);
        final bool isNeutral = !isArabicChar && !isCopticLetter;

        if (current.isEmpty) {
          current = char;
          if (isNeutral) {
            bool foundStrong = false;
            for (int j = i + 1; j < subtext.length; j++) {
              if (_arabicRegex.hasMatch(subtext[j])) {
                currentIsCoptic = false;
                foundStrong = true;
                break;
              }
              if (isCopticChar(subtext[j])) {
                currentIsCoptic = true;
                foundStrong = true;
                break;
              }
            }
            if (!foundStrong) currentIsCoptic = isLegacy;
          } else {
            currentIsCoptic = isCopticLetter;
          }
        } else {
          bool shouldContinue;
          if (isNeutral) {
            shouldContinue = true;
          } else if (isArabicChar) {
            shouldContinue = !currentIsCoptic;
          } else {
            shouldContinue = currentIsCoptic;
          }
          
          if (shouldContinue) {
            current += char;
          } else {
            if (currentIsCoptic) {
              addCopticSpans(current);
            } else {
              spans.add(TextSpan(
                text: current,
                style: GoogleFonts.cairo(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: color,
                  height: height,
                ),
              ));
            }
            current = char;
            currentIsCoptic = isCopticLetter;
          }
        }
      }

      if (current.isNotEmpty) {
        if (currentIsCoptic) {
          addCopticSpans(current);
        } else {
          spans.add(TextSpan(
            text: current,
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              height: height,
            ),
          ));
        }
      }
    }

    // Process explicit [c] tags
    for (final match in tagRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        addAutoDetectedSpans(text.substring(lastMatchEnd, match.start));
      }
      
      String copticText = match.group(1) ?? '';
      // Force everything inside [c] to use Coptic logic
      addCopticSpans(copticText);
      
      lastMatchEnd = match.end;
    }

    // Process remaining text
    if (lastMatchEnd < text.length) {
      addAutoDetectedSpans(text.substring(lastMatchEnd));
    }

    return RichText(
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(children: spans),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final stageId = _stageService.selectedStage.id;
    
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
      // 1. Try to load stage-specific file: grammar_stageId.json
      final String jsonPath = 'assets/data/grammar_$stageId.json';
      final String jsonString = await tryLoad(jsonPath);
      final dynamic decoded = jsonDecode(jsonString);
      
      List<dynamic> stageLessons;
      if (decoded is List) {
        stageLessons = decoded;
      } else if (decoded is Map) {
        stageLessons = decoded[stageId] ?? [];
      } else {
        stageLessons = [];
      }
      
      _applyLessons(stageLessons);
    } catch (e) {
      // 2. Fallback to old grammar.json
      try {
        final String jsonString = await tryLoad(_langService.getDataPath('grammar'));
        final Map<String, dynamic> allJson = jsonDecode(jsonString);
        _applyLessons(allJson[stageId] ?? []);
      } catch (e2) {
        print("Error loading fallback grammar data: $e2");
        _applyLessons([]);
      }
    }
  }

  void _applyLessons(List<dynamic> stageLessons) {
    if (!mounted) return;
    
    setState(() {
      _lessons = stageLessons.map((data) => GrammarLesson(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        sections: (data['sections'] as List<dynamic>? ?? []).map((s) => GrammarSection(
          type: s['type'] ?? 'text',
          title: s['title'],
          content: s['content'],
          examples: s['examples'],
          table: s['table'],
          tree: s['tree'],
          gridItems: s['gridItems'],
          isLegacy: s['isLegacy'],
        )).toList(),
      )).toList();

      if (_lessons.isNotEmpty) {
        _activeLessonId = _lessons[0].id;
      } else {
        _activeLessonId = null;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    if (_lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              ),
              child: const Icon(Icons.auto_stories_rounded, size: 64, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            Text(
              _langService.translate('no_grammar_found'),
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),
      );
    }

    final activeLesson = _lessons.firstWhere(
      (l) => l.id == _activeLessonId,
      orElse: () => _lessons[0],
    );

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
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
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
                    Icons.bookmarks_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _langService.translate('coptic_grammar'),
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1C1917),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_langService.translate('year_2026')} • ${_langService.translate(_stageService.selectedStage.id)}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Level Navigation (Pill Selector)
          if (_lessons.length > 1)
            Container(
              height: 46,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: _langService.isArabic, // RTL feel when Arabic
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  final l = _lessons[index];
                  final isSelected = _activeLessonId == l.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _activeLessonId = l.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFFE2E8F0),
                            width: 1.5,
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
                            l.title,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Grammar Lessons Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 120),
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Lesson Title Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              activeLesson.title,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1C1917),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.bookmark_added_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 3,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...activeLesson.sections.map((sec) => _buildSectionWidget(sec)).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionWidget(GrammarSection sec) {
    switch (sec.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(top: 14.0, bottom: 6),
          child: _buildTextWithMixedFonts(
            sec.content ?? '',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF334155),
            height: 1.6,
          ),
        );

      case 'note':
        final String title = sec.title ?? '';
        final String content = sec.content ?? '';
        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title.isNotEmpty) ...[
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.stars_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextWithMixedFonts(
                        title,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                        isLegacy: sec.isLegacy ?? false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              _buildTextWithMixedFonts(
                content,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C1917),
                height: 1.7,
                isLegacy: sec.isLegacy ?? false,
              ),
            ],
          ),
        );

      case 'example':
        final examplesList = sec.examples ?? [];
        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sec.title != null && sec.title!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        sec.title!,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.label_important_rounded, color: Theme.of(context).colorScheme.primary, size: 16),
                    ],
                  ),
                ),
              ...examplesList.map((ex) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ex['coptic'] ?? '',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: _getCopticFontFamily(ex['coptic'] ?? ''),
                        fontFamilyFallback: const ['AbraamLegacy', 'Antinoou', 'CopticStandard'],
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ex['arabic'] ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (ex['phonetic'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '[ ${ex['phonetic']} ]',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              )).toList(),
            ],
          ),
        );

      case 'table':
        final tableData = sec.table;
        if (tableData == null) return const SizedBox();
        final headersList = tableData['headers'] as List<dynamic>? ?? [];
        final rowsList = tableData['rows'] as List<dynamic>? ?? [];

        int totalRows = rowsList.length;
        int maxCells = 0;
        for (final row in rowsList) {
          if (row is List && row.length > maxCells) {
            maxCells = row.length;
          }
        }

        if (maxCells == 0) return const SizedBox();

        final List<dynamic> computedHeaders = headersList.isNotEmpty
            ? headersList
            : List<String>.filled(maxCells, '');

        final int numCols = computedHeaders.length;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double availWidth = (screenWidth - 80).clamp(100.0, 800.0);
        final double colWidth = (availWidth / numCols).clamp(95.0, 400.0);

        // Compute dynamic height for each row based on text character length
        List<double> rowHeights = List.filled(totalRows, 85.0); // Minimum row height is 85.0

        for (int r = 0; r < totalRows; r++) {
          final cellsList = rowsList[r] as List<dynamic>? ?? [];
          for (final cell in cellsList) {
            String cellText = '';
            int rSpan = 1;
            int cSpan = 1;
            if (cell is Map) {
              cellText = (cell['value'] ?? '').toString();
              rSpan = cell['rowSpan'] is int ? cell['rowSpan'] : 1;
              cSpan = cell['colSpan'] is int ? cell['colSpan'] : 1;
            } else {
              cellText = cell.toString();
            }

            final int textLength = cellText.length;
            final double cellWidth = cSpan * colWidth;
            
            final double charsPerLine = (cellWidth / 6.2).clamp(1.0, 150.0);
            final int lines = (textLength / charsPerLine).ceil().clamp(1, 15);
            
            final double estimatedHeight = (lines * 26.0) + 40.0;
            final double heightPerOccupiedRow = estimatedHeight / rSpan;

            for (int dr = 0; dr < rSpan; dr++) {
              if (r + dr < totalRows) {
                if (heightPerOccupiedRow > rowHeights[r + dr]) {
                  rowHeights[r + dr] = heightPerOccupiedRow;
                }
              }
            }
          }
        }

        double getRowTop(int targetRow) {
          double sum = 0;
          for (int i = 0; i < targetRow; i++) {
            sum += rowHeights[i];
          }
          return sum;
        }

        double getCellHeight(int startRow, int rSpan) {
          double sum = 0;
          for (int i = 0; i < rSpan; i++) {
            if (startRow + i < totalRows) {
              sum += rowHeights[startRow + i];
            }
          }
          return sum;
        }

        // Build matrix of cell positions taking rowSpan & colSpan into account
        List<List<bool>> occupied = List.generate(totalRows, (_) => List.filled(numCols, false));
        List<PositionedCell> positionedCells = [];

        for (int r = 0; r < totalRows; r++) {
          final cellsList = rowsList[r] as List<dynamic>? ?? [];
          int cellIdx = 0;
          for (int c = 0; c < numCols; c++) {
            if (occupied[r][c]) continue;

            if (cellIdx < cellsList.length) {
              final cell = cellsList[cellIdx++];
              String cellText = '';
              int rSpan = 1;
              int cSpan = 1;

              if (cell is Map) {
                cellText = (cell['value'] ?? '').toString();
                rSpan = cell['rowSpan'] is int ? cell['rowSpan'] : 1;
                cSpan = cell['colSpan'] is int ? cell['colSpan'] : 1;
              } else {
                cellText = cell.toString();
              }

              for (int dr = 0; dr < rSpan; dr++) {
                for (int dc = 0; dc < cSpan; dc++) {
                  if (r + dr < totalRows && c + dc < numCols) {
                    occupied[r + dr][c + dc] = true;
                  }
                }
              }

              positionedCells.add(PositionedCell(
                text: cellText,
                row: r,
                col: c,
                rowSpan: rSpan,
                colSpan: cSpan,
              ));
            }
          }
        }

        const double headerHeight = 48.0;
        double totalRowsHeight = 0;
        for (double h in rowHeights) {
          totalRowsHeight += h;
        }
        final double totalTableHeight = headerHeight + totalRowsHeight;

        String joinedHeader = computedHeaders
            .where((h) => h.toString().trim().isNotEmpty)
            .join('  •  ');
        if (joinedHeader.isEmpty) joinedHeader = 'جدول توضيحي';

        return Container(
          margin: const EdgeInsets.only(top: 18, bottom: 8),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: _langService.isArabic, // RTL feel when Arabic
              child: SizedBox(
              width: colWidth * numCols,
              height: totalTableHeight,
              child: Stack(
                children: [
                  // Combined single column header
                  Positioned(
                    top: 0,
                    right: 0, // Align header to the right
                    width: colWidth * numCols,
                    height: headerHeight,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
                      ),
                      child: _buildTextWithMixedFonts(
                        joinedHeader,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        textAlign: TextAlign.center,
                        isLegacy: sec.isLegacy ?? false,
                      ),
                    ),
                  ),

                  // Draw body cells taking colSpan/rowSpan into account
                  ...positionedCells.map((cell) {
                    final double cellTop = headerHeight + getRowTop(cell.row);
                    final double cellHeight = getCellHeight(cell.row, cell.rowSpan);
                    final double cellLeft = (numCols - cell.col - cell.colSpan) * colWidth;
                    return Positioned(
                      top: cellTop,
                      left: cellLeft,
                      width: cell.colSpan * colWidth,
                      height: cellHeight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: (() {
                          final bool isSentence = cell.text.trim().contains(' ');
                          final Widget textWidget = _buildTextWithMixedFonts(
                            cell.text,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            fontSize: 11,
                            textAlign: TextAlign.center,
                            height: 1.35,
                            isLegacy: sec.isLegacy ?? false,
                          );
                          
                          if (isSentence) {
                            return textWidget;
                          } else {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: textWidget,
                            );
                          }
                        })(),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      );

      case 'grid':
        final gridList = sec.gridItems ?? [];
        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: gridList.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTextWithMixedFonts(
                    item['title'] ?? '',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 4),
                  _buildTextWithMixedFonts(
                    item['value'] ?? '',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    textAlign: TextAlign.center,
                    isLegacy: sec.isLegacy ?? false,
                  ),
                ],
              ),
            )).toList(),
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
