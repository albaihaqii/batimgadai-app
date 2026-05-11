import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import 'app_green_header.dart';

class AppPlaceholderScreen extends StatelessWidget {
  final String title, subtitle, svgIcon;
  final Color? iconColor;
  const AppPlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.svgIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppGreenHeader(title: title),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: AppColors.primarySurface, shape: BoxShape.circle),
                  child: Center(
                    child: SvgPicture.asset(svgIcon,
                        width: 36,
                        height: 36,
                        colorFilter: ColorFilter.mode(
                            iconColor ?? AppColors.primary, BlendMode.srcIn),
                        errorBuilder: (_, __, ___) => Icon(Icons.info_outline,
                            size: 36, color: iconColor ?? AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                const SizedBox(height: 8),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                        height: 1.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
