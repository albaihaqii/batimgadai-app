import 'package:flutter/material.dart';
import '../../widgets/common/app_placeholder_screen.dart';

class BookingKunjunganScreen extends StatelessWidget {
  const BookingKunjunganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Booking Kunjungan Saya',
      subtitle:
          'Riwayat booking kunjungan ke outlet BATIM GADAI Anda akan tersedia di sini.',
      svgIcon: 'assets/icons/calendar.svg',
    );
  }
}
