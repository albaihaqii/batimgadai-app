import 'package:flutter/material.dart';
import '../../widgets/common/app_placeholder_screen.dart';

class CabangTerdekatScreen extends StatelessWidget {
  const CabangTerdekatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Cabang Terdekat',
      subtitle:
          'Fitur pencarian cabang terdekat menggunakan GPS sedang dalam pengembangan.',
      svgIcon: 'assets/icons/location.svg',
    );
  }
}
