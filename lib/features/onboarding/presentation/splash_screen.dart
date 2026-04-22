import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/shared/app_colors.dart'; // Sesuaikan path ini

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: _isVisible
                    ? 1.0
                    : 0.90, // Efek zoom-in dibikin lebih kalem (0.90)
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutBack,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Pastikan path ini benar
                      width: 56.w, // Ukuran logo di-adjust biar proporsional
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BATIM',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontSize: 26.sp, // Ukuran diturunin biar elegan
                                fontWeight: FontWeight
                                    .w800, // Ketebalan diturunin 1 tingkat
                                height: 1.0,
                                letterSpacing: 1.0,
                              ),
                        ),
                        Text(
                          'GADAI',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontSize: 26.sp, // Ukuran diturunin biar elegan
                                fontWeight: FontWeight
                                    .w800, // Ketebalan diturunin 1 tingkat
                                height: 1.0,
                                letterSpacing: 1.0,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.h),
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeIn,
                child: Text(
                  'v1.0.26',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.greyA0, // Pakai abu-abu kalem
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
