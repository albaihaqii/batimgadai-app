import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import 'perpanjangan_screen.dart';
import 'pelunasan_screen.dart';

class DetailPinjamanScreen extends StatefulWidget {
  final int gadaiId;
  const DetailPinjamanScreen({super.key, required this.gadaiId});

  @override
  State<DetailPinjamanScreen> createState() => _DetailPinjamanScreenState();
}

class _DetailPinjamanScreenState extends State<DetailPinjamanScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.getDetailPinjaman(widget.gadaiId);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _data = result['data'] as Map<String, dynamic>;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = result['message'];
      });
    }
  }

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
            _buildHeader(context),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2))
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _data == null
                          ? const SizedBox()
                          : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFB6D96C),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/chevron-left.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF1F5C3A), BlendMode.srcIn),
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF1F5C3A),
                          size: 24),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _data?['no_sbg'] ?? 'Detail Pinjaman',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A)),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    final status = d['status'] as String? ?? 'aktif';
    final cfg = _statusConfig[status] ?? _statusConfig['aktif']!;
    final sisaHari = (d['sisa_hari'] as num?)?.toInt() ?? 0;
    final isLunas = status == 'lunas';
    final isJatuhTempo = status == 'jatuh_tempo' || sisaHari <= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          if (isJatuhTempo && !isLunas)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sisaHari < 0
                          ? 'Pinjaman telat ${sisaHari.abs()} hari. Segera lakukan perpanjangan atau pelunasan.'
                          : 'Pinjaman jatuh tempo ${sisaHari == 0 ? "hari ini" : "dalam $sisaHari hari"}.',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Color(0xFFDC2626),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

          // Info barang
          _buildSection('Informasi Barang', [
            _buildRow('No. SBG', d['no_sbg'] ?? '-'),
            _buildRow('Nama Barang', d['nama_barang'] ?? '-'),
            _buildRow('Kategori', d['kategori_barang'] ?? '-'),
            _buildRow('Status', '',
                badge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                )),
            _buildRow('Kode Loker', d['kode_loker'] ?? '-'),
            _buildRow('Cabang', d['nama_cabang'] ?? '-'),
          ]),

          const SizedBox(height: 12),

          // Info keuangan
          _buildSection('Rincian Keuangan', [
            _buildRow('Tgl Gadai', d['tgl_gadai'] ?? '-'),
            _buildRow('Jatuh Tempo', d['tgl_jatuh_tempo_label'] ?? '-'),
            _buildRow(
                'Nilai Pinjaman', _formatRupiah(d['nilai_pinjaman'] ?? 0)),
            _buildRow('Jasa (${d['jasa_persen'] ?? 0}%)',
                _formatRupiah(d['jasa_nominal'] ?? 0)),
            _buildRow('Total Tebus', _formatRupiah(d['total_tebus'] ?? 0),
                bold: true, color: AppColors.primary),
          ]),

          const SizedBox(height: 24),

          // Tombol aksi
          if (!isLunas) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PerpanjanganScreen(gadaiId: d['id'], data: d),
                      ),
                    ).then((_) => _loadData()),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Perpanjang',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PelunasanScreen(gadaiId: d['id'], data: d),
                      ),
                    ).then((_) => _loadData()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Lunasi',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('✅ Pinjaman Sudah Lunas',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF898A8D),
                    letterSpacing: 0.3)),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool bold = false, Color? color, Widget? badge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E))),
          badge ??
              Text(value,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                      color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
