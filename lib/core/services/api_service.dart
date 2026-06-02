import 'package:dio/dio.dart';
import '../../config/app_constants.dart';
import '../../data/models/gadai_model.dart';
import '../../data/models/cabang_model.dart';

class ApiService {
  ApiService._();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  // OTP
  static Future<bool> kirimOtp(String phone, String otp) async {
    try {
      final res = await Dio().post(
        AppConstants.fonnteUrl,
        data: {
          'target': phone,
          'message':
              'Kode OTP BATIM GADAI Anda: *$otp*\n\nJangan berikan kode ini kepada siapapun.',
          'delay': '2',
          'countryCode': '62',
        },
        options: Options(headers: {'Authorization': AppConstants.fonnteToken}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Auth
  static Future<Map<String, dynamic>> verifyNasabah({
    required String noKtp,
    required String noCif,
  }) async {
    try {
      final res = await _dio.post('/mobile/verify-nasabah', data: {
        'no_ktp': noKtp,
        'no_cif': noCif,
      });
      return {'success': true, 'data': res.data['data']};
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Data tidak ditemukan';
      return {'success': false, 'message': msg};
    }
  }

  // Cabang
  static Future<List<CabangModel>> getCabang() async {
    try {
      final res = await _dio.get('/mobile/cabang');
      return (res.data['data'] as List)
          .map((e) => CabangModel.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Pinjaman
  static Future<List<GadaiModel>> getPinjamanNasabah(String noCif) async {
    try {
      final res = await _dio.get(
        '/mobile/pinjaman',
        queryParameters: {'no_cif': noCif},
      );
      return (res.data['data'] as List)
          .map((e) => GadaiModel.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<GadaiModel> getDetailPinjaman(int id) async {
    final res = await _dio.get('/mobile/pinjaman/$id');
    return GadaiModel.fromJson(res.data['data']);
  }

  // Midtrans
  static Future<Map<String, dynamic>> getBayarOnlineToken(
      int gadaiId, String tipe) async {
    final res = await _dio.post(
      '/mobile/pinjaman/$gadaiId/bayar-online',
      data: {'tipe': tipe},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<void> paymentSuccess({
    required int gadaiId,
    required String tipe,
    required String orderId,
    required String transactionId,
    required String paymentType,
    required int jasaNominal,
    required int total,
  }) async {
    await _dio.post(
      '/mobile/pinjaman/$gadaiId/payment-success',
      data: {
        'tipe': tipe,
        'order_id': orderId,
        'transaction_id': transactionId,
        'payment_type': paymentType,
        'jasa_nominal': jasaNominal,
        'total': total,
      },
    );
  }

  // Riwayat per gadai
  static Future<List<Map<String, dynamic>>> getRiwayatPembayaran(
      int gadaiId) async {
    try {
      final res = await _dio.get('/mobile/pinjaman/$gadaiId/riwayat');
      return (res.data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Riwayat semua gadai nasabah
  static Future<List<Map<String, dynamic>>> getRiwayatNasabah(
      String noCif) async {
    if (noCif.isEmpty) throw Exception('no_cif tidak boleh kosong');
    final res = await _dio.get(
      '/mobile/riwayat-nasabah',
      queryParameters: {'no_cif': noCif},
    );
    return (res.data['data'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Notifikasi
  // noCif kosong = pengunjung (hanya info umum)
  // noCif diisi = nasabah (info umum + notif personal)
  static Future<List<Map<String, dynamic>>> getNotifikasi(String noCif) async {
    try {
      final params = noCif.isNotEmpty ? {'no_cif': noCif} : <String, dynamic>{};
      final res = await _dio.get(
        '/mobile/notifikasi',
        queryParameters: params,
      );
      if (res.data['success'] == true) {
        return (res.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> markNotifikasiRead(int id) async {
    try {
      await _dio.post('/mobile/notifikasi/$id/read');
    } catch (_) {}
  }

  // Banner mobile
  static Future<List<Map<String, dynamic>>> getBanners() async {
    try {
      final res = await _dio.get('/mobile/banners');
      if (res.data['success'] == true) {
        return (res.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // FCM Token — kirim ke backend saat login/verifikasi
  static Future<void> saveFcmToken({
    required String phone,
    required String token,
    String? deviceId,
  }) async {
    await _dio.post(
      '/mobile/fcm-token',
      data: {
        'no_hp': phone.isNotEmpty ? phone : null,
        'token': token,
        'device_id': deviceId,
        'platform': 'android',
      },
    );
  }

  // Ambil options simulasi by kategori
  static Future<Map<String, dynamic>> getSimulasiOptions(
      String kategori) async {
    final res = await _dio.get(
      '/simulasi/options',
      queryParameters: {'kategori': kategori},
    );
    return res.data as Map<String, dynamic>;
  }

  // Hitung estimasi simulasi
  static Future<Map<String, dynamic>> hitungSimulasi(
      Map<String, dynamic> body) async {
    final res = await _dio.post('/simulasi/hitung', data: body);
    return res.data as Map<String, dynamic>;
  }

  // Submit booking kunjungan
  static Future<Map<String, dynamic>> submitBooking(
      Map<String, dynamic> body) async {
    final res = await _dio.post('/mobile/booking', data: body);
    return res.data as Map<String, dynamic>;
  }

  // Ambil daftar booking nasabah
  static Future<List<Map<String, dynamic>>> getBookingList(String noCif) async {
    final res = await _dio.get(
      '/mobile/booking',
      queryParameters: {'no_cif': noCif},
    );
    final data = res.data['data'] as List;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
