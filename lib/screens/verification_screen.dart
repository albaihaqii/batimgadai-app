import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pinput/pinput.dart';
import '../widgets/primary_button.dart';
import 'pin_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isButtonEnabled = false;

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _validatePin(String pin) {
    setState(() {
      // Tombol aktif hanya jika panjang PIN tepat 6 digit
      _isButtonEnabled = pin.length == 6;
    });
  }

  void _handleResendCode() {
    // Menampilkan notifikasi Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Kode verifikasi baru telah dikirim ke WhatsApp Anda.',
        ),
        backgroundColor: const Color(0xFF1F5C3A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: const EdgeInsets.all(16.0),
      ),
    );
    // Mengosongkan inputan setelah mengirim ulang
    _pinController.clear();
    setState(() {
      _isButtonEnabled = false;
    });
  }

  void _handleConfirmation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PinScreen(mode: PinMode.create),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Desain untuk kotak input (default state)
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
    );

    // Desain untuk kotak input saat sedang diklik/fokus
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF1F5C3A)),
      borderRadius: BorderRadius.circular(8.0),
    );

    // Desain untuk kotak input yang sudah terisi angka
    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8.0),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Row(
              children: [
                Image.asset('assets/images/logo_onboard.png', width: 24),
                const SizedBox(width: 8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATIM',
                      style: TextStyle(
                        color: Color(0xFF1F5C3A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'GADAI',
                      style: TextStyle(
                        color: Color(0xFF1F5C3A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Kode Verifikasi Terkirim!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Kami telah mengirim kode verifikasi ke ',
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        color: Color(0xFF1F5C3A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' melalui Whatsapp. Mohon cek dan masukkan kembali kode verifikasi pada kolom.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  keyboardType: TextInputType.number,
                  onChanged: _validatePin,
                  showCursor: true,
                  cursor: Container(
                    width: 2,
                    height: 24,
                    color: const Color(0xFF1F5C3A),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Konfirmasi',
                onPressed: _isButtonEnabled ? _handleConfirmation : null,
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    children: [
                      const TextSpan(text: 'Belum menerima kode? '),
                      TextSpan(
                        text: 'Kirim Ulang',
                        style: const TextStyle(
                          color: Color(0xFF1F5C3A),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _handleResendCode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
