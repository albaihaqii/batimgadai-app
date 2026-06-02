import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/cabang_model.dart';
import '../cabang/cabang_terdekat_screen.dart';
import '../cabang/detail_cabang_screen.dart';
import '../info/info_gadai_screen.dart';
import '../info/cara_gadai_screen.dart';
import '../notifikasi/notifikasi_screen.dart';
import '../verification/verify_account_screen.dart';

class BerandaPengunjungScreen extends StatefulWidget {
  const BerandaPengunjungScreen({super.key});

  @override
  State<BerandaPengunjungScreen> createState() =>
      _BerandaPengunjungScreenState();
}

class _BerandaPengunjungScreenState extends State<BerandaPengunjungScreen> {
  String _phone = '';
  List<Map<String, dynamic>> _banners = [];
  List<CabangModel> _cabang = [];
  bool _loadingBanner = true;
  bool _loadingCabang = true;
  int _notifCount = 0;

  final PageController _pageCtrl = PageController();
  int _bannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    StorageService.getPhone().then((p) {
      if (mounted && p != null) setState(() => _phone = p);
    });
    _loadBanners();
    _loadCabang();
    _loadNotifCount();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final data = await ApiService.getBanners();
      if (mounted) {
        setState(() {
          _banners = data;
          _loadingBanner = false;
        });
        _startBannerTimer();
      }
    } catch (_) {
      if (mounted) setState(() => _loadingBanner = false);
    }
  }

  Future<void> _loadCabang() async {
    try {
      final data = await ApiService.getCabang();
      if (mounted) {
        setState(() {
          _cabang = data.take(5).toList();
          _loadingCabang = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCabang = false);
    }
  }

  Future<void> _loadNotifCount() async {
    try {
      // Pengunjung — notif info umum (no_cif kosong)
      final data = await ApiService.getNotifikasi('');
      if (mounted) {
        setState(() {
          _notifCount = data.where((n) => n['is_read'] == false).length;
        });
      }
    } catch (_) {}
  }

  void _startBannerTimer() {
    if (_banners.length <= 1) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _banners.isEmpty) return;
      final next = (_bannerPage + 1) % _banners.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: _buildHeader(context),
          ),
          Expanded(
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _VerifikasiBanner(),
                      const SizedBox(height: 24),
                      _buildLayanan(context),
                      const SizedBox(height: 20),
                      _BannerSlider(
                        banners: _banners,
                        loading: _loadingBanner,
                        pageCtrl: _pageCtrl,
                        currentPage: _bannerPage,
                        onPageChanged: (p) => setState(() => _bannerPage = p),
                      ),
                      const SizedBox(height: 24),
                      _buildCabangHeader(context),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _loadingCabang
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2),
                        ),
                      ),
                    )
                  : _cabang.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                            child: _EmptyCabang(),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: _CabangCardBeranda(
                                cabang: _cabang[i],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailCabangScreen(cabang: _cabang[i]),
                                  ),
                                ),
                              ),
                            ),
                            childCount: _cabang.length,
                          ),
                        ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Halo, Selamat Datang! 👋',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black)),
            const SizedBox(height: 2),
            Text(_phone.isNotEmpty ? _phone : 'Pengunjung',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
          ]),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
          child: _NotifBell(count: _notifCount),
        ),
      ],
    );
  }

  Widget _buildLayanan(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Layanan Kami',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black)),
      const SizedBox(height: 12),
      Row(children: [
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
      ]),
    ]);
  }

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

// ── Banner Verifikasi ─────────────────────────────────────────────────────────

class _VerifikasiBanner extends StatelessWidget {
  const _VerifikasiBanner();

  @override
  Widget build(BuildContext context) {
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

    return LayoutBuilder(builder: (context, constraints) {
      final bw = constraints.maxWidth;
      final scale = bw / 353.0;
      final ringLeft = 172.0 * scale;
      final scaledRingW = ringW * scale;
      final scaledBtnW = btnW * scale;
      final layer2W = bw * 0.87;
      final layer3W = bw * 0.74;
      final layer2H = bannerH + (bannerTop - 10);

      return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VerifyAccountScreen())),
        child: SizedBox(
          height: wrapH,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: (bw - layer3W) / 2,
              top: 0,
              child: Container(
                width: layer3W,
                height: layer2H,
                decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            Positioned(
              left: (bw - layer2W) / 2,
              top: 10,
              child: Container(
                width: layer2W,
                height: layer2H,
                decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
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
                    color: c),
                child: SizedBox(
                  width: bw,
                  height: bannerH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                        child: Image.asset(
                          'assets/images/illustrations/verification.png',
                          width: bw * 0.30,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              SizedBox(width: bw * 0.30),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 18, 14, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Verifikasi Akun!',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const SizedBox(height: 4),
                              const Text(
                                  'Verifikasi identitas kamu & nikmati semua fitur.',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Colors.white,
                                      height: 1.45)),
                              const SizedBox(height: 10),
                              const Row(children: [
                                _BadgeInfo(
                                    icon: 'assets/icons/card-linier.svg',
                                    label: 'No KTP'),
                                SizedBox(width: 6),
                                _BadgeInfo(
                                    icon: 'assets/icons/cif-linier.svg',
                                    label: 'No CIF'),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: ringLeft,
              top: ringTop,
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VerifyAccountScreen())),
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
                    decoration: BoxDecoration(
                        color: const Color(0xFF1F5C3A),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Mulai Sekarang',
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
            ),
          ]),
        ),
      );
    });
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

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

class _BadgeInfo extends StatelessWidget {
  final String icon, label;
  const _BadgeInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SvgPicture.asset(icon,
              width: 12,
              height: 12,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ]),
      );
}

class _ServiceCard extends StatelessWidget {
  final String icon, label;
  const _ServiceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
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

class _BannerSlider extends StatelessWidget {
  final List<Map<String, dynamic>> banners;
  final bool loading;
  final PageController pageCtrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _BannerSlider({
    required this.banners,
    required this.loading,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14)),
        child: const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(children: [
      SizedBox(
        height: 80,
        child: PageView.builder(
          controller: pageCtrl,
          onPageChanged: onPageChanged,
          itemCount: banners.length,
          itemBuilder: (_, i) {
            final b = banners[i];
            final fotoUrl = (b['foto_url'] ?? b['foto']) as String?;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFF3F4F6),
                image: fotoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(fotoUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: fotoUrl == null
                  ? Center(
                      child: Text(b['judul'] ?? '',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)))
                  : null,
            );
          },
        ),
      ),
      if (banners.length > 1) ...[
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    ]);
  }
}

class _CabangCardBeranda extends StatelessWidget {
  final CabangModel cabang;
  final VoidCallback onTap;
  const _CabangCardBeranda({required this.cabang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: const Color(0xFFB6D96C),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: SvgPicture.asset('assets/icons/store.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.primary, BlendMode.srcIn),
                  errorBuilder: (_, __, ___) => const Icon(Icons.store_rounded,
                      size: 22, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cabang.nama,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              const SizedBox(height: 2),
              Text(cabang.alamat,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF9E9E9E))),
              const SizedBox(height: 5),
              Row(children: [
                SvgPicture.asset('assets/icons/calendar.svg',
                    width: 11,
                    height: 11,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF9E9E9E), BlendMode.srcIn)),
                const SizedBox(width: 4),
                Text(cabang.hariBuka,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF9E9E9E))),
                const SizedBox(width: 10),
                SvgPicture.asset('assets/icons/clock-linier.svg',
                    width: 11,
                    height: 11,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF9E9E9E), BlendMode.srcIn)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('${cabang.jamBuka}–${cabang.jamTutup} WIB',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Color(0xFF9E9E9E))),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child:
                const Icon(Icons.chevron_right, color: Colors.white, size: 14),
          ),
        ]),
      ),
    );
  }
}

class _EmptyCabang extends StatelessWidget {
  const _EmptyCabang();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: const Row(children: [
          Icon(Icons.store_outlined, color: Color(0xFFCCCCCC), size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text('Data cabang belum tersedia.',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E))),
          ),
        ]),
      );
}
