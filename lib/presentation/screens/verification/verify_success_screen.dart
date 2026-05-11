import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/nasabah_provider.dart';
import '../home/home_screen.dart';

class VerifySuccessScreen extends ConsumerWidget {
  final Map<String, dynamic> nasabahData;
  const VerifySuccessScreen({super.key, required this.nasabahData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 1.5),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.black, size: 24),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Image.asset(
                    'assets/images/illustrations/verify_data.png',
                    width: 200,
                    height: 197,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 200, height: 197),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Selamat! Anda telah\nTerverifikasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.35),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Silahkan nikmati fitur lengkap yang telah kami\nsediakan untuk Anda!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFA0A0A0),
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(nasabahProvider.notifier)
                          .save(nasabahData);
                      await ref.read(authProvider.notifier).setNasabah(true);
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen(isNasabah: true)),
                        (_) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB6D96C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Masuk ke Beranda Nasabah',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F5C3A))),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF1F5C3A), size: 18),
                      ],
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
