import 'package:dio/dio.dart';
import '../../config/app_constants.dart';
import '../../data/models/cabang_model.dart';
import '../../data/models/gadai_model.dart';

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

  // ── OTP ──────────────────────────────────────────────────────────────────
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

  // ── Auth ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> verifyNasabah({
    required String noKtp,
    required String noCif,
  }) async {
    try {
      final res = await _dio.post('/verify-nasabah', data: {
        'no_ktp': noKtp,
        'no_cif': noCif,
      });
      return {'success': true, 'data': res.data['data']};
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Data tidak ditemukan';
      return {'success': false, 'message': msg};
    }
  }

  // ── Cabang ────────────────────────────────────────────────────────────────
  static Future<List<CabangModel>> getCabang() async {
    final res = await _dio.get('/cabang');
    return (res.data['data'] as List)
        .map((e) => CabangModel.fromJson(e))
        .toList();
  }

  // ── Pinjaman ──────────────────────────────────────────────────────────────
  static Future<List<GadaiModel>> getPinjamanNasabah(String noCif) async {
    try {
      final res = await _dio.get(
        '/pinjaman',
        queryParameters: {'no_cif': noCif},
      );
      return (res.data['data'] as List)
          .map((e) => GadaiModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 403 || statusCode == 404) return [];
      rethrow;
    }
  }

  static Future<GadaiModel> getDetailPinjaman(int id) async {
    final res = await _dio.get('/pinjaman/$id');
    return GadaiModel.fromJson(res.data['data']);
  }

  // ── Midtrans ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getBayarOnlineToken(
      int gadaiId, String tipe) async {
    final res = await _dio.post(
      '/pinjaman/$gadaiId/bayar-online',
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
      '/pinjaman/$gadaiId/payment-success',
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

  // ── Riwayat per gadai (dari detail pinjaman) ──────────────────────────────
  static Future<List<Map<String, dynamic>>> getRiwayatPembayaran(
      int gadaiId) async {
    final res = await _dio.get('/pinjaman/$gadaiId/riwayat');
    return (res.data['data'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ── Riwayat nasabah (dari halaman akun, semua gadai) ─────────────────────
  static Future<List<Map<String, dynamic>>> getRiwayatNasabah(
      String noCif) async {
    final res = await _dio.get(
      '/riwayat-nasabah',
      queryParameters: {'no_cif': noCif},
    );
    return (res.data['data'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
