import 'package:flutter/material.dart';
import '../../widgets/common/app_placeholder_screen.dart';

class RiwayatPembayaranScreen extends StatelessWidget {
  const RiwayatPembayaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderScreen(
      title: 'Riwayat Pembayaran',
      subtitle:
          'Riwayat transaksi perpanjangan dan pelunasan gadai Anda akan tersedia di sini.',
      svgIcon: 'assets/icons/restart.svg',
      iconColor: Color(0xFF1F5C3A),
    );
  }
}
