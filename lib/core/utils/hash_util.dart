import 'package:crypto/crypto.dart';
import 'dart:convert';

class HashUtil {
  HashUtil._();

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPin(String inputPin, String storedHash) {
    return hashPin(inputPin) == storedHash;
  }
}
