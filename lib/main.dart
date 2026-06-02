import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'config/app_constants.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';
import 'presentation/screens/splash/splash_screen.dart';

MidtransSDK? midtransSDK;

// Background FCM handler — harus top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init locale Indonesia untuk DateFormat
  await initializeDateFormatting('id_ID', null);

  // Background FCM handler — harus SEBELUM Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase — harus sebelum semua service lain
  await Firebase.initializeApp();

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

  // FCM — init setelah Firebase
  await FcmService.init();

  runApp(const ProviderScope(child: BatimGadaiApp()));
}

class BatimGadaiApp extends StatelessWidget {
  const BatimGadaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        title: 'BATIM GADAI',
        debugShowCheckedModeBanner: false,
        // Localization supaya DateFormat Bahasa Indonesia berjalan
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        locale: const Locale('id', 'ID'),
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F5C3A),
          ),
          useMaterial3: false,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Color(0xFFB6D96C),
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        home: child,
      ),
      child: const SplashScreen(),
    );
  }
}
