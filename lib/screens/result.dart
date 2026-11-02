import 'package:flutter/material.dart';

import '../app_state.dart';
import '../main.dart';
import '../models.dart';
import '../questions.dart';
import '../theme.dart';
import '../widgets.dart';

/// Écran 3 — Résultat et recommandation.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? _chosen;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final rec = recommend(s.answers);
    final code = _chosen ?? rec.code;
    final p = Catalog.byCode(code)!;
    final isReco = code == rec.code;
    final tasks = p.tasks.where((t) => evalCondition(t.condition, s.answers)).toList();
    final phases = tasks.map((t) => t.phaseNumber).toSet().length;
    final docs = tasks.fold<int>(0, (n, t) => n + t.documents.length);
    final alternatives = <Alternative>[
      if (!isReco) Alternative(rec.code, 'Notre recommandation selon vos réponses'),
      ...rec.alternatives.where((a) => a.code != code),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Row(children: [
              CircleIconButton(Icons.chevron_left, onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(width: 14),
              const Text('Votre résultat', style: TS.h3),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              children: [
                AppCard(
                  color: AppColors.primaire,
                  borderWidth: 0,
                  radius: 22,
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Pill(
                      icon: isReco ? Icons.check : Icons.touch_app_outlined,
                      text: isReco ? 'Recommandé pour vous' : 'Votre choix',
                      fg: Colors.white,
                      bg: AppColors.accent,
                    ),
                    const SizedBox(height: 10),
                    Text(p.name,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15)),
                    const SizedBox(height: 4),
                    Text(p.subtitle, style: const TextStyle(fontSize: 14, color: Color(0xDDFFFFFF), fontWeight: FontWeight.w500)),
                  ]),
                ),
                const SizedBox(height: 12),
                if (isReco)
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Pourquoi ce choix', style: TS.title),
                      const SizedBox(height: 10),
                      for (final r in rec.reasons)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const IconBox(Icons.check, size: 22, radius: 11),
                            const SizedBox(width: 10),
                            Expanded(child: Text(r, style: TS.bodyDark)),
                          ]),
                        ),
                    ]),
                  ),
                for (final w in rec.warnings) ...[
                  const SizedBox(height: 10),
                  InfoBox(w, icon: Icons.warning_amber_rounded, fg: AppColors.accent, bg: AppColors.accentDoux),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Stat(Icons.checklist, '${tasks.length}', 'tâches')),
                  const SizedBox(width: 10),
                  Expanded(child: _Stat(Icons.layers_outlined, '$phases', 'phases')),
                  const SizedBox(width: 10),
                  Expanded(child: _Stat(Icons.description_outlined, '$docs', 'documents')),
                ]),
                if (alternatives.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Autres options possibles', style: TS.title),
                      const SizedBox(height: 4),
                      for (final a in alternatives)
                        InkWell(
                          onTap: () => setState(() => _chosen = a.code),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(Catalog.byCode(a.code)!.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text(a.reason, style: TS.small),
                                ]),
                              ),
                              const Text('Choisir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaire)),
                              const Icon(Icons.chevron_right, color: AppColors.desactive),
                            ]),
                          ),
                        ),
                    ]),
                  ),
                ],
                const SizedBox(height: 14),
                const Text(
                  'Orientation indicative, à confirmer avec un professionnel (expert-comptable, avocat).',
                  textAlign: TextAlign.center,
                  style: TS.small,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: FilledButton(
              onPressed: () {
                s.chooseParcours(code);
                goToRoot(context);
              },
              child: const Text('Voir mon parcours'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: TS.small),
      ]),
    );
  }
}
