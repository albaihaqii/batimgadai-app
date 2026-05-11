import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/phone_util.dart';
import '../info/syarat_ketentuan_screen.dart';
import 'otp_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _hasInput = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final filled = _ctrl.text.trim().length >= 9;
      if (filled != _hasInput) setState(() => _hasInput = filled);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _generateOtp() =>
      List.generate(6, (_) => Random().nextInt(10).toString()).join();

  Future<void> _submit() async {
    if (!_hasInput || _isLoading) return;
    setState(() => _isLoading = true);
    final phone = PhoneUtil.toE164(_ctrl.text.trim());
    final otp = _generateOtp();
    await StorageService.savePhone(phone);
    await ApiService.kirimOtp(phone, otp);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(phoneNumber: phone, generatedOtp: otp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sh = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (_, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 78),
                      SizedBox(
                        height: sh * 0.28,
                        child: Image.asset(
                          'assets/images/illustrations/login.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.phone_android,
                              size: 100,
                              color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Cepat, Aman, dan\nNyaman di Batim Gadai',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Masukkan nomor handphone untuk login ke aplikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF757575),
                            height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('No. Handphone',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333))),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: const BoxDecoration(
                                border: Border(
                                    right:
                                        BorderSide(color: Color(0xFFE5E7EB))),
                              ),
                              child: const Text('+62',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A)),
                                decoration: const InputDecoration(
                                  hintText: '81234567890',
                                  hintStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Color(0xFFBBBBBB)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _hasInput ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.primary,
                            disabledBackgroundColor: const Color(0xFFDBDBDB),
                            disabledForegroundColor: const Color(0xFF263238),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primary))
                              : const Text(
                                  'Kirim Kode OTP via WhatsApp',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SyaratKetentuanScreen()),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Color(0xFF9E9E9E),
                                height: 1.5),
                            children: [
                              TextSpan(
                                  text: 'Dengan melanjutkan, saya menyetujui '),
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                  text:
                                      ' serta Kebijakan Privasi dari Batim Gadai'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
