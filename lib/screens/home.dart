import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'annuaire.dart';
import 'parcours.dart';
import 'profil.dart';
import 'task_detail.dart';

/// Navigation principale : Accueil, Parcours, Annuaire, Profil.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: [
        DashboardScreen(onOpenParcours: () => setState(() => _tab = 1)),
        const ParcoursScreen(),
        const AnnuaireScreen(),
        const ProfilScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Parcours'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Annuaire'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

void openTask(BuildContext context, TaskItem t) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: t.id)));
}

/// Écran 4 — Tableau de bord.
class DashboardScreen extends StatelessWidget {
  final VoidCallback onOpenParcours;
  const DashboardScreen({super.key, required this.onOpenParcours});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final p = s.parcours;
    if (p == null) return const SizedBox.shrink();
    final next = s.nextTask;
    final phaseTotal = p.tasks.map((t) => t.phaseNumber).toSet().length;
    final upcoming = s.upcomingReminders.take(4).toList();
    final hello = s.userName.isEmpty ? 'Bonjour' : 'Bonjour ${s.userName}';
    final project = s.projectName.isEmpty ? 'Mon projet' : s.projectName;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          Text(hello, style: TS.h2),
          const SizedBox(height: 2),
          Text('$project · ${p.name}', style: TS.small),
          const SizedBox(height: 18),
          AppCard(
            color: AppColors.primaire,
            borderWidth: 0,
            radius: 22,
            padding: const EdgeInsets.all(20),
            onTap: onOpenParcours,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Votre avancement',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${s.doneCount} tâches sur ${s.totalCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ]),
                ),
                Text('${(s.progress * 100).round()} %',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 12),
              ProgressBar(value: s.progress, bg: const Color(0x38FFFFFF), fg: AppColors.accent, height: 8),
              const SizedBox(height: 10),
              Text(
                next == null
                    ? 'Toutes les tâches sont terminées'
                    : 'Phase ${next.phaseNumber} sur $phaseTotal · ${next.phaseName}',
                style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          const Text('Prochaine tâche', style: TS.h3),
          const SizedBox(height: 10),
          if (next == null)
            const AppCard(
              child: Row(children: [
                IconBox(Icons.celebration_outlined),
                SizedBox(width: 12),
                Expanded(child: Text('Bravo ! Votre parcours est terminé. Pensez à vos échéances fiscales.', style: TS.bodyDark)),
              ]),
            )
          else
            _NextTaskCard(task: next),
          const SizedBox(height: 22),
          const Text('Rappels à venir', style: TS.h3),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            const AppCard(
              child: Row(children: [
                IconBox(Icons.notifications_none, fg: AppColors.accent, bg: AppColors.accentDoux),
                SizedBox(width: 12),
                Expanded(child: Text('Aucun rappel programmé. Ouvrez une tâche pour en ajouter un.', style: TS.body)),
              ]),
            )
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(children: [
                for (var i = 0; i < upcoming.length; i++) ...[
                  if (i > 0) const Divider(),
                  InkWell(
                    onTap: () => openTask(context, upcoming[i].key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        const IconBox(Icons.notifications_none, size: 36, radius: 10, bg: AppColors.fond),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(upcoming[i].key.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(
                              '${capitalize(fmtDateLong(upcoming[i].value))} à ${fmtTime(upcoming[i].value)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: i == 0 ? AppColors.accent : AppColors.texteSecondaire,
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ],
              ]),
            ),
        ],
      ),
    );
  }
}

class _NextTaskCard extends StatelessWidget {
  final TaskItem task;
  const _NextTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final due = s.dueDate(task);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (due != null) ...[
          Pill(icon: Icons.schedule, text: 'À faire avant le ${fmtDate(due)}'),
          const SizedBox(height: 10),
        ],
        Text(task.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 14, runSpacing: 6, children: [
          _Meta(Icons.apartment_outlined, task.organisme),
          if (task.demarche != '—') _Meta(Icons.language, task.demarche),
          if (task.delay != '—') _Meta(Icons.schedule, task.delay),
        ]),
        const SizedBox(height: 14),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          onPressed: () => openTask(context, task),
          child: const Text('Commencer la tâche'),
        ),
      ]),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.texteSecondaire),
      const SizedBox(width: 5),
      Flexible(child: Text(text, style: TS.small)),
    ]);
  }
}
