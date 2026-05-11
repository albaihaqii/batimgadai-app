import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';

class AuthState {
  final String? phone;
  final bool isNasabah;
  final bool isLoading;

  const AuthState({
    this.phone,
    this.isNasabah = false,
    this.isLoading = false,
  });

  AuthState copyWith({String? phone, bool? isNasabah, bool? isLoading}) =>
      AuthState(
        phone: phone ?? this.phone,
        isNasabah: isNasabah ?? this.isNasabah,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> init() async {
    final phone = await StorageService.getPhone();
    final isNasabah = await StorageService.isNasabah();
    state = state.copyWith(phone: phone, isNasabah: isNasabah);
  }

  Future<void> setPhone(String phone) async {
    await StorageService.savePhone(phone);
    state = state.copyWith(phone: phone);
  }

  Future<void> setNasabah(bool val) async {
    await StorageService.setIsNasabah(val);
    state = state.copyWith(isNasabah: val);
  }

  Future<void> hapusAkun() async {
    await StorageService.clearAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
