import 'package:flutter/material.dart';

class PinDotsWidget extends StatelessWidget {
  final int filled;
  final int total;

  const PinDotsWidget({super.key, required this.filled, this.total = 6});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final bool active = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFFB6D96C) : const Color(0xFFE6EDE2),
          ),
        );
      }),
    );
  }
}
