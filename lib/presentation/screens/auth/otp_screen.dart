import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

enum _ResendState { idle, sending, sent, countdown }

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focuses = List.generate(6, (_) => FocusNode());

  static const _correctOtp = '123456';
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
    if (val.length == 1 && i < 5) {
      _focuses[i + 1].requestFocus();
    } else if (val.isEmpty && i > 0) {
      _focuses[i - 1].requestFocus();
    }
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
      _showResult(_otpValue == _correctOtp);
    });
  }

  void _onResend() {
    if (_resendState != _ResendState.idle) return;
    for (final c in _controllers) c.clear();
    _focuses[0].requestFocus();
    setState(() => _resendState = _ResendState.sending);

    Future.delayed(const Duration(milliseconds: 1500), () {
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

  void _showResult(bool success) {
    setState(() => _dialogVisible = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _ResultDialog(
        success: success,
        onClose: () {
          Navigator.pop(context);
          setState(() => _dialogVisible = false);
          if (!success) {
            for (final c in _controllers) c.clear();
            _focuses[0].requestFocus();
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildResendWidget() {
    switch (_resendState) {
      case _ResendState.idle:
        return GestureDetector(
          onTap: _onResend,
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xFF9E9E9E)),
              children: [
                TextSpan(text: 'Belum menerima kode? '),
                TextSpan(
                  text: 'Kirim Ulang',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      case _ResendState.sending:
        return RichText(
          text: const TextSpan(
            style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF9E9E9E)),
            children: [
              TextSpan(text: 'Belum menerima kode? '),
              TextSpan(
                text: 'Mengirim...',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF555555)),
              ),
            ],
          ),
        );
      case _ResendState.sent:
        return RichText(
          text: const TextSpan(
            style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF9E9E9E)),
            children: [
              TextSpan(text: 'Belum menerima kode? '),
              TextSpan(
                text: 'Terkirim!',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        );
      case _ResendState.countdown:
        return RichText(
          text: TextSpan(
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF9E9E9E)),
            children: [
              const TextSpan(text: 'Belum menerima kode? '),
              TextSpan(
                text: 'Kirim Ulang (${_resendCountdown}s)',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
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
                            Text(
                              'BATIM',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                height: 1.15,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'GADAI',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                height: 1.15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text(
                  'Kode Verifikasi Terkirim!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9E9E),
                      height: 1.65,
                    ),
                    children: [
                      const TextSpan(
                          text: 'Kami telah mengirimkan kode verifikasi ke '),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                          text:
                              ' melalui WhatsApp. Mohon cek dan masukkan kode verifikasi pada kolom berikut.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
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
                              )),
                    );
                  },
                ),
                const SizedBox(height: 28),
                _isLoading
                    ? SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            disabledBackgroundColor: AppColors.primaryLight,
                            elevation: 0,
                            shadowColor: Colors.transparent,
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
                    : AppButton(
                        label: 'Konfirmasi',
                        enabled: _isFilled,
                        onTap: _verify),
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
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() {
    setState(() => _focused = widget.focusNode.hasFocus);
    widget.focusNode.hasFocus ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.controller.text.isNotEmpty;
    final double radius = widget.size * 0.2;
    const double strokeWidth = 1.2;

    final Gradient borderGradient;
    if (_focused) {
      borderGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2E7D52), Color(0xFF1F5C3A), Color(0xFF174D30)],
        stops: [0.0, 0.5, 1.0],
      );
    } else if (filled) {
      borderGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC8E87A), Color(0xFFB6D96C), Color(0xFF9DC85A)],
        stops: [0.0, 0.5, 1.0],
      );
    } else {
      borderGradient = const LinearGradient(
        colors: [Color(0xFFE8E8E8), Color(0xFFDDDDDD)],
      );
    }

    final List<BoxShadow> shadows = _focused
        ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.13),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ]
        : filled
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.28),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ]
            : [];

    final Color bgColor =
        filled && !_focused ? const Color(0xFFF6FAF0) : Colors.white;

    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: borderGradient,
          boxShadow: shadows,
        ),
        child: Padding(
          padding: const EdgeInsets.all(strokeWidth),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(radius - strokeWidth),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius - strokeWidth),
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
                      color: Colors.black,
                    ),
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

class _ResultDialog extends StatefulWidget {
  final bool success;
  final VoidCallback onClose;
  const _ResultDialog({required this.success, required this.onClose});

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
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
      CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOutBack),
    );
    _dialogFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _dialogCtrl,
          curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _r1Scale = Tween<double>(begin: 0.6, end: 2.0).animate(
      CurvedAnimation(
          parent: _rippleCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );
    _r1Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
          parent: _rippleCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );
    _r2Scale = Tween<double>(begin: 0.6, end: 2.0).animate(
      CurvedAnimation(
          parent: _rippleCtrl,
          curve: const Interval(0.2, 0.85, curve: Curves.easeOut)),
    );
    _r2Opacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
          parent: _rippleCtrl,
          curve: const Interval(0.2, 0.85, curve: Curves.easeOut)),
    );

    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _iconScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack),
    );

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
    final bool ok = widget.success;
    final Color circleColor =
        ok ? AppColors.primaryLight : const Color(0xFFFFEBEE);
    final Color iconColor = ok ? AppColors.primary : const Color(0xFFD32F2F);
    final Color rippleColor =
        ok ? AppColors.primaryLight : const Color(0xFFD32F2F);
    final Color btnBg = ok ? AppColors.primaryLight : const Color(0xFFFFEBEE);
    final Color btnFg = ok ? AppColors.primary : const Color(0xFFD32F2F);

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
                              color: rippleColor.withValues(
                                  alpha: _r2Opacity.value),
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
                              color: rippleColor.withValues(
                                  alpha: _r1Opacity.value),
                            ),
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                              color: circleColor, shape: BoxShape.circle),
                          child: Icon(
                              ok ? Icons.check_rounded : Icons.close_rounded,
                              color: iconColor,
                              size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  ok ? 'Verifikasi Berhasil' : 'Kode Tidak Valid',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ok
                      ? 'Kode OTP yang Anda masukkan sudah benar. Lanjutkan untuk membuat PIN akun Anda.'
                      : 'Kode OTP yang Anda masukkan salah atau telah kedaluwarsa. Silakan coba lagi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnBg,
                      foregroundColor: btnFg,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      ok ? 'Lanjutkan' : 'Coba Lagi',
                      style: const TextStyle(
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
