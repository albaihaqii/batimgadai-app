import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart'; // Sesuaikan path ini jika beda folder

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String prefixIconPath;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIconPath,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontSize: 16.sp, color: AppColors.black),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16.sp,
          color: AppColors.greyA0,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(12.w),
          child: SvgPicture.asset(
            prefixIconPath,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
            width: 20.w,
            height: 20.h,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.greyE0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.greyE0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5, // Ditebelin dikit pas lagi diklik biar mantap
          ),
        ),
      ),
    );
  }
}
