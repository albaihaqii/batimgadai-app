import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/shared/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu sangat muda
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Akun',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // ── Header Profil (Card Nama) ──
            _buildProfileHeader(),
            SizedBox(height: 20.h),

            // ── Row Statistik (Total Transaksi & Status) ──
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Transaksi',
                    '12',
                    Icons.receipt_long_rounded,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildStatusCard(
                    'Status Akun',
                    'Aktif',
                    Icons.verified_user_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ── Menu List ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.history_rounded,
                    'Riwayat Pembayaran',
                    isFirst: true,
                  ),
                  _buildMenuItem(
                    Icons.event_note_rounded,
                    'Booking Kunjungan Saya',
                  ),
                  _buildMenuItem(
                    Icons.notifications_none_rounded,
                    'Notifikasi',
                  ),
                  _buildMenuItem(Icons.password_rounded, 'Ganti PIN'),
                  _buildMenuItem(
                    Icons.info_outline_rounded,
                    'Tentang Aplikasi',
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // ── Tombol Keluar ──
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFC62828),
                  size: 20.sp,
                ),
                label: Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC62828),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC62828)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColors.greyEB,
            backgroundImage: const AssetImage(
              'assets/images/avatar_placeholder.png',
            ), // Ganti sesuai aset lu
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User3987',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'CIF: 1234567890',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.greyA0),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: const Color(0xFF2E7D32),
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Terverifikasi',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyA0),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: Colors.blue, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.greyA0),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF2E7D32),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.greyEB, width: 1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.greyA0,
          size: 20.sp,
        ),
        onTap: () {},
      ),
    );
  }
}
