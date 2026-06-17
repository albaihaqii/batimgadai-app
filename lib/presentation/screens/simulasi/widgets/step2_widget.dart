import 'package:flutter/material.dart';

class Step2Widget extends StatefulWidget {
  final List<Map<String, dynamic>> kelengkapanList;
  final List<Map<String, dynamic>> kecacatanList;
  final String kategoriLabel;
  final VoidCallback onBack;
  final void Function(String kondisi, Set<int> klIds, Set<int> kcIds) onNext;
  final bool loading;
  final String? error;

  const Step2Widget({
    super.key,
    required this.kelengkapanList,
    required this.kecacatanList,
    required this.kategoriLabel,
    required this.onBack,
    required this.onNext,
    required this.loading,
    this.error,
  });

  @override
  State<Step2Widget> createState() => _Step2WidgetState();
}

class _Step2WidgetState extends State<Step2Widget> {
  String? _kondisi;
  final Set<int> _kl = {};
  final Set<int> _kc = {};

  static const _dark = Color(0xFF1F5C3A);
  static const _border = Color(0xFFE0E0E0);
  static const _soft = Color(0xFFF4F8EF);

  static const _kondisiOpts = [
    {'v': 'baik', 'label': 'Baik', 'emoji': '😊'},
    {'v': 'cukup', 'label': 'Cukup', 'emoji': '😐'},
    {'v': 'rusak_ringan', 'label': 'Rusak Ringan', 'emoji': '😟'},
  ];

  bool get _canNext => _kondisi != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Kondisi Barang ─────────────────────────────────────
        const _SLbl('Kondisi Barang'),
        const SizedBox(height: 10),
        Row(
            children: List.generate(_kondisiOpts.length, (i) {
          final o = _kondisiOpts[i];
          final v = o['v']!;
          final sel = _kondisi == v;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _kondisi = v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? _soft : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel ? _dark : _border, width: sel ? 2 : 1.5),
                  ),
                  child: Column(children: [
                    Text(o['emoji']!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(o['label']!,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sel ? _dark : const Color(0xFF1A1A1A))),
                  ]),
                ),
              ),
            ),
          );
        })),

        // ── Kelengkapan ────────────────────────────────────────
        if (widget.kelengkapanList.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SLbl('Kelengkapan'),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.kelengkapanList.map((k) {
                final id = (k['id'] as num).toInt();
                final sel = _kl.contains(id);
                return _Chip(
                    label: k['label'] as String,
                    selected: sel,
                    onTap: () => setState(() {
                          if (sel)
                            _kl.remove(id);
                          else
                            _kl.add(id);
                        }));
              }).toList()),
        ],

        // ── Kecacatan ──────────────────────────────────────────
        if (widget.kecacatanList.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _SLbl('Kecacatan'),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.kecacatanList.map((k) {
                final id = (k['id'] as num).toInt();
                final sel = _kc.contains(id);
                return _Chip(
                    label: k['label'] as String,
                    selected: sel,
                    onTap: () => setState(() {
                          if (sel)
                            _kc.remove(id);
                          else
                            _kc.add(id);
                        }));
              }).toList()),
        ],

        // ── Error ──────────────────────────────────────────────
        if (widget.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5))),
            child: Row(children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFDC2626), size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(widget.error!,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFFDC2626)))),
            ]),
          ),
        ],

        const SizedBox(height: 24),

        // ── Hitung Simulasi ────────────────────────────────────
        _AppBtn(
          label: 'Hitung Simulasi',
          enabled: _canNext,
          onTap: _canNext
              ? () => widget.onNext(_kondisi!, Set.from(_kl), Set.from(_kc))
              : null,
          loading: widget.loading,
        ),
        const SizedBox(height: 10),

        // ── Kembali ────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: widget.loading ? null : widget.onBack,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kembali',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
          ),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFDCE8CF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected
                    ? const Color(0xFFDCE8CF)
                    : const Color(0xFFE0E0E0),
                width: 1.5),
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF1F5C3A)
                      : const Color(0xFF1A1A1A))),
        ),
      );
}

class _SLbl extends StatelessWidget {
  final String t;
  const _SLbl(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A)));
}

class _AppBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final bool loading;
  const _AppBtn(
      {required this.label,
      required this.enabled,
      this.onTap,
      this.loading = false});
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Color(0xFF1F5C3A), strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
        ),
      );
}
