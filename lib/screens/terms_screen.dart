import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/term_info.dart';
import '../widgets/term_item_card.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final List<TermCategory> _termCategories = [
    TermCategory(
      categoryName: 'UMUM',
      items: [
        TermItem(
          title: 'Perjanjian Gadai',
          subtitle:
              'Barang jaminan adalah milik sah Nasabah, bukan hasil kejahatan, dan tidak dalam status sengketa atau sita jaminan.',
          detailContent:
              'Kepala Cabang/Outlet bertindak untuk dan atas nama BINTANG TIMUR PERGADAIAN bersama Nasabah sepakat membuat Perjanjian Gadai dengan ketentuan berikut:\n\n1. Barang yang diserahkan sebagai jaminan adalah milik sah Nasabah sesuai hukum yang berlaku di Indonesia, bukan berasal dari hasil kejahatan, tidak dalam objek sengketa, dan tidak dalam status sita jaminan.\n2. Nasabah menyatakan telah berhutang kepada Batim Gadai dan berkewajiban membayar pokok pinjaman beserta jasa pinjaman pada saat pelunasan atau perpanjangan gadai.\n3. Nasabah menyatakan setuju terhadap penetapan taksiran barang jaminan, besaran uang pinjaman, dan tarif jasa pinjaman yang tertera pada Surat Bukti Gadai (SBG).',
        ),
      ],
    ),
    TermCategory(
      categoryName: 'TARIF & JANGKA WAKTU',
      items: [
        TermItem(
          title: 'Tarif Jasa Pinjaman',
          subtitle:
              'Dihitung per 15 hari. Hari ke-1 s/d 15 dihitung setengah bulan, hari ke-16 s/d 30 dihitung satu bulan penuh.',
          detailContent:
              'Detail tarif jasa pinjaman akan dijelaskan secara rinci pada saat transaksi di cabang kami.',
        ),
        TermItem(
          title: 'Jangka Waktu & Masa Tunggu',
          subtitle:
              'Jangka waktu pinjaman 1 bulan. Jika tidak dilunasi saat jatuh tempo, diberikan masa tunggu 60 hari sebelum barang dijual.',
          detailContent:
              'Detail mengenai jangka waktu dan masa tunggu lelang barang jaminan.',
        ),
        TermItem(
          title: 'Gadai Ulang & Tambah Pinjaman',
          subtitle:
              'Nasabah dapat melakukan gadai ulang dan mengajukan tambahan pinjaman selama nilai taksiran masih memenuhi syarat.',
          detailContent:
              'Detail persyaratan gadai ulang dan penambahan plafon pinjaman.',
        ),
      ],
    ),
    TermCategory(
      categoryName: 'PENGAMBILAN BARANG',
      items: [
        TermItem(
          title: 'Dokumen Wajib Pengambilan',
          subtitle:
              'Wajib membawa KTP asli, SBG asli, dan bukti pelunasan. Hanya dapat dilakukan di cabang tempat transaksi gadai.',
          detailContent:
              'Detail dokumen administrasi untuk pengambilan barang jaminan.',
        ),
      ],
    ),
  ];

  void _showTermDetailModal(BuildContext context, TermItem term) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F7F2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/icon_shield.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          term.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                    children: [
                      Text(
                        term.detailContent,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB6D96C),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F5C3A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Syarat & Ketentuan',
          style: TextStyle(
            color: Color(0xFF1F5C3A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _termCategories.length,
        itemBuilder: (context, sectionIndex) {
          final category = _termCategories[sectionIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: category.items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Colors.black12),
                    itemBuilder: (context, itemIndex) {
                      final item = category.items[itemIndex];
                      return TermItemCard(
                        term: item,
                        onTap: () => _showTermDetailModal(context, item),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
