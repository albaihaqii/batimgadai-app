import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/gadai_model.dart';
import '../../widgets/common/app_green_header.dart';

enum _RiwayatMode { byGadai, byNasabah }

class RiwayatPembayaranScreen extends StatefulWidget {
  final int? gadaiId;
  final String? noSbg;
  final String? noCif;

  const RiwayatPembayaranScreen({
    super.key,
    this.gadaiId,
    this.noSbg,
    this.noCif,
  });

  @override
  State<RiwayatPembayaranScreen> createState() =>
      _RiwayatPembayaranScreenState();
}

class _RiwayatPembayaranScreenState extends State<RiwayatPembayaranScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];
  String? _error;

  _RiwayatMode get _mode =>
      widget.gadaiId != null ? _RiwayatMode.byGadai : _RiwayatMode.byNasabah;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<Map<String, dynamic>> result;
      if (_mode == _RiwayatMode.byGadai) {
        result = await ApiService.getRiwayatPembayaran(widget.gadaiId!);
      } else {
        result = await ApiService.getRiwayatNasabah(widget.noCif ?? '');
      }
      if (mounted)
        setState(() {
          _data = result;
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

  String get _title {
    if (_mode == _RiwayatMode.byGadai && widget.noSbg != null) {
      return 'Riwayat — ${widget.noSbg}';
    }
    return 'Riwayat Pembayaran';
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
            AppGreenHeader(title: _title),
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
      return Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Coba Lagi',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F5C3A))),
          ),
        ]),
      ));
    }
    if (_data.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: AppColors.primarySurface, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Belum Ada Riwayat',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const SizedBox(height: 8),
          const Text(
            'Riwayat pembayaran perpanjangan dan pelunasan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF9E9E9E),
                height: 1.5),
          ),
        ]),
      ));
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _data.length,
        itemBuilder: (_, i) => _RiwayatCard(
          item: _data[i],
          showNoSbg: _mode == _RiwayatMode.byNasabah,
          onTap: () => _showDetail(_data[i]),
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(item: item),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool showNoSbg;
  final VoidCallback onTap;
  const _RiwayatCard({
    required this.item,
    required this.showNoSbg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPerpanjang = item['tipe'] == 'perpanjang';
    final total = (item['total_bayar'] as num?)?.toInt() ?? 0;
    final tgl = item['tgl_bayar'] as String? ?? '-';
    final metode = item['metode_bayar'] as String? ?? '-';
    final label = item['tipe_label'] as String? ?? '-';
    final noSbg = item['no_sbg'] as String? ?? '';

    final Color badgeBg =
        isPerpanjang ? const Color(0xFFDBEAFE) : AppColors.primarySurface;
    final Color badgeColor =
        isPerpanjang ? const Color(0xFF1D4ED8) : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeColor)),
              ),
              if (showNoSbg && noSbg.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(noSbg,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF9E9E9E))),
              ],
              const Spacer(),
              Text(tgl,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF9E9E9E))),
            ]),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Bayar',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(GadaiModel.formatRupiah(total),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Metode',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(_fmtMetode(metode),
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ]),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Icon(Icons.chevron_right,
                  size: 14, color: Color(0xFF9E9E9E)),
              const Text('Tap untuk detail',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF9E9E9E))),
            ]),
          ]),
        ),
      ),
    );
  }

  static String _fmtMetode(String m) {
    const map = {
      'bca_va': 'BCA Virtual Account',
      'bni_va': 'BNI Virtual Account',
      'bri_va': 'BRI Virtual Account',
      'mandiri_va': 'Mandiri Virtual Account',
      'permata_va': 'Permata Virtual Account',
      'gopay': 'GoPay',
      'shopeepay': 'ShopeePay',
      'qris': 'QRIS',
      'credit_card': 'Kartu Kredit',
      'online': 'Online',
    };
    return map[m.toLowerCase().trim()] ?? m.toUpperCase();
  }
}

// Detail sheet mirip mobile banking
class _DetailSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  const _DetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPerpanjang = item['tipe'] == 'perpanjang';
    final total = (item['total_bayar'] as num?)?.toInt() ?? 0;
    final tgl = item['tgl_bayar'] as String? ?? '-';
    final metode = item['metode_bayar'] as String? ?? '-';
    final label = item['tipe_label'] as String? ?? '-';
    final orderId = item['order_id'] as String? ?? '-';
    final noSbg = item['no_sbg'] as String? ?? '-';
    final tglBaru = item['tgl_jt_baru'] as String? ?? '';
    final status = item['status_bayar'] as String? ?? 'berhasil';

    final Color badgeColor =
        isPerpanjang ? const Color(0xFF1D4ED8) : AppColors.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),

          // Icon sukses
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.primarySurface, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: badgeColor)),
          const SizedBox(height: 4),
          Text(GadaiModel.formatRupiah(total),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20)),
            child: Text(status.toUpperCase(),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A))),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),

          // Detail rows
          _row('No. SBG', noSbg),
          _row('Tanggal', tgl),
          _row('Metode Bayar', _RiwayatCard._fmtMetode(metode)),
          if (isPerpanjang && tglBaru.isNotEmpty && tglBaru != '-')
            _row('JT Baru', tglBaru, valueColor: AppColors.primary),
          _row('Order ID', orderId),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF9E9E9E))),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black))),
      ]),
    );
  }
}
