import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home.dart';

enum _Filter { all, todo, done }

/// Écran 5 — Parcours : phases et tâches.
class ParcoursScreen extends StatefulWidget {
  const ParcoursScreen({super.key});

  @override
  State<ParcoursScreen> createState() => _ParcoursScreenState();
}

class _ParcoursScreenState extends State<ParcoursScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.parcours;
    if (p == null) return const SizedBox.shrink();
    final tasks = s.visibleTasks;
    final next = s.nextTask;
    final phases = <int, List<TaskItem>>{};
    for (final t in tasks) {
      phases.putIfAbsent(t.phaseNumber, () => []).add(t);
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const Text('Mon parcours', style: TS.h2),
          const SizedBox(height: 2),
          Text('${p.name} · ${s.doneCount} tâches terminées sur ${s.totalCount}', style: TS.small),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: [
            _chip('Toutes', _Filter.all),
            _chip('À faire', _Filter.todo),
            _chip('Faites', _Filter.done),
          ]),
          const SizedBox(height: 14),
          for (final entry in phases.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PhaseCard(
                number: entry.key,
                tasks: entry.value,
                filter: _filter,
                isCurrent: next != null && next.phaseNumber == entry.key,
                nextId: next?.id,
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, _Filter f) {
    final on = _filter == f;
    return ChoiceChip(
      label: Text(label),
      selected: on,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = f),
      selectedColor: AppColors.primaire,
      backgroundColor: Colors.white,
      side: BorderSide(color: on ? AppColors.primaire : AppColors.bordure),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.texte),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final int number;
  final List<TaskItem> tasks;
  final _Filter filter;
  final bool isCurrent;
  final String? nextId;
  const _PhaseCard({required this.number, required this.tasks, required this.filter, required this.isCurrent, this.nextId});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final done = tasks.where((t) => s.isClosed(t.id)).length;
    final complete = done == tasks.length;
    final allLocked = !complete && tasks.every((t) => s.isClosed(t.id) || s.isLocked(t));
    final shown = tasks.where((t) {
      switch (filter) {
        case _Filter.all:
          return true;
        case _Filter.todo:
          return !s.isClosed(t.id);
        case _Filter.done:
          return s.isClosed(t.id);
      }
    }).toList();
    if (shown.isEmpty && filter != _Filter.all) return const SizedBox.shrink();

    Widget leading;
    if (complete) {
      leading = const TaskDot(TaskVisual.done);
    } else if (allLocked) {
      leading = const TaskDot(TaskVisual.locked);
    } else {
      leading = CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.accentDoux,
        child: Text('$number', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accent)),
      );
    }
    final meta = complete
        ? '$done tâche${done > 1 ? 's' : ''} sur ${tasks.length} · terminée'
        : allLocked
            ? '${tasks.length} tâche${tasks.length > 1 ? 's' : ''} · se débloque plus tard'
            : '$done tâche${done > 1 ? 's' : ''} sur ${tasks.length} · en cours';

    return AppCard(
      padding: EdgeInsets.zero,
      borderColor: isCurrent ? AppColors.accent : AppColors.bordure,
      borderWidth: isCurrent ? 1.5 : 1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('phase-$number'),
          initiallyExpanded: isCurrent || filter != _Filter.all,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          leading: leading,
          title: Text('Phase $number · ${tasks.first.phaseName}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: allLocked ? AppColors.texteSecondaire : AppColors.texte)),
          subtitle: Text(meta,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isCurrent ? AppColors.accent : AppColors.texteSecondaire)),
          children: [for (final t in shown) TaskRow(task: t, isNext: t.id == nextId)],
        ),
      ),
    );
  }
}

class TaskRow extends StatelessWidget {
  final TaskItem task;
  final bool isNext;
  const TaskRow({super.key, required this.task, this.isNext = false});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final done = s.isDone(task.id);
    final nc = s.isNotConcerned(task.id);
    final locked = s.isLocked(task);
    final due = s.dueDate(task);
    TaskVisual visual;
    String detail;
    if (done) {
      visual = TaskVisual.done;
      final d = DateTime.tryParse(s.doneDates[task.id] ?? '');
      detail = d == null ? 'Faite' : 'Faite le ${fmtDate(d)}';
    } else if (nc) {
      visual = TaskVisual.notConcerned;
      detail = 'Non concernée';
    } else if (locked) {
      visual = TaskVisual.locked;
      detail = 'Après : ${s.blockers(task).first.title}';
    } else {
      visual = isNext ? TaskVisual.current : TaskVisual.todo;
      detail = due != null ? 'À faire avant le ${fmtDate(due)} · ${task.organisme}' : task.organisme;
    }

    return Material(
      color: isNext ? AppColors.accentDoux : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openTask(context, task),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(children: [
            TaskDot(visual),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                    color: locked || nc ? AppColors.desactive : AppColors.texte,
                    decoration: done || nc ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isNext ? AppColors.accent : AppColors.texteSecondaire)),
              ]),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.desactive),
          ]),
        ),
      ),
    );
  }
}
