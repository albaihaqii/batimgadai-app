import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/gadai_model.dart';
import '../../widgets/common/app_green_header.dart';
import '../../widgets/common/app_success_sheet.dart';
import 'midtrans_webview_screen.dart';
import 'riwayat_pembayaran_screen.dart';

class PerpanjanganScreen extends StatefulWidget {
  final GadaiModel gadai;
  const PerpanjanganScreen({super.key, required this.gadai});

  @override
  State<PerpanjanganScreen> createState() => _PerpanjanganScreenState();
}

class _PerpanjanganScreenState extends State<PerpanjanganScreen> {
  bool _loading = false;
  String? _errorMsg;

  GadaiModel get _g => widget.gadai;

  Future<void> _bayarOnline() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final result = await ApiService.getBayarOnlineToken(_g.id, 'perpanjang');

      final snapToken = result['snap_token'] as String;
      final orderId = result['order_id'] as String;
      final jasaNominal = (result['jasa_nominal'] as num).toInt();
      final total = (result['total'] as num).toInt();

      if (!mounted) return;
      setState(() => _loading = false);

      // Buka Midtrans WebView
      final pr = await Navigator.push<PaymentResult>(
        context,
        MaterialPageRoute(
            builder: (_) => MidtransWebViewScreen(
                  snapToken: snapToken,
                  title: 'Perpanjangan Gadai',
                )),
      );

      if (!mounted || pr == null) return;

      if (pr.status == 'success') {
        setState(() {
          _loading = true;
          _errorMsg = null;
        });
        try {
          await ApiService.paymentSuccess(
            gadaiId: _g.id,
            tipe: 'perpanjang',
            orderId: orderId,
            transactionId:
                pr.transactionId.isNotEmpty ? pr.transactionId : orderId,
            paymentType: pr.paymentType.isNotEmpty ? pr.paymentType : 'online',
            jasaNominal: jasaNominal,
            total: total,
          );
          if (mounted) {
            setState(() => _loading = false);
            _showSuccess(orderId, jasaNominal);
          }
        } catch (e) {
          debugPrint('[payment-success] $e');
          if (mounted)
            setState(() {
              _loading = false;
              _errorMsg =
                  'Pembayaran berhasil namun gagal sinkronisasi. Hubungi CS dengan kode: $orderId';
            });
        }
      } else if (pr.status == 'pending') {
        setState(() => _errorMsg =
            'Pembayaran pending. Selesaikan di aplikasi bank Anda.');
      } else {
        setState(() => _errorMsg = 'Pembayaran dibatalkan.');
      }
    } catch (e) {
      debugPrint('[bayar-online] $e');
      if (mounted)
        setState(() {
          _loading = false;
          _errorMsg = 'Terjadi kesalahan: ${e.toString()}';
        });
    }
  }

  void _showSuccess(String orderId, int jasaNominal) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => AppSuccessSheet(
        title: 'Perpanjangan Berhasil!',
        subtitle:
            'Masa gadai ${_g.noSbg} diperpanjang 30 hari.\nJatuh tempo baru telah diperbarui.',
        onOk: () {
          Navigator.pop(context); // tutup sheet
          Navigator.pop(context); // kembali ke detail
          Navigator.pop(context); // kembali ke list
        },
      ),
    );
  }

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
            const AppGreenHeader(title: 'Perpanjangan Gadai'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _card('INFORMASI GADAI', [
                      _row('No. SBG', _g.noSbg),
                      _row('Barang', _g.namaDisplay),
                      _row('Nilai Pinjaman',
                          GadaiModel.formatRupiah(_g.nilaiPinjaman)),
                      _row('JT Saat Ini', _g.tglJatuhTempoLabel),
                      _row('JT Setelah Perpanjang', '+30 hari otomatis',
                          color: AppColors.primary),
                    ]),
                    const SizedBox(height: 12),
                    _card('RINCIAN BIAYA', [
                      _row('Nilai Pinjaman',
                          GadaiModel.formatRupiah(_g.nilaiPinjaman)),
                      _row('Biaya Jasa (${_g.jasaPersen.toStringAsFixed(1)}%)',
                          GadaiModel.formatRupiah(_g.jasaNominal)),
                      const Divider(
                          height: 1,
                          indent: 14,
                          endIndent: 14,
                          color: Color(0xFFF0F0F0)),
                      _row('Total Bayar',
                          GadaiModel.formatRupiah(_g.jasaNominal),
                          bold: true, color: AppColors.primary),
                    ]),
                    const SizedBox(height: 12),
                    _note(
                        'Pembayaran via Midtrans. Transfer bank, e-wallet, QRIS, kartu kredit tersedia.'),
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 12),
                      _errorBox(_errorMsg!),
                    ],
                    const SizedBox(height: 16),
                    // Tombol Riwayat
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RiwayatPembayaranScreen(
                                      gadaiId: _g.id,
                                      noSbg: _g.noSbg,
                                    ))),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 16, color: Color(0xFF555555)),
                            SizedBox(width: 6),
                            Text('Lihat Riwayat Pembayaran',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF555555))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tombol Bayar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _bayarOnline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB6D96C),
                          disabledBackgroundColor:
                              const Color(0xFFB6D96C).withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Color(0xFF1F5C3A)))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.payment_rounded,
                                      color: Color(0xFF1F5C3A), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                      'Bayar ${GadaiModel.formatRupiah(_g.jasaNominal)}',
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F5C3A))),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ]),
      );

  Widget _row(String label, String value, {bool bold = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E))),
          const SizedBox(width: 16),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                      color: color ?? Colors.black))),
        ]),
      );

  Widget _note(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFFEF9C3),
            borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, size: 14, color: Color(0xFF854D0E)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF854D0E),
                      height: 1.5))),
        ]),
      );

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFFDC2626),
                      height: 1.4))),
        ]),
      );
}
