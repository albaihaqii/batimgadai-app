import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/gadai_model.dart';
import '../../widgets/common/app_green_header.dart';
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
  GadaiModel? _gadai;
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
    try {
      final data = await ApiService.getDetailPinjaman(widget.gadaiId);
      if (mounted)
        setState(() {
          _gadai = data;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  bool _notEmpty(String? s) => s != null && s.isNotEmpty && s != '-';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB6D96C),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            const AppGreenHeader(title: 'Detail Pinjaman'),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2));
    }
    if (_error != null) {
      return _buildError();
    }
    if (_gadai == null) return const SizedBox();
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _buildContent(_gadai!),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF555555))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                foregroundColor: const Color(0xFF1F5C3A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(GadaiModel g) {
    final cfg = GadaiModel.statusConfig(g.status);
    final badgeColor = Color(cfg['color'] as int);
    final badgeBg = Color(cfg['bg'] as int);
    final isLunas = g.status == 'lunas';
    final isWarning = g.sisaHari <= 3 && !isLunas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner warning
        if (isWarning) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    g.sisaHari < 0
                        ? 'Melewati jatuh tempo ${g.sisaHari.abs()} hari. Segera perpanjang atau lunasi.'
                        : g.sisaHari == 0
                            ? 'Pinjaman jatuh tempo hari ini!'
                            : 'Jatuh tempo dalam ${g.sisaHari} hari.',
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
          const SizedBox(height: 12),
        ],

        // Card: Identitas Gadai
        _buildCard('IDENTITAS GADAI', [
          _buildRow('No. SBG', g.noSbg, bold: true),
          _buildRowWidget(
            'Status',
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: badgeBg, borderRadius: BorderRadius.circular(20)),
              child: Text(cfg['label'] as String,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeColor)),
            ),
          ),
          _buildRow('Nasabah', g.namaNasabah ?? '-'),
          _buildRow('Cabang', g.namaCabang),
          if (_notEmpty(g.kodeLoker)) _buildRow('Kode Loker', g.kodeLoker!),
        ]),
        const SizedBox(height: 12),

        // Card: Barang Jaminan
        _buildCard('BARANG JAMINAN', [
          _buildRow('Nama Barang', g.namaDisplay),
          _buildRow('Kategori', GadaiModel.aliasKategori(g.kategoriBarang)),
          if (_notEmpty(g.merk)) _buildRow('Merk', g.merk!),
          if (_notEmpty(g.tipeModel)) _buildRow('Tipe / Model', g.tipeModel!),
          if (_notEmpty(g.kondisiBarang))
            _buildRow('Kondisi', GadaiModel.aliasKondisi(g.kondisiBarang!)),
          if (_notEmpty(g.kelengkapan))
            _buildRow('Kelengkapan', g.kelengkapan!),
          if ((g.nilaiTaksiranMin ?? 0) > 0 && (g.nilaiTaksiranMax ?? 0) > 0)
            _buildRow('Estimasi Nilai',
                '${GadaiModel.formatRupiah(g.nilaiTaksiranMin!)} – ${GadaiModel.formatRupiah(g.nilaiTaksiranMax!)}'),
        ]),
        const SizedBox(height: 12),

        // Card: Rincian Keuangan
        _buildCard('RINCIAN KEUANGAN', [
          _buildRow('Tgl Gadai', g.tglGadai),
          _buildRow('Jatuh Tempo', g.tglJatuhTempoLabel),
          _buildRow('Sisa Waktu', g.sisaHariLabel,
              color: Color(g.sisaHariColorValue)),
          _buildDivider(),
          _buildRow('Nilai Pinjaman', GadaiModel.formatRupiah(g.nilaiPinjaman)),
          _buildRow('Tipe Jasa',
              g.tipeJasa == 'perhiasan' ? 'Perhiasan / Emas' : 'Barang Umum'),
          if (g.jasaPersen15 != null && g.jasaPersen30 != null)
            _buildRow('Rate Jasa',
                '15hr: ${g.jasaPersen15!.toStringAsFixed(1)}%  •  30hr: ${g.jasaPersen30!.toStringAsFixed(1)}%',
                small: true),
          _buildRow('Biaya Jasa (${g.jasaPersen.toStringAsFixed(1)}%)',
              GadaiModel.formatRupiah(g.jasaNominal)),
          _buildDivider(),
          _buildRow('Total Tebus', GadaiModel.formatRupiah(g.totalTebus),
              bold: true, color: AppColors.primary),
        ]),
        const SizedBox(height: 24),

        // Tombol aksi — bertumpuk
        if (!isLunas) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerpanjanganScreen(gadai: g)),
              ).then((_) => _loadData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Perpanjang Gadai',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A))),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PelunasanScreen(gadai: g)),
              ).then((_) => _loadData()),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lunasi Gadai',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
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

        const SizedBox(height: 16),
      ],
    );
  }

  // ─── UI Helpers ─────────────────────────────────────────────

  Widget _buildCard(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF898A8D),
                    letterSpacing: 0.4)),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool bold = false, Color? color, bool small = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: small ? 10 : 12,
                  color: const Color(0xFF9E9E9E))),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: small ? 10 : 12,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: color ?? Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWidget(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E))),
          widget,
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(
      height: 1, indent: 14, endIndent: 14, color: Color(0xFFF0F0F0));
}
