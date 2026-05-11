import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import 'verify_success_screen.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen>
    with TickerProviderStateMixin {
  final TextEditingController _ktpCtrl = TextEditingController();
  final TextEditingController _cifCtrl = TextEditingController();
  final FocusNode _ktpFocus = FocusNode();
  final FocusNode _cifFocus = FocusNode();

  bool _isLoading = false;
  bool _dialogVisible = false;

  bool get _isFilled => _ktpCtrl.text.isNotEmpty && _cifCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ktpCtrl.addListener(() => setState(() {}));
    _cifCtrl.addListener(() => setState(() {}));
    _ktpFocus.addListener(() => setState(() {}));
    _cifFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ktpCtrl.dispose();
    _cifCtrl.dispose();
    _ktpFocus.dispose();
    _cifFocus.dispose();
    super.dispose();
  }

  void _verify() {
    if (!_isFilled || _isLoading) return;
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    ApiService.verifyNasabah(
      noKtp: _ktpCtrl.text.trim(),
      noCif: _cifCtrl.text.trim(),
    ).then((result) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifySuccessScreen(
              nasabahData: result['data'] as Map<String, dynamic>,
            ),
          ),
        );
      } else {
        _showErrorDialog();
      }
    });
  }

  void _showErrorDialog() {
    setState(() => _dialogVisible = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _VerifyErrorDialog(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
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
                ),
                const SizedBox(height: 28),
                Image.asset(
                  'assets/images/illustrations/verify_data.png',
                  width: 200,
                  height: 197,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 200, height: 197),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verifikasi Data Akun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon isi Nomor KTP dan CIF dengan benar agar kami dapat mengenali Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFFA0A0A0),
                      height: 1.6),
                ),
                const SizedBox(height: 24),
                _buildField(
                  label: 'Nomor KTP',
                  controller: _ktpCtrl,
                  focusNode: _ktpFocus,
                  iconAsset: 'assets/icons/card-linier.svg',
                  placeholder: 'Masukkan Nomor KTP',
                  inputType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Nomor CIF',
                  controller: _cifCtrl,
                  focusNode: _cifFocus,
                  iconAsset: 'assets/icons/cif-linier.svg',
                  placeholder: 'CIF-SMG-000001',
                  inputType: TextInputType.text,
                  formatters: [_CifFormatter()],
                  isUpperCase: true,
                ),
                const SizedBox(height: 12),
                _buildCifInfo(),
                const SizedBox(height: 24),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String iconAsset,
    required String placeholder,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool isUpperCase = false,
  }) {
    final bool focused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? AppColors.primary : const Color(0xFFE0E0E0),
              width: focused ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      AppColors.primary, BlendMode.srcIn),
                  errorBuilder: (_, __, ___) => const Icon(Icons.credit_card,
                      size: 20, color: AppColors.primary),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: inputType,
                  inputFormatters: formatters,
                  textCapitalization: isUpperCase
                      ? TextCapitalization.characters
                      : TextCapitalization.none,
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFFBDBDBD)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCifInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE8CF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: SvgPicture.asset(
              'assets/icons/info-circle.svg',
              width: 14,
              height: 14,
              colorFilter:
                  const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              errorBuilder: (_, __, ___) => const Icon(Icons.info_outline,
                  size: 14, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Nomor CIF dapat dilihat pada Surat Bukti Gadai (SBG) yang diterima saat pertama kali gadai.',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.primary,
                  height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            _isFilled && !_isLoading ? _verify : (_isFilled ? () {} : null),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isFilled ? const Color(0xFFB6D96C) : const Color(0xFFDBDBDB),
          disabledBackgroundColor: const Color(0xFFDBDBDB),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Color(0xFF1F5C3A)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verifikasi Data',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isFilled
                            ? const Color(0xFF1F5C3A)
                            : const Color(0xFF9E9E9E)),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: _isFilled
                        ? const Color(0xFF1F5C3A)
                        : const Color(0xFF9E9E9E),
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}

class _CifFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    final clean = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    String result = clean;
    if (clean.length > 6) {
      result =
          '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    } else if (clean.length > 3) {
      result = '${clean.substring(0, 3)}-${clean.substring(3)}';
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class _VerifyErrorDialog extends StatefulWidget {
  final VoidCallback onClose;
  const _VerifyErrorDialog({required this.onClose});

  @override
  State<_VerifyErrorDialog> createState() => _VerifyErrorDialogState();
}

class _VerifyErrorDialogState extends State<_VerifyErrorDialog>
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
                  'Data Tidak Valid',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nomor KTP atau CIF yang Anda masukkan tidak sesuai. Silakan coba lagi.',
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
