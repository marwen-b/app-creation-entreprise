import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'notifications.dart';

/// Toutes les données de l'utilisateur, enregistrées sur le téléphone.
class AppState extends ChangeNotifier {
  static const _key = 'etat_v1';
  SharedPreferences? _prefs;

  Map<String, String> answers = {};
  String? parcoursCode;
  DateTime? startDate;
  Map<String, String> status = {}; // 'done' ou 'nc' (non concernée)
  Map<String, String> doneDates = {};
  Map<String, List<int>> docs = {};
  Map<String, String> reminders = {}; // date ISO
  String userName = '';
  String projectName = '';
  bool remindersEnabled = true;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      answers = Map<String, String>.from((j['answers'] ?? {}) as Map);
      parcoursCode = j['parcoursCode'] as String?;
      final sd = j['startDate'] as String?;
      startDate = sd == null ? null : DateTime.tryParse(sd);
      status = Map<String, String>.from((j['status'] ?? {}) as Map);
      doneDates = Map<String, String>.from((j['doneDates'] ?? {}) as Map);
      docs = ((j['docs'] ?? {}) as Map).map((k, v) => MapEntry(k as String, List<int>.from(v as List)));
      reminders = Map<String, String>.from((j['reminders'] ?? {}) as Map);
      userName = (j['userName'] ?? '') as String;
      projectName = (j['projectName'] ?? '') as String;
      remindersEnabled = (j['remindersEnabled'] ?? true) as bool;
      if (Catalog.byCode(parcoursCode) == null) parcoursCode = null;
    } catch (_) {
      // Données illisibles : on repart de zéro plutôt que de bloquer l'application.
    }
  }

  Future<void> _save() async {
    final j = {
      'answers': answers,
      'parcoursCode': parcoursCode,
      'startDate': startDate?.toIso8601String(),
      'status': status,
      'doneDates': doneDates,
      'docs': docs,
      'reminders': reminders,
      'userName': userName,
      'projectName': projectName,
      'remindersEnabled': remindersEnabled,
    };
    await _prefs?.setString(_key, jsonEncode(j));
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  // ---------- Questionnaire ----------

  void setAnswer(String questionId, String optionId) {
    answers[questionId] = optionId;
    _changed();
  }

  void chooseParcours(String code) {
    if (parcoursCode != code) startDate = DateTime.now();
    startDate ??= DateTime.now();
    parcoursCode = code;
    _changed();
  }

  // ---------- Parcours ----------

  Parcours? get parcours => Catalog.byCode(parcoursCode);

  List<TaskItem> get visibleTasks {
    final p = parcours;
    if (p == null) return [];
    return p.tasks.where((t) => evalCondition(t.condition, answers)).toList();
  }

  Set<String> get _visibleIds => visibleTasks.map((t) => t.id).toSet();

  TaskItem? taskById(String id) {
    for (final t in parcours?.tasks ?? <TaskItem>[]) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool isDone(String id) => status[id] == 'done';
  bool isNotConcerned(String id) => status[id] == 'nc';
  bool isClosed(String id) => isDone(id) || isNotConcerned(id);

  /// Tâches visibles dont celle-ci dépend et qui ne sont pas encore faites.
  List<TaskItem> blockers(TaskItem t) {
    final vis = _visibleIds;
    final out = <TaskItem>[];
    for (final d in t.dependsOn) {
      if (vis.contains(d) && !isClosed(d)) {
        final dep = taskById(d);
        if (dep != null) out.add(dep);
      }
    }
    return out;
  }

  bool isLocked(TaskItem t) => !isClosed(t.id) && blockers(t).isNotEmpty;

  int get doneCount => visibleTasks.where((t) => isClosed(t.id)).length;
  int get totalCount => visibleTasks.length;
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  TaskItem? get nextTask {
    for (final t in visibleTasks) {
      if (!isClosed(t.id) && !isLocked(t)) return t;
    }
    return null;
  }

  /// Date à partir de laquelle la tâche est disponible : fin de sa dernière dépendance, sinon début du parcours.
  DateTime? availableFrom(TaskItem t) {
    DateTime? from = startDate;
    for (final d in t.dependsOn) {
      final iso = doneDates[d];
      if (iso == null) continue;
      final dt = DateTime.tryParse(iso);
      if (dt != null && (from == null || dt.isAfter(from))) from = dt;
    }
    return from;
  }

  /// Échéance suggérée (colonne « Rappel suggéré » du catalogue, ex. J+7).
  DateTime? dueDate(TaskItem t) {
    final from = availableFrom(t);
    if (from == null || t.offsetDays == null) return null;
    final d = from.add(Duration(days: t.offsetDays!));
    return DateTime(d.year, d.month, d.day);
  }

  void setDone(String id, bool done) {
    if (done) {
      status[id] = 'done';
      doneDates[id] = DateTime.now().toIso8601String();
      if (reminders.containsKey(id)) {
        reminders.remove(id);
        Notifs.cancel(id);
      }
    } else {
      status.remove(id);
      doneDates.remove(id);
    }
    _changed();
  }

  void setNotConcerned(String id, bool nc) {
    if (nc) {
      status[id] = 'nc';
      doneDates[id] = DateTime.now().toIso8601String();
      if (reminders.containsKey(id)) {
        reminders.remove(id);
        Notifs.cancel(id);
      }
    } else {
      status.remove(id);
      doneDates.remove(id);
    }
    _changed();
  }

  bool isDocChecked(String taskId, int index) => docs[taskId]?.contains(index) ?? false;

  void toggleDoc(String taskId, int index) {
    final list = List<int>.from(docs[taskId] ?? <int>[]);
    if (list.contains(index)) {
      list.remove(index);
    } else {
      list.add(index);
    }
    docs[taskId] = list;
    _changed();
  }

  // ---------- Rappels ----------

  DateTime? reminderFor(String id) {
    final iso = reminders[id];
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<void> setReminder(TaskItem t, DateTime? when) async {
    if (when == null) {
      reminders.remove(t.id);
      await Notifs.cancel(t.id);
    } else {
      reminders[t.id] = when.toIso8601String();
      if (remindersEnabled) {
        await Notifs.requestPermission();
        await Notifs.schedule(t.id, t.title, when);
      }
    }
    _changed();
  }

  List<MapEntry<TaskItem, DateTime>> get upcomingReminders {
    final now = DateTime.now();
    final out = <MapEntry<TaskItem, DateTime>>[];
    reminders.forEach((id, iso) {
      final t = taskById(id);
      final d = DateTime.tryParse(iso);
      if (t != null && d != null && d.isAfter(now) && !isClosed(id)) out.add(MapEntry(t, d));
    });
    out.sort((a, b) => a.value.compareTo(b.value));
    return out;
  }

  Future<void> setRemindersEnabled(bool on) async {
    remindersEnabled = on;
    if (!on) {
      await Notifs.cancelAll();
    } else {
      await Notifs.requestPermission();
      for (final e in upcomingReminders) {
        await Notifs.schedule(e.key.id, e.key.title, e.value);
      }
    }
    _changed();
  }

  // ---------- Profil ----------

  void setProfile({String? name, String? project}) {
    if (name != null) userName = name.trim();
    if (project != null) projectName = project.trim();
    _changed();
  }

  Future<void> resetAll() async {
    await Notifs.cancelAll();
    answers = {};
    parcoursCode = null;
    startDate = null;
    status = {};
    doneDates = {};
    docs = {};
    reminders = {};
    userName = '';
    projectName = '';
    remindersEnabled = true;
    _changed();
  }
}

/// Rend l'état accessible à tous les écrans.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
