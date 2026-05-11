import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/pin/pin_dots_widget.dart';
import '../../widgets/pin/pin_keyboard_widget.dart';
import '../home/home_screen.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String pin;
  const ConfirmPinScreen({super.key, required this.pin});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _dialogVisible = false;
  static const int _pinLength = 6;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_pin.length >= _pinLength || _dialogVisible) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 200), _verify);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty || _dialogVisible) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    if (_pin == widget.pin) {
      await _saveAndNavigate();
    } else {
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => _pin = '');
      });
      _showErrorDialog();
    }
  }

  Future<void> _saveAndNavigate() async {
    setState(() => _dialogVisible = true);
    await StorageService.savePin(widget.pin);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const _LoadingDialog(),
    ).then((_) {
      if (mounted) setState(() => _dialogVisible = false);
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    });
  }

  void _showErrorDialog() {
    setState(() => _dialogVisible = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _PinMismatchDialog(
        onClose: () {
          Navigator.pop(context);
          setState(() => _dialogVisible = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _dialogVisible ? Brightness.light : Brightness.dark,
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
                    _BackButton(),
                    const Spacer(),
                    const AppLogo(),
                  ],
                ),
                const SizedBox(height: 36),
                const Text(
                  'Konfirmasi PIN',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Masukkan kembali 6 digit PIN yang telah dibuat sebelumnya untuk melanjutkan penggunaan aplikasi.',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                      height: 1.65),
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0), child: child),
                  child: PinDotsWidget(filled: _pin.length),
                ),
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

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinMismatchDialog extends StatelessWidget {
  final VoidCallback onClose;
  const _PinMismatchDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                  color: Color(0xFFD32F2F), size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'PIN Tidak Cocok',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'PIN yang Anda masukkan tidak sesuai. Silakan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  height: 1.65),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEBEE),
                  foregroundColor: const Color(0xFFD32F2F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
      ),
    );
  }
}
