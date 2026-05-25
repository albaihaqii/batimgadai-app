import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'config/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';
import 'presentation/screens/splash/splash_screen.dart';

MidtransSDK? midtransSDK;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Midtrans SDK
  try {
    midtransSDK = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: AppConstants.midtransClientKey,
        merchantBaseUrl: '',
        enableLog: true,
      ),
    );
    debugPrint('[Midtrans] init: ${midtransSDK != null}');
  } catch (e) {
    debugPrint('[Midtrans] error: $e');
  }

  // Notifikasi lokal
  await NotificationService.init();

  // Background periodic check jatuh tempo
  await BackgroundService.init();
  await BackgroundService.registerPeriodicTask();

  runApp(const ProviderScope(child: BatimGadaiApp()));
}

class BatimGadaiApp extends StatelessWidget {
  const BatimGadaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BATIM GADAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F5C3A)),
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
