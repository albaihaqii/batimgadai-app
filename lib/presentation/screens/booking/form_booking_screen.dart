import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';

class FormBookingScreen extends StatefulWidget {
  final String noCif;
  final Map<String, dynamic>? hasilSimulasi;
  final String? kategori;

  const FormBookingScreen({
    super.key,
    required this.noCif,
    this.hasilSimulasi,
    this.kategori,
  });

  @override
  State<FormBookingScreen> createState() => _FormBookingScreenState();
}

class _FormBookingScreenState extends State<FormBookingScreen> {
  final _catatanCtrl = TextEditingController();

  DateTime? _tgl;
  String? _jam;
  String? _keperluan;
  int? _cabangId;
  String? _cabangNama;

  List<Map<String, dynamic>> _cabangList = [];
  bool _loadingCabang = true;
  bool _submitting = false;
  String? _error;

  static const _bg = Color(0xFFB6D96C);
  static const _dark = Color(0xFF1F5C3A);
  static const _border = Color(0xFFE5E7EB);
  static const _soft = Color(0xFFF4F8EF);
  static const _sel = Color(0xFFDCE8CF);

  static const _jamOpts = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];
  static const _keperluanOpts = [
    'Gadai Baru',
    'Perpanjang Gadai',
    'Tebus Barang',
    'Cicil Tebus',
    'Tanya Info Gadai',
    'Konsultasi Taksiran',
    'Lainnya',
  ];
  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _loadCabang();
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCabang() async {
    try {
      final data = await ApiService.getCabang();
      if (mounted)
        setState(() {
          _cabangList = data
              .map<Map<String, dynamic>>(
                  (c) => <String, dynamic>{'id': c.id, 'nama': c.nama})
              .toList();
          _loadingCabang = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingCabang = false);
    }
  }

  Future<void> _submit() async {
    if (_cabangId == null) {
      setState(() => _error = 'Pilih cabang tujuan.');
      return;
    }
    if (_tgl == null) {
      setState(() => _error = 'Pilih tanggal kunjungan.');
      return;
    }
    if (_jam == null) {
      setState(() => _error = 'Pilih jam kunjungan.');
      return;
    }
    if (_keperluan == null) {
      setState(() => _error = 'Pilih keperluan.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final h = widget.hasilSimulasi;
      await ApiService.submitBooking({
        'no_cif': widget.noCif,
        'cabang_id': _cabangId,
        'tgl_kunjungan': DateFormat('yyyy-MM-dd').format(_tgl!),
        'jam_kunjungan': _jam,
        'keperluan': _keperluan,
        'catatan_nasabah':
            _catatanCtrl.text.trim().isEmpty ? null : _catatanCtrl.text.trim(),
        'kategori_barang': widget.kategori,
        'estimasi_min': h?['nilai_min'],
        'estimasi_max': h?['nilai_max'],
        'harga_pasar': h?['harga_pasar'],
      });
      if (mounted) _showSuccess();
    } catch (_) {
      if (mounted)
        setState(() {
          _submitting = false;
          _error = 'Gagal mengajukan booking. Coba lagi.';
        });
    }
  }

  void _showSuccess() => showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => _SuccessSheet(onKembali: () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }),
      );

  void _openDatePicker() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _DateSheet(
            initialDate: _tgl, onConfirm: (d) => setState(() => _tgl = d)),
      );

  String _fmtTgl(DateTime d) {
    const h = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return '${h[d.weekday % 7]}, ${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  OutlineInputBorder _ob(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c));

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: _bg, statusBarIconBrightness: Brightness.dark),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            // ── Header — konsisten dengan SyaratKetentuan (AppBar style) ──
            Container(
              color: _bg,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 52,
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: _dark, size: 22),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 52, minHeight: 52),
                    ),
                    const Expanded(
                        child: Text('Booking Kunjungan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _dark))),
                    const SizedBox(width: 52),
                  ]),
                ),
              ),
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  // top 16 — langsung mepet header
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Simulasi summary
                        if (widget.hasilSimulasi != null) ...[
                          _SimSummary(
                              hasil: widget.hasilSimulasi!,
                              kategori: widget.kategori ?? '-'),
                          const SizedBox(height: 16),
                        ],

                        // ── Cabang ────────────────────────────────────────
                        _FL('Pilih Cabang Tujuan'),
                        const SizedBox(height: 8),
                        _loadingCabang
                            ? const Center(
                                child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: CircularProgressIndicator(
                                        color: _dark, strokeWidth: 2)))
                            : _StrDropdown(
                                hint: 'Pilih cabang tujuan',
                                selected: _cabangNama,
                                items: _cabangList
                                    .map((c) => c['nama'] as String)
                                    .toList(),
                                onSelect: (nama) {
                                  final f = _cabangList
                                      .cast<Map<String, dynamic>>()
                                      .firstWhere((c) => c['nama'] == nama,
                                          orElse: () => <String, dynamic>{});
                                  if (f.isNotEmpty)
                                    setState(() {
                                      _cabangId = f['id'] as int;
                                      _cabangNama = nama;
                                    });
                                },
                              ),
                        const SizedBox(height: 16),

                        // ── Tanggal ───────────────────────────────────────
                        _FL('Tanggal Kunjungan'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _openDatePicker,
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border)),
                            child: Row(children: [
                              Expanded(
                                  child: Text(
                                _tgl != null
                                    ? _fmtTgl(_tgl!)
                                    : 'Pilih tanggal kunjungan',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: _tgl != null
                                        ? const Color(0xFF1A1A1A)
                                        : const Color(0xFFBBBBBB)),
                              )),
                              const Icon(Icons.calendar_today_outlined,
                                  size: 17, color: Color(0xFFBBBBBB)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Jam Kunjungan — label langsung mepet grid ─────
                        _FL('Jam Kunjungan'),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.6,
                          ),
                          itemCount: _jamOpts.length,
                          itemBuilder: (_, i) {
                            final jam = _jamOpts[i];
                            final sel = _jam == jam;
                            return GestureDetector(
                              onTap: () => setState(() => _jam = jam),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: sel ? _bg : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: sel ? _bg : _border),
                                ),
                                child: Text(jam,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: sel
                                            ? _dark
                                            : const Color(0xFF1A1A1A))),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Keperluan ─────────────────────────────────────
                        _FL('Keperluan'),
                        const SizedBox(height: 8),
                        _StrDropdown(
                          hint: 'Pilih keperluan kunjungan',
                          selected: _keperluan,
                          items: _keperluanOpts.toList(),
                          onSelect: (v) => setState(() => _keperluan = v),
                        ),
                        const SizedBox(height: 16),

                        // ── Catatan ───────────────────────────────────────
                        _FL('Catatan'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _catatanCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 14),
                          decoration: InputDecoration(
                            hintText:
                                'Tambahkan catatan untuk petugas (Opsional)',
                            hintStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Color(0xFFBBBBBB)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(14),
                            border: _ob(_border),
                            enabledBorder: _ob(_border),
                            focusedBorder: _ob(_dark),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Error ─────────────────────────────────────────
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFFCA5A5))),
                            child: Row(children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFDC2626), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Color(0xFFDC2626)))),
                            ]),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ── Submit ────────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _bg,
                              foregroundColor: _dark,
                              disabledBackgroundColor: const Color(0xFFDBDBDB),
                              disabledForegroundColor: const Color(0xFF263238),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: _dark, strokeWidth: 2))
                                : const Text('Ajukan Booking  →',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ]),
        ),
      );
}

// ── Success sheet ─────────────────────────────────────────────────────────────
class _SuccessSheet extends StatelessWidget {
  final VoidCallback onKembali;
  const _SuccessSheet({required this.onKembali});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 28),
          Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: Color(0xFFF4F8EF), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF1F5C3A), size: 32)),
          const SizedBox(height: 16),
          const Text('Booking Berhasil',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
          const SizedBox(height: 8),
          const Text(
            'Booking kunjungan Anda sudah diterima. Petugas akan '
            'menginformasikan jadwal kunjungan Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF757575),
                height: 1.6),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onKembali,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6D96C),
                  foregroundColor: const Color(0xFF1F5C3A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: const Text('Kembali ke Beranda',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );
}

// ── String overlay dropdown ───────────────────────────────────────────────────
class _StrDropdown extends StatefulWidget {
  final String hint;
  final String? selected;
  final List<String> items;
  final ValueChanged<String> onSelect;
  const _StrDropdown(
      {required this.hint,
      required this.selected,
      required this.items,
      required this.onSelect});
  @override
  State<_StrDropdown> createState() => _StrDropdownState();
}

class _StrDropdownState extends State<_StrDropdown>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();
  OverlayEntry? _e;
  late AnimationController _ac;
  late Animation<double> _fade, _ty, _arrow;
  bool _open = false;

  static const _dark = Color(0xFF1F5C3A);
  static const _border = Color(0xFFE5E7EB);
  static const _sel = Color(0xFFDCE8CF);

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ty = Tween<double>(begin: -6, end: 0)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _arrow = Tween<double>(begin: 0, end: .5)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _rm();
    _ac.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _show();

  void _show() {
    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final off = box.localToGlobal(Offset.zero);
    final sz = box.size;
    final mh = (widget.items.length * 46.0).clamp(0.0, 220.0);

    _e = OverlayEntry(
        builder: (_) => Stack(children: [
              Positioned.fill(
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent, onTap: _close)),
              Positioned(
                left: off.dx,
                top: off.dy + sz.height + 4,
                width: sz.width,
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (_, child) => Opacity(
                      opacity: _fade.value,
                      child: Transform.translate(
                          offset: Offset(0, _ty.value), child: child)),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: mh),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _dark, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.09),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: widget.items.length,
                          itemBuilder: (_, i) {
                            final item = widget.items[i];
                            final s = widget.selected == item;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                widget.onSelect(item);
                                _close();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                  color: s ? _sel : Colors.white,
                                  border: i < widget.items.length - 1
                                      ? const Border(
                                          bottom: BorderSide(
                                              color: Color(0xFFF0F0F0)))
                                      : null,
                                ),
                                child: Text(item,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: s
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: s
                                            ? _dark
                                            : const Color(0xFF1A1A1A))),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]));
    Overlay.of(context).insert(_e!);
    setState(() => _open = true);
    _ac.forward();
  }

  void _close() {
    _ac.reverse().then((_) {
      _rm();
      if (mounted) setState(() => _open = false);
    });
  }

  void _rm() {
    _e?.remove();
    _e = null;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: _key,
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _open ? _dark : _border),
          ),
          child: Row(children: [
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFFAAAAAA))),
            const SizedBox(width: 10),
            Expanded(
                child: Text(widget.selected ?? widget.hint,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: widget.selected != null
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFBBBBBB)))),
            RotationTransition(
                turns: _arrow,
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF555555), size: 22)),
          ]),
        ),
      );
}

// ── Date picker sheet ─────────────────────────────────────────────────────────
class _DateSheet extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onConfirm;
  const _DateSheet({this.initialDate, required this.onConfirm});
  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late int _y, _m;
  DateTime? _sel;

  static const _days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  static const _mons = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _green = Color(0xFFB6D96C);
  static const _dark = Color(0xFF1F5C3A);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _sel = widget.initialDate;
    _y = widget.initialDate?.year ?? now.year;
    _m = widget.initialDate?.month ?? now.month;
  }

  void _chMon(int d) => setState(() {
        _m += d;
        if (_m < 1) {
          _m = 12;
          _y--;
        }
        if (_m > 12) {
          _m = 1;
          _y++;
        }
      });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tod0 = DateTime(today.year, today.month, today.day);
    final first = DateTime(_y, _m, 1).weekday % 7;
    final days = DateTime(_y, _m + 1, 0).day;

    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Pilih Tanggal',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          Row(children: [
            _Nb(icon: Icons.chevron_left_rounded, onTap: () => _chMon(-1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${_mons[_m - 1]} $_y',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
            ),
            _Nb(icon: Icons.chevron_right_rounded, onTap: () => _chMon(1)),
          ]),
        ]),
        const SizedBox(height: 12),
        Row(
            children: _days
                .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E))))))
                .toList()),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1),
          itemCount: first + days,
          itemBuilder: (_, i) {
            if (i < first) return const SizedBox();
            final day = i - first + 1;
            final date = DateTime(_y, _m, day);
            final past = date.isBefore(tod0);
            final isSel = _sel != null &&
                _sel!.year == date.year &&
                _sel!.month == date.month &&
                _sel!.day == date.day;
            final isToday = date == tod0;
            return GestureDetector(
              onTap: past ? null : () => setState(() => _sel = date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSel ? _green : Colors.transparent),
                child: Center(
                    child: Text('$day',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: (isSel || isToday)
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: past
                                ? const Color(0xFFCCCCCC)
                                : isSel
                                    ? _dark
                                    : isToday
                                        ? _dark
                                        : const Color(0xFF1A1A1A)))),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _sel == null
                ? null
                : () {
                    widget.onConfirm(_sel!);
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: _dark,
                disabledBackgroundColor: const Color(0xFFDBDBDB),
                disabledForegroundColor: const Color(0xFF263238),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            child: const Text('Pilih Tanggal',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

class _Nb extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Nb({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 17, color: const Color(0xFF1A1A1A))),
      );
}

// ── Simulasi summary card ─────────────────────────────────────────────────────
class _SimSummary extends StatelessWidget {
  final Map<String, dynamic> hasil;
  final String kategori;
  const _SimSummary({required this.hasil, required this.kategori});
  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final mn = (hasil['nilai_min'] as num?)?.toInt() ?? 0;
    final mx = (hasil['nilai_max'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8EF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDCE8CF))),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFFB6D96C),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calculate_rounded,
                color: Color(0xFF1F5C3A), size: 20)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(kategori,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F5C3A))),
          const SizedBox(height: 2),
          Text('${fmt.format(mn)} — ${fmt.format(mx)}',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
        ])),
      ]),
    );
  }
}

class _FL extends StatelessWidget {
  final String t;
  const _FL(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333)));
}
