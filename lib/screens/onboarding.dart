import 'package:flutter/material.dart';

import '../theme.dart';
import 'questionnaire.dart';

/// Écran 1 — Accueil et présentation.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(children: [
        Container(
          height: h * 0.46,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primaireDoux,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(color: AppColors.accentDoux, shape: BoxShape.circle),
              ),
              Transform.rotate(angle: -0.07, child: const _ChecklistCard()),
              Positioned(
                right: 28,
                bottom: 36,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(100)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.notifications_none, size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Rappel : demain', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('BIENVENUE', style: TS.label),
                const SizedBox(height: 10),
                const Text('Créez votre entreprise en Tunisie, étape par étape', style: TS.h1),
                const SizedBox(height: 12),
                const Text(
                  'Répondez à quelques questions. Nous vous indiquons la forme juridique adaptée, les papiers à préparer et les démarches dans le bon ordre.',
                  style: TS.body,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const QuestionnaireScreen()),
                  ),
                  child: const Text('Commencer'),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Gratuit · vos données restent sur votre téléphone', style: TS.small),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      ['Réserver le nom', true],
      ['Rédiger les statuts', true],
      ['Déposer le capital', false],
      ['Immatriculer au RNE', false],
    ];
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x240F5C4D), blurRadius: 28, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        const Text('Mon parcours SUARL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: it[1] == true ? AppColors.primaire : Colors.transparent,
                  border: Border.all(color: it[1] == true ? AppColors.primaire : AppColors.bordure, width: 2),
                ),
                child: it[1] == true ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
              Text(it[0] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: it[1] == true ? AppColors.texteSecondaire : AppColors.texte,
                  )),
            ]),
          ),
      ]),
    );
  }
}
