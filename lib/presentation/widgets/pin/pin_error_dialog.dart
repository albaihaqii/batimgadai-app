import 'package:flutter/material.dart';

class PinErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onClose;

  const PinErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onClose,
  });

  @override
  State<PinErrorDialog> createState() => _PinErrorDialogState();
}

class _PinErrorDialogState extends State<PinErrorDialog>
    with TickerProviderStateMixin {
  late final AnimationController _dialogCtrl;
  late final AnimationController _rippleCtrl;
  late final AnimationController _iconCtrl;
  late final Animation<double> _dialogScale;
  late final Animation<double> _dialogFade;
  late final Animation<double> _r1Scale;
  late final Animation<double> _r1Opacity;
  late final Animation<double> _r2Scale;
  late final Animation<double> _r2Opacity;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _dialogCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _dialogScale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOutBack));
    _dialogFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _dialogCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut)));

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _r1Scale = Tween<double>(begin: 0.6, end: 2.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _r1Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _r2Scale = Tween<double>(begin: 0.6, end: 2.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOut)));
    _r2Opacity = Tween<double>(begin: 0.35, end: 0.0).animate(CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOut)));

    _iconCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _iconScale = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack));

    _dialogCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _rippleCtrl.forward();
      _iconCtrl.forward();
    });
  }

  @override
  void dispose() {
    _dialogCtrl.dispose();
    _rippleCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Widget _buildRipple(Animation<double> scale, Animation<double> opacity) {
    return AnimatedBuilder(
      animation: _rippleCtrl,
      builder: (_, __) => Transform.scale(
        scale: scale.value,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD32F2F).withValues(alpha: opacity.value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _dialogFade,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ScaleTransition(
          scale: _dialogScale,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRipple(_r2Scale, _r2Opacity),
                      _buildRipple(_r1Scale, _r1Opacity),
                      ScaleTransition(
                        scale: _iconScale,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFFD32F2F), size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      height: 1.65),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      foregroundColor: const Color(0xFFD32F2F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
