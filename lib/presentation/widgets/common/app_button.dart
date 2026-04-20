import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const AppButton({
    super.key,
    required this.label,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? const Color(0xFFB6D96C) : const Color(0xFFDBDBDB),
          foregroundColor:
              enabled ? const Color(0xFF1F5C3A) : const Color(0xFF263238),
          disabledBackgroundColor: const Color(0xFFDBDBDB),
          disabledForegroundColor: const Color(0xFF263238),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
