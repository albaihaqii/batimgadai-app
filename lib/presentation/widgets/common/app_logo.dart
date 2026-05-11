import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 34,
          width: 34,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox(width: 34, height: 34),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BATIM',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.15,
                    letterSpacing: 0.5)),
            Text('GADAI',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.15,
                    letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }
}
