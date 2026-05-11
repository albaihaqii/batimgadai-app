import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';

class SimulasiScreen extends StatelessWidget {
  const SimulasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB6D96C),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: const Color(0xFFB6D96C),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: const Text(
                      'Simulasi',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F5C3A)),
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SimulasiIcon(),
                      SizedBox(height: 20),
                      Text(
                        'Simulasi Gadai',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fitur simulasi estimasi nilai gadai sedang dalam pengembangan dan akan segera tersedia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulasiIcon extends StatelessWidget {
  const _SimulasiIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/calculator-linier.svg',
          width: 36,
          height: 36,
          colorFilter:
              const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          errorBuilder: (_, __, ___) => const Icon(Icons.calculate_outlined,
              size: 36, color: AppColors.primary),
        ),
      ),
    );
  }
}
