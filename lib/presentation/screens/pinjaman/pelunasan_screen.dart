import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/common/app_success_sheet.dart';

class PelunasanScreen extends StatefulWidget {
  final int gadaiId;
  final Map<String, dynamic> data;
  const PelunasanScreen({super.key, required this.gadaiId, required this.data});

  @override
  State<PelunasanScreen> createState() => _PelunasanScreenState();
}

class _PelunasanScreenState extends State<PelunasanScreen> {
  bool _loading = false;

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

  Future<void> _bayarTunai() async {
    setState(() => _loading = true);
    final result = await ApiService.lunasiTunai(widget.gadaiId);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['success'] == true) {
      _showSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Gagal memproses',
                style: const TextStyle(fontFamily: 'Poppins'))),
      );
    }
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => AppSuccessSheet(
        title: 'Pelunasan Berhasil',
        subtitle: 'Barang gadai Anda dapat diambil di outlet BATIM GADAI.',
        onOk: () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final nilaiPinjaman = (d['nilai_pinjaman'] as num?)?.toInt() ?? 0;
    final jasaNominal = (d['jasa_nominal'] as num?)?.toInt() ?? 0;
    final totalTebus = (d['total_tebus'] as num?)?.toInt() ?? 0;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDCE8CF)),
                      ),
                      child: Column(
                        children: [
                          _buildRow('No. SBG', d['no_sbg'] ?? '-'),
                          _buildRow('Barang', d['nama_barang'] ?? '-'),
                          _buildRow('Tgl Gadai', d['tgl_gadai'] ?? '-'),
                          _buildRow(
                              'Jatuh Tempo', d['tgl_jatuh_tempo_label'] ?? '-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rincian Pelunasan',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                          const SizedBox(height: 10),
                          _buildRow(
                              'Pokok Pinjaman', _formatRupiah(nilaiPinjaman)),
                          _buildRow('Biaya Jasa (${d['jasa_persen'] ?? 0}%)',
                              _formatRupiah(jasaNominal)),
                          const Divider(height: 16, color: Color(0xFFE0E0E0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Tebus',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              Text(_formatRupiah(totalTebus),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Pilih Metode Pembayaran',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _bayarTunai,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Text('Bayar Tunai di Outlet',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pembayaran online segera hadir.',
                                    style: TextStyle(fontFamily: 'Poppins'))),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Bayar Online via Midtrans',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
              ),
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
              const Expanded(
                child: Text('Pelunasan Gadai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F5C3A))),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E))),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
        ],
      ),
    );
  }
}
