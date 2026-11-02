import 'package:flutter/material.dart';

import '../organismes.dart';
import '../theme.dart';
import '../widgets.dart';

/// Écran 7 — Annuaire des organismes.
class AnnuaireScreen extends StatefulWidget {
  const AnnuaireScreen({super.key});

  @override
  State<AnnuaireScreen> createState() => _AnnuaireScreenState();
}

class _AnnuaireScreenState extends State<AnnuaireScreen> {
  String _query = '';
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase().trim();
    final list = organismes.where((o) {
      if (_tag != null && !o.tags.contains(_tag)) return false;
      if (q.isEmpty) return true;
      return o.name.toLowerCase().contains(q) || o.role.toLowerCase().contains(q);
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const Text('Annuaire', style: TS.h2),
          const SizedBox(height: 2),
          const Text('Les organismes de votre parcours', style: TS.small),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un organisme',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.bordure)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.bordure)),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _chip('Tous', null),
            for (final t in organismeTags) _chip(t, t),
          ]),
          const SizedBox(height: 14),
          if (list.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Aucun résultat', style: TS.body))),
          for (final o in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                radius: 16,
                padding: const EdgeInsets.all(14),
                onTap: () => _showDetails(context, o),
                child: Row(children: [
                  IconBox(o.icon, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o.name, style: TS.title),
                      const SizedBox(height: 2),
                      Text(o.role, maxLines: 2, overflow: TextOverflow.ellipsis, style: TS.small),
                      const SizedBox(height: 6),
                      Pill(
                        text: o.mode,
                        fg: o.mode == 'En ligne' ? AppColors.primaire : AppColors.texteSecondaire,
                        bg: o.mode == 'En ligne' ? AppColors.primaireDoux : AppColors.fond,
                      ),
                    ]),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.desactive),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? tag) {
    final on = _tag == tag;
    return ChoiceChip(
      label: Text(label),
      selected: on,
      showCheckmark: false,
      onSelected: (_) => setState(() => _tag = tag),
      selectedColor: AppColors.primaire,
      backgroundColor: Colors.white,
      side: BorderSide(color: on ? AppColors.primaire : AppColors.bordure),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.texte),
    );
  }

  void _showDetails(BuildContext context, Organisme o) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconBox(o.icon, size: 48),
              const SizedBox(width: 14),
              Expanded(child: Text(o.name, style: TS.h3)),
            ]),
            const SizedBox(height: 14),
            Text(o.role, style: TS.bodyDark),
            const SizedBox(height: 10),
            Pill(icon: Icons.language, text: o.mode, fg: AppColors.primaire, bg: AppColors.primaireDoux),
            const SizedBox(height: 18),
            if (o.url != null)
              FilledButton.icon(
                onPressed: () => openLink(ctx, o.url!),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Ouvrir le site'),
              )
            else
              const Text('Adresse et horaires : renseignez-vous auprès du bureau le plus proche.', style: TS.small),
          ]),
        ),
      ),
    );
  }
}
