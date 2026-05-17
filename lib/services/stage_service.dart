import 'package:flutter/material.dart';

class Stage {
  final String id;
  final String name;
  final String subtext;
  final Color color;
  final Color accent;

  const Stage({
    required this.id,
    required this.name,
    this.subtext = '',
    required this.color,
    required this.accent,
  });
}

class StageService extends ChangeNotifier {
  static final StageService _instance = StageService._internal();

  factory StageService() => _instance;

  StageService._internal();

  // Colors match the per-stage palette shown on the home screen cards so
  // theme chrome (nav, badges, dialogs, etc.) is the exact same shade as the
  // stage button the user tapped.
  final List<Stage> stages = const [
    Stage(id: "nursery",            name: "حضانة",       color: Color(0xFFFEF2F2), accent: Color(0xFFEF4444)),
    Stage(id: "primary12",          name: "أولى وتانية",  color: Color(0xFFFFFBEB), accent: Color(0xFFF59E0B)),
    Stage(id: "primary34",          name: "تالتة ورابعة", color: Color(0xFFECFDF5), accent: Color(0xFF10B981)),
    Stage(id: "primary56",          name: "خامسة وسادسة", color: Color(0xFFECFEFF), accent: Color(0xFF06B6D4)),
    Stage(id: "prep",               name: "إعدادي",      color: Color(0xFFFDF2F8), accent: Color(0xFFEC4899)),
    Stage(id: "sec",                name: "ثانوي",       color: Color(0xFFEEF2FF), accent: Color(0xFF6366F1)),
    Stage(id: "qana",               name: "قانا الجليل",  color: Color(0xFFF0FDFA), accent: Color(0xFF14B8A6)),
    Stage(id: "uni",                name: "جامعة",       color: Color(0xFFF5F3FF), accent: Color(0xFF8B5CF6)),
    Stage(id: "graduates",          name: "خريجين",      color: Color(0xFFEFF6FF), accent: Color(0xFF3B82F6)),
    Stage(id: "servants",           name: "خدام",        color: Color(0xFFFAF5FF), accent: Color(0xFFA855F7)),
    Stage(id: "servants_trainees",  name: "إعداد خدام",   color: Color(0xFFF7FEE7), accent: Color(0xFF84CC16)),
  ];

  late Stage _selectedStage = stages[0];

  Stage get selectedStage => _selectedStage;

  void setSelectedStage(Stage stage) {
    _selectedStage = stage;
    notifyListeners();
  }
}
