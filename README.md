# Nebda — créer son entreprise en Tunisie (version 0)

Application Android qui guide un porteur de projet tunisien de l'idée au démarrage :
un questionnaire l'oriente vers la bonne forme juridique, puis une liste de tâches à cocher
et des rappels l'accompagnent jusqu'à l'ouverture.

« Nebda » est un nom provisoire.

## Ce que contient la version 0

- Questionnaire d'orientation (15 questions, plus une question sur les projets collectifs).
- 5 parcours : SUARL, SARL, entreprise individuelle, auto-entrepreneur, entreprise communautaire (99 tâches).
- Tâches par phase, dépendances (une tâche se débloque quand la précédente est faite), documents à cocher.
- Rappels sous forme de notifications sur le téléphone.
- Annuaire des organismes, profil, effacement des données.
- **Sans serveur** : tout est enregistré sur le téléphone, aucune inscription.

## Télécharger l'APK de test

Chaque modification envoyée sur la branche `main` fabrique automatiquement un nouvel APK :
onglet **Releases** du dépôt → « Version de test (dernière) » → fichier `Nebda-test.apk`.

Sur le téléphone, autorisez l'installation depuis cette source quand Android le demande.

## Modifier le contenu des parcours

1. Mettre à jour les catalogues Excel dans `docs/catalogues/` (après révision par l'expert-comptable).
2. Lancer `python3 tool/convert_catalogues.py` : il régénère `assets/data/parcours.json`.
3. Envoyer la modification sur `main` : un nouvel APK est fabriqué.

## Organisation du code

| Fichier | Rôle |
| --- | --- |
| `lib/questions.dart` | Questions, réponses et arbre de recommandation |
| `lib/models.dart` | Lecture des parcours et conditions d'affichage des tâches |
| `lib/app_state.dart` | Réponses, avancement, rappels — enregistrés sur le téléphone |
| `lib/notifications.dart` | Rappels locaux |
| `lib/organismes.dart` | Annuaire et liens officiels |
| `lib/screens/` | Les écrans (accueil, questionnaire, résultat, tableau de bord, parcours, détail, annuaire, profil) |
| `tool/patch_android.py` | Réglages Android appliqués pendant la fabrication |
| `.github/workflows/build-apk.yml` | Fabrication automatique de l'APK |

Le dossier `android/` n'est pas dans le dépôt : il est généré à chaque fabrication par `flutter create`,
puis adapté par `tool/patch_android.py`.

## Avertissement

L'application informe et oriente ; elle ne remplace pas un expert-comptable ou un avocat.
Les coûts et délais sont indicatifs.

Police : Plus Jakarta Sans (licence SIL Open Font, voir `assets/fonts/OFL.txt`).
