import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
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
        String noCif = widget.noCif ?? '';
        if (noCif.isEmpty) {
          final nasabah = await StorageService.getNasabah();
          noCif = nasabah?['no_cif'] as String? ?? '';
        }
        if (noCif.isEmpty) {
          throw Exception('Data nasabah tidak ditemukan. Silakan login ulang.');
        }
        result = await ApiService.getRiwayatNasabah(noCif);
      }

      if (mounted) {
        setState(() {
          _data = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceAll('Exception:', '').trim();
        });
      }
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
        child:
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      );
    }
    if (_error != null) return _buildError();
    if (_data.isEmpty) return _buildEmpty();

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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFFDC2626), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6D96C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A)),
                ),
              ),
            ),
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
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Riwayat',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Riwayat perpanjangan dan pelunasan akan muncul di sini setelah Anda melakukan pembayaran.',
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

  void _showDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(item: item),
    );
  }
}

// ── Riwayat Card ──────────────────────────────────────────────────────────────

class _RiwayatCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool showNoSbg;
  final VoidCallback onTap;

  const _RiwayatCard({
    required this.item,
    required this.showNoSbg,
    required this.onTap,
  });

  static String formatMetode(String m) {
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
      'midtrans': 'Online',
      'tunai': 'Tunai',
      'online': 'Online',
    };
    return map[m.toLowerCase().trim()] ?? m;
  }

  @override
  Widget build(BuildContext context) {
    final tipe = item['tipe']?.toString() ?? '';
    final isPerpanjang = tipe == 'perpanjang';
    final total =
        (double.tryParse(item['total_bayar']?.toString() ?? '0') ?? 0.0)
            .toInt();
    final tgl = item['tgl_bayar']?.toString() ?? '-';
    final metode = item['metode_bayar']?.toString() ?? '-';
    final label = item['tipe_label']?.toString() ?? '-';
    final noSbg = item['no_sbg']?.toString() ?? '';
    final status = item['status_bayar']?.toString() ?? 'berhasil';

    // Warna badge tipe — biru untuk perpanjang, hijau untuk lunasi
    final Color tipeColor =
        isPerpanjang ? const Color(0xFF1D4ED8) : AppColors.primary;
    final Color tipeBg =
        isPerpanjang ? const Color(0xFFDBEAFE) : AppColors.primarySurface;

    // Border kiri — konsisten dengan _PinjamanCard
    final Color borderLeft =
        isPerpanjang ? const Color(0xFF3B82F6) : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Border kiri saja — sama seperti _PinjamanCard agar kompatibel
          // dengan borderRadius (Flutter tidak mendukung borderRadius
          // jika Border memiliki 4 sisi dengan warna berbeda)
          border: Border(left: BorderSide(color: borderLeft, width: 4)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: icon + identitas + badge tipe
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tipeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        isPerpanjang
                            ? Icons.autorenew_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 22,
                        color: tipeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: tipeColor),
                        ),
                        const SizedBox(height: 2),
                        if (showNoSbg && noSbg.isNotEmpty)
                          Text(
                            noSbg,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Color(0xFF9E9E9E)),
                          )
                        else
                          Text(
                            tgl,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Color(0xFF9E9E9E)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge status bayar
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: status == 'berhasil'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF9C3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status == 'berhasil' ? 'Berhasil' : 'Pending',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: status == 'berhasil'
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF854D0E)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Container(height: 1, color: const Color(0xFFF0F0F0)),
              const SizedBox(height: 10),

              // Baris bawah: total bayar + metode + tanggal (jika showNoSbg)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Bayar',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Color(0xFF9E9E9E)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        GadaiModel.formatRupiah(total),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: tipeColor),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMetode(metode),
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      // Jika mode byNasabah, tampilkan tanggal di sini
                      if (showNoSbg)
                        Text(
                          tgl,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Color(0xFF9E9E9E)),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail Bottom Sheet ───────────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  const _DetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final tipe = item['tipe']?.toString() ?? '';
    final isPerpanjang = tipe == 'perpanjang';
    final total =
        (double.tryParse(item['total_bayar']?.toString() ?? '0') ?? 0.0)
            .toInt();
    final tgl = item['tgl_bayar']?.toString() ?? '-';
    final metode = item['metode_bayar']?.toString() ?? '-';
    final label = item['tipe_label']?.toString() ?? '-';
    final orderId = item['order_id']?.toString() ?? '-';
    final noSbg = item['no_sbg']?.toString() ?? '-';
    final tglBaru = item['tgl_jt_baru']?.toString() ?? '';
    final status = item['status_bayar']?.toString() ?? 'berhasil';

    final Color tipeColor =
        isPerpanjang ? const Color(0xFF1D4ED8) : AppColors.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: isPerpanjang
                  ? const Color(0xFFDBEAFE)
                  : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPerpanjang
                  ? Icons.autorenew_rounded
                  : Icons.check_circle_rounded,
              size: 36,
              color: tipeColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tipeColor),
          ),
          const SizedBox(height: 4),
          Text(
            GadaiModel.formatRupiah(total),
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'berhasil'
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status == 'berhasil' ? 'BERHASIL' : 'PENDING',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: status == 'berhasil'
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF854D0E)),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),

          _row('No. SBG', noSbg),
          _row('Tanggal', tgl),
          _row('Metode Bayar', _RiwayatCard.formatMetode(metode)),
          if (isPerpanjang && tglBaru.isNotEmpty && tglBaru != '-')
            _row('Jatuh Tempo Baru', tglBaru, valueColor: AppColors.primary),
          if (orderId != '-') _row('Order ID', orderId),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F5C3A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
