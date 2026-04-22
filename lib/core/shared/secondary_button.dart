import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart'; // Sesuaikan path ini jika beda folder

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // Default background putih
          backgroundColor: backgroundColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.greyF5,
          disabledForegroundColor: AppColors.greyA0,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(
              // Default border abu-abu
              color: borderColor ?? AppColors.greyE0,
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // Default teks hitam
            color: textColor ?? AppColors.black,
          ),
        ),
      ),
    );
  }
}
