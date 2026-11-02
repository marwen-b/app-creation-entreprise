import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'models.dart';
import 'notifications.dart';
import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'theme.dart';

/// Nom provisoire de l'application (pistes du cahier des charges : Bdéya, Nebda, Massar…).
const String appName = 'Nebda';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Catalog.load();
  final state = AppState();
  await state.load();
  await Notifs.init();
  runApp(NebdaApp(state: state));
}

class NebdaApp extends StatelessWidget {
  final AppState state;
  const NebdaApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const RootGate(),
      ),
    );
  }
}

/// Affiche l'accueil tant qu'aucun parcours n'est choisi, puis l'application.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return s.parcoursCode == null ? const OnboardingScreen() : const HomeShell();
  }
}

/// Revient à l'écran racine en vidant l'historique de navigation.
void goToRoot(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const RootGate()),
    (_) => false,
  );
}
