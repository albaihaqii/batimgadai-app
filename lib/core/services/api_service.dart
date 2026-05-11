import 'package:dio/dio.dart';
import '../../config/app_constants.dart';

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

  // Kirim OTP via Fonnte ke WhatsApp
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

  // Verifikasi nasabah via No KTP + No CIF
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

  // Ambil list cabang
  static Future<List<dynamic>> getCabang() async {
    try {
      final res = await _dio.get('/mobile/cabang');
      return res.data['data'] as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  // Ambil list pinjaman nasabah
  static Future<List<dynamic>> getPinjaman(String noCif) async {
    try {
      final res = await _dio.get('/mobile/pinjaman', queryParameters: {
        'no_cif': noCif,
      });
      return res.data['data'] as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  // Ambil list pinjaman nasabah
  static Future<Map<String, dynamic>> getPinjamanNasabah(String noCif) async {
    try {
      final res = await _dio
          .get('/mobile/pinjaman', queryParameters: {'no_cif': noCif});
      return {'success': true, 'data': res.data['data']};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Gagal memuat pinjaman'
      };
    }
  }

  // Detail pinjaman
  static Future<Map<String, dynamic>> getDetailPinjaman(int id) async {
    try {
      final res = await _dio.get('/mobile/pinjaman/$id');
      return {'success': true, 'data': res.data['data']};
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Gagal memuat detail'};
    }
  }

  // Perpanjangan tunai
  static Future<Map<String, dynamic>> perpanjangTunai(int gadaiId) async {
    try {
      final res = await _dio.post('/mobile/pinjaman/$gadaiId/perpanjang',
          data: {'metode': 'tunai'});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Gagal perpanjang'};
    }
  }

  // Pelunasan tunai
  static Future<Map<String, dynamic>> lunasiTunai(int gadaiId) async {
    try {
      final res = await _dio
          .post('/mobile/pinjaman/$gadaiId/lunasi', data: {'metode': 'tunai'});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {'success': false, 'message': e.message ?? 'Gagal lunasi'};
    }
  }

  // Midtrans Snap token
  static Future<Map<String, dynamic>> getBayarOnlineToken(
      int gadaiId, String tipe) async {
    try {
      final res = await _dio
          .post('/mobile/pinjaman/$gadaiId/bayar-online', data: {'tipe': tipe});
      return {'success': true, 'data': res.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Gagal mendapatkan token'
      };
    }
  }
}
