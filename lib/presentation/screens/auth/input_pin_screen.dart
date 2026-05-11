import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/phone_util.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/pin/pin_dots_widget.dart';
import '../../widgets/pin/pin_keyboard_widget.dart';
import '../home/home_screen.dart';
import 'phone_input_screen.dart';

class InputPinScreen extends StatefulWidget {
  const InputPinScreen({super.key});

  @override
  State<InputPinScreen> createState() => _InputPinScreenState();
}

class _InputPinScreenState extends State<InputPinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _phone = '';
  int _wrongCount = 0;
  bool _bottomSheetVisible = false;
  static const int _pinLength = 6;
  static const int _maxAttempts = 3;

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
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final p = await StorageService.getPhone() ?? '';
    if (mounted) setState(() => _phone = p);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_pin.length >= _pinLength || _bottomSheetVisible) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _verify);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty || _bottomSheetVisible) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    final isCorrect = await StorageService.checkPin(_pin);
    if (!mounted) return;
    if (isCorrect) {
      final isNasabah = await StorageService.isNasabah();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(isNasabah: isNasabah)),
        (_) => false,
      );
    } else {
      _wrongCount++;
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => _pin = '');
      });
      if (_wrongCount >= _maxAttempts) {
        _showTooManyBottomSheet();
      } else {
        setState(() {});
      }
    }
  }

  void _showTooManyBottomSheet() {
    setState(() => _bottomSheetVisible = true);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _TooManyAttemptsSheet(
        onReset: () async {
          await StorageService.clearAll();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
            (_) => false,
          );
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _bottomSheetVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = _phone.isNotEmpty ? PhoneUtil.mask(_phone) : '';
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
                const Text('Masukkan PIN Kamu',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF9E9E9E),
                        height: 1.65),
                    children: [
                      const TextSpan(
                          text:
                              'Silakan masukkan 6 digit PIN untuk mengakses akun '),
                      if (maskedPhone.isNotEmpty)
                        TextSpan(
                            text: maskedPhone,
                            style: const TextStyle(
                                color: Color(0xFF1F5C3A),
                                fontWeight: FontWeight.w600)),
                      const TextSpan(text: ' Anda dengan aman.'),
                    ],
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0), child: child),
                  child: PinDotsWidget(filled: _pin.length),
                ),
                if (_wrongCount > 0 && _wrongCount < _maxAttempts)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text(
                        'PIN salah. Sisa percobaan: ${_maxAttempts - _wrongCount}',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.primary),
                      ),
                    ),
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

class _TooManyAttemptsSheet extends StatelessWidget {
  final VoidCallback onReset;
  const _TooManyAttemptsSheet({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE), shape: BoxShape.circle),
            child: const Icon(Icons.lock_outline_rounded,
                color: Color(0xFFD32F2F), size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Terlalu Banyak Percobaan',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const SizedBox(height: 8),
          const Text(
            'PIN salah 3 kali. Demi keamanan akun Anda,\nsilakan daftar ulang untuk melanjutkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                height: 1.6),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: const Color(0xFFD32F2F),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Daftar Ulang',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
