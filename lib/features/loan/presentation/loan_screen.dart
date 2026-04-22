import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/shared/app_colors.dart';
import '../domain/loan_model.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Aktif', 'Lunas'];

  Color _getStatusColor(LoanStatus status) {
    return status == LoanStatus.aktif
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE57373);
  }

  String _formatRupiah(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    List<LoanItem> filteredLoans = dummyLoans.where((loan) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Aktif') return loan.status == LoanStatus.aktif;
      if (_selectedFilter == 'Lunas') return loan.status == LoanStatus.lunas;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pinjaman',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: AppColors.secondary.withOpacity(0.4),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected ? AppColors.primary : AppColors.greyA0,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.greyE0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredLoans.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada pinjaman ${_selectedFilter == 'Semua' ? '' : _selectedFilter}",
                      style: TextStyle(
                        color: AppColors.greyA0,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(24.w),
                    itemCount: filteredLoans.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      final loan = filteredLoans[index];
                      return _buildLoanCard(context, loan);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanItem loan) {
    return GestureDetector(
      onTap: () {
        context.push('/loan-detail', extra: loan);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE8F1D7)),
              ),
              child: Icon(loan.icon, color: AppColors.primary, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${loan.category} ${loan.productName}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(loan.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          loan.status == LoanStatus.aktif ? 'Aktif' : 'Lunas',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(loan.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Nilai Pinjaman',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.greyA0),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatRupiah(loan.loanAmount),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
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
                        'Jatuh Tempo:',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.greyA0,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        loan.dueDate,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: AppColors.greyA0, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
