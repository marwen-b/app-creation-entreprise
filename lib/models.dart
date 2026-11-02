import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Une tâche d'un parcours, chargée depuis assets/data/parcours.json.
class TaskItem {
  final String id;
  final String phase;
  final String title;
  final String explanation;
  final String why;
  final String organisme;
  final String demarche;
  final List<String> documents;
  final String cost;
  final String delay;
  final List<String> dependsOn;
  final Map<String, dynamic>? condition;
  final String reminderText;
  final int? offsetDays;
  final bool toVerify;

  TaskItem.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        phase = j['phase'] as String,
        title = j['title'] as String,
        explanation = j['explanation'] as String,
        why = j['why'] as String,
        organisme = j['organisme'] as String,
        demarche = j['demarche'] as String,
        documents = List<String>.from(j['documents'] as List),
        cost = j['cost'] as String,
        delay = j['delay'] as String,
        dependsOn = List<String>.from(j['dependsOn'] as List),
        condition = j['condition'] == null ? null : Map<String, dynamic>.from(j['condition'] as Map),
        reminderText = (j['reminderText'] ?? '') as String,
        offsetDays = j['offsetDays'] as int?,
        toVerify = (j['toVerify'] ?? false) as bool;

  int get phaseNumber => int.tryParse(phase.split('.').first.trim()) ?? 0;

  String get phaseName {
    final i = phase.indexOf('. ');
    return i >= 0 ? phase.substring(i + 2) : phase;
  }
}

class Parcours {
  final String code;
  final String name;
  final String subtitle;
  final List<TaskItem> tasks;

  Parcours.fromJson(Map<String, dynamic> j)
      : code = j['code'] as String,
        name = j['name'] as String,
        subtitle = j['subtitle'] as String,
        tasks = (j['tasks'] as List).map((t) => TaskItem.fromJson(Map<String, dynamic>.from(t as Map))).toList();
}

class Catalog {
  static List<Parcours> all = [];

  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/parcours.json');
    final list = jsonDecode(raw) as List;
    all = list.map((p) => Parcours.fromJson(Map<String, dynamic>.from(p as Map))).toList();
  }

  static Parcours? byCode(String? code) {
    for (final p in all) {
      if (p.code == code) return p;
    }
    return null;
  }
}

/// Évalue la condition d'affichage d'une tâche à partir des réponses au questionnaire.
/// Une réponse absente affiche la tâche (on préfère montrer trop que pas assez).
bool evalCondition(Map<String, dynamic>? c, Map<String, String> answers) {
  if (c == null) return true;
  if (c.containsKey('any')) {
    return (c['any'] as List).any((x) => evalCondition(Map<String, dynamic>.from(x as Map), answers));
  }
  if (c.containsKey('all')) {
    return (c['all'] as List).every((x) => evalCondition(Map<String, dynamic>.from(x as Map), answers));
  }
  final q = c['q'] as String?;
  if (q == null) return true;
  final a = answers[q];
  if (a == null) return true;
  if (c.containsKey('eq')) return a == c['eq'];
  if (c.containsKey('ne')) return a != c['ne'];
  if (c.containsKey('in')) return (c['in'] as List).contains(a);
  return true;
}
