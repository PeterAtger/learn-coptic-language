import 'dart:convert';

import 'package:ebty/presentation/blocs/year/year_state.dart';
import 'package:flutter/services.dart';

enum RulesKeys { rule, examples, shouldScale }

enum RuleTypes { level, rule, example }

Map<Years, String> rulesFiles = {
  Years.kg: "assets/data/rules_kg.json",
  Years.primary_1: "assets/data/rules_primary_1.json",
  Years.primary_3: "assets/data/rules_primary_3.json",
  Years.primary_5: "assets/data/rules_primary_5.json",
  Years.preparatory: "assets/data/rules_prep.json",
  Years.secondary: "assets/data/rules_sec.json",
};

class Rules {
  String fliePath = '';
  List<RulesLevel> levels = [];
  int count = 0;
  bool loaded = false;

  Rules({required Years year}) {
    if (!rulesFiles.containsKey(year)) {
      throw Exception("Year not found");
    }

    fliePath = rulesFiles[year]!;
  }

  Future<Rules> getRules() async {
    if (loaded) return this;

    final String rawData = await rootBundle.loadString(fliePath);
    final Map<String, dynamic> data = await json.decode(rawData);

    for (String key in data.keys) {
      levels.add(parseLevel(key, data[key]));
      count++;
    }

    loaded = true;

    return this;
  }

  static List<FlatRuleItem> toFlatList(Rules rules) {
    List<FlatRuleItem> flatList = [];

    for (RulesLevel level in rules.levels) {
      flatList.add(FlatRuleItem(item: level, type: RuleTypes.level));
      for (Rule rule in level.rules) {
        flatList.add(FlatRuleItem(
            item: rule, type: RuleTypes.rule, shouldScale: rule.shouldScale));
        for (Example example in rule.examples) {
          flatList.add(FlatRuleItem(item: example, type: RuleTypes.example));
        }
      }
    }

    return flatList;
  }

  static RulesLevel parseLevel(String level, List data) {
    List<Rule> rules = [];

    for (Map ruleData in data) {
      rules.add(parseRule(ruleData));
    }

    return RulesLevel(level: level, rules: rules);
  }

  static Rule parseRule(Map data) {
    List<Example> examples = [];

    for (var element in data[RulesKeys.examples.name]) {
      examples.add(Example(example: element));
    }

    return Rule(
        rule: data[RulesKeys.rule.name],
        examples: examples,
        shouldScale: data[RulesKeys.shouldScale.name]);
  }
}

class BaseRule {}

class RulesLevel extends BaseRule {
  final String level;
  final List<Rule> rules;

  RulesLevel({required this.level, required this.rules});
}

class Rule extends BaseRule {
  final String rule;
  final List<Example> examples;
  final bool? shouldScale;

  Rule({required this.rule, required this.examples, this.shouldScale = false});
}

class Example extends BaseRule {
  final String example;

  Example({required this.example});
}

class FlatRuleItem {
  final BaseRule item;
  final RuleTypes type;
  final bool? shouldScale;

  FlatRuleItem(
      {required this.item, required this.type, this.shouldScale = false});
}
