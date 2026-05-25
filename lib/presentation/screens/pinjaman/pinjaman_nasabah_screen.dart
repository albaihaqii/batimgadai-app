import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/gadai_model.dart';
import '../../widgets/common/app_chip_filter.dart';
import 'detail_pinjaman_screen.dart';

class PinjamanNasabahScreen extends StatefulWidget {
  const PinjamanNasabahScreen({super.key});

  @override
  State<PinjamanNasabahScreen> createState() => PinjamanNasabahScreenState();
}

class PinjamanNasabahScreenState extends State<PinjamanNasabahScreen> {
  int _chipIndex = 0;
  bool _loading = true;
  List<GadaiModel> _allData = [];
  String? _error;

  static const _chips = [
    'Semua',
    'Aktif',
    'Jatuh Tempo',
    'Perpanjangan',
    'Lunas'
  ];
  static const _chipStatus = [
    '',
    'aktif',
    'jatuh_tempo',
    'perpanjangan',
    'lunas'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Dipanggil dari HomeScreen saat tab pinjaman di-tap
  void resetAndReload() => _loadData();

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _chipIndex = 0;
    });
    try {
      final nasabah = await StorageService.getNasabah();
      final noCif = nasabah?['no_cif'] as String? ?? '';
      if (noCif.isEmpty) throw Exception('Data nasabah tidak ditemukan');
      final data = await ApiService.getPinjamanNasabah(noCif);
      if (mounted)
        setState(() {
          _allData = data;
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

  List<GadaiModel> get _filtered {
    final status = _chipStatus[_chipIndex];
    if (status.isEmpty) return _allData;
    return _allData.where((p) => p.status == status).toList();
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
            _buildHeader(),
            Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2));
    }
    if (_error != null) return _buildError();
    if (_filtered.isEmpty) return _buildEmpty();
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _PinjamanCard(
          gadai: _filtered[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailPinjamanScreen(gadaiId: _filtered[i].id)),
          ).then((_) => _loadData()),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final isFilter = _chipIndex != 0;
    final chipLabel = _chips[_chipIndex];
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/illustrations/empty_pinjaman.png',
              width: 200,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(width: 200, height: 180),
            ),
            const SizedBox(height: 20),
            Text(
              isFilter ? 'Tidak Ada Pinjaman $chipLabel' : 'Belum Ada Pinjaman',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              isFilter
                  ? 'Tidak ada transaksi gadai dengan status "$chipLabel" saat ini.'
                  : 'Anda belum memiliki transaksi gadai aktif.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFFA0A0A0),
                  height: 1.6),
            ),
          ],
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
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(_error ?? 'Terjadi kesalahan',
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
}

class _PinjamanCard extends StatelessWidget {
  final GadaiModel gadai;
  final VoidCallback onTap;
  const _PinjamanCard({required this.gadai, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cfg = GadaiModel.statusConfig(gadai.status);
    final badgeColor = Color(cfg['color'] as int);
    final badgeBg = Color(cfg['bg'] as int);
    final borderColor = Color(cfg['border'] as int);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F8EF),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: SvgPicture.asset('assets/icons/wallet-bold.svg',
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.account_balance_wallet,
                              size: 22)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gadai.noSbg,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        const SizedBox(height: 2),
                        Text(gadai.namaDisplay,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(cfg['label'] as String,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                      const SizedBox(height: 2),
                      Text(GadaiModel.formatRupiah(gadai.nilaiPinjaman),
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
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
                      const SizedBox(height: 2),
                      Text(gadai.tglJatuhTempoLabel,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const SizedBox(height: 2),
                      Text(gadai.sisaHariLabel,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(gadai.sisaHariColorValue))),
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
