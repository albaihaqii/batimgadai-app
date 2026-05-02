import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/pin/pin_dots_widget.dart';
import '../../widgets/pin/pin_keyboard_widget.dart';
import 'confirm_pin_screen.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';
  static const int _pinLength = 6;

  void _onKey(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 200), _goToConfirm);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _goToConfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmPinScreen(pin: _pin)),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
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
                _AppHeader(),
                const SizedBox(height: 36),
                const Text(
                  'Buat PIN',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Silakan buat PIN 6 digit yang akan digunakan sebagai kode keamanan untuk mengakses aplikasi.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9E9E9E),
                    height: 1.65,
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
                PinDotsWidget(filled: _pin.length),
                const Expanded(flex: 4, child: SizedBox.shrink()),
                PinKeyboardWidget(
                  onKeyTap: _onKey,
                  onBackspace: _onBackspace,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
            ),
            child:
                const Icon(Icons.chevron_left, color: Colors.black, size: 24),
          ),
        ),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png',
                height: 34, width: 34, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('BATIM',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.15,
                        letterSpacing: 0.5)),
                Text('GADAI',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.15,
                        letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
