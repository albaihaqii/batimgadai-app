import 'package:flutter/material.dart';
// Nah, perhatiin baris di bawah ini alamatnya berubah ada 'screens/' nya
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Batim Gadai',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
