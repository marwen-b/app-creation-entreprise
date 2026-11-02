import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../organismes.dart';
import '../theme.dart';
import '../widgets.dart';

/// Écran 6 — Détail d'une tâche.
class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.taskById(taskId);
    if (t == null) {
      return const Scaffold(body: Center(child: Text('Tâche introuvable')));
    }
    final done = s.isDone(t.id);
    final nc = s.isNotConcerned(t.id);
    final locked = s.isLocked(t);
    final due = s.dueDate(t);
    final reminder = s.reminderFor(t.id);
    final link = linkForOrganisme(t.organisme);
    final checked = List.generate(t.documents.length, (i) => s.isDocChecked(t.id, i)).where((c) => c).length;

    Widget statusPill;
    if (done) {
      statusPill = const Pill(icon: Icons.check, text: 'Tâche faite', fg: AppColors.primaire, bg: AppColors.primaireDoux);
    } else if (nc) {
      statusPill = const Pill(icon: Icons.remove, text: 'Non concernée', fg: AppColors.texteSecondaire, bg: AppColors.bordure);
    } else if (locked) {
      statusPill = const Pill(icon: Icons.lock_outline, text: 'Verrouillée', fg: AppColors.texteSecondaire, bg: AppColors.bordure);
    } else if (due != null) {
      statusPill = Pill(icon: Icons.schedule, text: 'À faire avant le ${fmtDate(due)}');
    } else {
      statusPill = const Pill(icon: Icons.radio_button_unchecked, text: 'À faire');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Row(children: [
              CircleIconButton(Icons.chevron_left, onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(width: 14),
              Expanded(child: Text('Phase ${t.phaseNumber} · ${t.phaseName}', style: TS.small)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              children: [
                Align(alignment: Alignment.centerLeft, child: statusPill),
                const SizedBox(height: 8),
                Text(t.title, style: TS.h2),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _Info(Icons.apartment_outlined, 'Organisme', t.organisme)),
                  const SizedBox(width: 8),
                  Expanded(child: _Info(Icons.language, 'Démarche', t.demarche)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _Info(Icons.payments_outlined, 'Coût estimé', _dt(t.cost))),
                  const SizedBox(width: 8),
                  Expanded(child: _Info(Icons.schedule, 'Délai', t.delay)),
                ]),
                const SizedBox(height: 16),
                Text(t.explanation, style: TS.bodyDark),
                const SizedBox(height: 8),
                Text('Pourquoi : ${t.why}', style: TS.body),
                if (locked) ...[
                  const SizedBox(height: 14),
                  InfoBox(
                    'Terminez d\'abord : ${s.blockers(t).map((b) => b.title).join(' · ')}',
                    icon: Icons.lock_outline,
                    fg: AppColors.texteSecondaire,
                    bg: AppColors.bordure,
                  ),
                ],
                if (t.documents.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                    child: Column(children: [
                      Row(children: [
                        const Expanded(child: Text('Documents à préparer', style: TS.title)),
                        Text('$checked sur ${t.documents.length}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaire)),
                      ]),
                      const SizedBox(height: 6),
                      for (var i = 0; i < t.documents.length; i++) ...[
                        const Divider(),
                        InkWell(
                          onTap: () => s.toggleDoc(t.id, i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(children: [
                              _CheckBox(checked: s.isDocChecked(t.id, i)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t.documents[i],
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: s.isDocChecked(t.id, i) ? FontWeight.w500 : FontWeight.w600,
                                    color: s.isDocChecked(t.id, i) ? AppColors.texteSecondaire : AppColors.texte,
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ],
                if (!done && !nc) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const IconBox(Icons.notifications_none, fg: AppColors.accent, bg: AppColors.accentDoux, size: 36, radius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Rappel', style: TS.small),
                          Text(
                            reminder == null
                                ? 'Aucun rappel'
                                : '${capitalize(fmtDateLong(reminder))} à ${fmtTime(reminder)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                      if (reminder != null)
                        IconButton(
                          tooltip: 'Supprimer le rappel',
                          onPressed: () => s.setReminder(t, null),
                          icon: const Icon(Icons.close, size: 20, color: AppColors.texteSecondaire),
                        ),
                      TextButton(
                        onPressed: () => _pickReminder(context, s, t, reminder ?? due),
                        child: Text(reminder == null ? 'Programmer' : 'Modifier'),
                      ),
                    ]),
                  ),
                ],
                if (link != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => openLink(context, link),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text(linkLabel(link)),
                    ),
                  ),
                ],
                if (t.toVerify) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Coûts et délais indicatifs, en cours de vérification. Confirmez-les auprès de l\'organisme.',
                    textAlign: TextAlign.center,
                    style: TS.small,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Column(children: [
              if (done)
                OutlinedButton(onPressed: () => s.setDone(t.id, false), child: const Text('Remettre à faire'))
              else if (nc)
                OutlinedButton(onPressed: () => s.setNotConcerned(t.id, false), child: const Text('Je suis concerné(e)'))
              else
                FilledButton(
                  onPressed: locked
                      ? null
                      : () {
                          final messenger = ScaffoldMessenger.of(context);
                          s.setDone(t.id, true);
                          Navigator.of(context).maybePop();
                          messenger.showSnackBar(
                            SnackBar(content: Text('« ${t.title} » est faite. Bravo !')),
                          );
                        },
                  child: Text(locked ? 'Tâche verrouillée' : 'Marquer comme faite'),
                ),
              if (!done && !nc)
                TextButton(
                  onPressed: () => s.setNotConcerned(t.id, true),
                  child: const Text('Je ne suis pas concerné(e)'),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  static String _dt(String cost) {
    final c = cost.trim();
    if (RegExp(r'^[0-9 ,]+(à [0-9 ,]+)?$').hasMatch(c)) return '$c DT';
    return c;
  }

  Future<void> _pickReminder(BuildContext context, AppState s, TaskItem t, DateTime? initial) async {
    final now = DateTime.now();
    var init = initial ?? now.add(const Duration(days: 1));
    if (init.isBefore(now)) init = now;
    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Date du rappel',
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Heure du rappel',
    );
    if (time == null) return;
    final when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (when.isBefore(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez une heure à venir.')));
      }
      return;
    }
    await s.setReminder(t, when);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rappel programmé le ${fmtDate(when)} à ${fmtTime(when)}')),
      );
    }
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Info(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 14,
      padding: const EdgeInsets.all(10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconBox(icon, size: 32, radius: 9),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.texteSecondaire)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool checked;
  const _CheckBox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.primaire : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: checked ? AppColors.primaire : AppColors.desactive, width: 2),
      ),
      child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }
}
