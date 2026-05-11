import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_green_header.dart';

class CaraGadaiScreen extends StatelessWidget {
  const CaraGadaiScreen({super.key});

  static const _steps = [
    _Step(
        '01',
        'Datang ke Outlet',
        'Nasabah datang langsung ke outlet BATIM GADAI terdekat dengan membawa barang yang akan dijadikan jaminan gadai beserta KTP asli.',
        'assets/icons/location-bold.svg'),
    _Step(
        '02',
        'Input Data Nasabah',
        'Petugas melakukan input dan verifikasi data identitas nasabah ke dalam sistem informasi gadai elektronik BATIM GADAI.',
        'assets/icons/user-hand-up.svg'),
    _Step(
        '03',
        'Penaksiran Barang',
        'Juru taksir melakukan penilaian kondisi fisik barang jaminan secara langsung dan menentukan estimasi range nilai harga barang.',
        'assets/icons/scale.svg'),
    _Step(
        '04',
        'Persetujuan Pinjaman',
        'Pimpinan cabang meninjau hasil taksiran dan menentukan nilai pinjaman final yang disetujui untuk diberikan kepada nasabah.',
        'assets/icons/file-check.svg'),
    _Step(
        '05',
        'Cetak Surat Bukti Gadai',
        'Admin mencetak Surat Bukti Gadai (SBG) sebagai dokumen resmi transaksi yang ditandatangani oleh kedua belah pihak.',
        'assets/icons/contract.svg'),
    _Step(
        '06',
        'Dana Cair ke Nasabah',
        'Dana pinjaman langsung diberikan secara tunai kepada nasabah setelah seluruh proses administrasi dan penandatanganan selesai.',
        'assets/icons/wallet-bold.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppGreenHeader(title: 'Cara Gadai'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Langkah Mudah Mendapatkan Pinjaman',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(height: 2),
                      Text(
                          'Ikuti 6 langkah berikut untuk mulai gadai di BATIM GADAI dan dapatkan dana tunai dengan cepat dan aman.',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                              height: 1.55)),
                    ]),
              ),
              const SizedBox(height: 20),
              ..._steps.asMap().entries.map((e) =>
                  _StepCard(step: e.value, isLast: e.key == _steps.length - 1)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String number, title, desc, icon;
  const _Step(this.number, this.title, this.desc, this.icon);
}

class _StepCard extends StatelessWidget {
  final _Step step;
  final bool isLast;
  const _StepCard({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFFB6D96C), shape: BoxShape.circle),
            child: Center(
                child: Text(step.number,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16, // ← diperbesar dari 12
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F5C3A)))),
          ),
          if (!isLast)
            Expanded(
                child: Container(width: 2, color: const Color(0xFFDCE8CF))),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('LANGKAH ${step.number}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 3),
                      Text(step.title,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const SizedBox(height: 6),
                      Text(step.desc,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                              height: 1.55)),
                    ])),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4F8EF),
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(step.icon,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.circle_outlined,
                          size: 20,
                          color: AppColors.primary)),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
