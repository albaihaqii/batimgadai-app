import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/pin/pin_dots_widget.dart';
import '../../widgets/pin/pin_keyboard_widget.dart';
import 'ganti_pin_konfirmasi_screen.dart';

class GantiPinBaruScreen extends StatefulWidget {
  const GantiPinBaruScreen({super.key});

  @override
  State<GantiPinBaruScreen> createState() => _GantiPinBaruScreenState();
}

class _GantiPinBaruScreenState extends State<GantiPinBaruScreen> {
  String _pin = '';
  static const int _pinLength = 6;

  void _onKey(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _next);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _next() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => GantiPinKonfirmasiScreen(pinBaru: _pin)),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _pin = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFE0E0E0), width: 1.5),
                        ),
                        child: const Icon(Icons.chevron_left,
                            color: Colors.black, size: 24),
                      ),
                    ),
                    const Spacer(),
                    const AppLogo(),
                  ],
                ),
                const SizedBox(height: 36),
                const Text(
                  'Buat PIN Baru',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Buat PIN baru yang mudah Anda ingat namun sulit ditebak orang lain untuk keamanan akun Anda.',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                      height: 1.65),
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
                PinDotsWidget(filled: _pin.length),
                const Expanded(flex: 4, child: SizedBox.shrink()),
                PinKeyboardWidget(onKeyTap: _onKey, onBackspace: _onBackspace),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
