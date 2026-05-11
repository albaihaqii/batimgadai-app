import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_green_header.dart';

class InfoGadaiScreen extends StatelessWidget {
  const InfoGadaiScreen({super.key});

  static const _layanan = [
    _Layanan('assets/icons/box-minimalistic.svg', 'Gadai Barang Elektronik',
        'Handphone & Smartphone, Laptop & Komputer/PC, Tablet & Perangkat Elektronik Lainnya.'),
    _Layanan('assets/icons/scale.svg', 'Gadai Barang Bergerak',
        'Peralatan rumah tangga bernilai, perlengkapan kamar & furnitur, dan barang lain yang memiliki nilai ekonomis.'),
    _Layanan('assets/icons/id-card.svg', 'Gadai Kendaraan Bermotor',
        'Kendaraan dengan BPKB dan unit kendaraan. BPKB tanpa unit kendaraan tidak dapat digadaikan.'),
  ];

  // Kategori pakai emoji, tanpa SVG icon
  static const _kategori = [
    _Kategori('📱', 'Handphone'),
    _Kategori('💻', 'Laptop'),
    _Kategori('📟', 'Tablet'),
    _Kategori('🖥️', 'Elektronik Lainnya'),
    _Kategori('🛵', 'Motor + BPKB'),
    _Kategori('🛋️', 'Barang Rumah'),
    _Kategori('💍', 'Perhiasan / Emas'),
  ];

  static const _ratesUmum = [
    _Rate('Rp 0 – Rp 99.999', '10%', '10%'),
    _Rate('Rp 100.000 – Rp 1.999.999', '5%', '8%'),
    _Rate('Rp 2.000.000 – Rp 2.999.999', '4%', '7%'),
    _Rate('Rp 3.000.000 – Rp 4.999.999', '4%', '6%'),
    _Rate('Rp 5.000.000+', '3%', '5%'),
  ];

  static const _ratesPerhiasan = [
    _Rate('Rp 100.000+', '2.5%', '5%'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppGreenHeader(title: 'Info Gadai'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('LAYANAN GADAI KAMI'),
              const SizedBox(height: 8),
              _card(
                  children: List.generate(
                      _layanan.length,
                      (i) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LayananTile(layanan: _layanan[i]),
                              if (i < _layanan.length - 1)
                                const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 14,
                                    endIndent: 14,
                                    color: Color(0xFFE0E0E0)),
                            ],
                          ))),
              const SizedBox(height: 20),
              _label('KATEGORI BARANG DITERIMA'),
              const SizedBox(height: 8),
              _card(
                  children: List.generate(
                      _kategori.length,
                      (i) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _KategoriTile(kategori: _kategori[i]),
                              if (i < _kategori.length - 1)
                                const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 14,
                                    endIndent: 14,
                                    color: Color(0xFFE0E0E0)),
                            ],
                          ))),
              const SizedBox(height: 20),
              _label('PERHITUNGAN JASA'),
              const SizedBox(height: 8),
              _buildTable('Barang Umum', _ratesUmum),
              const SizedBox(height: 10),
              _buildTable('Perhiasan / Emas', _ratesPerhiasan),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCE8CF)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset('assets/icons/info-circle.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              AppColors.primary, BlendMode.srcIn)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Nilai pinjaman final ditentukan oleh petugas setelah inspeksi langsung di outlet.',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppColors.primary,
                              height: 1.55),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF898A8D),
                letterSpacing: 0.3)),
      );

  Widget _card({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );

  Widget _buildTable(String title, List<_Rate> rates) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555))),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Row(children: [
              Expanded(
                  flex: 3,
                  child: Text('Range Nilai',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))),
              Expanded(
                  flex: 1,
                  child: Text('15 Hr',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))),
              Expanded(
                  flex: 1,
                  child: Text('30 Hr',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))),
            ]),
          ),
          ...rates.asMap().entries.map((e) {
            final isLast = e.key == rates.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: e.key % 2 == 0 ? Colors.white : const Color(0xFFF4F8EF),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(11))
                    : BorderRadius.zero,
                border: !isLast
                    ? const Border(
                        bottom:
                            BorderSide(color: Color(0xFFE0E0E0), width: 0.5))
                    : null,
              ),
              child: Row(children: [
                Expanded(
                    flex: 3,
                    child: Text(e.value.range,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.black))),
                Expanded(
                    flex: 1,
                    child: Text(e.value.jasa15,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
                Expanded(
                    flex: 1,
                    child: Text(e.value.jasa30,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary))),
              ]),
            );
          }),
        ]),
      ),
    ]);
  }
}

class _Layanan {
  final String icon, title, desc;
  const _Layanan(this.icon, this.title, this.desc);
}

class _Kategori {
  final String emoji, label;
  const _Kategori(this.emoji, this.label);
}

class _Rate {
  final String range, jasa15, jasa30;
  const _Rate(this.range, this.jasa15, this.jasa30);
}

// Layanan tile — tanpa chevron
class _LayananTile extends StatelessWidget {
  final _Layanan layanan;
  const _LayananTile({required this.layanan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFF4F8EF),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(layanan.icon,
              errorBuilder: (_, __, ___) => const Icon(Icons.category_outlined,
                  size: 20, color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(layanan.title,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const SizedBox(height: 4),
          Text(layanan.desc,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                  height: 1.55)),
        ])),
      ]),
    );
  }
}

// Kategori tile — emoji, tanpa chevron
class _KategoriTile extends StatelessWidget {
  final _Kategori kategori;
  const _KategoriTile({required this.kategori});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: const Color(0xFFF4F8EF),
              borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Text(
            kategori.emoji,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(kategori.label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black))),
      ]),
    );
  }
}
