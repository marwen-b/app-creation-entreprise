import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Rappels locaux : programmés sur le téléphone, sans serveur.
class Notifs {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Tunis'));
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Demande l'autorisation d'afficher des notifications (Android 13 et plus).
  static Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Identifiant numérique stable pour une tâche.
  static int idFor(String taskId) {
    var h = 17;
    for (final c in taskId.codeUnits) {
      h = (h * 31 + c) & 0x3fffffff;
    }
    return h;
  }

  static Future<void> schedule(String taskId, String taskTitle, DateTime when) async {
    if (!_ready) return;
    final at = tz.TZDateTime.from(when, tz.local);
    if (at.isBefore(tz.TZDateTime.now(tz.local))) return;
    try {
      await _plugin.zonedSchedule(
        idFor(taskId),
        'Rappel : $taskTitle',
        "Ouvrez l'application pour voir les documents à préparer.",
        at,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rappels',
            'Rappels des tâches',
            channelDescription: 'Rappels de votre parcours de création',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Un rappel qui ne peut pas être programmé ne doit pas bloquer l'application.
    }
  }

  static Future<void> cancel(String taskId) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(idFor(taskId));
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
