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
  static const _green = Color(0xFFB6D96C);
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
    final fmtCurr =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Estimate card ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _badge),
          ),
          child: Column(children: [
            const Text('Estimasi nilai barang',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF555555))),
            const SizedBox(height: 8),
            Text('Rp ${fmtNum.format(nilaiMin)}',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                    height: 1.1)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('s/d',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey.shade500)),
            ),
            Text('Rp ${fmtNum.format(nilaiMax)}',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                    height: 1.1)),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Detail card (icon kiri + label kecil abu + value bold) ─
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(children: [
            _DR(
                icon: Icons.category_outlined,
                label: 'Kategori',
                value: kategoriLabel),
            _DR(
                icon: Icons.inventory_2_outlined,
                label: 'Nama Barang',
                value: namaBarang.isNotEmpty ? namaBarang : '-'),
            _DR(
                icon: Icons.shield_outlined,
                label: 'Kondisi',
                value: kondisiLabel),
            _DR(
                icon: Icons.phone_iphone_outlined,
                label: 'Kelengkapan',
                value: kelengkapan),
            _DR(
                icon: Icons.check_circle_outline,
                label: 'Kecacatan',
                value: kecacatan,
                last: true),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Info note ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _badge),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: _dark, size: 15),
              SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Estimasi bersifat perkiraan. Nilai taksiran aktual '
                      'ditentukan petugas saat kunjungan ke cabang.',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: _dark,
                          height: 1.55))),
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
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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

// ── Detail row ────────────────────────────────────────────────────────────────
class _DR extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool last;
  const _DR(
      {required this.icon,
      required this.label,
      required this.value,
      this.last = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: const Color(0xFFF4F8EF),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: const Color(0xFF1F5C3A))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
              ])),
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
