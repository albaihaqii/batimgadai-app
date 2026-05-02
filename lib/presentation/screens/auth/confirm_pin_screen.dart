import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/pin/pin_dots_widget.dart';
import '../../widgets/pin/pin_keyboard_widget.dart';
import 'package:batimgadai_app/presentation/screens/home/home_screen.dart';

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

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

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

  void _verify() {
    if (_pin == widget.pin) {
      _showLoading();
    } else {
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => _pin = '');
      });
      _showError();
    }
  }

  void _showLoading() {
    setState(() => _dialogVisible = true);
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
        (route) => false,
      );
    });
  }

  void _showError() {
    setState(() => _dialogVisible = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _PinErrorDialog(
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
                _AppHeader(),
                const SizedBox(height: 36),
                const Text(
                  'Konfirmasi PIN',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Masukkan kembali 6 digit PIN yang dibuat sebelumnya untuk memastikan keamanan penggunaan aplikasi.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9E9E9E),
                    height: 1.65,
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  ),
                  child: PinDotsWidget(filled: _pin.length),
                ),
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
                strokeWidth: 3,
                color: AppColors.primary,
              ),
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

class _PinErrorDialog extends StatefulWidget {
  final VoidCallback onClose;
  const _PinErrorDialog({required this.onClose});

  @override
  State<_PinErrorDialog> createState() => _PinErrorDialogState();
}

class _PinErrorDialogState extends State<_PinErrorDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogCtrl;
  late AnimationController _rippleCtrl;
  late AnimationController _iconCtrl;
  late Animation<double> _dialogScale;
  late Animation<double> _dialogFade;
  late Animation<double> _r1Scale;
  late Animation<double> _r1Opacity;
  late Animation<double> _r2Scale;
  late Animation<double> _r2Opacity;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _dialogCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _dialogScale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOutBack));
    _dialogFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _dialogCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut)));

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _r1Scale = Tween<double>(begin: 0.6, end: 2.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _r1Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _r2Scale = Tween<double>(begin: 0.6, end: 2.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOut)));
    _r2Opacity = Tween<double>(begin: 0.35, end: 0.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOut)));

    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _iconScale = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack));

    _dialogCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _rippleCtrl.forward();
      _iconCtrl.forward();
    });
  }

  @override
  void dispose() {
    _dialogCtrl.dispose();
    _rippleCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _dialogFade,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ScaleTransition(
          scale: _dialogScale,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _rippleCtrl,
                        builder: (_, __) => Transform.scale(
                          scale: _r2Scale.value,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD32F2F)
                                  .withValues(alpha: _r2Opacity.value),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _rippleCtrl,
                        builder: (_, __) => Transform.scale(
                          scale: _r1Scale.value,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD32F2F)
                                  .withValues(alpha: _r1Opacity.value),
                            ),
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEBEE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFFD32F2F), size: 36),
                        ),
                      ),
                    ],
                  ),
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
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      foregroundColor: const Color(0xFFD32F2F),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Coba Lagi',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
