import 'dart:math';

class CabangModel {
  final int id;
  final String kode;
  final String nama;
  final String alamat;
  final String noTelp;
  final String hariBuka;
  final String jamBuka;
  final String jamTutup;
  final double? latitude;
  final double? longitude;
  double? jarakKm;

  CabangModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.alamat,
    required this.noTelp,
    required this.hariBuka,
    required this.jamBuka,
    required this.jamTutup,
    this.latitude,
    this.longitude,
    this.jarakKm,
  });

  factory CabangModel.fromJson(Map<String, dynamic> j) => CabangModel(
        id: j['id'] as int,
        kode: j['kode'] ?? '-',
        nama: j['nama'] ?? '-',
        alamat: j['alamat'] ?? '-',
        noTelp: j['no_telp'] ?? '-',
        hariBuka: j['hari_buka'] ?? 'Senin - Sabtu',
        jamBuka: j['jam_buka'] ?? '07.00',
        jamTutup: j['jam_tutup'] ?? '17.00',
        latitude:
            j['latitude'] != null ? (j['latitude'] as num).toDouble() : null,
        longitude:
            j['longitude'] != null ? (j['longitude'] as num).toDouble() : null,
      );

  bool get hasCoords => latitude != null && longitude != null;

  String get jamOperasional => '$hariBuka, $jamBuka – $jamTutup WIB';

  String get jarakLabel {
    if (jarakKm == null) return '';
    return jarakKm! < 1
        ? '${(jarakKm! * 1000).round()} m'
        : '${jarakKm!.toStringAsFixed(1)} km';
  }

  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;
}
