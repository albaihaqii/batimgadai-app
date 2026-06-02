import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class FcmService {
  FcmService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static const _channelId = 'batimgadai_channel';
  static const _channelName = 'BATIM GADAI Notifikasi';
  static const _channelDesc = 'Notifikasi jatuh tempo dan transaksi';

  static Future<void> init() async {
    // Setup Android notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _localNotif.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[FCM] Local notif tapped: ${details.payload}');
      },
    );

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Matikan auto-display FCM saat foreground supaya tidak duplikat
    // Local notif yang akan handle saat foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Foreground — tampilkan via local notif (1 notif, tidak duplikat)
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground: ${message.notification?.title}');
      _showLocalNotif(message);
    });

    // Background tap — app dibuka dari notif
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from background: ${message.data}');
    });

    // Terminated state — app dibuka dari notif
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Opened from terminated: ${initial.data}');
    }

    // Upload token — untuk pengunjung maupun nasabah
    await _uploadToken();

    // Refresh token otomatis jika berubah
    _messaging.onTokenRefresh.listen((token) async {
      await _saveAndUpload(token);
    });
  }

  static Future<void> _uploadToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      if (token != null) await _saveAndUpload(token);
    } catch (e) {
      debugPrint('[FCM] Get token error: $e');
    }
  }

  static Future<String> _getDeviceId() async {
    try {
      final info = DeviceInfoPlugin();
      final android = await info.androidInfo;
      return android.id;
    } catch (_) {
      return 'unknown_device';
    }
  }

  static Future<void> _saveAndUpload(String token) async {
    await StorageService.saveFcmToken(token);
    try {
      final phone = await StorageService.getPhone();
      final deviceId = await _getDeviceId();

      await ApiService.saveFcmToken(
        phone: phone ?? '',
        token: token,
        deviceId: deviceId,
      );
      debugPrint('[FCM] Token uploaded — phone: $phone, device: $deviceId');
    } catch (e) {
      debugPrint('[FCM] Upload error: $e');
    }
  }

  static void _showLocalNotif(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  // Panggil saat logout
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      await StorageService.saveFcmToken(null);
      debugPrint('[FCM] Token deleted');
    } catch (e) {
      debugPrint('[FCM] Delete token error: $e');
    }
  }

  // Re-upload token — panggil setelah verifikasi nasabah berhasil
  static Future<void> reUploadToken() async {
    await _uploadToken();
  }
}
