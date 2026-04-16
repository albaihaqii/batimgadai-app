import 'package:flutter/material.dart';
import '../models/onboarding_info.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingInfo> _onboardingData = [
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
          'Ajukan gadai secara online hanya dalam 3 langkah sederhana, tanpa proses rumit, sehingga pengajuan dapat dilakukan kapan saja dan di mana saja.',
    ),
    OnboardingInfo(
      image: 'assets/images/onboard_3.png',
      title: 'Pencairan\nDana Instan',
      description:
          'Setelah pengajuan disetujui, dana tunai akan langsung ditransfer ke rekening Anda dengan cepat untuk membantu memenuhi kebutuhan finansial segera.',
    ),
  ];

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildLogo(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(_onboardingData[index]);
                },
              ),
            ),
            _buildDotIndicator(),
            _buildBottomControls(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo_onboard.png', width: 32),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BATIM',
              style: TextStyle(
                color: Color(0xFF1F5C3A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
            Text(
              'GADAI',
              style: TextStyle(
                color: Color(0xFF1F5C3A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageContent(OnboardingInfo data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data.image, height: 300, fit: BoxFit.contain),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _onboardingData.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: 8.0,
            width: _currentIndex == index ? 24.0 : 8.0,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? const Color(0xFF1F5C3A)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          PrimaryButton(
            text: _currentIndex == 2 ? 'Mulai' : 'Lanjut',
            onPressed: _currentIndex == 2 ? _finishOnboarding : _nextPage,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            text: _currentIndex == 0 ? 'Lewati' : 'Kembali',
            onPressed: _currentIndex == 0 ? _finishOnboarding : _previousPage,
          ),
        ],
      ),
    );
  }
}
