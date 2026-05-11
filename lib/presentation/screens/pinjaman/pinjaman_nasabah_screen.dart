import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../widgets/common/app_chip_filter.dart';
import 'detail_pinjaman_screen.dart';

class PinjamanNasabahScreen extends StatefulWidget {
  final int initialChipIndex;
  const PinjamanNasabahScreen({super.key, this.initialChipIndex = 0});

  @override
  State<PinjamanNasabahScreen> createState() => _PinjamanNasabahScreenState();
}

class _PinjamanNasabahScreenState extends State<PinjamanNasabahScreen> {
  int _chipIndex = 0;
  bool _loading = true;
  List<Map<String, dynamic>> _allData = [];
  String? _error;

  static const _chips = [
    'Semua',
    'Aktif',
    'Jatuh Tempo',
    'Perpanjangan',
    'Lunas',
  ];

  static const _chipStatus = [
    '',
    'aktif',
    'jatuh_tempo',
    'perpanjangan',
    'lunas',
  ];

  @override
  void initState() {
    super.initState();
    _chipIndex = widget.initialChipIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final nasabah = await StorageService.getNasabah();
    final noCif = nasabah?['no_cif'] as String? ?? '';
    if (noCif.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Data nasabah tidak ditemukan';
      });
      return;
    }
    final result = await ApiService.getPinjamanNasabah(noCif);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _allData = List<Map<String, dynamic>>.from(result['data']);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = result['message'] ?? 'Gagal memuat data';
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final status = _chipStatus[_chipIndex];
    if (status.isEmpty) return _allData;
    return _allData.where((p) => p['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB6D96C),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2))
                  : _error != null
                      ? _buildError()
                      : _filtered.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppColors.primary,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                itemCount: _filtered.length,
                                itemBuilder: (_, i) => _PinjamanCard(
                                  data: _filtered[i],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailPinjamanScreen(
                                          gadaiId: _filtered[i]['id']),
                                    ),
                                  ).then((_) => _loadData()),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFB6D96C),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text('Pinjaman',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A))),
            ),
            const SizedBox(height: 12),
            AppChipFilter(
              labels: _chips,
              selected: _chipIndex,
              onSelected: (i) => setState(() => _chipIndex = i),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppColors.primarySurface, shape: BoxShape.circle),
              child: Center(
                child: SvgPicture.asset('assets/icons/wallet-linier.svg',
                    width: 36,
                    height: 36,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Belum Ada Pinjaman',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 8),
            const Text(
              'Tidak ada data pinjaman pada kategori ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(_error ?? 'Terjadi kesalahan',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                elevation: 0),
            child: const Text('Coba Lagi',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PinjamanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _PinjamanCard({required this.data, required this.onTap});

  static const _statusConfig = {
    'aktif': {
      'label': 'Aktif',
      'color': Color(0xFF16A34A),
      'bg': Color(0xFFDCFCE7)
    },
    'perpanjangan': {
      'label': 'Perpanjangan',
      'color': Color(0xFF1D4ED8),
      'bg': Color(0xFFDBEAFE)
    },
    'jatuh_tempo': {
      'label': 'Jatuh Tempo',
      'color': Color(0xFFDC2626),
      'bg': Color(0xFFFEE2E2)
    },
    'lunas': {
      'label': 'Lunas',
      'color': Color(0xFF6B7280),
      'bg': Color(0xFFF3F4F6)
    },
  };

  static const _borderColor = {
    'aktif': Color(0xFF16A34A),
    'perpanjangan': Color(0xFF1D4ED8),
    'jatuh_tempo': Color(0xFFDC2626),
    'lunas': Color(0xFF9CA3AF),
  };

  String _formatRupiah(dynamic value) {
    final n = (value as num).toInt();
    final s = n.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return 'Rp ${result.toString()}';
  }

  String _sisaHariLabel(dynamic sisa) {
    final days = (sisa as num).toInt();
    if (days < 0) return 'Telat ${days.abs()} hari';
    if (days == 0) return 'Jatuh tempo hari ini';
    return '$days hari lagi';
  }

  Color _sisaHariColor(dynamic sisa) {
    final days = (sisa as num).toInt();
    if (days < 0) return const Color(0xFFDC2626);
    if (days <= 3) return const Color(0xFFDC2626);
    if (days <= 7) return const Color(0xFFF97316);
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'aktif';
    final cfg = _statusConfig[status] ?? _statusConfig['aktif']!;
    final borderColor = _borderColor[status] ?? const Color(0xFF16A34A);
    final sisaHari = data['sisa_hari'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Border kiri berwarna sesuai status
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F8EF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/wallet-bold.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.primary, BlendMode.srcIn),
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.account_balance_wallet,
                                    size: 18,
                                    color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['no_sbg'] ?? '-',
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black)),
                                Text(data['nama_barang'] ?? '-',
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cfg['bg'] as Color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(cfg['label'] as String,
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: cfg['color'] as Color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(height: 1, color: const Color(0xFFF0F0F0)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nilai Pinjaman',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF9E9E9E))),
                              Text(_formatRupiah(data['nilai_pinjaman'] ?? 0),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Jatuh Tempo',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF9E9E9E))),
                              if (sisaHari != null)
                                Text(_sisaHariLabel(sisaHari),
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _sisaHariColor(sisaHari))),
                              Text(data['tgl_jatuh_tempo_label'] ?? '-',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF9E9E9E))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
