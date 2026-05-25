import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'batim_gadai_channel';
  static const _channelName = 'BATIM GADAI';

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Notifikasi pinjaman dan transaksi BATIM GADAI',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('[Notif] init OK');
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifikasi pinjaman dan transaksi BATIM GADAI',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> showJatuhTempo({
    required String noSbg,
    required String namaBarang,
    required int sisaHari,
    required int gadaiId,
  }) async {
    final title = sisaHari <= 0
        ? 'Jatuh Tempo Terlewat! $noSbg'
        : 'Pengingat Jatuh Tempo';

    final body = sisaHari <= 0
        ? '$namaBarang telah melewati jatuh tempo ${sisaHari.abs()} hari. Segera perpanjang atau lunasi!'
        : sisaHari == 1
            ? '$namaBarang jatuh tempo BESOK!'
            : '$namaBarang jatuh tempo dalam $sisaHari hari.';

    await show(
        id: gadaiId, title: title, body: body, payload: 'gadai_$gadaiId');
  }
}
