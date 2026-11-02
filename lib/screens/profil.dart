import 'package:flutter/material.dart';

import '../app_state.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';
import 'questionnaire.dart';

/// Écran 8 — Profil et paramètres.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final name = s.userName.isEmpty ? 'Votre nom' : s.userName;
    final initials = s.userName.isEmpty
        ? '?'
        : s.userName.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const Text('Profil', style: TS.h2),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _editProfile(context, s),
            child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaire,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: TS.h3),
                  const Text('Modifier mon nom et mon projet', style: TS.small),
                ]),
              ),
              const Icon(Icons.edit_outlined, size: 20, color: AppColors.texteSecondaire),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.primaireDoux,
            borderWidth: 0,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mon projet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaire)),
              Text('${s.projectName.isEmpty ? 'Projet sans nom' : s.projectName} · ${s.parcours?.name ?? ''}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ActionChip(
                avatar: const Icon(Icons.refresh, size: 16, color: AppColors.primaire),
                label: const Text('Refaire le questionnaire'),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaire),
                backgroundColor: Colors.white,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const QuestionnaireScreen()),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('PRÉFÉRENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.texteSecondaire)),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Column(children: [
              _Row(
                icon: Icons.notifications_none,
                label: 'Rappels',
                trailing: Switch(
                  value: s.remindersEnabled,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.primaire,
                  onChanged: (v) => s.setRemindersEnabled(v),
                ),
              ),
              const Divider(),
              const _Row(
                icon: Icons.language,
                label: 'Langue',
                trailing: Text('Français · عربي bientôt', style: TS.small),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('COMPTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.texteSecondaire)),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Column(children: [
              _Row(
                icon: Icons.info_outline,
                label: 'Mentions légales',
                trailing: const Icon(Icons.chevron_right, color: AppColors.desactive),
                onTap: () => _legal(context),
              ),
              const Divider(),
              _Row(
                icon: Icons.delete_outline,
                label: 'Effacer toutes mes données',
                danger: true,
                onTap: () => _confirmReset(context, s),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const Center(child: Text('$appName · version 0.1 de test', style: TS.small)),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, AppState s) async {
    final nameCtrl = TextEditingController(text: s.userName);
    final projectCtrl = TextEditingController(text: s.projectName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mon profil'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Votre prénom et nom')),
          const SizedBox(height: 10),
          TextField(controller: projectCtrl, decoration: const InputDecoration(labelText: 'Votre projet (ex. Café de quartier)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (ok == true) s.setProfile(name: nameCtrl.text, project: projectCtrl.text);
  }

  void _legal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mentions légales'),
        content: const Text(
          'Cette application informe et oriente. Elle ne remplace pas le conseil d\'un expert-comptable ou d\'un avocat.\n\n'
          'Les coûts et délais sont indicatifs et peuvent évoluer. Vérifiez-les auprès des organismes officiels.\n\n'
          'Vos réponses et votre avancement sont enregistrés uniquement sur ce téléphone.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer toutes mes données ?'),
        content: const Text('Vos réponses, votre avancement et vos rappels seront supprimés de ce téléphone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Effacer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await s.resetAll();
      if (context.mounted) goToRoot(context);
    }
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  const _Row({required this.icon, required this.label, this.trailing, this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          IconBox(icon,
              size: 32, radius: 9, fg: danger ? AppColors.accent : AppColors.texte, bg: danger ? AppColors.accentDoux : AppColors.fond),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: danger ? AppColors.accent : AppColors.texte)),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
    );
  }
}
