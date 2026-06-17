import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../beranda/beranda_pengunjung_screen.dart';
import '../beranda/beranda_nasabah_screen.dart';
import '../pinjaman/pinjaman_screen.dart';
import '../pinjaman/pinjaman_nasabah_screen.dart';
import '../simulasi/simulasi_screen.dart';
import '../akun/akun_screen.dart';
import '../akun/akun_nasabah_screen.dart';
import '../verification/verify_account_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isNasabah;
  const HomeScreen({super.key, this.isNasabah = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _modalVisible = false;
  late bool _isNasabah;

  final _pinjamanKey = GlobalKey<PinjamanScreenState>();
  final _pinjamanNasabahKey = GlobalKey<PinjamanNasabahScreenState>();
  final _akunNasabahKey = GlobalKey<AkunNasabahScreenState>();

  static const List<_NavItem> _navItems = [
    _NavItem('Beranda', 'assets/icons/home-bold.svg',
        'assets/icons/home-linier.svg'),
    _NavItem('Pinjaman', 'assets/icons/wallet-bold.svg',
        'assets/icons/wallet-linier.svg'),
    _NavItem('Simulasi', 'assets/icons/calculator-bold.svg',
        'assets/icons/calculator-linier.svg'),
    _NavItem(
        'Akun', 'assets/icons/user-bold.svg', 'assets/icons/user-linier.svg'),
  ];

  @override
  void initState() {
    super.initState();
    _isNasabah = widget.isNasabah;
  }

  List<Widget> get _screens => [
        _isNasabah
            ? const BerandaNasabahScreen()
            : const BerandaPengunjungScreen(),
        _isNasabah
            ? PinjamanScreen(
                key: _pinjamanKey,
                isNasabah: true,
                pinjamanNasabahKey: _pinjamanNasabahKey,
              )
            : PinjamanScreen(key: _pinjamanKey, isNasabah: false),
        const SimulasiScreen(),
        _isNasabah
            ? AkunNasabahScreen(key: _akunNasabahKey, onTabSwitch: _onNavTap)
            : const AkunScreen(),
      ];

  void _onNavTap(int index) {
    if (index == 3 && _currentIndex == 3 && _isNasabah) {
      _akunNasabahKey.currentState?.resetScroll();
      return;
    }

    // Reset chip pinjaman saat tap tab pinjaman
    if (index == 1 && _isNasabah) {
      _pinjamanNasabahKey.currentState?.resetAndReload();
    }

    if (index == 1 && !_isNasabah) {
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = index;
        _modalVisible = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pinjamanKey.currentState?.showPengunjungModal(
          onVerifikasi: () {
            Navigator.pop(context);
            setState(() => _modalVisible = false);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VerifyAccountScreen()),
            ).then((_) {
              if (mounted) setState(() => _currentIndex = _previousIndex);
            });
          },
          onNantiSaja: () {
            Navigator.pop(context);
            setState(() {
              _modalVisible = false;
              _currentIndex = _previousIndex;
            });
          },
        );
      });
      return;
    }

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _modalVisible ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _currentIndex,
          items: _navItems,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

class _NavItem {
  final String label, iconActive, iconInactive;
  const _NavItem(this.label, this.iconActive, this.iconInactive);
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  const _BottomNavBar(
      {required this.currentIndex, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int count = items.length;
    final double itemWidth = screenWidth / count;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                left: itemWidth * currentIndex + (itemWidth - 40) / 2,
                top: 0,
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: List.generate(count, (i) {
                  final bool isActive = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 6),
                          isActive
                              ? SvgPicture.asset(items[i].iconActive,
                                  width: 26,
                                  height: 26,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.circle,
                                      size: 26,
                                      color: AppColors.primary))
                              : SvgPicture.asset(items[i].iconInactive,
                                  width: 26,
                                  height: 26,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFFB0B0B0), BlendMode.srcIn),
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.circle_outlined,
                                      size: 26,
                                      color: Color(0xFFB0B0B0))),
                          const SizedBox(height: 4),
                          Text(items[i].label,
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? AppColors.primary
                                      : const Color(0xFFB0B0B0))),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
