import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../beranda/beranda_pengunjung_screen.dart';
import '../pinjaman/pinjaman_screen.dart';
import '../simulasi/simulasi_screen.dart';
import '../akun/akun_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  static const _screens = [
    BerandaPengunjungScreen(),
    PinjamanScreen(),
    SimulasiScreen(),
    AkunScreen(),
  ];

  static const _items = [
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
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: _BottomNav(
          currentIndex: _idx,
          items: _items,
          onTap: (i) => setState(() => _idx = i),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label, iconOn, iconOff;
  const _NavItem(this.label, this.iconOn, this.iconOff);
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final int n = items.length;
    final double itemW = w / n;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, -2)),
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
                left: itemW * currentIndex + (itemW - 40) / 2,
                top: 0,
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: List.generate(n, (i) {
                  final bool on = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 6),
                          on
                              ? SvgPicture.asset(
                                  items[i].iconOn,
                                  width: 26,
                                  height: 26,
                                )
                              : SvgPicture.asset(
                                  items[i].iconOff,
                                  width: 26,
                                  height: 26,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFB0B0B0),
                                    BlendMode.srcIn,
                                  ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            items[i].label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight:
                                  on ? FontWeight.w600 : FontWeight.w400,
                              color: on
                                  ? AppColors.primary
                                  : const Color(0xFFB0B0B0),
                            ),
                          ),
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
