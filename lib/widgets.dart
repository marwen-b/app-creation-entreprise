import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme.dart';

const _mois = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];
const _jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];

String fmtDate(DateTime d) => '${d.day} ${_mois[d.month - 1]}';
String fmtDateLong(DateTime d) => '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]}';
String fmtTime(DateTime d) => '${d.hour} h ${d.minute.toString().padLeft(2, '0')}';
String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

Future<void> openLink(BuildContext context, String url) async {
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'ouvrir $url')));
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor = AppColors.bordure,
    this.borderWidth = 1,
    this.radius = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderWidth == 0 ? BorderSide.none : BorderSide(color: borderColor, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: TS.label);
}

class Pill extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color fg;
  final Color bg;
  const Pill({super.key, this.icon, required this.text, this.fg = AppColors.accent, this.bg = AppColors.accentDoux});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 5)],
        Flexible(child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg))),
      ]),
    );
  }
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color fg;
  final Color bg;
  final double size;
  final double radius;
  const IconBox(this.icon,
      {super.key, this.fg = AppColors.primaire, this.bg = AppColors.primaireDoux, this.size = 40, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
      child: Icon(icon, color: fg, size: size * 0.5),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color bg;
  final Color fg;
  final double height;
  const ProgressBar({super.key, required this.value, this.bg = AppColors.bordure, this.fg = AppColors.primaire, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: bg,
        valueColor: AlwaysStoppedAnimation<Color>(fg),
      ),
    );
  }
}

/// Carte de réponse du questionnaire (composant « Carte réponse » de Figma).
class OptionCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool selected;
  final VoidCallback onTap;
  const OptionCard({super.key, required this.title, this.description, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 16,
      color: selected ? AppColors.primaireDoux : AppColors.surface,
      borderColor: selected ? AppColors.primaire : AppColors.bordure,
      borderWidth: selected ? 2 : 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primaire : Colors.transparent,
            border: Border.all(color: selected ? AppColors.primaire : AppColors.desactive, width: 2),
          ),
          child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TS.h3),
            if (description != null) ...[
              const SizedBox(height: 2),
              Text(description!, style: TS.small),
            ],
          ]),
        ),
      ]),
    );
  }
}

enum TaskVisual { done, current, todo, locked, notConcerned }

/// Indicateur rond d'une tâche (composant « Ligne tâche » de Figma).
class TaskDot extends StatelessWidget {
  final TaskVisual visual;
  const TaskDot(this.visual, {super.key});

  @override
  Widget build(BuildContext context) {
    switch (visual) {
      case TaskVisual.done:
        return const CircleAvatar(
            radius: 14, backgroundColor: AppColors.primaire, child: Icon(Icons.check, size: 16, color: Colors.white));
      case TaskVisual.notConcerned:
        return const CircleAvatar(
            radius: 14, backgroundColor: AppColors.bordure, child: Icon(Icons.remove, size: 16, color: AppColors.texteSecondaire));
      case TaskVisual.locked:
        return const CircleAvatar(
            radius: 14, backgroundColor: AppColors.fond, child: Icon(Icons.lock_outline, size: 14, color: AppColors.desactive));
      case TaskVisual.current:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.accent, width: 2.5)),
        );
      case TaskVisual.todo:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.desactive, width: 2)),
        );
    }
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CircleIconButton(this.icon, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.bordure)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 42, height: 42, child: Icon(icon, size: 20, color: AppColors.texte)),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color fg;
  final Color bg;
  const InfoBox(this.text,
      {super.key, this.icon = Icons.info_outline, this.fg = AppColors.primaire, this.bg = AppColors.primaireDoux});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500, color: fg))),
      ]),
    );
  }
}
