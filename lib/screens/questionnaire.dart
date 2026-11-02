import 'package:flutter/material.dart';

import '../app_state.dart';
import '../questions.dart';
import '../theme.dart';
import '../widgets.dart';
import 'result.dart';

/// Écran 2 — Questionnaire d'orientation, une question par écran.
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final questions = visibleQuestions(s.answers);
    if (_index >= questions.length) _index = questions.length - 1;
    final q = questions[_index];
    final selected = s.answers[q.id];
    final isLast = _index == questions.length - 1;
    final minutesLeft = (((questions.length - _index) * 12) / 60).ceil();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Row(children: [
              CircleIconButton(Icons.chevron_left, onTap: () {
                if (_index == 0) {
                  Navigator.of(context).maybePop();
                } else {
                  setState(() => _index--);
                }
              }),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('Question ${_index + 1} sur ${questions.length}', style: TS.title)),
                    Text('≈ $minutesLeft min restante${minutesLeft > 1 ? 's' : ''}', style: TS.small),
                  ]),
                  const SizedBox(height: 8),
                  ProgressBar(value: (_index + 1) / questions.length),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              children: [
                SectionLabel(q.section),
                const SizedBox(height: 10),
                Text(q.title, style: TS.h1),
                if (q.help != null) ...[
                  const SizedBox(height: 16),
                  InfoBox(q.help!),
                ],
                const SizedBox(height: 18),
                for (final o in q.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OptionCard(
                      title: o.title,
                      description: o.description,
                      selected: selected == o.id,
                      onTap: () => s.setAnswer(q.id, o.id),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: FilledButton(
              onPressed: selected == null
                  ? null
                  : () {
                      if (isLast) {
                        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ResultScreen()));
                      } else {
                        setState(() => _index++);
                      }
                    },
              child: Text(isLast ? 'Voir mon résultat' : 'Continuer'),
            ),
          ),
        ]),
      ),
    );
  }
}
