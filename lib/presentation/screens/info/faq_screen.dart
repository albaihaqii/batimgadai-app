import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_green_header.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    _Faq('Barang apa saja yang dapat digadaikan?',
        'BATIM GADAI menerima barang elektronik (HP, laptop, tablet), barang bergerak yang memiliki nilai ekonomis, serta kendaraan bermotor dengan BPKB dan unit kendaraan.'),
    _Faq('Apakah bisa gadai tanpa datang ke outlet?',
        'Saat ini proses gadai wajib dilakukan langsung di outlet karena memerlukan penilaian fisik barang oleh petugas kami secara langsung.'),
    _Faq('Apakah bisa gadai BPKB saja tanpa unit kendaraan?',
        'Tidak. BATIM GADAI mensyaratkan kendaraan bermotor beserta BPKB dan unit kendaraannya. BPKB tanpa unit kendaraan tidak dapat digadaikan.'),
    _Faq('Bagaimana cara melakukan perpanjangan gadai?',
        'Perpanjangan dilakukan langsung di outlet BATIM GADAI sebelum jatuh tempo dengan membayar biaya jasa pinjaman. Nasabah wajib membawa SBG asli.'),
    _Faq('Berapa lama proses pencairan dana gadai?',
        'Proses pencairan dana berlangsung sekitar 15–30 menit setelah proses penilaian barang dan persetujuan pinjaman selesai dilakukan.'),
    _Faq('Apa yang terjadi jika gadai tidak dilunasi tepat waktu?',
        'Jika sampai tanggal jatuh tempo tidak ada pelunasan atau perpanjangan, BATIM GADAI memberikan masa tunggu 60 hari sebelum barang dijual sesuai peraturan OJK.'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppGreenHeader(title: 'FAQ'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pertanyaan yang Sering Diajukan',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(height: 2),
                      Text(
                          'Temukan jawaban atas pertanyaan umum seputar layanan gadai, ketentuan pinjaman, dan proses transaksi di BATIM GADAI.',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                              height: 1.55)),
                    ]),
              ),
              const SizedBox(height: 16),
              ..._faqs.map((f) => _FaqItem(faq: f)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Faq {
  final String question, answer;
  const _Faq(this.question, this.answer);
}

class _FaqItem extends StatefulWidget {
  final _Faq faq;
  const _FaqItem({required this.faq});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotation, _height;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _rotation = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _height = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color:
                _expanded ? const Color(0xFFB6D96C) : const Color(0xFFE0E0E0)),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                  child: Text(widget.faq.question,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              _expanded ? AppColors.primary : Colors.black))),
              const SizedBox(width: 8),
              RotationTransition(
                turns: _rotation,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _expanded
                          ? AppColors.primary
                          : AppColors.primarySurface,
                      shape: BoxShape.circle),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: _expanded ? Colors.white : AppColors.primary),
                ),
              ),
            ]),
          ),
        ),
        SizeTransition(
          sizeFactor: _height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  height: 1,
                  color: const Color(0xFFE0E0E0),
                  margin: const EdgeInsets.only(bottom: 10)),
              Text(widget.faq.answer,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF555555),
                      height: 1.6)),
            ]),
          ),
        ),
      ]),
    );
  }
}
