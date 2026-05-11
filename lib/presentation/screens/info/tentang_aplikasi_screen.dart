import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_green_header.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  static const _fitur = [
    _Fitur('assets/icons/user-hand-up.svg', 'Melayani Semua Kalangan',
        'Melayani kebutuhan pinjaman masyarakat dari berbagai kalangan dengan mudah dan cepat.'),
    _Fitur('assets/icons/shield-warning.svg', 'Berizin & Diawasi OJK',
        'Seluruh kegiatan operasional telah berizin dan diawasi Otoritas Jasa Keuangan Republik Indonesia.'),
    _Fitur('assets/icons/database.svg', 'Sistem Digital Terintegrasi',
        'Pengelolaan transaksi gadai secara terintegrasi dan terkomputerisasi dengan sistem modern.'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppGreenHeader(title: 'Tentang Aplikasi'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(children: [
                  Image.asset('assets/images/logo.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance,
                                size: 40, color: Colors.white),
                          )),
                  const SizedBox(height: 12),
                  const Text('BATIM GADAI',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('Sistem Informasi Gadai Elektronik',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Color(0xFF9E9E9E))),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDCE8CF))),
                    child: const Text('Versi 1.0.0',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Text(
                  'BATIM GADAI merupakan pegadaian swasta yang menyediakan layanan pinjaman dana dengan sistem gadai yang aman dan terpercaya. BATIM GADAI menerima berbagai jenis barang jaminan seperti barang elektronik, barang non-elektronik yang memiliki nilai ekonomis, serta kendaraan bermotor dengan BPKB dan unit kendaraan.\n\nSeluruh kegiatan operasional BATIM GADAI telah berizin dan diawasi oleh Otoritas Jasa Keuangan (OJK) sehingga memberikan rasa aman dan kepercayaan bagi masyarakat.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF555555),
                      height: 1.65),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('PROFIL PERUSAHAAN',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF898A8D),
                        letterSpacing: 0.3)),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        _fitur.length,
                        (i) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _FiturTile(fitur: _fitur[i]),
                                if (i < _fitur.length - 1)
                                  const Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      indent: 14,
                                      endIndent: 14,
                                      color: Color(0xFFE0E0E0)),
                              ],
                            ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fitur {
  final String icon, title, desc;
  const _Fitur(this.icon, this.title, this.desc);
}

class _FiturTile extends StatelessWidget {
  final _Fitur fitur;
  const _FiturTile({required this.fitur});

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
          child: SvgPicture.asset(fitur.icon,
              errorBuilder: (_, __, ___) => const Icon(Icons.star_outline,
                  size: 20, color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fitur.title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 4),
            Text(fitur.desc,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                    height: 1.5)),
          ]),
        ),
        // chevron dihapus
      ]),
    );
  }
}
