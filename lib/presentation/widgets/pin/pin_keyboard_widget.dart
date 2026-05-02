import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PinKeyboardWidget extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;

  const PinKeyboardWidget({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
  });

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row
                      .map((key) => _Key(
                            label: key,
                            onTap: key == 'del'
                                ? onBackspace
                                : key.isEmpty
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        onKeyTap(key);
                                      },
                          ))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }
}

class _Key extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  const _Key({required this.label, this.onTap});

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label.isEmpty) {
      return const SizedBox(width: 72, height: 72);
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
        onTapUp: widget.onTap != null
            ? (_) async {
                await _ctrl.reverse();
                widget.onTap!();
              }
            : null,
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: widget.label == 'del'
                ? Colors.transparent
                : const Color(0xFFF4F8EF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: widget.label == 'del'
                ? SvgPicture.asset(
                    'assets/icons/backspace.svg',
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1F5C3A),
                      BlendMode.srcIn,
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
