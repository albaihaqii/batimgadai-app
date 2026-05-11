class PhoneUtil {
  PhoneUtil._();

  /// "081234567890" → "+6281234567890"
  static String toE164(String phone) {
    String p = phone.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (p.startsWith('0')) {
      return '+62${p.substring(1)}';
    }
    if (p.startsWith('62')) {
      return '+$p';
    }
    if (p.startsWith('+62')) {
      return p;
    }
    return '+62$p';
  }

  /// "+6281234567890" → "081234567890"
  static String toLocal(String phone) {
    if (phone.startsWith('+62')) {
      return '0${phone.substring(3)}';
    }
    if (phone.startsWith('62')) {
      return '0${phone.substring(2)}';
    }
    return phone;
  }

  /// Mask: "+62812***7890"
  static String mask(String phone) {
    final e = toE164(phone);
    if (e.length < 8) return e;
    final visible = e.substring(e.length - 4);
    final prefix = e.substring(0, 4);
    return '$prefix***$visible';
  }
}
