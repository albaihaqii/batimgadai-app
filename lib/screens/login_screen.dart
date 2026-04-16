import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import 'terms_screen.dart';
import 'verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  void _validateInput(String value) {
    setState(() {
      _isButtonEnabled = value.trim().isNotEmpty;
    });
  }

  void _handleLogin() {
    final String phone = _phoneController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(phoneNumber: phone),
      ),
    );
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/login_illustration.png',
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Cepat, Aman, dan\nNyaman di Batim Gadai',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Masukkan nomor handphone kamu untuk login ke aplikasi untuk menikmati semua fitur.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No. Handphone',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hintText: '0812345xxxxx',
                        prefixIconPath: 'assets/images/icon_phone.svg',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: _validateInput,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Masuk dengan No. Handphone',
                        onPressed: _isButtonEnabled ? _handleLogin : null,
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Dengan melanjutkan, saya menyetujui ',
                            ),
                            TextSpan(
                              text: 'Syarat\n& Ketentuan',
                              style: const TextStyle(
                                color: Color(0xFF1F5C3A),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TermsScreen(),
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: ' dari Batim Gadai'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: Text(
                          'v1.0.26',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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
