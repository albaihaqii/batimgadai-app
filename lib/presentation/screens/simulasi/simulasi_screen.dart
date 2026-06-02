import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../booking/form_booking_screen.dart';
import '../verification/verify_account_screen.dart';
import 'widgets/sim_header.dart';
import 'widgets/step1_widget.dart';
import 'widgets/step2_widget.dart';
import 'widgets/step3_widget.dart';

class SimulasiScreen extends StatefulWidget {
  const SimulasiScreen({super.key});
  @override
  State<SimulasiScreen> createState() => _SimulasiScreenState();
}

class _SimulasiScreenState extends State<SimulasiScreen> {
  int _step = 0;

  String? _katKey;
  int? _harga;
  String _nama = '';

  String? _kondisi;
  final Set<int> _kl = {}, _kc = {};
  List<Map<String, dynamic>> _klList = [], _kcList = [];
  bool _loadingOpts = false;
  String? _optsErr;

  Map<String, dynamic>? _hasil;
  bool _loadingHitung = false;
  String? _hitungErr;

  bool _isNasabah = false;
  String _noCif = '';

  static const _katMap = {
    'handphone': 'Handphone',
    'laptop': 'Laptop',
    'tablet': 'Tablet',
    'elektronik_lainnya': 'Elektronik Lainnya',
    'kendaraan_motor': 'Kendaraan Bermotor',
    'barang_rumah_tangga': 'Barang Rumah Tangga',
    'perhiasan': 'Perhiasan/Emas',
  };

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final isN = await StorageService.getIsNasabah();
    final n = await StorageService.getNasabah();
    if (mounted)
      setState(() {
        _isNasabah = isN;
        _noCif = n?['no_cif'] as String? ?? '';
      });
  }

  Future<void> _loadOpts(String kat) async {
    setState(() {
      _loadingOpts = true;
      _optsErr = null;
    });
    try {
      final d = await ApiService.getSimulasiOptions(kat);
      if (mounted)
        setState(() {
          _klList = List<Map<String, dynamic>>.from(d['kelengkapan'] ?? []);
          _kcList = List<Map<String, dynamic>>.from(d['kecacatan'] ?? []);
          _loadingOpts = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loadingOpts = false;
          _optsErr = 'Gagal memuat data. Coba lagi.';
        });
    }
  }

  Future<void> _hitung() async {
    if (_kondisi == null) return;
    setState(() {
      _loadingHitung = true;
      _hitungErr = null;
    });
    try {
      final d = await ApiService.hitungSimulasi({
        'kategori': _katKey,
        'harga_pasar': _harga,
        'kondisi': _kondisi,
        'kecacatan_ids': _kc.toList(),
        'kelengkapan_id': _kl.isNotEmpty ? _kl.first : null,
      });
      if (mounted)
        setState(() {
          _hasil = d;
          _loadingHitung = false;
          _step = 2;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loadingHitung = false;
          _hitungErr = 'Gagal menghitung estimasi. Coba lagi.';
        });
    }
  }

  void _reset() => setState(() {
        _step = 0;
        _katKey = null;
        _harga = null;
        _nama = '';
        _kondisi = null;
        _kl.clear();
        _kc.clear();
        _klList.clear();
        _kcList.clear();
        _hasil = null;
        _hitungErr = null;
      });

  void _step1Done(String k, int h, String n) async {
    setState(() {
      _katKey = k;
      _harga = h;
      _nama = n;
    });
    await _loadOpts(k);
    if (mounted) setState(() => _step = 1);
  }

  void _step2Done(String kondisi, Set<int> kl, Set<int> kc) {
    setState(() {
      _kondisi = kondisi;
      _kl
        ..clear()
        ..addAll(kl);
      _kc
        ..clear()
        ..addAll(kc);
    });
    _hitung();
  }

  Widget _body() {
    if (_step == 0) {
      return Step1Widget(
          key: const ValueKey(0), kategoriMap: _katMap, onNext: _step1Done);
    }
    if (_step == 1) {
      if (_loadingOpts)
        return const Center(
            key: ValueKey('ld'),
            child: CircularProgressIndicator(
                color: Color(0xFF1F5C3A), strokeWidth: 2));
      if (_optsErr != null)
        return _ErrView(
            key: const ValueKey('er'),
            msg: _optsErr!,
            onRetry: () => _loadOpts(_katKey!));
      return Step2Widget(
        key: const ValueKey(1),
        kelengkapanList: _klList,
        kecacatanList: _kcList,
        kategoriLabel: _katMap[_katKey] ?? '',
        onBack: _reset,
        onNext: _step2Done,
        loading: _loadingHitung,
        error: _hitungErr,
      );
    }
    return Step3Widget(
      key: const ValueKey(2),
      hasil: _hasil ?? {},
      kategoriLabel: _katMap[_katKey] ?? '',
      namaBarang: _nama,
      isNasabah: _isNasabah,
      onHitungUlang: _reset,
      onBooking: () {
        if (_isNasabah) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FormBookingScreen(
                      noCif: _noCif,
                      hasilSimulasi: _hasil,
                      kategori: _katMap[_katKey] ?? '')));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const VerifyAccountScreen()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFFB6D96C),
            statusBarIconBrightness: Brightness.dark),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            SimHeader(step: _step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.03, 0), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: _body(),
              ),
            ),
          ]),
        ),
      );
}

class _ErrView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrView({super.key, required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                child: const Icon(Icons.error_outline,
                    color: Color(0xFFDC2626), size: 28)),
            const SizedBox(height: 14),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF555555))),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6D96C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
              child: const Text('Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A))),
            ),
          ]),
        ),
      );
}
