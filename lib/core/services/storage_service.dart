import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/hash_util.dart';
import '../../config/app_constants.dart';

class StorageService {
  StorageService._();

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  // No HP
  static Future<void> savePhone(String phone) async =>
      (await _prefs).setString(AppConstants.keyPhone, phone);

  static Future<String?> getPhone() async =>
      (await _prefs).getString(AppConstants.keyPhone);

  // PIN
  static Future<void> savePin(String pin) async =>
      (await _prefs).setString(AppConstants.keyPinHash, HashUtil.hashPin(pin));

  static Future<bool> hasPin() async =>
      (await _prefs).containsKey(AppConstants.keyPinHash);

  static Future<bool> checkPin(String pin) async {
    final stored = (await _prefs).getString(AppConstants.keyPinHash);
    if (stored == null) return false;
    return HashUtil.verifyPin(pin, stored);
  }

  static Future<void> updatePin(String newPin) async => (await _prefs)
      .setString(AppConstants.keyPinHash, HashUtil.hashPin(newPin));

  // Nasabah
  static Future<void> saveNasabah(Map<String, dynamic> data) async =>
      (await _prefs).setString(AppConstants.keyNasabah, jsonEncode(data));

  static Future<Map<String, dynamic>?> getNasabah() async {
    final raw = (await _prefs).getString(AppConstants.keyNasabah);
    return raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;
  }

  static Future<void> setIsNasabah(bool val) async =>
      (await _prefs).setBool(AppConstants.keyIsNasabah, val);

  static Future<bool> isNasabah() async =>
      (await _prefs).getBool(AppConstants.keyIsNasabah) ?? false;

  // Hapus Akun
  static Future<void> clearAll() async => (await _prefs).clear();
}
