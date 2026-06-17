import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/storage_service.dart';
import '../../../providers/nasabah_provider.dart';
import '../auth/phone_input_screen.dart';
import '../info/info_gadai_screen.dart';
import '../info/cara_gadai_screen.dart';
import '../info/faq_screen.dart';
import '../info/hubungi_kami_screen.dart';
import '../info/tentang_aplikasi_screen.dart';
import '../pinjaman/riwayat_pembayaran_screen.dart';
import '../booking/booking_screen.dart';
import 'data_pribadi_screen.dart';
import 'ganti_pin_lama_screen.dart';

class AkunNasabahScreen extends ConsumerStatefulWidget {
  final Function(int)? onTabSwitch;
  const AkunNasabahScreen({super.key, this.onTabSwitch});

  @override
  ConsumerState<AkunNasabahScreen> createState() => AkunNasabahScreenState();
}

class AkunNasabahScreenState extends ConsumerState<AkunNasabahScreen> {
  bool _dialogVisible = false;
  final ScrollController _scrollController = ScrollController();

  static const _menuProfil = [
    _MenuItem('assets/icons/user-bold.svg', 'Data Pribadi'),
  ];

  static const _menuTransaksi = [
    _MenuItem('assets/icons/wallet-bold.svg', 'Pinjaman Aktif Saya'),
    _MenuItem('assets/icons/restart.svg', 'Riwayat Pembayaran'),
    _MenuItem('assets/icons/calendar-bold.svg', 'Booking Kunjungan Saya'),
  ];

  static const _menuKeamanan = [
    _MenuItem('assets/icons/lock-keyhole.svg', 'Ganti PIN'),
  ];

  static const _menuInformasi = [
    _MenuItem('assets/icons/contract.svg', 'Info Gadai'),
    _MenuItem('assets/icons/refresh-circle.svg', 'Cara Gadai'),
    _MenuItem('assets/icons/tag-price.svg', 'FAQ'),
    _MenuItem('assets/icons/phone-bold.svg', 'Hubungi Kami'),
    _MenuItem('assets/icons/restart.svg', 'Tentang Aplikasi'),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onMenuTap(BuildContext context, String label) async {
    switch (label) {
      case 'Data Pribadi':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DataPribadiScreen()));
        break;

      case 'Pinjaman Aktif Saya':
        widget.onTabSwitch?.call(1);
        break;

      case 'Riwayat Pembayaran':
        final nasabah = ref.read(nasabahProvider);
        String noCif = nasabah.noCif ?? '';
        if (noCif.isEmpty) {
          final stored = await StorageService.getNasabah();
          noCif = stored?['no_cif'] as String? ?? '';
        }
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RiwayatPembayaranScreen(noCif: noCif),
          ),
        );
        break;

      case 'Booking Kunjungan Saya':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BookingScreen()));
        break;

      case 'Ganti PIN':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GantiPinLamaScreen()));
        break;

      case 'Info Gadai':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InfoGadaiScreen()));
        break;

      case 'Cara Gadai':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CaraGadaiScreen()));
        break;

      case 'FAQ':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FaqScreen()));
        break;

      case 'Hubungi Kami':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HubungiKamiScreen()));
        break;

      case 'Tentang Aplikasi':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TentangAplikasiScreen()));
        break;
    }
  }

  void _showLogout() {
    setState(() => _dialogVisible = true);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => _LogoutDialog(
        onTidak: () {
          Navigator.pop(context);
          setState(() => _dialogVisible = false);
        },
        onYa: () async {
          Navigator.pop(context);
          await StorageService.setIsNasabah(false);
          await StorageService.saveNasabah({});
          ref.read(nasabahProvider.notifier).clear();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
            (_) => false,
          );
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _dialogVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nasabah = ref.watch(nasabahProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0xFFB6D96C),
        statusBarIconBrightness:
            _dialogVisible ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── FIXED: Header hijau + banner mengambang di garis bawah ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(nasabah),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -26,
                  child: _buildBanner(),
                ),
              ],
            ),
            // Ruang untuk setengah bagian bawah banner yang menonjol
            const SizedBox(height: 26),
            // ── SCROLLABLE: Menu Sections (clips di batas atas) ─────────
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('PROFIL'),
                      const SizedBox(height: 8),
                      _buildMenuGroup(context, _menuProfil),
                      const SizedBox(height: 16),
                      _sectionLabel('TRANSAKSI'),
                      const SizedBox(height: 8),
                      _buildMenuGroup(context, _menuTransaksi),
                      const SizedBox(height: 16),
                      _sectionLabel('KEAMANAN'),
                      const SizedBox(height: 8),
                      _buildMenuGroup(context, _menuKeamanan),
                      const SizedBox(height: 16),
                      _sectionLabel('INFORMASI'),
                      const SizedBox(height: 8),
                      _buildMenuGroup(context, _menuInformasi),
                      const SizedBox(height: 16),
                      _buildLogoutButton(),
                      const SizedBox(height: 16),
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

  Widget _buildHeader(NasabahState nasabah) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFB6D96C),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 52),
          child: Column(
            children: [
              const SizedBox(
                height: 36,
                child: Center(
                  child: Text(
                    'Akun',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F5C3A)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFEAF3E1), width: 4),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/user-bold.svg',
                    width: 38,
                    height: 38,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF1F5C3A), BlendMode.srcIn),
                    errorBuilder: (_, __, ___) => const Icon(Icons.person,
                        size: 38, color: Color(0xFF1F5C3A)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                nasabah.nama ?? 'Nasabah',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                nasabah.noCif ?? '',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF555555)),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9EDB3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/verified.svg',
                      width: 13,
                      height: 13,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF1F5C3A), BlendMode.srcIn),
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.verified,
                          size: 13,
                          color: Color(0xFF1F5C3A)),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Nasabah Terverifikasi',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F5C3A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return GestureDetector(
      onTap: () => widget.onTabSwitch?.call(1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F5C3A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/wallet-linier.svg',
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 24,
                  color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pinjaman Aktif Saya',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pantau semua pinjaman Anda secara realtime.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF898A8D),
          letterSpacing: 0.3),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          items.length,
          (i) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuTile(
                item: items[i],
                onTap: () => _onMenuTap(context, items[i].label),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFFE0E0E0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _showLogout,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE53935),
          overlayColor: const Color(0xFFFFEBEE),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/logout.svg',
              width: 18,
              height: 18,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFE53935), BlendMode.srcIn),
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.logout, size: 18, color: Color(0xFFE53935)),
            ),
            const SizedBox(width: 8),
            const Text(
              'Keluar',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }
}

// Supporting Classes

class _MenuItem {
  final String icon, label;
  const _MenuItem(this.icon, this.label);
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;
  const _MenuTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8EF),
                borderRadius: BorderRadius.circular(9),
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                item.icon,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.circle, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1F5C3A), size: 18),
          ],
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  final VoidCallback onTidak, onYa;
  const _LogoutDialog({required this.onTidak, required this.onYa});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/illustrations/logout.png',
              width: 150,
              height: 175,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(width: 150, height: 175),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keluar dari Akun?',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dengan menekan Ya, Anda akan keluar dari akun ini. Pastikan semua aktivitas sudah selesai sebelum melanjutkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  height: 1.6),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onTidak,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFE0E0E0), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onYa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB6D96C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F5C3A)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
