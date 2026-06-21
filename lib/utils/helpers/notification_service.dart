import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Handler background/terminated (top-level obligatoire) ─────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé par main.dart avant ce handler.
  // Rien à faire ici : FCM affiche automatiquement la notification système
  // quand l'app est en arrière-plan ou fermée.
  debugPrint('[FCM BG] ${message.notification?.title}: ${message.notification?.body}');
}

// ── Canal Android ─────────────────────────────────────────────────────────────
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'osho_high_importance',
  'Osho — Notifications',
  description: 'Commandes, livraisons et mises à jour importantes.',
  importance: Importance.high,
  playSound: true,
);

// ── Service singleton ─────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Callback appelé quand l'utilisateur tape sur une notification
  // (à brancher depuis main.dart ou NavigationMenu)
  Function(Map<String, dynamic> data)? onNotificationTap;

  // ── Initialisation principale ──────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Handler background (app fermée ou en arrière-plan)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Demande de permission (iOS + Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // 3. Créer le canal Android haute priorité
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 4. Initialiser flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleTap(response.payload);
      },
    );

    // 5. Afficher les notifications FCM en FOREGROUND (app ouverte)
    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message);
    });

    // 6. Tap sur notification quand app en arrière-plan (pas fermée)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleTap(message.data.toString());
      onNotificationTap?.call(message.data);
    });

    // 7. Tap sur notification quand app était FERMÉE
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      // Léger délai pour laisser l'app se construire
      Future.delayed(const Duration(seconds: 1), () {
        onNotificationTap?.call(initial.data);
      });
    }

    // 8. Sauvegarder le token FCM dans Supabase
    await _saveToken();

    // 9. Rafraîchir le token si FCM le renouvelle
    _fcm.onTokenRefresh.listen((token) async {
      await _upsertToken(token);
    });
  }

  // ── Affichage notification en foreground ───────────────────────────────────

  void _showForegroundNotification(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFC9A84C),
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  void _handleTap(String? payload) {
    if (payload == null) return;
    debugPrint('[FCM] Notification tappée: $payload');
  }

  // ── Gestion du token ───────────────────────────────────────────────────────

  Future<void> _saveToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _upsertToken(token);
    } catch (e) {
      debugPrint('[FCM] Impossible de récupérer le token: $e');
    }
  }

  Future<void> _upsertToken(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
        onConflict: 'user_id, token',
      );
      debugPrint('[FCM] Token sauvegardé: ${token.substring(0, 20)}…');
    } catch (e) {
      debugPrint('[FCM] Erreur sauvegarde token: $e');
    }
  }

  /// Appeler lors du logout pour supprimer le token du device courant
  Future<void> deleteToken() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await Supabase.instance.client
          .from('fcm_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
      await _fcm.deleteToken();
      debugPrint('[FCM] Token supprimé.');
    } catch (e) {
      debugPrint('[FCM] Erreur suppression token: $e');
    }
  }

  /// Ré-enregistrer le token après connexion
  Future<void> onLogin() => _saveToken();

  /// Afficher une notification locale (test ou rappel local)
  Future<void> showLocal({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFC9A84C),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}
