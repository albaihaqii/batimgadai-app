import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Step1Widget extends StatefulWidget {
  final Map<String, String> kategoriMap;
  final void Function(String kategori, int harga, String nama) onNext;
  const Step1Widget(
      {super.key, required this.kategoriMap, required this.onNext});

  @override
  State<Step1Widget> createState() => _Step1WidgetState();
}

class _Step1WidgetState extends State<Step1Widget> {
  String? _katKey, _katLabel;
  final _hargaCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();

  static const _dark = Color(0xFF1F5C3A);
  static const _border = Color(0xFFE5E7EB);
  static const _hint = Color(0xFFBBBBBB);

  @override
  void initState() {
    super.initState();
    _hargaCtrl.addListener(_fmt);
  }

  @override
  void dispose() {
    _hargaCtrl.removeListener(_fmt);
    _hargaCtrl.dispose();
    _namaCtrl.dispose();
    super.dispose();
  }

  void _fmt() {
    final raw = _hargaCtrl.text.replaceAll('.', '').replaceAll(',', '');
    if (raw.isEmpty) {
      setState(() {});
      return;
    }
    final n = int.tryParse(raw);
    if (n == null) return;
    final s = NumberFormat('#,###', 'id_ID').format(n);
    if (_hargaCtrl.text != s) {
      _hargaCtrl.value = TextEditingValue(
          text: s, selection: TextSelection.collapsed(offset: s.length));
    }
    setState(() {});
  }

  int get _hargaInt {
    final raw = _hargaCtrl.text.replaceAll('.', '').replaceAll(',', '');
    return int.tryParse(raw) ?? 0;
  }

  bool get _valid =>
      _katKey != null &&
      _hargaInt >= 100000 &&
      _namaCtrl.text.trim().isNotEmpty;

  // Sama dengan phone_input: border radius 12, border Color(0xFFE5E7EB)
  OutlineInputBorder _ob(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        // padding top 16 — langsung mepet header, tidak ada space kosong
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Kategori ───────────────────────────────────────────
          _Lbl('Kategori'),
          const SizedBox(height: 8),
          _KatDropdown(
            hint: 'Pilih kategori barang',
            selected: _katLabel,
            items: widget.kategoriMap.entries
                .map((e) => _KO(e.key, e.value))
                .toList(),
            onSelect: (o) => setState(() {
              _katKey = o.k;
              _katLabel = o.v;
            }),
          ),
          const SizedBox(height: 16),

          // ── Harga Pasar ────────────────────────────────────────
          _Lbl('Harga Pasar'),
          const SizedBox(height: 8),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(children: [
              const Padding(
                padding: EdgeInsets.only(left: 14, right: 4),
                child: Text('Rp.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF555555))),
              ),
              Expanded(
                child: TextField(
                  controller: _hargaCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A)),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                        fontFamily: 'Poppins', fontSize: 14, color: _hint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                    isDense: true,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Nama Barang ────────────────────────────────────────
          _Lbl('Nama Barang'),
          const SizedBox(height: 8),
          TextField(
            controller: _namaCtrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: 'Masukkan nama barang Anda',
              hintStyle: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 14, color: _hint),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: _ob(_border),
              enabledBorder: _ob(_border),
              focusedBorder: _ob(_dark),
              suffixIcon: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC), size: 20),
            ),
          ),
          const SizedBox(height: 24),

          // ── Button — pakai AppButton style (radius 14) ─────────
          _AppBtn(
              label: 'Lanjut  →',
              enabled: _valid,
              onTap: _valid
                  ? () =>
                      widget.onNext(_katKey!, _hargaInt, _namaCtrl.text.trim())
                  : null),
        ]),
      ),
    );
  }
}

// ── KV option ─────────────────────────────────────────────────────────────────
class _KO {
  final String k, v;
  const _KO(this.k, this.v);
}

// ── Kategori overlay dropdown ─────────────────────────────────────────────────
class _KatDropdown extends StatefulWidget {
  final String hint;
  final String? selected;
  final List<_KO> items;
  final ValueChanged<_KO> onSelect;
  const _KatDropdown(
      {required this.hint,
      required this.selected,
      required this.items,
      required this.onSelect});
  @override
  State<_KatDropdown> createState() => _KatDropdownState();
}

class _KatDropdownState extends State<_KatDropdown>
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _dark, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.items.length,
                          itemBuilder: (_, i) {
                            final o = widget.items[i];
                            final s = widget.selected == o.v;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                widget.onSelect(o);
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
                                child: Text(o.v,
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
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _open ? _dark : const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.category_outlined,
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
}

// ── Shared label ──────────────────────────────────────────────────────────────
class _Lbl extends StatelessWidget {
  final String t;
  const _Lbl(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333)));
}

// ── AppButton style (radius 14, konsisten dengan phone_input) ─────────────────
class _AppBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  const _AppBtn({required this.label, required this.enabled, this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB6D96C),
            foregroundColor: const Color(0xFF1F5C3A),
            disabledBackgroundColor: const Color(0xFFDBDBDB),
            disabledForegroundColor: const Color(0xFF263238),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
