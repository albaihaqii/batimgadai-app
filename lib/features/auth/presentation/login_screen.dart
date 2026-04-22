import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/shared/primary_button.dart';
import '../../../../../core/shared/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  void _validateInput(String value) {
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      bool isValidPrefix = cleanNumber.startsWith('08');
      bool isValidLength = cleanNumber.length >= 10 && cleanNumber.length <= 13;
      _isButtonEnabled = isValidPrefix && isValidLength;
    });
  }

  void _handleLogin() {
    final String phone = _phoneController.text.trim();
    context.push('/verification', extra: phone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.h,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      Image.asset(
                        'assets/images/login_illustration.png',
                        height: 250.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'Cepat, Aman, dan\nNyaman di Batim Gadai',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall, // Kembali ke layout Gambar 1
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Masukkan nomor handphone kamu untuk login ke aplikasi untuk menikmati semua fitur.',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium, // Kembali ke layout Gambar 1
                      ),
                      SizedBox(height: 32.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No. Handphone',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      CustomTextField(
                        hintText: '0812345xxxxx',
                        prefixIconPath: 'assets/images/icon_phone.svg',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: _validateInput,
                        maxLength: 13,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      SizedBox(height: 24.h),
                      PrimaryButton(
                        text: 'Masuk dengan No. Handphone',
                        onPressed: _isButtonEnabled ? _handleLogin : null,
                      ),
                      SizedBox(height: 24.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall, // Layout Gambar 1
                          children: [
                            const TextSpan(
                              text: 'Dengan melanjutkan, saya menyetujui ',
                            ),
                            TextSpan(
                              text: 'Syarat\n& Ketentuan',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFF1F5C3A),
                                    fontWeight: FontWeight.w600,
                                  ),
                              // INI FUNGSINYA GUA IDUPIN LAGI
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.push('/terms');
                                },
                            ),
                            const TextSpan(text: ' dari Batim Gadai'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: Text(
                          'v1.0.26',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey.shade400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
