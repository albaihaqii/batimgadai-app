import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  static const _primary = Color(0xFF1F5C3A);
  static const _accent = Color(0xFFB6D96C);

  static const _sections = [
    _Section('UMUM', [
      _Item(
          'contract',
          'Perjanjian Gadai',
          'Barang jaminan adalah milik sah Nasabah, bukan hasil kejahatan, dan tidak dalam status sengketa atau sita jaminan.',
          [
            _Para(
                'Kepala Cabang/Outlet bertindak untuk dan atas nama BINTANG TIMUR PERGADAIAN bersama Nasabah sepakat membuat Perjanjian Gadai dengan ketentuan berikut:',
                false),
            _Para(
                'Barang yang diserahkan sebagai jaminan adalah milik sah Nasabah sesuai hukum yang berlaku di Indonesia, bukan berasal dari hasil kejahatan, tidak dalam objek sengketa, dan tidak dalam status sita jaminan.',
                true),
            _Para(
                'Nasabah menyatakan telah berhutang kepada Batim Gadai dan berkewajiban membayar pokok pinjaman beserta jasa pinjaman pada saat pelunasan atau perpanjangan gadai.',
                true),
            _Para(
                'Nasabah menyatakan setuju terhadap penetapan taksiran barang jaminan, besaran uang pinjaman, dan tarif jasa pinjaman yang tertera pada Surat Bukti Gadai (SBG).',
                true),
          ]),
    ]),
    _Section('TARIF & JANGKA WAKTU', [
      _Item(
          'tag-price',
          'Tarif Jasa Pinjaman',
          'Dihitung per 15 hari. Hari ke-1 s/d 15 dihitung setengah bulan, hari ke-16 s/d 30 dihitung satu bulan penuh.',
          [
            _Para('Tarif jasa pinjaman dihitung per 15 hari.', true),
            _Para(
                'Hari ke-1 sampai ke-15 dihitung setengah bulan dengan tarif 2,5%.',
                true),
            _Para(
                'Hari ke-16 sampai ke-30 dihitung satu bulan penuh dengan tarif 5%.',
                true),
          ]),
      _Item(
          'clock-circle',
          'Jangka Waktu & Masa Tunggu',
          'Jangka waktu pinjaman 1 bulan. Jika tidak dilunasi saat jatuh tempo, diberikan masa tunggu 60 hari sebelum barang dijual.',
          [
            _Para(
                'Jangka waktu pinjaman adalah 1 bulan terhitung sejak tanggal transaksi gadai.',
                true),
            _Para(
                'Apabila sampai tanggal jatuh tempo Nasabah tidak melakukan pelunasan maupun perpanjangan, Batim Gadai akan memberikan masa tunggu 60 hari sebelum barang jaminan dijual, sesuai Peraturan OJK No. 31/POJK.05/2016 Pasal 24 Ayat 4.',
                true),
            _Para(
                'Jatuh tempo diingatkan pada saat awal transaksi dan di MADING Batim Gadai. Tidak melalui SMS, Telepon, atau Surat menyurat.',
                true),
          ]),
      _Item(
          'refresh-circle',
          'Gadai Ulang & Tambah Pinjaman',
          'Nasabah dapat melakukan gadai ulang dan mengajukan tambahan pinjaman selama nilai taksiran masih memenuhi syarat.',
          [
            _Para(
                'Nasabah dapat melakukan gadai ulang dan mengajukan tambahan uang pinjaman selama nilai taksiran barang masih memenuhi syarat ketentuan Batim Gadai.',
                true),
          ]),
    ]),
    _Section('PENGAMBILAN BARANG', [
      _Item(
          'id-card',
          'Dokumen Wajib Pengambilan',
          'Wajib membawa KTP asli, SBG asli, dan bukti pelunasan. Hanya dapat dilakukan di cabang tempat transaksi gadai.',
          [
            _Para(
                'Pengambilan barang gadai hanya dapat dilakukan di cabang Batim Gadai tempat transaksi gadai dilakukan. Nasabah wajib membawa dokumen berikut:',
                false),
            _Para('KTP asli sesuai data transaksi gadai.', true),
            _Para('Surat Bukti Gadai (SBG) asli.', true),
            _Para('Resi atau bukti pelunasan.', true),
            _Para(
                'Petugas berhak menolak proses pengambilan apabila dokumen tidak lengkap, tidak sesuai data, atau diragukan keabsahannya.',
                false),
          ]),
      _Item(
          'user-hand-up',
          'Pengambilan Diwakilkan',
          'Wajib melampirkan surat kuasa bermaterai, KTP asli penerima kuasa, dan fotokopi KTP pemberi kuasa.',
          [
            _Para(
                'Apabila pengambilan barang diwakilkan kepada pihak lain, wajib melampirkan:',
                false),
            _Para('Surat kuasa bermaterai yang ditandatangani pemilik barang.',
                true),
            _Para('KTP asli penerima kuasa.', true),
            _Para('Fotokopi KTP pemberi kuasa.', true),
          ]),
    ]),
    _Section('GANTI RUGI & TANGGUNG JAWAB', [
      _Item(
          'box-minimalistic',
          'Kehilangan Barang',
          'Kehilangan bukan force majeure diganti sebesar 1x jumlah pinjaman yang tercantum pada SBG.',
          [
            _Para(
                'Batim Gadai akan memberikan ganti rugi apabila barang jaminan mengalami kehilangan yang tidak disebabkan oleh bencana alam atau force majeure.',
                true),
            _Para(
                'Santunan ganti rugi diberikan sebesar 1 kali jumlah pinjaman yang tercantum pada SBG.',
                true),
          ]),
      _Item(
          'shield-warning',
          'Kerusakan Barang',
          'Kerusakan selama masa gadai aktif 30 hari diganti maks Rp200.000. Lewat jatuh tempo tidak menjadi tanggung jawab Batim Gadai.',
          [
            _Para(
                'Untuk kerusakan barang yang terjadi selama masa gadai aktif 30 hari, Batim Gadai akan mengganti biaya servis atau perbaikan maksimal sebesar Rp200.000.',
                true),
            _Para(
                'Apabila telah melewati tanggal jatuh tempo, Batim Gadai tidak bertanggung jawab atas kerusakan yang terjadi pada barang jaminan.',
                true),
          ]),
      _Item(
          'database',
          'Data Elektronik',
          'Nasabah wajib backup data sebelum gadai. Batim Gadai tidak bertanggung jawab atas data yang hilang atau rusak selama masa gadai.',
          [
            _Para(
                'Nasabah menyatakan telah melakukan backup atau salinan atas seluruh data pada barang elektronik yang digadaikan.',
                true),
            _Para(
                'Batim Gadai tidak bertanggung jawab atas data yang hilang atau rusak selama masa gadai.',
                true),
          ]),
    ]),
    _Section('KEWAJIBAN NASABAH', [
      _Item(
          'pen-new-square',
          'Perubahan Data Nasabah',
          'Nasabah wajib melaporkan perubahan data secara tertulis disertai dokumen pendukung yang sah. Kelalaian menjadi tanggung jawab Nasabah.',
          [
            _Para(
                'Nasabah wajib memberitahukan secara tertulis kepada Batim Gadai disertai dokumen pendukung yang sah apabila terjadi perubahan data diri.',
                true),
            _Para(
                'Perubahan berlaku sejak diterimanya pemberitahuan tersebut dengan baik oleh Batim Gadai.',
                true),
            _Para(
                'Segala kerugian akibat kelalaian pemberitahuan perubahan data menjadi tanggung jawab penuh Nasabah.',
                true),
          ]),
      _Item(
          'file-check',
          'Kepatuhan Perjanjian',
          'Nasabah wajib mematuhi seluruh ketentuan Batim Gadai. Pelanggaran wajib mengganti kerugian dan membebaskan Batim Gadai dari akibat hukum.',
          [
            _Para(
                'Nasabah wajib mematuhi seluruh ketentuan peraturan di Batim Gadai sepanjang yang menyangkut Perjanjian Gadai.',
                true),
            _Para(
                'Apabila Nasabah melanggar ketentuan dalam perjanjian ini, Nasabah wajib mengganti setiap kerugian yang timbul akibat pelanggaran tersebut.',
                true),
            _Para(
                'Nasabah membebaskan Batim Gadai dari segala akibat hukum yang timbul. Apabila timbul akibat hukum, maka akan diambil alih dan menjadi tanggung jawab Nasabah.',
                true),
          ]),
    ]),
    _Section('KEAMANAN & SENGKETA', [
      _Item(
          'lock-keyhole',
          'Keamanan Akun',
          'Batim Gadai tidak pernah meminta PIN atau OTP melalui pesan pribadi, telepon, maupun media sosial dalam bentuk apapun.',
          [
            _Para(
                'Batim Gadai tidak pernah meminta PIN, OTP, atau data pribadi Nasabah melalui pesan pribadi, telepon, maupun media sosial dalam bentuk apapun.',
                true),
            _Para(
                'Nasabah bertanggung jawab penuh atas kerahasiaan data akun dan segala aktivitas yang terjadi melalui akun miliknya.',
                true),
            _Para(
                'Batim Gadai berhak menangguhkan akun sementara apabila ditemukan indikasi aktivitas mencurigakan yang dapat merugikan Nasabah maupun Batim Gadai.',
                true),
          ]),
      _Item(
          'scale',
          'Penyelesaian Sengketa',
          'Perselisihan diselesaikan secara musyawarah terlebih dahulu. Jika tidak mufakat, diselesaikan melalui LAPS sesuai ketentuan OJK.',
          [
            _Para(
                'Syarat dan Ketentuan ini tunduk pada hukum yang berlaku di Republik Indonesia.',
                true),
            _Para(
                'Apabila terjadi perselisihan antara Nasabah dan Batim Gadai, kedua pihak sepakat untuk menyelesaikannya secara musyawarah dan kekeluargaan terlebih dahulu.',
                true),
            _Para(
                'Apabila musyawarah tidak mencapai kesepakatan, perselisihan akan diselesaikan melalui Lembaga Alternatif Penyelesaian Sengketa di bidang usaha pergadaian sesuai ketentuan OJK yang berlaku.',
                true),
          ]),
      _Item(
          'restart',
          'Pembaruan Ketentuan',
          'Batim Gadai berhak mengubah ketentuan sewaktu-waktu. Penggunaan aplikasi yang berlanjut berarti Anda menyetujui perubahan tersebut.',
          [
            _Para(
                'Batim Gadai berhak mengubah, menambah, atau menghapus Ketentuan sewaktu-waktu tanpa pemberitahuan sebelumnya.',
                true),
            _Para(
                'Penggunaan aplikasi yang berlanjut merupakan bentuk penerimaan Anda atas semua perubahan yang diterapkan pada Ketentuan ini.',
                true),
            _Para(
                'Segala hal yang belum diatur mengacu pada ketentuan dalam Surat Bukti Gadai serta peraturan perundang-undangan yang berlaku di Republik Indonesia.',
                true),
          ]),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _accent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: _accent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset('assets/icons/arrow-left.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(_primary, BlendMode.srcIn)),
          ),
          title: const Text(
            'Syarat & Ketentuan',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _primary),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 32),
          itemCount: _sections.length,
          itemBuilder: (_, i) => _SectionWidget(_sections[i]),
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _Section section;
  const _SectionWidget(this.section);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Text(
            section.label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF898A8D),
                letterSpacing: 0.3),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: List.generate(section.items.length, (i) {
              return Column(
                children: [
                  _ItemTile(section.items[i]),
                  if (i < section.items.length - 1)
                    const Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: 14,
                        endIndent: 14,
                        color: Color(0xFFE0E0E0)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final _Item item;
  const _ItemTile(this.item);

  void _show(BuildContext ctx) => showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _DetailSheet(item),
      );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _show(context),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F8EF),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset('assets/icons/${item.icon}.svg'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000))),
                    const SizedBox(height: 3),
                    Text(item.subtitle,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFA0A0A0),
                            height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.chevron_right,
                    color: Color(0xFF1F5C3A), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final _Item item;
  const _DetailSheet(this.item);

  @override
  Widget build(BuildContext context) {
    int counter = 0;
    const ts = TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Color(0xFF000000),
        height: 1.75);

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF4F8EF),
                              borderRadius: BorderRadius.circular(9)),
                          padding: const EdgeInsets.all(9),
                          child:
                              SvgPicture.asset('assets/icons/${item.icon}.svg'),
                        ),
                        const SizedBox(width: 10),
                        Text(item.title,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000))),
                      ],
                    ),
                  ),
                  const Divider(
                      height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.paragraphs.map((p) {
                          if (p.numbered) counter++;
                          final n = counter;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: p.numbered
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          width: 22,
                                          child: Text('$n.', style: ts)),
                                      Expanded(child: Text(p.text, style: ts)),
                                    ],
                                  )
                                : Text(p.text, style: ts),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final String label;
  final List<_Item> items;
  const _Section(this.label, this.items);
}

class _Item {
  final String icon, title, subtitle;
  final List<_Para> paragraphs;
  const _Item(this.icon, this.title, this.subtitle, this.paragraphs);
}

class _Para {
  final String text;
  final bool numbered;
  const _Para(this.text, this.numbered);
}
