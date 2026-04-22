import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/shared/app_colors.dart';
import '../../home/presentation/home_screen.dart';
import '../../loan/presentation/loan_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Ini daftar halamannya, urutannya sesuai tombol di bawah
  final List<Widget> _pages = [
    const HomeScreen(), // Index 0: Beranda
    const LoanScreen(), // Index 1: Pinjaman
    const Center(child: Text('Halaman Simulasi (Coming Soon)')), // Index 2
    const ProfileScreen(), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_selectedIndex], // Nampilin halaman sesuai yang diklik
      bottomNavigationBar:
          _buildBottomNav(), // Navigasi bawah yang udah perfect
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyA0,
        selectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        items: [
          _buildNavItem(
            inactiveIcon: 'assets/icons/nav_home.svg',
            activeIcon: 'assets/icons/nav_home_active.svg',
            label: 'Beranda',
            index: 0,
          ),
          _buildNavItem(
            inactiveIcon: 'assets/icons/nav_loan.svg',
            activeIcon: 'assets/icons/nav_loan_active.svg',
            label: 'Pinjaman',
            index: 1,
          ),
          _buildNavItem(
            inactiveIcon: 'assets/icons/nav_calc.svg',
            activeIcon: 'assets/icons/nav_calc_active.svg',
            label: 'Simulasi',
            index: 2,
          ),
          _buildNavItem(
            inactiveIcon: 'assets/icons/nav_account.svg',
            activeIcon: 'assets/icons/nav_account_active.svg',
            label: 'Akun',
            index: 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String inactiveIcon,
    required String activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: SvgPicture.asset(
          isActive ? activeIcon : inactiveIcon,
          width: 24.w,
          colorFilter: isActive
              ? null
              : const ColorFilter.mode(AppColors.greyA0, BlendMode.srcIn),
        ),
      ),
      label: label,
    );
  }
}
