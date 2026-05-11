import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/storage_service.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/pin/pin_dots_widget.dart';
import '../../widgets/pin/pin_keyboard_widget.dart';
import '../../widgets/pin/pin_error_dialog.dart';
import '../../widgets/common/app_success_sheet.dart';

class GantiPinKonfirmasiScreen extends StatefulWidget {
  final String pinBaru;
  const GantiPinKonfirmasiScreen({super.key, required this.pinBaru});

  @override
  State<GantiPinKonfirmasiScreen> createState() =>
      _GantiPinKonfirmasiScreenState();
}

class _GantiPinKonfirmasiScreenState extends State<GantiPinKonfirmasiScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _sheetVisible = false;
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
    if (_pin.length >= _pinLength || _sheetVisible) return;
    setState(() => _pin += digit);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _verify);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty || _sheetVisible) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    if (_pin == widget.pinBaru) {
      await StorageService.updatePin(_pin);
      _showSuccessSheet();
    } else {
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => _pin = '');
      });
      _showError();
    }
  }

  void _showError() {
    setState(() => _sheetVisible = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PinErrorDialog(
        title: 'PIN Tidak Cocok',
        message:
            'Konfirmasi PIN tidak sesuai dengan PIN baru yang Anda masukkan sebelumnya.',
        onClose: () {
          Navigator.pop(context);
          setState(() => _sheetVisible = false);
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _sheetVisible = false);
    });
  }

  void _showSuccessSheet() {
    setState(() => _sheetVisible = true);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => AppSuccessSheet(
        title: 'PIN Berhasil Diubah',
        subtitle:
            'PIN baru Anda telah berhasil disimpan. Gunakan PIN baru untuk masuk ke aplikasi selanjutnya.',
        onOk: () {
          Navigator.pop(context);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _sheetVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _sheetVisible ? Brightness.light : Brightness.dark,
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
                  'Konfirmasi PIN Baru',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Masukkan kembali PIN baru Anda untuk memastikan PIN yang dibuat sudah benar dan sesuai.',
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
