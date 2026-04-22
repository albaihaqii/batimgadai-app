import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/shared/custom_keypad.dart';
import '../../../../../core/shared/app_colors.dart'; // Sesuaikan path ini

enum PinMode { create, confirm }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? createdPin;

  const PinScreen({super.key, required this.mode, this.createdPin});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  final int _pinLength = 6;
  bool _hasError = false;

  void _onNumberTapped(String number) {
    if (_hasError) {
      setState(() {
        _hasError = false;
      });
    }

    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == _pinLength) {
        Future.delayed(const Duration(milliseconds: 300), _processPin);
      }
    }
  }

  void _onBackspaceTapped() {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _pin = '';
      });
      return;
    }

    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _processPin() {
    if (widget.mode == PinMode.create) {
      context
          .push('/pin', extra: {'mode': PinMode.confirm, 'createdPin': _pin})
          .then((_) {
            setState(() {
              _pin = '';
              _hasError = false;
            });
          });
    } else {
      if (_pin == widget.createdPin) {
        _showLoadingOverlay();
      } else {
        setState(() {
          _hasError = true;
          _pin = '';
        });
      }
    }
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop();
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreate = widget.mode == PinMode.create;

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
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'GADAI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
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
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    Text(
                      isCreate ? 'Buat PIN' : 'Konfirmasi PIN',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      isCreate
                          ? 'Silakan buat PIN 6 digit yang akan digunakan sebagai kode keamanan untuk mengakses aplikasi.'
                          : 'Masukkan kembali 6 digit PIN yang telah dibuat sebelumnya untuk melanjutkan penggunaan aplikasi.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.greyA0,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 64.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pinLength,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 16.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hasError
                                ? AppColors.errorRed
                                : (index < _pin.length
                                      ? AppColors.secondary
                                      : AppColors.greyEB),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: SizedBox(
                        height: 20.h,
                        child: _hasError
                            ? Text(
                                'PIN tidak cocok. Silakan coba lagi.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.errorRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 48.h),
              child: CustomKeypad(
                onNumberTapped: _onNumberTapped,
                onBackspaceTapped: _onBackspaceTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
