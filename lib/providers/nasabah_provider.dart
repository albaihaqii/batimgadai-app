import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';

class NasabahState {
  final String? nama;
  final String? noCif;
  final String? noKtp;
  final String? noHp;
  final String? alamat;
  final String? cabang;
  final bool loaded;

  const NasabahState({
    this.nama,
    this.noCif,
    this.noKtp,
    this.noHp,
    this.alamat,
    this.cabang,
    this.loaded = false,
  });

  factory NasabahState.fromMap(Map<String, dynamic> map) => NasabahState(
        nama: map['nama'],
        noCif: map['no_cif'],
        noKtp: map['no_ktp'],
        noHp: map['no_hp'],
        alamat: map['alamat'],
        cabang: map['cabang']?['nama'],
        loaded: true,
      );
}

class NasabahNotifier extends StateNotifier<NasabahState> {
  NasabahNotifier() : super(const NasabahState());

  Future<void> init() async {
    final data = await StorageService.getNasabah();
    if (data != null) {
      state = NasabahState.fromMap(data);
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    await StorageService.saveNasabah(data);
    state = NasabahState.fromMap(data);
  }

  Future<void> clear() async {
    await StorageService.saveNasabah({});
    state = const NasabahState();
  }
}

final nasabahProvider = StateNotifierProvider<NasabahNotifier, NasabahState>(
  (ref) => NasabahNotifier(),
);
