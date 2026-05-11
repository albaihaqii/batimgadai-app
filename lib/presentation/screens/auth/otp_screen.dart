import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_logo.dart';
import 'create_pin_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String generatedOtp;
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.generatedOtp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

enum _ResendState { idle, sending, sent, countdown }

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focuses = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _dialogVisible = false;
  _ResendState _resendState = _ResendState.idle;
  int _resendCountdown = 0;

  bool get _isFilled => _controllers.every((c) => c.text.isNotEmpty);
  String get _otpValue => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focuses[0].requestFocus());
    for (final f in _focuses) {
      f.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focuses) f.dispose();
    super.dispose();
  }

  void _onChanged(String val, int i) {
    if (val.length == 1 && i < 5)
      _focuses[i + 1].requestFocus();
    else if (val.isEmpty && i > 0) _focuses[i - 1].requestFocus();
    setState(() {});
    if (_isFilled && !_isLoading) {
      Future.delayed(const Duration(milliseconds: 150), _verify);
    }
  }

  void _onKeyEvent(KeyEvent event, int i) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _focuses[i - 1].requestFocus();
      _controllers[i - 1].clear();
      setState(() {});
    }
  }

  void _verify() {
    if (!_isFilled || _isLoading) return;
    setState(() => _isLoading = true);
    for (final f in _focuses) f.unfocus();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (_otpValue == widget.generatedOtp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CreatePinScreen()),
        );
      } else {
        _showError();
      }
    });
  }

  Future<void> _onResend() async {
    if (_resendState != _ResendState.idle) return;
    for (final c in _controllers) c.clear();
    _focuses[0].requestFocus();
    setState(() => _resendState = _ResendState.sending);

    // Kirim OTP baru ke WA
    await ApiService.kirimOtp(widget.phoneNumber, widget.generatedOtp);

    if (!mounted) return;
    setState(() => _resendState = _ResendState.sent);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _resendState = _ResendState.countdown;
        _resendCountdown = 30;
      });
      _tickCountdown();
    });
  }

  void _tickCountdown() {
    if (_resendCountdown <= 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) _resendState = _ResendState.idle;
      });
      _tickCountdown();
    });
  }

  void _showError() {
    setState(() => _dialogVisible = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _OtpErrorDialog(
        onClose: () {
          Navigator.pop(context);
          setState(() => _dialogVisible = false);
          for (final c in _controllers) c.clear();
          _focuses[0].requestFocus();
          setState(() {});
        },
      ),
    );
  }

  Widget _buildResendWidget() {
    const base = TextStyle(
        fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF9E9E9E));

    switch (_resendState) {
      case _ResendState.idle:
        return GestureDetector(
          onTap: _onResend,
          child: RichText(
            text: TextSpan(style: base, children: [
              const TextSpan(text: 'Belum menerima kode? '),
              TextSpan(
                  text: 'Kirim Ulang',
                  style: const TextStyle(fontWeight: FontWeight.w600)
                      .copyWith(color: AppColors.primary)),
            ]),
          ),
        );
      case _ResendState.sending:
        return RichText(
          text: TextSpan(style: base, children: [
            const TextSpan(text: 'Belum menerima kode? '),
            const TextSpan(
                text: 'Mengirim...',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF555555))),
          ]),
        );
      case _ResendState.sent:
        return RichText(
          text: TextSpan(style: base, children: [
            const TextSpan(text: 'Belum menerima kode? '),
            TextSpan(
                text: 'Terkirim!',
                style: const TextStyle(fontWeight: FontWeight.w600)
                    .copyWith(color: AppColors.primary)),
          ]),
        );
      case _ResendState.countdown:
        return RichText(
          text: TextSpan(style: base, children: [
            const TextSpan(text: 'Belum menerima kode? '),
            TextSpan(
                text: 'Kirim Ulang (${_resendCountdown}s)',
                style: const TextStyle(fontWeight: FontWeight.w600)
                    .copyWith(color: AppColors.primary)),
          ]),
        );
    }
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
                  'Kode Verifikasi Terkirim!',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                        height: 1.65),
                    children: [
                      const TextSpan(
                          text: 'Kami telah mengirim kode verifikasi ke '),
                      TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(
                              color: Color(0xFF1F5C3A),
                              fontWeight: FontWeight.w600)),
                      const TextSpan(
                          text:
                              ' melalui WhatsApp. Mohon cek dan masukkan kembali kode verifikasi pada kolom.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (_, constraints) {
                    final double boxSize = (constraints.maxWidth - 5 * 10) / 6;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (i) => _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focuses[i],
                          onChanged: (v) => _onChanged(v, i),
                          onKeyEvent: (e) => _onKeyEvent(e, i),
                          disabled: _isLoading,
                          size: boxSize,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                if (_isLoading)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        disabledBackgroundColor: AppColors.primaryLight,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppColors.primary),
                      ),
                    ),
                  )
                else
                  AppButton(
                      label: 'Konfirmasi', enabled: _isFilled, onTap: _verify),
                const SizedBox(height: 20),
                Center(child: _buildResendWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  final bool disabled;
  final double size;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.disabled,
    required this.size,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
    widget.focusNode.hasFocus ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.controller.text.isNotEmpty;
    final double radius = widget.size * 0.2;
    const double stroke = 1.2;

    final Gradient borderGradient = _focused
        ? const LinearGradient(colors: [
            Color(0xFF2E7D52),
            Color(0xFF1F5C3A),
          ])
        : filled
            ? const LinearGradient(colors: [
                Color(0xFFC8E87A),
                Color(0xFFB6D96C),
              ])
            : const LinearGradient(
                colors: [Color(0xFFE8E8E8), Color(0xFFDDDDDD)]);

    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: borderGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(stroke),
          child: Container(
            decoration: BoxDecoration(
              color:
                  filled && !_focused ? const Color(0xFFF6FAF0) : Colors.white,
              borderRadius: BorderRadius.circular(radius - stroke),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius - stroke),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: widget.onKeyEvent,
                child: Center(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    enabled: !widget.disabled,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: widget.onChanged,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: widget.size * 0.38,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpErrorDialog extends StatefulWidget {
  final VoidCallback onClose;
  const _OtpErrorDialog({required this.onClose});

  @override
  State<_OtpErrorDialog> createState() => _OtpErrorDialogState();
}

class _OtpErrorDialogState extends State<_OtpErrorDialog>
    with TickerProviderStateMixin {
  late final AnimationController _dialogCtrl;
  late final AnimationController _rippleCtrl;
  late final AnimationController _iconCtrl;
  late final Animation<double> _dialogScale;
  late final Animation<double> _dialogFade;
  late final Animation<double> _r1Scale;
  late final Animation<double> _r1Opacity;
  late final Animation<double> _r2Scale;
  late final Animation<double> _r2Opacity;
  late final Animation<double> _iconScale;

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

  Widget _buildRipple(Animation<double> scale, Animation<double> opacity) {
    return AnimatedBuilder(
      animation: _rippleCtrl,
      builder: (_, __) => Transform.scale(
        scale: scale.value,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD32F2F).withValues(alpha: opacity.value),
          ),
        ),
      ),
    );
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
                      _buildRipple(_r2Scale, _r2Opacity),
                      _buildRipple(_r1Scale, _r1Opacity),
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFFD32F2F), size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Kode Tidak Valid',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kode OTP salah atau kedaluwarsa. Silakan coba lagi.',
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
        ),
      ),
    );
  }
}
