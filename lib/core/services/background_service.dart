import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'api_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

const _taskName = 'check_jatuh_tempo';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == _taskName) await _checkJatuhTempo();
    } catch (e) {
      debugPrint('[Background] error: $e');
    }
    return true;
  });
}

Future<void> _checkJatuhTempo() async {
  final nasabah = await StorageService.getNasabah();
  final noCif = nasabah?['no_cif'] as String? ?? '';
  if (noCif.isEmpty) return;

  final pinjaman = await ApiService.getPinjamanNasabah(noCif);
  await NotificationService.init();

  for (final g in pinjaman) {
    if (g.status == 'lunas') continue;
    final h = g.sisaHari;
    if (h <= 7 && h >= -3) {
      await NotificationService.showJatuhTempo(
        noSbg: g.noSbg,
        namaBarang: g.namaDisplay,
        sisaHari: h,
        gadaiId: g.id,
      );
    }
  }
}

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      'batim_periodic',
      _taskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
