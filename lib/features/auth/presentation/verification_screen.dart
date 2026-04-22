import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/shared/primary_button.dart';

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
      _isButtonEnabled = pin.length == 6;
    });
  }

  Future<void> _verifyOtp(String pin) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1F5C3A)),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) context.pop();

    if (pin == '123456') {
      if (mounted) {
        context.push('/pin', extra: 'create');
      }
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.red, size: 40.sp),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Kode Tidak Valid',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Kode OTP yang Anda masukkan salah atau\ntelah kedaluwarsa. Silakan coba lagi.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                SizedBox(height: 24.h),
                TextButton(
                  onPressed: () {
                    context.pop();
                    _pinController.clear();
                    _pinFocusNode.requestFocus();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Coba Lagi',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleResendCode() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  color: const Color(0xFF1F5C3A),
                  size: 56.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Kode Terkirim!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Kode verifikasi baru telah dikirim ulang ke WhatsApp Anda.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 24.h),
                PrimaryButton(text: 'Tutup', onPressed: () => context.pop()),
              ],
            ),
          ),
        );
      },
    );

    _pinController.clear();
    setState(() {
      _isButtonEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 60.h,
      textStyle: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontSize: 22.sp),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF1F5C3A)),
      borderRadius: BorderRadius.circular(8.r),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8.r),
      color: const Color(0xFFF2F7F2),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: Row(
              children: [
                Image.asset('assets/images/logo_onboard.png', width: 24.w),
                SizedBox(width: 8.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATIM',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'GADAI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
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
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(
                'Kode Verifikasi Terkirim!',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontSize: 24.sp),
              ),
              SizedBox(height: 12.h),
              RichText(
                text: TextSpan(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  children: [
                    const TextSpan(
                      text: 'Kami telah mengirim kode verifikasi ke ',
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1F5C3A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' melalui Whatsapp. Mohon cek dan masukkan kembali kode verifikasi pada kolom berikut.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _validatePin,
                  onCompleted: _verifyOtp,
                  showCursor: true,
                  cursor: Container(
                    width: 2.w,
                    height: 24.h,
                    color: const Color(0xFF1F5C3A),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              PrimaryButton(
                text: 'Konfirmasi',
                onPressed: _isButtonEnabled
                    ? () => _verifyOtp(_pinController.text)
                    : null,
              ),
              SizedBox(height: 24.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Belum menerima kode? '),
                      TextSpan(
                        text: 'Kirim Ulang',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF1F5C3A),
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
