import 'package:flutter/material.dart';
import '../auth/phone_input_screen.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingData {
  final String illustration, title, subtitle;
  const _OnboardingData({
    required this.illustration,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      illustration: 'assets/images/illustrations/onboarding_1.png',
      title: 'Gadai Aman &\nTerpercaya',
      subtitle:
          'Solusi keuangan cepat dan aman dengan proses transparan serta jaminan perlindungan terbaik untuk setiap barang yang Anda gadaikan tanpa khawatir risiko.',
    ),
    _OnboardingData(
      illustration: 'assets/images/illustrations/onboarding_2.png',
      title: 'Proses Cepat &\nMudah',
      subtitle:
          'Ajukan gadai secara online hanya dalam 3 langkah sederhana, tanpa proses rumit, sehingga pengajuan dapat dilakukan kapan saja dan di mana saja.',
    ),
    _OnboardingData(
      illustration: 'assets/images/illustrations/onboarding_3.png',
      title: 'Pencairan\nDana Instan',
      subtitle:
          'Setelah pengajuan disetujui, dana tunai akan langsung ditransfer ke rekening Anda dengan cepat untuk membantu memenuhi kebutuhan finansial segera.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PhoneInputScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  void _prevPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final double sh = MediaQuery.of(context).size.height;
    final double illustrationH = sh * 0.38;
    final double pageViewH = illustrationH + 36 + 6 + 36 + 78 + 10 + 72;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png',
                    width: 36, height: 36, fit: BoxFit.contain),
                const SizedBox(width: 8),
                const Text(
                  'BATIM\nGADAI',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: pageViewH,
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: illustrationH,
                        width: double.infinity,
                        child: Image.asset(_pages[i].illustration,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (d) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 18,
                            height: 6,
                            decoration: BoxDecoration(
                              color: d == _currentPage
                                  ? const Color(0xFF1F5C3A)
                                  : const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        _pages[i].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _pages[i].subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF757575),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _currentPage == 0 ? _goToLogin : _prevPage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray500,
                    elevation: 0,
                    side:
                        const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _currentPage == 0 ? 'Lewati' : 'Kembali',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
