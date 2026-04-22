import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/shared/app_colors.dart';
import '../../../../../core/shared/custom_text_field.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final TextEditingController _ktpController = TextEditingController();
  final TextEditingController _cifController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  void _validateInput() {
    setState(() {
      _isButtonEnabled =
          _ktpController.text.length == 16 && _cifController.text.isNotEmpty;
    });
  }

  void _handleVerify() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/verify-success');
    }
  }

  @override
  void dispose() {
    _ktpController.dispose();
    _cifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.greyE0),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Center(
                child: Image.asset(
                  'assets/images/illust_verify_account.png',
                  height: 180.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 32.h),
              Center(
                child: Text(
                  'Verifikasi Data Akun',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  'Mohon isi nomor KTP dan CIF dengan benar agar\nkami dapat mengenali Anda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.greyA0,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Nomor KTP',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'Masukkan Nomor KTP',
                prefixIconPath: 'assets/icons/icon_ktp.svg',
                controller: _ktpController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _validateInput(),
              ),
              SizedBox(height: 16.h),
              Text(
                'Nomor CIF',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'Masukkan Nomor CIF',
                prefixIconPath: 'assets/icons/icon_cif.svg',
                controller: _cifController,
                keyboardType: TextInputType.text,
                onChanged: (_) => _validateInput(),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8EF),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE8F1D7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Nomor CIF dapat dilihat pada surat yang diberikan ketika selesai memberikan barang gadai (SBG).',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled && !_isLoading
                      ? _handleVerify
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: AppColors.greyEB,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verifikasi Data',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _isButtonEnabled
                                    ? AppColors.primary
                                    : AppColors.greyA0,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward,
                              color: _isButtonEnabled
                                  ? AppColors.primary
                                  : AppColors.greyA0,
                              size: 16.sp,
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
