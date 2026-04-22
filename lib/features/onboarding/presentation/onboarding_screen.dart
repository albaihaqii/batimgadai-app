import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../models/onboarding_info.dart';
import '../../../../../core/shared/app_colors.dart';
import '../../../../../core/shared/primary_button.dart';
import '../../../../../core/shared/secondary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingInfo> _onboardingItems = [
    OnboardingInfo(
      image: 'assets/images/onboard_1.png',
      title: 'Gadai Aman &\nTerpercaya',
      description:
          'Solusi keuangan cepat dan aman dengan proses transparan serta jaminan perlindungan terbaik untuk setiap barang yang Anda gadaikan tanpa khawatir risiko.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboard_2.png',
      title: 'Proses Cepat &\nMudah',
      description:
          'Dapatkan dana tunai dalam hitungan menit. Persyaratan mudah dan tidak berbelit-belit, langsung cair ke rekening Anda hari ini juga.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboard_3.png',
      title: 'Bunga Ringan &\nFleksibel',
      description:
          'Nikmati tarif jasa pinjaman yang kompetitif dengan jangka waktu yang dapat disesuaikan dengan kemampuan finansial Anda.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _onboardingItems.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_onboard.png', height: 32.h),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BATIM',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'GADAI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingItems.length,
                    itemBuilder: (context, index) {
                      final item = _onboardingItems[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 40.h),
                            SizedBox(
                              height: 250.h,
                              child: Image.asset(
                                item.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 64.h),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                    height: 1.2,
                                  ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColors.greyA0,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 318.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 6.h,
                          width: _currentPage == index ? 18.w : 6.h,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : AppColors.greyEB,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  PrimaryButton(
                    text: isLastPage ? 'Mulai' : 'Lanjut',
                    onPressed: _nextPage,
                  ),
                  SizedBox(height: 12.h),
                  if (!isLastPage)
                    SecondaryButton(text: 'Lewati', onPressed: _navigateToLogin)
                  else
                    SizedBox(height: 50.h),
                ],
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
