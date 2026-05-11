import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/common/app_chip_filter.dart';
import '../../widgets/common/app_bottom_sheet.dart';
import 'pinjaman_nasabah_screen.dart';

class PinjamanScreen extends StatefulWidget {
  final bool isNasabah;
  const PinjamanScreen({super.key, this.isNasabah = false});

  @override
  State<PinjamanScreen> createState() => PinjamanScreenState();
}

class PinjamanScreenState extends State<PinjamanScreen> {
  int _chipIndex = 0;
  bool _modalVisible = false;

  static const List<String> _chips = [
    'Semua Pinjaman',
    'Aktif',
    'Jatuh Tempo',
    'Perpanjangan',
    'Lunas',
  ];

  void showPengunjungModal({
    required VoidCallback onVerifikasi,
    required VoidCallback onNantiSaja,
  }) {
    setState(() => _modalVisible = true);
    AppBottomSheet.show(
      context: context,
      isDismissible: false,
      enableDrag: false,
      child: AppBottomSheetContent(
        child: _PengunjungModalContent(
          onVerifikasi: () {
            setState(() => _modalVisible = false);
            onVerifikasi();
          },
          onNantiSaja: () {
            setState(() => _modalVisible = false);
            onNantiSaja();
          },
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _modalVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNasabah) {
      return const PinjamanNasabahScreen();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _modalVisible ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            const Expanded(child: _EmptyPinjaman()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFB6D96C),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Text(
              'Pinjaman',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F5C3A)),
            ),
            const SizedBox(height: 14),
            AppChipFilter(
              labels: _chips,
              selected: _chipIndex,
              onSelected: (i) => setState(() => _chipIndex = i),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _EmptyPinjaman extends StatelessWidget {
  const _EmptyPinjaman();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/illustrations/empty_pinjaman.png',
              width: 220,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(width: 220, height: 200),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Pinjaman Aktif',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kamu belum memiliki transaksi gadai. Yuk, mulai gadaikan barangmu ke outlet sekarang!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFFA0A0A0),
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _PengunjungModalContent extends StatelessWidget {
  final VoidCallback onVerifikasi;
  final VoidCallback onNantiSaja;
  const _PengunjungModalContent(
      {required this.onVerifikasi, required this.onNantiSaja});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
              color: Color(0xFFF4F8EF), shape: BoxShape.circle),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/lock-linier.svg',
              width: 32,
              height: 32,
              colorFilter:
                  const ColorFilter.mode(Color(0xFF1F5C3A), BlendMode.srcIn),
              errorBuilder: (_, __, ___) => const Icon(Icons.lock_outline,
                  size: 32, color: Color(0xFF1F5C3A)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Fitur Khusus Nasabah',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verifikasi akun Anda untuk mengakses daftar pinjaman, SBG, dan riwayat transaksi.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFFA0A0A0),
              height: 1.6),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onVerifikasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB6D96C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/verified.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF1F5C3A), BlendMode.srcIn),
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: Color(0xFF1F5C3A)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Verifikasi Sekarang',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onNantiSaja,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
