import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../models/term_info.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    TermCategory('UMUM', [
      TermItem(
        'contract',
        'Perjanjian Gadai',
        'Barang jaminan adalah milik sah Nasabah, bukan hasil kejahatan, dan tidak dalam status sengketa atau sita jaminan.',
        [
          TermPara(
            'Kepala Cabang/Outlet bertindak untuk dan atas nama BINTANG TIMUR PERGADAIAN bersama Nasabah sepakat membuat Perjanjian Gadai dengan ketentuan berikut:',
            false,
          ),
          TermPara(
            'Barang yang diserahkan sebagai jaminan adalah milik sah Nasabah sesuai hukum yang berlaku di Indonesia, bukan berasal dari hasil kejahatan, tidak dalam objek sengketa, dan tidak dalam status sita jaminan.',
            true,
          ),
          TermPara(
            'Nasabah menyatakan telah berhutang kepada Batim Gadai dan berkewajiban membayar pokok pinjaman beserta jasa pinjaman pada saat pelunasan atau perpanjangan gadai.',
            true,
          ),
          TermPara(
            'Nasabah menyatakan setuju terhadap penetapan taksiran barang jaminan, besaran uang pinjaman, dan tarif jasa pinjaman yang tertera pada Surat Bukti Gadai (SBG).',
            true,
          ),
        ],
      ),
    ]),
    TermCategory('TARIF & JANGKA WAKTU', [
      TermItem(
        'tag-price',
        'Tarif Jasa Pinjaman',
        'Dihitung per 15 hari. Hari ke-1 s/d 15 dihitung setengah bulan, hari ke-16 s/d 30 dihitung satu bulan penuh.',
        [
          TermPara('Tarif jasa pinjaman dihitung per 15 hari.', true),
          TermPara(
            'Hari ke-1 sampai ke-15 dihitung setengah bulan dengan tarif 2,5%.',
            true,
          ),
          TermPara(
            'Hari ke-16 sampai ke-30 dihitung satu bulan penuh dengan tarif 5%.',
            true,
          ),
        ],
      ),
      TermItem(
        'clock-circle',
        'Jangka Waktu & Masa Tunggu',
        'Jangka waktu pinjaman 1 bulan. Jika tidak dilunasi saat jatuh tempo, diberikan masa tunggu 60 hari sebelum barang dijual.',
        [
          TermPara(
            'Jangka waktu pinjaman adalah 1 bulan terhitung sejak tanggal transaksi gadai.',
            true,
          ),
          TermPara(
            'Apabila sampai tanggal jatuh tempo Nasabah tidak melakukan pelunasan maupun perpanjangan, Batim Gadai akan memberikan masa tunggu 60 hari sebelum barang jaminan dijual, sesuai Peraturan OJK No. 31/POJK.05/2016 Pasal 24 Ayat 4.',
            true,
          ),
          TermPara(
            'Jatuh tempo diingatkan pada saat awal transaksi dan di MADING Batim Gadai. Tidak melalui SMS, Telepon, atau Surat menyurat.',
            true,
          ),
        ],
      ),
      TermItem(
        'refresh-circle',
        'Gadai Ulang & Tambah Pinjaman',
        'Nasabah dapat melakukan gadai ulang dan mengajukan tambahan pinjaman selama nilai taksiran masih memenuhi syarat.',
        [
          TermPara(
            'Nasabah dapat melakukan gadai ulang dan mengajukan tambahan uang pinjaman selama nilai taksiran barang masih memenuhi syarat ketentuan Batim Gadai.',
            true,
          ),
        ],
      ),
    ]),
    TermCategory('PENGAMBILAN BARANG', [
      TermItem(
        'id-card',
        'Dokumen Wajib Pengambilan',
        'Wajib membawa KTP asli, SBG asli, dan bukti pelunasan. Hanya dapat dilakukan di cabang tempat transaksi gadai.',
        [
          TermPara(
            'Pengambilan barang gadai hanya dapat dilakukan di cabang Batim Gadai tempat transaksi gadai dilakukan. Nasabah wajib membawa dokumen berikut:',
            false,
          ),
          TermPara('KTP asli sesuai data transaksi gadai.', true),
          TermPara('Surat Bukti Gadai (SBG) asli.', true),
          TermPara('Resi atau bukti pelunasan.', true),
          TermPara(
            'Petugas berhak menolak proses pengambilan apabila dokumen tidak lengkap, tidak sesuai data, atau diragukan keabsahannya.',
            false,
          ),
        ],
      ),
      TermItem(
        'user-hand-up',
        'Pengambilan Diwakilkan',
        'Wajib melampirkan surat kuasa bermaterai, KTP asli penerima kuasa, dan fotokopi KTP pemberi kuasa.',
        [
          TermPara(
            'Apabila pengambilan barang diwakilkan kepada pihak lain, wajib melampirkan:',
            false,
          ),
          TermPara(
            'Surat kuasa bermaterai yang ditandatangani pemilik barang.',
            true,
          ),
          TermPara('KTP asli penerima kuasa.', true),
          TermPara('Fotokopi KTP pemberi kuasa.', true),
        ],
      ),
    ]),
    TermCategory('GANTI RUGI & TANGGUNG JAWAB', [
      TermItem(
        'box-minimalistic',
        'Kehilangan Barang',
        'Kehilangan bukan force majeure diganti sebesar 1x jumlah pinjaman yang tercantum pada SBG.',
        [
          TermPara(
            'Batim Gadai akan memberikan ganti rugi apabila barang jaminan mengalami kehilangan yang tidak disebabkan oleh bencana alam atau force majeure.',
            true,
          ),
          TermPara(
            'Santunan ganti rugi diberikan sebesar 1 kali jumlah pinjaman yang tercantum pada SBG.',
            true,
          ),
        ],
      ),
      TermItem(
        'shield-warning',
        'Kerusakan Barang',
        'Kerusakan selama masa gadai aktif 30 hari diganti maks Rp200.000. Lewat jatuh tempo tidak menjadi tanggung jawab Batim Gadai.',
        [
          TermPara(
            'Untuk kerusakan barang yang terjadi selama masa gadai aktif 30 hari, Batim Gadai akan mengganti biaya servis atau perbaikan maksimal sebesar Rp200.000.',
            true,
          ),
          TermPara(
            'Apabila telah melewati tanggal jatuh tempo, Batim Gadai tidak bertanggung jawab atas kerusakan yang terjadi pada barang jaminan.',
            true,
          ),
        ],
      ),
      TermItem(
        'database',
        'Data Elektronik',
        'Nasabah wajib backup data sebelum gadai. Batim Gadai tidak bertanggung jawab atas data yang hilang atau rusak selama masa gadai.',
        [
          TermPara(
            'Nasabah menyatakan telah melakukan backup atau salinan atas seluruh data pada barang elektronik yang digadaikan.',
            true,
          ),
          TermPara(
            'Batim Gadai tidak bertanggung jawab atas data yang hilang atau rusak selama masa gadai.',
            true,
          ),
        ],
      ),
    ]),
    TermCategory('KEWAJIBAN NASABAH', [
      TermItem(
        'pen-new-square',
        'Perubahan Data Nasabah',
        'Nasabah wajib melaporkan perubahan data secara tertulis disertai dokumen pendukung yang sah. Kelalaian menjadi tanggung jawab Nasabah.',
        [
          TermPara(
            'Nasabah wajib memberitahukan secara tertulis kepada Batim Gadai disertai dokumen pendukung yang sah apabila terjadi perubahan data diri.',
            true,
          ),
          TermPara(
            'Perubahan berlaku sejak diterimanya pemberitahuan tersebut dengan baik oleh Batim Gadai.',
            true,
          ),
          TermPara(
            'Segala kerugian akibat kelalaian pemberitahuan perubahan data menjadi tanggung jawab penuh Nasabah.',
            true,
          ),
        ],
      ),
      TermItem(
        'file-check',
        'Kepatuhan Perjanjian',
        'Nasabah wajib mematuhi seluruh ketentuan Batim Gadai. Pelanggaran wajib mengganti kerugian dan membebaskan Batim Gadai dari akibat hukum.',
        [
          TermPara(
            'Nasabah wajib mematuhi seluruh ketentuan peraturan di Batim Gadai sepanjang yang menyangkut Perjanjian Gadai.',
            true,
          ),
          TermPara(
            'Apabila Nasabah melanggar ketentuan dalam perjanjian ini, Nasabah wajib mengganti setiap kerugian yang timbul akibat pelanggaran tersebut.',
            true,
          ),
          TermPara(
            'Nasabah membebaskan Batim Gadai dari segala akibat hukum yang timbul. Apabila timbul akibat hukum, maka akan diambil alih dan menjadi tanggung jawab Nasabah.',
            true,
          ),
        ],
      ),
    ]),
    TermCategory('KEAMANAN & SENGKETA', [
      TermItem(
        'lock-keyhole',
        'Keamanan Akun',
        'Batim Gadai tidak pernah meminta PIN atau OTP melalui pesan pribadi, telepon, maupun media sosial dalam bentuk apapun.',
        [
          TermPara(
            'Batim Gadai tidak pernah meminta PIN, OTP, atau data pribadi Nasabah melalui pesan pribadi, telepon, maupun media sosial dalam bentuk apapun.',
            true,
          ),
          TermPara(
            'Nasabah bertanggung jawab penuh atas kerahasiaan data akun dan segala aktivitas yang terjadi melalui akun miliknya.',
            true,
          ),
          TermPara(
            'Batim Gadai berhak menangguhkan akun sementara apabila ditemukan indikasi aktivitas mencurigakan yang dapat merugikan Nasabah maupun Batim Gadai.',
            true,
          ),
        ],
      ),
      TermItem(
        'scale',
        'Penyelesaian Sengketa',
        'Perselisihan diselesaikan secara musyawarah terlebih dahulu. Jika tidak mufakat, diselesaikan melalui LAPS sesuai ketentuan OJK.',
        [
          TermPara(
            'Syarat dan Ketentuan ini tunduk pada hukum yang berlaku di Republik Indonesia.',
            true,
          ),
          TermPara(
            'Apabila terjadi perselisihan antara Nasabah dan Batim Gadai, kedua pihak sepakat untuk menyelesaikannya secara musyawarah dan kekeluargaan terlebih dahulu.',
            true,
          ),
          TermPara(
            'Apabila musyawarah tidak mencapai kesepakatan, perselisihan akan diselesaikan melalui Lembaga Alternatif Penyelesaian Sengketa di bidang usaha pergadaian sesuai ketentuan OJK yang berlaku.',
            true,
          ),
        ],
      ),
      TermItem(
        'restart',
        'Pembaruan Ketentuan',
        'Batim Gadai berhak mengubah ketentuan sewaktu-waktu. Penggunaan aplikasi yang berlanjut berarti Anda menyetujui perubahan tersebut.',
        [
          TermPara(
            'Batim Gadai berhak mengubah, menambah, atau menghapus Ketentuan sewaktu-waktu tanpa pemberitahuan sebelumnya.',
            true,
          ),
          TermPara(
            'Penggunaan aplikasi yang berlanjut merupakan bentuk penerimaan Anda atas semua perubahan yang diterapkan pada Ketentuan ini.',
            true,
          ),
          TermPara(
            'Segala hal yang belum diatur mengacu pada ketentuan dalam Surat Bukti Gadai serta peraturan perundang-undangan yang berlaku di Republik Indonesia.',
            true,
          ),
        ],
      ),
    ]),
  ];

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Syarat & Ketentuan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1F5C3A),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 4.h, bottom: 32.h),
        itemCount: _sections.length,
        itemBuilder: (_, i) => _SectionWidget(_sections[i]),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final TermCategory section;
  const _SectionWidget(this.section);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 6.h),
          child: Text(
            section.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF898A8D),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: List.generate(section.items.length, (i) {
              return Column(
                children: [
                  _ItemTile(section.items[i]),
                  if (i < section.items.length - 1)
                    Divider(
                      height: 1.h,
                      thickness: 0.5.h,
                      indent: 14.w,
                      endIndent: 14.w,
                      color: const Color(0xFFE0E0E0),
                    ),
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
  final TermItem item;
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
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                margin: EdgeInsets.only(top: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8EF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.all(10.w),
                child: SvgPicture.asset('assets/icons/${item.icon}.svg'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA0A0A0),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF1F5C3A),
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final TermItem item;
  const _DetailSheet(this.item);

  @override
  Widget build(BuildContext context) {
    int counter = 0;
    final ts = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 12.sp,
      color: const Color(0xFF000000),
      height: 1.75,
    );

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F8EF),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          padding: EdgeInsets.all(9.w),
                          child: SvgPicture.asset(
                            'assets/icons/${item.icon}.svg',
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF000000),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.h,
                    thickness: 0.5.h,
                    color: const Color(0xFFF0F0F0),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.paragraphs.map((p) {
                          if (p.numbered) counter++;
                          final n = counter;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: p.numbered
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 22.w,
                                        child: Text('$n.', style: ts),
                                      ),
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
