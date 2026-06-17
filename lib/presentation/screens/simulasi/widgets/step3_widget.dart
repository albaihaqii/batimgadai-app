import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Step3Widget extends StatelessWidget {
  final Map<String, dynamic> hasil;
  final String kategoriLabel;
  final String namaBarang;
  final bool isNasabah;
  final VoidCallback onHitungUlang;
  final VoidCallback onBooking;

  const Step3Widget({
    super.key,
    required this.hasil,
    required this.kategoriLabel,
    required this.namaBarang,
    required this.isNasabah,
    required this.onHitungUlang,
    required this.onBooking,
  });

  static const _dark = Color(0xFF1F5C3A);
  static const _soft = Color(0xFFF4F8EF);
  static const _badge = Color(0xFFDCE8CF);

  @override
  Widget build(BuildContext context) {
    final nilaiMin = (hasil['nilai_min'] as num?)?.toInt() ?? 0;
    final nilaiMax = (hasil['nilai_max'] as num?)?.toInt() ?? 0;
    final hargaPasar = (hasil['harga_pasar'] as num?)?.toInt() ?? 0;
    final kondisiRaw = hasil['kondisi'] as String? ?? '-';
    final kelengkapan = hasil['kelengkapan'] as String? ?? '-';
    final kecacatan =
        (hasil['kecacatan'] as List?)?.map((e) => e.toString()).join(', ') ??
            'Tidak ada';

    final kondisiLabel = const {
          'baik': 'Baik',
          'cukup': 'Cukup',
          'rusak_ringan': 'Rusak Ringan',
        }[kondisiRaw] ??
        kondisiRaw;

    final fmtNum = NumberFormat('#,###', 'id_ID');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Estimate card ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _badge, width: 1.5),
          ),
          child: Column(children: [
            const Text('Estimasi nilai barang',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF555555))),
            const SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('Rp',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _dark)),
                  const SizedBox(width: 4),
                  Text(fmtNum.format(nilaiMin),
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _dark,
                          height: 1.1)),
                ]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('s/d',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500)),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('Rp',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _dark)),
                  const SizedBox(width: 4),
                  Text(fmtNum.format(nilaiMax),
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _dark,
                          height: 1.1)),
                ]),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Detail card ────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(children: [
            _DR(label: 'Kategori', value: kategoriLabel),
            _DR(
                label: 'Nama Barang',
                value: namaBarang.isNotEmpty ? namaBarang : '-'),
            _DR(
                label: 'Harga Pasar',
                value: hargaPasar > 0
                    ? 'Rp ${fmtNum.format(hargaPasar)}'
                    : '-'),
            _DR(label: 'Kondisi', value: kondisiLabel),
            _DR(label: 'Kelengkapan', value: kelengkapan),
            _DR(label: 'Kecacatan', value: kecacatan, last: true),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Info note ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _badge, width: 1.5),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: _dark, size: 14),
              SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Estimasi bersifat perkiraan. Nilai taksiran aktual '
                      'ditentukan petugas saat kunjungan ke cabang.',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: _dark,
                          height: 1.5))),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Buttons ────────────────────────────────────────────
        _AppBtn(
          label: isNasabah
              ? 'Ajukan Booking Kunjungan  →'
              : 'Verifikasi Akun untuk Booking',
          onTap: onBooking,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onHitungUlang,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hitung Ulang',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
          ),
        ),
      ]),
    );
  }
}

// ── Detail row — key/value tanpa icon ─────────────────────────────────────────
class _DR extends StatelessWidget {
  final String label, value;
  final bool last;
  const _DR(
      {required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF2F2F2))),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF999999))),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A)))),
        ]),
      );
}

class _AppBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _AppBtn({required this.label, this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB6D96C),
            foregroundColor: const Color(0xFF1F5C3A),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
