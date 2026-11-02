/// Questionnaire d'orientation (cahier des charges, section 3) et logique de recommandation.
/// Les identifiants des réponses sont ceux utilisés dans assets/data/parcours.json.

class QOption {
  final String id;
  final String title;
  final String? description;
  const QOption(this.id, this.title, [this.description]);
}

class Question {
  final String id;
  final String section;
  final String title;
  final String? help;
  final List<QOption> options;
  final bool Function(Map<String, String> answers)? visibleIf;

  const Question({
    required this.id,
    required this.section,
    required this.title,
    this.help,
    required this.options,
    this.visibleIf,
  });
}

bool _always(Map<String, String> a) => true;
bool _withPartners(Map<String, String> a) => a['Q4'] == 'plusieurs';
bool _alone(Map<String, String> a) => a['Q4'] != 'plusieurs';

final List<Question> allQuestions = [
  const Question(
    id: 'Q1',
    section: 'VOUS',
    title: 'Quelle est votre situation ?',
    options: [
      QOption('tn_resident', 'Tunisien(ne) résidant en Tunisie'),
      QOption('tn_etranger', "Tunisien(ne) résidant à l'étranger"),
      QOption('etranger', 'De nationalité étrangère', 'Des démarches supplémentaires peuvent s\'appliquer'),
    ],
  ),
  const Question(
    id: 'Q2',
    section: 'VOTRE ACTIVITÉ',
    title: 'Dans quel secteur allez-vous travailler ?',
    options: [
      QOption('commerce', 'Commerce', 'Boutique, vente en ligne, distribution'),
      QOption('services', 'Services', 'Conseil, réparation, restauration, beauté…'),
      QOption('artisanat', 'Artisanat'),
      QOption('industrie', 'Industrie', 'Fabrication, transformation'),
      QOption('agriculture', 'Agriculture et pêche'),
      QOption('numerique', 'Numérique / tech'),
      QOption('liberal', 'Profession libérale'),
    ],
  ),
  const Question(
    id: 'Q3',
    section: 'VOTRE ACTIVITÉ',
    title: 'Votre activité demande-t-elle une autorisation ?',
    help:
        'Certaines activités (restauration, santé, transport, éducation…) exigent une autorisation, un cahier des charges ou un diplôme.',
    options: [
      QOption('oui', 'Oui'),
      QOption('non', 'Non'),
      QOption('nsp', 'Je ne sais pas', 'Nous ajouterons une tâche pour le vérifier'),
    ],
  ),
  const Question(
    id: 'Q4',
    section: 'VOTRE PROJET',
    title: 'Serez-vous seul ou avec des associés ?',
    help:
        "Le nombre d'associés détermine les formes possibles : seul, vous pouvez créer une SUARL ou une entreprise individuelle.",
    options: [
      QOption('seul', 'Seul(e)', "Je crée l'entreprise sans associé"),
      QOption('plusieurs', 'Avec un ou plusieurs associés', 'Nous serons au moins deux'),
    ],
  ),
  const Question(
    id: 'Q4b',
    section: 'VOTRE PROJET',
    title: 'Votre projet est-il collectif ?',
    help:
        "Au moins 10 habitants d'une même délégation ? Vous pouvez créer une entreprise communautaire, avec des avantages dédiés.",
    options: [
      QOption('non', 'Non, une société classique', 'Nous sommes quelques associés'),
      QOption('local10', 'Oui, au moins 10 personnes', 'Même délégation · entreprise locale'),
      QOption('regional15', 'Oui, au moins 15 personnes', 'Plusieurs délégations · entreprise régionale'),
      QOption('nsp', 'Je ne sais pas encore', 'Nous vous expliquerons les deux options'),
    ],
    visibleIf: _withPartners,
  ),
  const Question(
    id: 'Q5',
    section: 'VOTRE PROJET',
    title: "Quel chiffre d'affaires prévoyez-vous par an ?",
    options: [
      QOption('lt75', 'Moins de 75 000 DT'),
      QOption('75_300', 'De 75 000 à 300 000 DT'),
      QOption('gt300', 'Plus de 300 000 DT'),
      QOption('nsp', 'Je ne sais pas encore'),
    ],
  ),
  const Question(
    id: 'Q6',
    section: 'VOTRE PROJET',
    title: 'Voulez-vous protéger votre patrimoine personnel ?',
    help:
        "Dans une société, vos biens personnels sont séparés de ceux de l'entreprise. En entreprise individuelle, ils peuvent servir à payer ses dettes.",
    options: [
      QOption('oui', 'Oui, c\'est important pour moi'),
      QOption('non', 'Non, je préfère la simplicité'),
      QOption('nsp', 'Je ne sais pas'),
    ],
    visibleIf: _alone,
  ),
  const Question(
    id: 'Q7',
    section: 'VOTRE PROJET',
    title: 'De combien disposez-vous pour démarrer ?',
    options: [
      QOption('lt1000', 'Moins de 1 000 DT'),
      QOption('1000_10000', 'De 1 000 à 10 000 DT'),
      QOption('gt10000', 'Plus de 10 000 DT'),
    ],
  ),
  const Question(
    id: 'Q8',
    section: 'VOTRE LOCAL',
    title: "Avez-vous besoin d'un local ?",
    options: [
      QOption('domicile', 'Non, je travaille depuis chez moi'),
      QOption('a_louer', 'Oui, je dois en louer un'),
      QOption('disponible', "Oui, j'en ai déjà un"),
    ],
  ),
  const Question(
    id: 'Q9',
    section: 'VOTRE LOCAL',
    title: 'Recevrez-vous du public ?',
    help: "Un commerce, un café ou un cabinet doivent respecter des normes d'hygiène et de sécurité.",
    options: [
      QOption('oui', 'Oui'),
      QOption('non', 'Non'),
    ],
  ),
  const Question(
    id: 'Q10',
    section: 'VOTRE ÉQUIPE',
    title: "Prévoyez-vous d'embaucher la première année ?",
    options: [
      QOption('non', 'Non'),
      QOption('1_3', 'Oui, 1 à 3 personnes'),
      QOption('plus3', 'Oui, plus de 3 personnes'),
    ],
  ),
  const Question(
    id: 'Q11',
    section: 'VOTRE ACTIVITÉ',
    title: 'Allez-vous importer ou exporter ?',
    options: [
      QOption('non', 'Non'),
      QOption('import', 'Importer'),
      QOption('export', 'Exporter'),
      QOption('both', 'Les deux'),
    ],
  ),
  const Question(
    id: 'Q12',
    section: 'VOTRE PROJET',
    title: 'Votre projet est-il innovant ?',
    help: 'Un projet technologique ou de recherche peut obtenir le label Startup Act et ses avantages.',
    options: [
      QOption('oui', 'Oui'),
      QOption('non', 'Non'),
      QOption('nsp', 'Je ne sais pas'),
    ],
  ),
  const Question(
    id: 'Q13',
    section: 'FINANCEMENT',
    title: 'Cherchez-vous un financement ?',
    options: [
      QOption('non', 'Non'),
      QOption('banque', 'Un prêt bancaire'),
      QOption('bts', 'BTS ou microcrédit'),
      QOption('investisseurs', 'Des investisseurs'),
      QOption('subvention', 'Une subvention'),
    ],
  ),
  const Question(
    id: 'Q14',
    section: 'DÉMARCHES EN LIGNE',
    title: 'Avez-vous une identité numérique (Mobile ID) ?',
    help: 'Elle est nécessaire pour les démarches en ligne au registre national des entreprises.',
    options: [
      QOption('oui', 'Oui'),
      QOption('non', 'Non, ou je ne sais pas'),
    ],
  ),
  const Question(
    id: 'Q15',
    section: 'OÙ EN ÊTES-VOUS',
    title: 'Où en est votre projet ?',
    options: [
      QOption('idee', "C'est encore une idée"),
      QOption('etude', "J'ai étudié mon marché"),
      QOption('pret', 'Je suis prêt(e) à créer'),
      QOption('cree', "J'ai déjà commencé les démarches"),
    ],
  ),
];

List<Question> visibleQuestions(Map<String, String> answers) =>
    allQuestions.where((q) => (q.visibleIf ?? _always)(answers)).toList();

class Alternative {
  final String code;
  final String reason;
  const Alternative(this.code, this.reason);
}

class Recommendation {
  final String code;
  final List<String> reasons;
  final List<String> warnings;
  final List<Alternative> alternatives;
  const Recommendation(this.code, this.reasons, this.warnings, this.alternatives);
}

/// Arbre d'orientation (cahier des charges, section 3).
Recommendation recommend(Map<String, String> a) {
  late String code;
  late List<String> reasons;
  final alts = <Alternative>[];
  final warnings = <String>[];

  if (a['Q4'] == 'plusieurs') {
    final collectif = a['Q4b'];
    if (collectif == 'local10' || collectif == 'regional15') {
      code = 'EC';
      reasons = [
        'Votre projet est collectif',
        collectif == 'local10'
            ? "Au moins 10 membres d'une même délégation : entreprise locale"
            : "Au moins 15 membres de plusieurs délégations : entreprise régionale",
        'Avantages fiscaux et financements dédiés',
      ];
      alts.add(const Alternative('SA', 'Si vous préférez une société classique entre associés'));
      final minCapital = collectif == 'local10' ? '5 000' : '10 000';
      if (a['Q7'] != 'gt10000') {
        warnings.add('Le capital minimum est de $minCapital DT, réparti entre les membres.');
      }
    } else {
      code = 'SA';
      reasons = [
        'Vous créez à plusieurs',
        'La responsabilité de chaque associé est limitée à son apport',
        'Capital minimum accessible : 1 000 DT',
      ];
      if (collectif == 'nsp') {
        alts.add(const Alternative('EC', "Si au moins 10 habitants d'une même délégation s'associent"));
      }
    }
  } else {
    final autoOk = a['Q1'] == 'tn_resident' && a['Q5'] == 'lt75';
    final protect = a['Q6'];
    if (protect == 'oui') {
      code = 'SU';
      reasons = [
        'Vous créez seul(e)',
        'Votre patrimoine personnel est protégé',
        'Capital minimum accessible : 1 000 DT',
      ];
      alts.add(const Alternative('EI', 'Sans capital, mais patrimoine non protégé'));
      if (autoOk) alts.add(const Alternative('AE', "Si votre chiffre d'affaires reste sous 75 000 DT"));
    } else if (autoOk) {
      code = 'AE';
      reasons = [
        'Vous résidez en Tunisie et créez seul(e)',
        "Chiffre d'affaires prévu sous 75 000 DT",
        'Inscription en ligne et impôt forfaitaire de 0,5 %',
      ];
      alts.add(const Alternative('EI', 'Si votre activité dépasse le plafond plus tard'));
      alts.add(const Alternative('SU', 'Si vous voulez protéger votre patrimoine'));
    } else if (protect == 'nsp') {
      code = 'SU';
      reasons = [
        'Vous créez seul(e)',
        'Dans le doute, la SUARL protège votre patrimoine',
        'Capital minimum accessible : 1 000 DT',
      ];
      alts.add(const Alternative('EI', 'Sans capital, mais patrimoine non protégé'));
    } else {
      code = 'EI';
      reasons = [
        'Vous créez seul(e)',
        'Aucun capital minimum',
        "Démarches plus simples qu'une société",
      ];
      alts.add(const Alternative('SU', 'Pour protéger votre patrimoine personnel'));
    }
  }

  if ((code == 'SU' || code == 'SA') && a['Q7'] == 'lt1000') {
    warnings.add('Le capital minimum est de 1 000 DT : prévoyez de le réunir avant le dépôt en banque.');
  }
  if (a['Q1'] == 'etranger') {
    warnings.add(
        'Pour une personne de nationalité étrangère, des démarches supplémentaires s\'appliquent. Cette version ne les détaille pas encore.');
  }
  if (a['Q1'] == 'tn_etranger') {
    warnings.add('Depuis l\'étranger, la plupart des démarches se font en ligne avec une identité numérique.');
  }
  return Recommendation(code, reasons, warnings, alts);
}
