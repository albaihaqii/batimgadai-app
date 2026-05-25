class GadaiModel {
  final int id;
  final String noSbg;
  final String status;
  final String namaBarang;
  final String kategoriBarang;
  final int nilaiPinjaman;
  final double jasaPersen;
  final int jasaNominal;
  final int totalTebus;
  final String tglGadai;
  final String tglJatuhTempo;
  final String tglJatuhTempoLabel;
  final int sisaHari;
  final String namaCabang;
  final String tipeJasa;

  // Detail only
  final String? kondisiBarang;
  final String? merk;
  final String? tipeModel;
  final String? kelengkapan;
  final int? nilaiTaksiranMin;
  final int? nilaiTaksiranMax;
  final double? jasaPersen15;
  final double? jasaPersen30;
  final String? kodeLoker;
  final String? namaNasabah;
  final String? noHpNasabah;

  const GadaiModel({
    required this.id,
    required this.noSbg,
    required this.status,
    required this.namaBarang,
    required this.kategoriBarang,
    required this.nilaiPinjaman,
    required this.jasaPersen,
    required this.jasaNominal,
    required this.totalTebus,
    required this.tglGadai,
    required this.tglJatuhTempo,
    required this.tglJatuhTempoLabel,
    required this.sisaHari,
    required this.namaCabang,
    required this.tipeJasa,
    this.kondisiBarang,
    this.merk,
    this.tipeModel,
    this.kelengkapan,
    this.nilaiTaksiranMin,
    this.nilaiTaksiranMax,
    this.jasaPersen15,
    this.jasaPersen30,
    this.kodeLoker,
    this.namaNasabah,
    this.noHpNasabah,
  });

  factory GadaiModel.fromJson(Map<String, dynamic> j) => GadaiModel(
        id: j['id'] as int,
        noSbg: j['no_sbg'] ?? '-',
        status: j['status'] ?? 'aktif',
        namaBarang: j['nama_barang'] ?? '-',
        kategoriBarang: j['kategori_barang'] ?? '-',
        nilaiPinjaman: (j['nilai_pinjaman'] as num).toInt(),
        jasaPersen: (j['jasa_persen'] as num).toDouble(),
        jasaNominal: (j['jasa_nominal'] as num).toInt(),
        totalTebus: (j['total_tebus'] as num).toInt(),
        tglGadai: j['tgl_gadai'] ?? '-',
        tglJatuhTempo: j['tgl_jatuh_tempo'] ?? '-',
        tglJatuhTempoLabel: j['tgl_jatuh_tempo_label'] ?? '-',
        sisaHari: (j['sisa_hari'] as num).toInt(),
        namaCabang: j['nama_cabang'] ?? '-',
        tipeJasa: j['tipe_jasa'] ?? 'umum',
        kondisiBarang: j['kondisi_barang'],
        merk: j['merk'],
        tipeModel: j['tipe_model'],
        kelengkapan: j['kelengkapan'],
        nilaiTaksiranMin: j['nilai_taksiran_min'] != null
            ? (j['nilai_taksiran_min'] as num).toInt()
            : null,
        nilaiTaksiranMax: j['nilai_taksiran_max'] != null
            ? (j['nilai_taksiran_max'] as num).toInt()
            : null,
        jasaPersen15: j['jasa_persen_15'] != null
            ? (j['jasa_persen_15'] as num).toDouble()
            : null,
        jasaPersen30: j['jasa_persen_30'] != null
            ? (j['jasa_persen_30'] as num).toDouble()
            : null,
        kodeLoker: j['kode_loker'],
        namaNasabah: j['nama_nasabah'],
        noHpNasabah: j['no_hp_nasabah'],
      );

  static String aliasKategori(String raw) {
    const map = {
      'handphone': 'Handphone',
      'laptop': 'Laptop',
      'tablet': 'Tablet',
      'elektronik_lainnya': 'Elektronik Lainnya',
      'kendaraan_motor': 'Kendaraan Motor',
      'barang_rumah_tangga': 'Barang Rumah Tangga',
      'perhiasan': 'Perhiasan / Emas',
    };
    final key = raw.toLowerCase().trim();
    if (map.containsKey(key)) return map[key]!;
    if (raw.isEmpty || raw == '-') return '-';
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  static String aliasKondisi(String raw) {
    const map = {
      'baik': 'Baik',
      'cukup': 'Cukup',
      'kurang': 'Kurang',
      'rusak': 'Rusak',
      'baru': 'Baru',
      'like_new': 'Seperti Baru',
      'bekas': 'Bekas',
      'sangat_baik': 'Sangat Baik',
    };
    final key = raw.toLowerCase().trim();
    if (map.containsKey(key)) return map[key]!;
    if (raw.isEmpty || raw == '-') return '-';
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  static Map<String, dynamic> statusConfig(String status) {
    const cfg = {
      'aktif': {
        'label': 'Aktif',
        'color': 0xFF16A34A,
        'bg': 0xFFDCFCE7,
        'border': 0xFF16A34A,
      },
      'perpanjangan': {
        'label': 'Perpanjangan',
        'color': 0xFF1D4ED8,
        'bg': 0xFFDBEAFE,
        'border': 0xFF1D4ED8,
      },
      'jatuh_tempo': {
        'label': 'Jatuh Tempo',
        'color': 0xFFDC2626,
        'bg': 0xFFFEE2E2,
        'border': 0xFFDC2626,
      },
      'lunas': {
        'label': 'Lunas',
        'color': 0xFF6B7280,
        'bg': 0xFFF3F4F6,
        'border': 0xFF9CA3AF,
      },
    };
    return cfg[status] ?? cfg['aktif']!;
  }

  String get namaDisplay => (namaBarang.isNotEmpty && namaBarang != '-')
      ? namaBarang
      : aliasKategori(kategoriBarang);

  String get sisaHariLabel {
    if (sisaHari < 0) return 'Telat ${sisaHari.abs()} hari';
    if (sisaHari == 0) return 'Jatuh tempo hari ini';
    return '$sisaHari hari lagi';
  }

  int get sisaHariColorValue {
    if (sisaHari < 0) return 0xFFDC2626;
    if (sisaHari <= 3) return 0xFFDC2626;
    if (sisaHari <= 7) return 0xFFF97316;
    return 0xFF16A34A;
  }

  static String formatRupiah(int n) {
    final s = n.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
