import 'package:flutter/material.dart';

/// Annuaire des organismes (cahier des charges, section 6).
/// Les liens ne sont indiqués que lorsqu'ils ont été vérifiés.
class Organisme {
  final String name;
  final String role;
  final String mode;
  final List<String> tags;
  final IconData icon;
  final String? url;
  const Organisme(this.name, this.role, this.mode, this.tags, this.icon, [this.url]);
}

const String urlRne = 'https://www.registre-entreprises.tn';
const String urlAutoEntrepreneur = 'https://www.autoentrepreneur.tn';
const String urlCnss = 'https://www.cnss.tn';
const String urlStartup = 'https://startup.gov.tn';
const String urlMobileId = 'https://www.idaraty.tn/public/fr/procedures/e-houwiya-identite-digitale-mobile-id-tunisie';
const String urlIdaraty = 'https://www.idaraty.tn';

const List<Organisme> organismes = [
  Organisme('Registre national des entreprises (RNE)',
      'Réservation du nom, immatriculation, extrait RNE, bénéficiaires effectifs. Dépôts 100 % en ligne depuis juillet 2026.',
      'En ligne', ['En ligne', 'Juridique'], Icons.account_balance_outlined, urlRne),
  Organisme('Direction générale des impôts',
      'Déclaration d\'existence (patente), carte d\'identification fiscale, déclarations. La patente se fait en ligne depuis août 2026.',
      'En ligne', ['En ligne', 'Impôts'], Icons.receipt_long_outlined),
  Organisme('Recette des finances', 'Enregistrement des statuts et du contrat de bail.', 'Guichet', ['Impôts'],
      Icons.request_quote_outlined),
  Organisme('CNSS', 'Affiliation du gérant, de l\'entreprise et des salariés à la sécurité sociale.', 'Guichet · en ligne',
      ['Social', 'En ligne'], Icons.health_and_safety_outlined, urlCnss),
  Organisme('Plateforme auto-entrepreneur', 'Inscription au statut, carte d\'auto-entrepreneur, déclarations trimestrielles.',
      'En ligne', ['En ligne', 'Impôts', 'Social'], Icons.person_outline, urlAutoEntrepreneur),
  Organisme('Identité numérique (Mobile ID)', 'Identité numérique nécessaire pour les démarches en ligne.', 'Guichet',
      ['En ligne'], Icons.phonelink_lock_outlined, urlMobileId),
  Organisme('Banque tunisienne de solidarité (BTS)', 'Financement des petits projets et microcrédits.', 'Guichet',
      ['Financement'], Icons.savings_outlined),
  Organisme('APII · Espace Entreprendre', 'Accompagnement des promoteurs, vérification des activités réglementées.',
      'Guichet', ['Juridique', 'Financement'], Icons.support_agent_outlined),
  Organisme('Startup Tunisia', 'Label Startup Act et avantages pour les projets innovants.', 'En ligne',
      ['En ligne', 'Financement'], Icons.rocket_launch_outlined, urlStartup),
  Organisme('Municipalité', 'Légalisation des signatures, autorisations d\'ouverture au public.', 'Guichet', ['Juridique'],
      Icons.location_city_outlined),
  Organisme('Douane', 'Code en douane pour importer ou exporter.', 'Guichet · en ligne', ['Juridique'],
      Icons.local_shipping_outlined),
  Organisme('Idaraty', 'Guide gratuit des procédures administratives tunisiennes.', 'En ligne', ['En ligne'],
      Icons.menu_book_outlined, urlIdaraty),
];

const List<String> organismeTags = ['En ligne', 'Impôts', 'Social', 'Financement', 'Juridique'];

/// Lien officiel associé à une tâche, d'après son organisme.
String? linkForOrganisme(String organisme) {
  final o = organisme.toLowerCase();
  if (o.contains('autoentrepreneur')) return urlAutoEntrepreneur;
  if (o.contains('rne')) return urlRne;
  if (o.contains('cnss')) return urlCnss;
  if (o.contains('startup')) return urlStartup;
  if (o.contains('tuntrust')) return urlMobileId;
  return null;
}

String linkLabel(String url) {
  if (url == urlRne) return 'Ouvrir la plateforme du RNE';
  if (url == urlAutoEntrepreneur) return 'Ouvrir autoentrepreneur.tn';
  if (url == urlCnss) return 'Ouvrir le site de la CNSS';
  if (url == urlStartup) return 'Ouvrir Startup Tunisia';
  if (url == urlMobileId) return 'Comment obtenir le Mobile ID';
  return 'Ouvrir le site';
}
