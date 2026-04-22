import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart'; // Sesuaikan path ini jika beda folder

class CustomKeypad extends StatelessWidget {
  final Function(String) onNumberTapped;
  final VoidCallback onBackspaceTapped;

  const CustomKeypad({
    super.key,
    required this.onNumberTapped,
    required this.onBackspaceTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        SizedBox(height: 16.h),
        _buildRow(context, ['4', '5', '6']),
        SizedBox(height: 16.h),
        _buildRow(context, ['7', '8', '9']),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 72.w, height: 72.w),
            _buildButton(context, '0'),
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: IconButton(
                onPressed: onBackspaceTapped,
                icon: Icon(
                  Icons.backspace_outlined,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) => _buildButton(context, num)).toList(),
    );
  }

  Widget _buildButton(BuildContext context, String number) {
    return InkWell(
      onTap: () => onNumberTapped(number),
      borderRadius: BorderRadius.circular(36.r),
      child: Container(
        width: 72.w,
        height: 72.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.greyF5, // Narik dari Gudang Warna
          shape: BoxShape.circle,
        ),
        child: Text(
          number,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
