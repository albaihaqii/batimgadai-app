import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/shared/app_colors.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────────────────────

class _BadgeItem {
  final String iconPath;
  final String label;
  const _BadgeItem({required this.iconPath, required this.label});
}

class _BannerItem {
  final String title;
  final String description;
  final String imagePath;
  final List<_BadgeItem> badges;
  final String ctaText;
  final Color bgColor;

  const _BannerItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.badges,
    required this.ctaText,
    required this.bgColor,
  });
}

// ─────────────────────────────────────────────────────────────
//  Stacked Banner Carousel
// ─────────────────────────────────────────────────────────────

class _StackedBannerCarousel extends StatefulWidget {
  final List<_BannerItem> items;
  const _StackedBannerCarousel({required this.items});

  @override
  State<_StackedBannerCarousel> createState() => _StackedBannerCarouselState();
}

class _StackedBannerCarouselState extends State<_StackedBannerCarousel>
    with SingleTickerProviderStateMixin {
  int _active = 0;
  double _dragX = 0;
  bool _animating = false;
  bool _goNext = true;

  // Controller untuk exit animation
  late final AnimationController _ctrl;
  late Animation<double> _frontX;
  late Animation<double> _frontOpacity;
  late Animation<double> _midScale;
  late Animation<double> _midY;
  late Animation<double> _backScale;
  late Animation<double> _backY;

  // Controller untuk snap-back
  AnimationController? _snapCtrl;

  static const double _threshold = 75.0;
  static const double _cardH =
      158.0; // logical px — disesuaikan sama screenutil

  int get _total => widget.items.length;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _ctrl.addStatusListener(_onExitEnd);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _snapCtrl?.dispose();
    super.dispose();
  }

  void _onExitEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _active = _goNext
            ? (_active + 1) % _total
            : (_active - 1 + _total) % _total;
        _animating = false;
        _dragX = 0;
      });
      _ctrl.reset();
    }
  }

  // Posisi relatif terhadap kartu aktif: 0=depan, 1=tengah, 2=belakang
  int _pos(int idx) => ((idx - _active) + _total) % _total;

  // ── Mulai animasi exit ──────────────────────────────────────

  void _startExit(bool goNext) {
    if (_animating) return;
    _goNext = goNext;

    final progress = (_dragX.abs() / _threshold).clamp(0.0, 1.0);

    _frontX = Tween<double>(
      begin: _dragX,
      end: goNext ? -450.0 : 450.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    _frontOpacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.65)));

    _midScale = Tween<double>(
      begin: 0.93 + progress * 0.07,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _midY = Tween<double>(
      begin: 10.0 * (1 - progress),
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _backScale = Tween<double>(
      begin: 0.87,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _backY = Tween<double>(
      begin: 20.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    setState(() => _animating = true);
    _ctrl.forward(from: 0);
  }

  // ── Snap back ke posisi awal ────────────────────────────────

  void _snapBack() {
    _snapCtrl?.dispose();
    final start = _dragX;
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    final anim = Tween<double>(
      begin: start,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _snapCtrl!, curve: Curves.elasticOut));
    anim.addListener(() {
      if (mounted) setState(() => _dragX = anim.value);
    });
    _snapCtrl!.forward().then((_) {
      _snapCtrl?.dispose();
      _snapCtrl = null;
    });
  }

  // ── Helper transform ────────────────────────────────────────

  Widget _transformed({
    required Widget child,
    required double dx,
    required double dy,
    required double scale,
    required double opacity,
    double rotateZ = 0,
  }) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(dx, dy)
          ..rotateZ(rotateZ)
          ..scale(scale),
        child: child,
      ),
    );
  }

  // ── Build kartu stack ────────────────────────────────────────

  List<Widget> _buildStack() {
    // Urutkan: pos tertinggi (paling belakang) dulu → z-index terendah di Stack
    final sorted =
        List.generate(_total, (i) => i).where((i) => _pos(i) <= 2).toList()
          ..sort((a, b) => _pos(b).compareTo(_pos(a)));

    return sorted.map((idx) {
      final pos = _pos(idx);
      final cardWidget = SizedBox(
        height: _cardH.h,
        child: _buildCard(widget.items[idx]),
      );

      if (_animating) {
        // ── Dalam animasi exit ──
        return AnimatedBuilder(
          animation: _ctrl,
          key: ValueKey(idx),
          builder: (_, __) {
            switch (pos) {
              case 0: // kartu yang sedang pergi
                return _transformed(
                  child: cardWidget,
                  dx: _frontX.value,
                  dy: 0,
                  scale: 1.0 - _ctrl.value * 0.1,
                  opacity: _frontOpacity.value,
                  rotateZ: (_frontX.value / 600) * 0.12,
                );
              case 1: // naik jadi depan
                return _transformed(
                  child: cardWidget,
                  dx: 0,
                  dy: _midY.value,
                  scale: _midScale.value,
                  opacity: 1,
                );
              case 2: // naik jadi tengah
                return _transformed(
                  child: cardWidget,
                  dx: 0,
                  dy: _backY.value,
                  scale: _backScale.value,
                  opacity: 0.85 + _ctrl.value * 0.15,
                );
              default:
                return const SizedBox.shrink();
            }
          },
        );
      } else {
        // ── State idle / drag ──
        final progress = (_dragX.abs() / _threshold).clamp(0.0, 1.0);
        switch (pos) {
          case 0:
            return _transformed(
              child: cardWidget,
              dx: _dragX,
              dy: 0,
              scale: 1.0,
              opacity: 1,
              rotateZ: (_dragX / 600) * 0.12,
            );
          case 1:
            return _transformed(
              child: cardWidget,
              dx: 0,
              dy: 10.0 * (1 - progress),
              scale: 0.93 + progress * 0.07,
              opacity: 1,
            );
          case 2:
            return _transformed(
              child: cardWidget,
              dx: 0,
              dy: 20.0,
              scale: 0.87,
              opacity: 0.85,
            );
          default:
            return const SizedBox.shrink();
        }
      }
    }).toList();
  }

  // ── UI kartu ─────────────────────────────────────────────────

  Widget _buildCard(_BannerItem item) {
    return Container(
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.w, top: 10.h),
            child: Image.asset(
              item.imagePath,
              width: 95.w,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 18.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.white,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  // Badges
                  Row(
                    children: [
                      for (final badge in item.badges) ...[
                        SvgPicture.asset(badge.iconPath, width: 14.w),
                        SizedBox(width: 4.w),
                        Text(
                          badge.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // CTA Button
                  ElevatedButton(
                    onPressed: () {
                      if (item.title == "Verifikasi Akun!") {
                        context.push('/verify-account');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.ctaText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.white,
                          size: 12.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dot indicator ────────────────────────────────────────────

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_total, (i) {
        final isActive = i == _active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: isActive ? 20.0 : 6.0,
          height: 6.0,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFB8C8B8),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // ── Build utama carousel ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          // +20 biar kartu belakang kelihatan menonjol di bawah
          height: _cardH.h + 20.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _animating
                  ? null
                  : (d) => setState(() => _dragX += d.delta.dx),
              onHorizontalDragEnd: _animating
                  ? null
                  : (d) {
                      if (_dragX < -_threshold) {
                        _startExit(true);
                      } else if (_dragX > _threshold) {
                        _startExit(false);
                      } else {
                        _snapBack();
                      }
                    },
              child: Stack(clipBehavior: Clip.none, children: _buildStack()),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildDots(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Home Screen
// ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ── Data banner ──────────────────────────────────────────────
  // Ganti imagePath & badges banner ke-2 dan ke-3 sesuai aset kamu
  static final _banners = [
    _BannerItem(
      title: 'Verifikasi Akun!',
      description:
          'Verifikasi identitas kamu & nikmati semua fitur tanpa batas.',
      imagePath: 'assets/images/illust_verifikasi.png',
      badges: const [
        _BadgeItem(iconPath: 'assets/icons/icon_ktp.svg', label: 'No KTP'),
        _BadgeItem(iconPath: 'assets/icons/icon_cif.svg', label: 'No CIF'),
      ],
      ctaText: 'Mulai Sekarang',
      bgColor: AppColors.secondary,
    ),
    const _BannerItem(
      title: 'Gadai Mudah!',
      description: 'Proses cepat & aman. Dana cair dalam hitungan menit.',
      imagePath:
          'assets/images/illust_verifikasi.png', // TODO: ganti illust_gadai.png
      badges: [
        _BadgeItem(iconPath: 'assets/icons/icon_ktp.svg', label: 'Emas'),
        _BadgeItem(iconPath: 'assets/icons/icon_cif.svg', label: 'BPKB'),
      ],
      ctaText: 'Gadai Sekarang',
      bgColor: Color(0xFF5DCAA5),
    ),
    const _BannerItem(
      title: 'Promo Spesial!',
      description: 'Bunga 0% untuk gadai pertama kamu bulan ini.',
      imagePath:
          'assets/images/illust_verifikasi.png', // TODO: ganti illust_promo.png
      badges: [
        _BadgeItem(iconPath: 'assets/icons/icon_ktp.svg', label: '0% Bunga'),
        _BadgeItem(iconPath: 'assets/icons/icon_cif.svg', label: '30 Hari'),
      ],
      ctaText: 'Klaim Promo',
      bgColor: Color(0xFFFFB74D),
    ),
  ];

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 4.h),
              _StackedBannerCarousel(items: _banners),
              SizedBox(height: 16.h),
              _buildLayananSection(),
              SizedBox(height: 10.h),
              _buildCabangSection(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.greyA0,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Pengunjung Batim Gadai',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          // ── Icon notifikasi ──
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.greyF5,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(8.w),
            child: SvgPicture.asset(
              'assets/icons/icon_notification.svg',
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layanan Kami ──────────────────────────────────────────────
  // FIX: pakai Expanded biar ke-3 item otomatis lurus & sama lebar

  Widget _buildLayananSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan Kami',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 14.h),
          // IntrinsicHeight memastikan semua kartu sama tinggi
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildServiceItem(
                    'assets/images/menu_info.png',
                    'Info Gadai',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildServiceItem(
                    'assets/images/menu_sbg.png',
                    'Lihat SBG',
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildServiceItem(
                    'assets/images/menu_cabang.png',
                    'Cabang Terdekat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String imagePath, String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF6),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8F1D7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 44.w,
            height: 44.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cabang Terdekat ───────────────────────────────────────────

  Widget _buildCabangSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cabang Terdekat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                'Lihat Semua',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildBranchCard(
            context,
            'Batim Gadai Semanggi',
            'Jl. Brantas 2 No.30, Tegal Boto Lor, Sumbersari, Jember',
          ),
          SizedBox(height: 10.h),
          _buildBranchCard(
            context,
            'Batim Gadai Mangli',
            'Jl. Kauman No.92, Karang Mluwo, Mangli, Jember',
          ),
          SizedBox(height: 10.h),
          _buildBranchCard(
            context,
            'Batim Gadai Karimata',
            'Jl. Karimata No.217, Gumuk Kerang, Sumbersari, Jember',
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, String title, String address) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SvgPicture.asset(
              'assets/icons/icon_location_pin.svg',
              width: 22.w,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.greyA0,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 10.sp,
                      color: AppColors.greyA0,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Senin - Sabtu',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.greyA0,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.access_time,
                      size: 10.sp,
                      color: AppColors.greyA0,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '07.00 - 17.00 WIB',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.greyA0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.white,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────
}
