import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppGreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppGreenHeader({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFB6D96C),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset(
          'assets/icons/arrow-left.svg',
          width: 24,
          height: 24,
          colorFilter:
              const ColorFilter.mode(Color(0xFF1F5C3A), BlendMode.srcIn),
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.arrow_back, color: Color(0xFF1F5C3A), size: 24),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F5C3A),
        ),
      ),
    );
  }
}
