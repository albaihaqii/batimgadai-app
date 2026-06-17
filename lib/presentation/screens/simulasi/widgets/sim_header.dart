import 'package:flutter/material.dart';

class SimHeader extends StatelessWidget {
  final int step; // 0,1,2
  const SimHeader({super.key, required this.step});

  static const _labels = ['Pilih Kategori', 'Kondisi Barang', 'Hasil Simulasi'];
  static const _bg = Color(0xFFB6D96C);
  static const _dark = Color(0xFF1F5C3A);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Simulasi',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _dark)),
            const SizedBox(height: 12),
            Row(
                children: List.generate(5, (i) {
              if (i.isOdd) {
                final done = step > i ~/ 2;
                return Expanded(
                  child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: done ? _dark : _dark.withOpacity(0.2)),
                );
              }
              final idx = i ~/ 2;
              final isActive = step == idx;
              final isDone = step > idx;
              return Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (isActive || isDone) ? _dark : _dark.withOpacity(0.18),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : Text('${idx + 1}',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : _dark.withOpacity(0.5))),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_labels[idx],
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.5,
                        fontWeight: (isActive || isDone)
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _dark
                            .withOpacity((isActive || isDone) ? 1.0 : 0.5))),
              ]);
            })),
          ]),
        ),
      ),
    );
  }
}
