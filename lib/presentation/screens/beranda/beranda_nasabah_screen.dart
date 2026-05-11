import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../providers/nasabah_provider.dart';
import '../cabang/cabang_terdekat_screen.dart';
import '../info/info_gadai_screen.dart';
import '../info/cara_gadai_screen.dart';
import '../notifikasi/notifikasi_screen.dart';

class BerandaNasabahScreen extends ConsumerStatefulWidget {
  const BerandaNasabahScreen({super.key});

  @override
  ConsumerState<BerandaNasabahScreen> createState() =>
      _BerandaNasabahScreenState();
}

class _BerandaNasabahScreenState extends ConsumerState<BerandaNasabahScreen> {
  String _phone = '';

  // Data dummy — nanti dari API
  final List<Map<String, dynamic>> _pinjamanAktif = [
    {
      'no_sbg': '2604SMG000001',
      'barang': 'iPhone 13 128GB',
      'status': 'jatuh_tempo',
      'nilai': 6500000,
      'sisa_hari': -3,
    },
  ];

  static const _branches = [
    _Branch('Batim Gadai Semanggi',
        'Jl. Brantas 2 No.30, Tegal Boto Lor, Sumbersari, Jember'),
    _Branch(
        'Batim Gadai Mangli', 'Jl. Kauman No.92, Karang Miuwa, Mangli, Jember'),
    _Branch('Batim Gadai Karimata',
        'Jl. Karimata No.217, Gumuk Kerang, Sumbersari, Jember'),
    _Branch('Batim Gadai Mastrip',
        'Jl. Mastrip No.123, Kebonsari, Sumbersari, Jember'),
    _Branch('Batim Gadai Patrang',
        'Jl. PB Sudirman No.45, Patrang, Sumbersari, Jember'),
  ];

  @override
  void initState() {
    super.initState();
    StorageService.getPhone().then((p) {
      if (mounted && p != null) setState(() => _phone = p);
    });
    ref.read(nasabahProvider.notifier).init();
  }

  bool get _hasJatuhTempo => _pinjamanAktif
      .any((p) => p['status'] == 'jatuh_tempo' || (p['sisa_hari'] as int) <= 3);

  Map<String, dynamic>? get _jtItem => _hasJatuhTempo
      ? _pinjamanAktif.firstWhere(
          (p) => p['status'] == 'jatuh_tempo' || (p['sisa_hari'] as int) <= 3)
      : null;

  @override
  Widget build(BuildContext context) {
    final nasabah = ref.watch(nasabahProvider);
    final nama = nasabah.nama ?? _phone;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: _buildHeader(nama),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _JatuhTempoBanner(
                            hasJatuhTempo: _hasJatuhTempo,
                            item: _jtItem,
                          ),
                          const SizedBox(height: 24),
                          _buildLayanan(context),
                          const SizedBox(height: 24),
                          _buildCabangHeader(context),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _BranchCard(branch: _branches[i]),
                      ),
                      childCount: _branches.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String nama) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Halo, Selamat Datang! 👋',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
              const SizedBox(height: 2),
              Text(
                nama.isNotEmpty ? nama : 'Nasabah',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
          child: const _NotifBell(count: 2),
        ),
      ],
    );
  }

  Widget _buildLayanan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Layanan Kami',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const InfoGadaiScreen())),
                child: const _ServiceCard(
                    icon: 'assets/images/3d-contact.png', label: 'Info Gadai'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CaraGadaiScreen())),
                child: const _ServiceCard(
                    icon: 'assets/images/3d-report.png', label: 'Cara Gadai'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CabangTerdekatScreen())),
                child: const _ServiceCard(
                    icon: 'assets/images/3d-map.png', label: 'Cabang Terdekat'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ FIX: onTap lihat semua → CabangTerdekatScreen
  Widget _buildCabangHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Cabang Kami',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CabangTerdekatScreen())),
          child: const Text('Lihat Semua',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary)),
        ),
      ],
    );
  }
}

// ✅ UPDATE: warna B6D96C, ilustrasi verification.png, button 1F5C3A, hapus icon warning
class _JatuhTempoBanner extends StatelessWidget {
  final bool hasJatuhTempo;
  final Map<String, dynamic>? item;
  const _JatuhTempoBanner({required this.hasJatuhTempo, this.item});

  @override
  Widget build(BuildContext context) {
    // ✅ Warna sama persis dengan _VerifikasiBanner di pengunjung
    const Color c = Color(0xFFB6D96C);
    const double bannerH = 130.0;
    const double bannerTop = 20.0;
    const double ringW = 122.0;
    const double ringH = 38.0;
    const double btnW = 114.0;
    const double btnH = 30.0;
    const double ringTop = bannerTop + bannerH - ringH / 2;
    const double cutY = bannerH - ringH / 2;
    const double wrapH = ringTop + ringH / 2 + 4;

    final int sisaHari = item?['sisa_hari'] as int? ?? 0;
    final String barang = item?['barang'] as String? ?? '-';
    final String titleText = sisaHari < 0
        ? 'Telat ${sisaHari.abs()} Hari!'
        : 'Jatuh Tempo $sisaHari Hari Lagi!';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double bw = constraints.maxWidth;
        final double scale = bw / 353.0;
        final double ringLeft = 172.0 * scale;
        final double scaledRingW = ringW * scale;
        final double scaledBtnW = btnW * scale;
        final double layer2W = bw * 0.87;
        final double layer3W = bw * 0.74;
        final double layer2H = bannerH + (bannerTop - 10);
        final double layer3H = layer2H;

        return GestureDetector(
          onTap: () {},
          child: SizedBox(
            height: wrapH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Layer 3 — paling belakang, opacity 20%
                Positioned(
                  left: (bw - layer3W) / 2,
                  top: 0,
                  child: Container(
                    width: layer3W,
                    height: layer3H,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Layer 2 — tengah, opacity 60%
                Positioned(
                  left: (bw - layer2W) / 2,
                  top: 10,
                  child: Container(
                    width: layer2W,
                    height: layer2H,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Layer 1 — banner utama, full color B6D96C
                Positioned(
                  left: 0,
                  top: bannerTop,
                  child: CustomPaint(
                    painter: _SubtractPainter(
                      w: bw,
                      h: bannerH,
                      r: 20,
                      cutX: ringLeft,
                      cutY: cutY,
                      cutW: scaledRingW,
                      cutH: ringH,
                      cutR: 14,
                      color: c,
                    ),
                    child: SizedBox(
                      width: bw,
                      height: bannerH,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ✅ Ilustrasi verification.png, hapus icon warning
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                            child: Image.asset(
                              'assets/images/illustrations/verification.png',
                              width: bw * 0.28,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (_, __, ___) =>
                                  SizedBox(width: bw * 0.28),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 18, 14, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // ✅ Judul tanpa emoji ⚠️
                                  Text(titleText,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(barang,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10,
                                          color: Colors.white,
                                          height: 1.45)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tombol Bayar Sekarang
                Positioned(
                  left: ringLeft,
                  top: ringTop,
                  child: Container(
                    width: scaledRingW,
                    height: ringH,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Container(
                      width: scaledBtnW,
                      height: btnH,
                      // ✅ Warna button 1F5C3A
                      decoration: BoxDecoration(
                          color: const Color(0xFF1F5C3A),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bayar Sekarang',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SubtractPainter extends CustomPainter {
  final double w, h, r, cutX, cutY, cutW, cutH, cutR;
  final Color color;
  const _SubtractPainter({
    required this.w,
    required this.h,
    required this.r,
    required this.cutX,
    required this.cutY,
    required this.cutW,
    required this.cutH,
    required this.cutR,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final banner = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), Radius.circular(r)));
    final cut = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(cutX, cutY, cutW, cutH), Radius.circular(cutR)));
    canvas.drawPath(Path.combine(PathOperation.difference, banner, cut),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SubtractPainter o) => o.color != color || o.w != w;
}

class _NotifBell extends StatelessWidget {
  final int count;
  const _NotifBell({required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
              color: Color(0xFFF4F8EF), shape: BoxShape.circle),
          child: Center(
            child: SvgPicture.asset('assets/icons/bell.svg',
                width: 22,
                height: 22,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: Colors.black)),
          ),
        ),
        if (count > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                  color: Color(0xFFE53935), shape: BoxShape.circle),
              child: Center(
                child: Text(count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String icon, label;
  const _ServiceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8EF),
        border: Border.all(color: const Color(0xFFDCE8CF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Image.asset(icon,
            width: 32,
            height: 32,
            errorBuilder: (_, __, ___) => const Icon(Icons.category_outlined,
                size: 32, color: AppColors.primary)),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
      ]),
    );
  }
}

class _Branch {
  final String name, address;
  const _Branch(this.name, this.address);
}

class _BranchCard extends StatelessWidget {
  final _Branch branch;
  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: const Color(0xFFB6D96C),
              borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: SvgPicture.asset('assets/icons/location.svg',
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(branch.name,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              const SizedBox(height: 2),
              Text(branch.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF9E9E9E))),
              const SizedBox(height: 5),
              const Row(children: [
                _InfoRow(
                    svg: 'assets/icons/calendar.svg', text: 'Senin - Sabtu'),
                SizedBox(width: 10),
                _InfoRow(
                    svg: 'assets/icons/clock-linier.svg',
                    text: '07.00 - 17.00 WIB'),
              ]),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.chevron_right, color: Colors.white, size: 13),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String svg, text;
  const _InfoRow({required this.svg, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(svg,
            width: 11,
            height: 11,
            colorFilter:
                const ColorFilter.mode(Color(0xFF9E9E9E), BlendMode.srcIn)),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 10, color: Color(0xFF9E9E9E))),
      ],
    );
  }
}
