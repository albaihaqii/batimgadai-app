import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../akun/booking_kunjungan_screen.dart';

class SimulasiScreen extends StatefulWidget {
  final bool isNasabah;
  const SimulasiScreen({super.key, this.isNasabah = false});

  @override
  State<SimulasiScreen> createState() => _SimulasiScreenState();
}

class _SimulasiScreenState extends State<SimulasiScreen> {
  int _step = 1;
  String? _kategori;
  String? _merk;
  String? _tipe;
  String? _kondisiValue;
  String? _kondisiLabel;
  bool _isLoadingOptions = true;
  bool _isLoadingMerks = false;
  bool _isLoadingTipe = false;
  bool _isEstimating = false;
  List<String> _kategoriOptions = [];
  List<String> _merkOptions = [];
  List<String> _tipeOptions = [];
  List<Map<String, String>> _kondisiOptions = [];
  Map<String, dynamic>? _estimateResult;
  final TextEditingController _namaBarangCtrl = TextEditingController();

  bool get _stepOneReady => _kategori != null;
  bool get _stepTwoReady => _kondisiValue != null;

  @override
  void initState() {
    super.initState();
    _namaBarangCtrl.addListener(() => setState(() {}));
    _loadOptions();
  }

  @override
  void dispose() {
    _namaBarangCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1 && _stepOneReady) {
      setState(() => _step = 2);
    }
  }

  Future<void> _loadOptions() async {
    try {
      final data = await ApiService.getSimulasiOptions();
      final kondisiRaw = data['kondisi'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _kategoriOptions =
            (data['kategori'] as List? ?? []).map((e) => e.toString()).toList();
        _kondisiOptions = kondisiRaw
            .map((e) => Map<String, String>.from({
                  'value': e['value'].toString(),
                  'label': e['label'].toString(),
                }))
            .toList();
        _isLoadingOptions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingOptions = false);
      _showSnack('Gagal memuat data simulasi dari API local.');
    }
  }

  Future<void> _loadMerks(String kategori) async {
    setState(() {
      _isLoadingMerks = true;
      _merkOptions = [];
      _tipeOptions = [];
      _merk = null;
      _tipe = null;
    });
    try {
      final data = await ApiService.getSimulasiMerks(kategori);
      if (!mounted) return;
      setState(() => _merkOptions = data);
    } catch (_) {
      if (mounted) _showSnack('Gagal memuat merk barang.');
    } finally {
      if (mounted) setState(() => _isLoadingMerks = false);
    }
  }

  Future<void> _loadTipeModels(String merk) async {
    if (_kategori == null) return;
    setState(() {
      _isLoadingTipe = true;
      _tipeOptions = [];
      _tipe = null;
    });
    try {
      final data = await ApiService.getSimulasiTipeModels(
        kategori: _kategori!,
        merk: merk,
      );
      if (!mounted) return;
      setState(() => _tipeOptions = data);
    } catch (_) {
      if (mounted) _showSnack('Gagal memuat tipe model.');
    } finally {
      if (mounted) setState(() => _isLoadingTipe = false);
    }
  }

  Future<void> _estimate() async {
    if (!_stepTwoReady || _kategori == null || _isEstimating) return;
    setState(() => _isEstimating = true);
    try {
      final result = await ApiService.estimateSimulasi(
        kategori: _kategori!,
        kondisi: _kondisiValue!,
        merk: _merk,
        tipeModel: _tipe,
      );
      if (!mounted) return;
      setState(() {
        _estimateResult = result;
        _step = 3;
      });
    } catch (_) {
      if (mounted) _showSnack('Gagal menghitung simulasi.');
    } finally {
      if (mounted) setState(() => _isEstimating = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _reset() {
    setState(() {
      _step = 1;
      _kategori = null;
      _merk = null;
      _tipe = null;
      _kondisiValue = null;
      _kondisiLabel = null;
      _estimateResult = null;
      _namaBarangCtrl.clear();
    });
  }

  Future<void> _pickValue({
    required String title,
    required List<String> values,
    required ValueChanged<String> onSelected,
  }) async {
    if (values.isEmpty) {
      _showSnack('Pilihan belum tersedia.');
      return;
    }
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _OptionSheet(title: title, values: values),
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB6D96C),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _Header(step: _step),
            Expanded(
              child: _isLoadingOptions
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _buildContent(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_step == 3) {
      return _ResultStep(
        key: const ValueKey('result'),
        kategori: _kategori ?? '-',
        merk: _merk ?? '-',
        namaBarang:
            _namaBarangCtrl.text.trim().isEmpty ? _tipe ?? '-' : _namaBarangCtrl.text.trim(),
        kondisi: _kondisiLabel ?? '-',
        result: _estimateResult,
        isNasabah: widget.isNasabah,
        onReset: _reset,
      );
    }

    if (_step == 2) {
      return _ServiceStep(
        key: const ValueKey('service'),
        selected: _kondisiValue,
        conditions: _kondisiOptions,
        onSelected: (value, label) => setState(() {
          _kondisiValue = value;
          _kondisiLabel = label;
        }),
        onNext: _estimate,
        onBack: () => setState(() => _step = 1),
        enabled: _stepTwoReady,
        isLoading: _isEstimating,
      );
    }

    return _FormStep(
      key: const ValueKey('form'),
      kategori: _kategori,
      merk: _merk,
      tipe: _tipe,
      namaBarangCtrl: _namaBarangCtrl,
      enabled: _stepOneReady,
      onPickKategori: () => _pickValue(
        title: 'Pilih Kategori',
        values: _kategoriOptions,
        onSelected: (value) {
          setState(() {
            _kategori = value;
            _merk = null;
            _tipe = null;
          });
          _loadMerks(value);
        },
      ),
      onPickMerk: () => _pickValue(
        title: 'Pilih Merk',
        values: _merkOptions,
        onSelected: (value) {
          setState(() {
            _merk = value;
            _tipe = null;
          });
          _loadTipeModels(value);
        },
      ),
      onPickTipe: () => _pickValue(
        title: 'Pilih Tipe Model',
        values: _tipeOptions,
        onSelected: (value) => setState(() => _tipe = value),
      ),
      isLoadingMerks: _isLoadingMerks,
      isLoadingTipe: _isLoadingTipe,
      onNext: _next,
    );
  }
}

String _formatRupiah(dynamic value) {
  final number = value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(number);
}

num _numberValue(dynamic value) {
  return value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
}

String _conditionSubtitle(String value) {
  switch (value) {
    case 'baik':
      return 'Mulai';
    case 'cukup':
      return 'Standar';
    case 'rusak_ringan':
      return 'Minus';
    default:
      return value;
  }
}

IconData _conditionIcon(String value) {
  switch (value) {
    case 'baik':
      return Icons.sentiment_satisfied_alt_rounded;
    case 'cukup':
      return Icons.sentiment_neutral_rounded;
    case 'rusak_ringan':
      return Icons.sentiment_dissatisfied_rounded;
    default:
      return Icons.verified_outlined;
  }
}

class _Header extends StatelessWidget {
  final int step;
  const _Header({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            children: [
              const Text(
                'Simulasi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                      child: _StepItem(
                          index: 1, label: 'Pilih Barang', currentStep: step)),
                  const _StepLine(),
                  Expanded(
                      child: _StepItem(
                          index: 2,
                          label: 'Kondisi Barang',
                          currentStep: step)),
                  const _StepLine(),
                  Expanded(
                      child: _StepItem(
                          index: 3,
                          label: 'Hasil Simulasi',
                          currentStep: step)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String label;
  final int currentStep;
  const _StepItem({
    required this.index,
    required this.label,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final active = currentStep >= index;
    final done = currentStep > index;

    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white.withValues(alpha: .6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.gray500,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.primary : const Color(0xFF7B9440),
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 22),
      color: const Color(0xFF8CB34F),
    );
  }
}

class _FormStep extends StatelessWidget {
  final String? kategori;
  final String? merk;
  final String? tipe;
  final TextEditingController namaBarangCtrl;
  final bool enabled;
  final VoidCallback onPickKategori;
  final VoidCallback onPickMerk;
  final VoidCallback onPickTipe;
  final VoidCallback onNext;
  final bool isLoadingMerks;
  final bool isLoadingTipe;

  const _FormStep({
    super.key,
    required this.kategori,
    required this.merk,
    required this.tipe,
    required this.namaBarangCtrl,
    required this.enabled,
    required this.onPickKategori,
    required this.onPickMerk,
    required this.onPickTipe,
    required this.onNext,
    required this.isLoadingMerks,
    required this.isLoadingTipe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Kategori'),
        const SizedBox(height: 6),
        _SelectField(
          value: kategori,
          hint: 'Pilih kategori barang',
          iconAsset: 'assets/icons/box-minimalistic.svg',
          onTap: onPickKategori,
        ),
        const SizedBox(height: 14),
        const _SectionLabel('Merk'),
        const SizedBox(height: 6),
        _SelectField(
          value: merk,
          hint: isLoadingMerks ? 'Memuat merk...' : 'Pilih merk barang',
          iconAsset: 'assets/icons/tag-price.svg',
          onTap: kategori == null || isLoadingMerks ? null : onPickMerk,
        ),
        const SizedBox(height: 14),
        const _SectionLabel('Nama / Tipe Barang'),
        const SizedBox(height: 6),
        _SelectField(
          value: tipe,
          hint: isLoadingTipe ? 'Memuat tipe model...' : 'Pilih nama / tipe barang',
          iconAsset: 'assets/icons/file-check.svg',
          onTap: merk == null || isLoadingTipe ? null : onPickTipe,
        ),
        const SizedBox(height: 14),
        const _InfoBanner(),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Lanjut',
          enabled: enabled,
          onTap: onNext,
          icon: Icons.arrow_forward_rounded,
        ),
      ],
    );
  }
}

class _ServiceStep extends StatelessWidget {
  final String? selected;
  final List<Map<String, String>> conditions;
  final void Function(String value, String label) onSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool enabled;
  final bool isLoading;

  const _ServiceStep({
    super.key,
    required this.selected,
    required this.conditions,
    required this.onSelected,
    required this.onNext,
    required this.onBack,
    required this.enabled,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Kondisi Barang'),
        const SizedBox(height: 8),
        Row(
          children: conditions
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: item == conditions.last ? 0 : 10,
                    ),
                    child: _ServiceCard(
                      title: item['label'] ?? '-',
                      subtitle: _conditionSubtitle(item['value'] ?? ''),
                      icon: _conditionIcon(item['value'] ?? ''),
                      selected: selected == item['value'],
                      onTap: () => onSelected(
                        item['value'] ?? '',
                        item['label'] ?? '-',
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        const _SectionLabel('Kondisi Fisik'),
        const SizedBox(height: 8),
        const _CheckGrid(
          items: [
            ('Layar Retak', false),
            ('Body Baret', true),
            ('Tombol Rusak', false),
            ('Kamera Rusak', false),
            ('Speaker Rusak', true),
            ('Baterai Bocor', false),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionLabel('Kelengkapan'),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ChipPill('Charger', selected: true),
            _ChipPill('Dus/Kotak', selected: true),
            _ChipPill('Sim Ejector', selected: true),
            _ChipPill('USB C'),
            _ChipPill('Manual Book', selected: true),
            _ChipPill('Earphone'),
          ],
        ),
        const SizedBox(height: 22),
        _PrimaryButton(
          label: isLoading ? 'Menghitung...' : 'Hitung Simulasi',
          enabled: enabled && !isLoading,
          onTap: onNext,
        ),
        const SizedBox(height: 10),
        _SecondaryButton(label: 'Kembali', onTap: onBack),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  final String kategori;
  final String merk;
  final String namaBarang;
  final String kondisi;
  final Map<String, dynamic>? result;
  final bool isNasabah;
  final VoidCallback onReset;

  const _ResultStep({
    super.key,
    required this.kategori,
    required this.merk,
    required this.namaBarang,
    required this.kondisi,
    required this.result,
    required this.isNasabah,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final taksiran = Map<String, dynamic>.from(result?['taksiran'] ?? {});
    final pinjaman = Map<String, dynamic>.from(result?['pinjaman'] ?? {});
    final totalData = result?['total_data'] ?? 0;
    final hasReference = totalData is num ? totalData > 0 : totalData != '0';
    final estimasiBawah = _formatRupiah(taksiran['rentang_bawah']);
    final estimasiAtas = _formatRupiah(taksiran['rentang_atas']);
    final rekomendasiAtas = _numberValue(pinjaman['rekomendasi_atas']);
    final estimasiJasa = rekomendasiAtas * 0.05;
    final totalTebus = rekomendasiAtas + estimasiJasa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: .28)),
          ),
          child: Column(
            children: [
              Text(
                hasReference
                    ? 'Estimasi nilai barang'
                    : 'Belum ada data referensi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: hasReference ? AppColors.gray600 : AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasReference ? estimasiBawah : '-',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasReference ? 's/d $estimasiAtas' : 'Data belum cukup',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ResultInfoCard(
          rows: [
            ('Estimasi Jasa / Bulan', hasReference ? _formatRupiah(estimasiJasa) : '-'),
            ('Masa Gadai', hasReference ? '30 Hari' : '-'),
            ('Estimasi Total Tebus', hasReference ? _formatRupiah(totalTebus) : '-'),
          ],
        ),
        const SizedBox(height: 14),
        _ResultInfoCard(
          rows: [
            ('Kategori', kategori),
            ('Merk', merk),
            ('Barang', namaBarang.isEmpty ? '-' : namaBarang),
            ('Kondisi', kondisi),
          ],
        ),
        const SizedBox(height: 16),
        _InfoBanner(
          text: hasReference
              ? 'Estimasi hanya perkiraan. Nilai sebenarnya akan ditentukan setelah pengecekan barang di outlet.'
              : 'Belum ada histori transaksi yang cocok dengan pilihan ini. Coba pilih kategori, merk, tipe, atau kondisi lain.',
        ),
        const SizedBox(height: 20),
        if (isNasabah) ...[
          _PrimaryButton(
            label: 'Booking Kunjungan',
            enabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BookingKunjunganScreen(),
              ),
            ),
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 10),
        ],
        _SecondaryButton(label: 'Hitung Ulang', onTap: onReset),
        if (!isNasabah) ...[
          const SizedBox(height: 8),
          const Text(
            'Login sebagai nasabah untuk booking kunjungan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.gray400,
            ),
          ),
        ],
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  final String? value;
  final String hint;
  final String iconAsset;
  final VoidCallback? onTap;

  const _SelectField({
    required this.value,
    required this.hint,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: disabled ? AppColors.gray50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                disabled ? AppColors.gray300 : AppColors.primary,
                BlendMode.srcIn,
              ),
              errorBuilder: (_, __, ___) => Icon(
                Icons.category_outlined,
                size: 18,
                color: disabled ? AppColors.gray300 : AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: value == null ? AppColors.gray400 : AppColors.gray900,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.gray900,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.gray400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 78,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.gray200,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.warning),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  const _ChipPill(this.label, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySurface : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: selected ? const Color(0xFFDCE8CF) : AppColors.gray200,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: selected ? AppColors.primary : AppColors.gray700,
        ),
      ),
    );
  }
}

class _CheckGrid extends StatelessWidget {
  final List<(String, bool)> items;
  const _CheckGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 36,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        final (label, checked) = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked ? AppColors.primaryLight : AppColors.gray300,
                  ),
                ),
                child: checked
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.gray900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({
    this.text =
        'Data harga diperbarui oleh tim BATIM GADAI. Hasil simulasi bersifat estimasi.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8EF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE8CF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.55,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultInfoCard extends StatelessWidget {
  final List<(String, String)> rows;
  const _ResultInfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          final (label, value) = rows[index];
          return Column(
            children: [
              _SummaryRow(label: label, value: value),
              if (index != rows.length - 1)
                const Divider(height: 1, color: AppColors.gray200),
            ],
          );
        }),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final IconData? icon;

  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: enabled ? AppColors.primaryLight : AppColors.buttonDisabled,
      foregroundColor: enabled ? AppColors.primary : AppColors.buttonDisabledText,
      disabledBackgroundColor: AppColors.buttonDisabled,
      disabledForegroundColor: AppColors.buttonDisabledText,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: icon == null
          ? ElevatedButton(
              onPressed: enabled ? onTap : null,
              style: style,
              child: Text(label),
            )
          : ElevatedButton.icon(
              onPressed: enabled ? onTap : null,
              icon: Icon(icon, size: 17),
              label: Text(label),
              style: style,
            ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.gray200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> values;

  const _OptionSheet({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: values.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    values[index],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.gray900,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(context, values[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
