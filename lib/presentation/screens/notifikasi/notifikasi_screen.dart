import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../widgets/common/app_green_header.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _loading = true;
  List<_NotifItem> _notifs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final nasabah = await StorageService.getNasabah();
      final noCif = nasabah?['no_cif'] as String? ?? '';
      if (noCif.isEmpty) {
        if (mounted)
          setState(() {
            _loading = false;
            _notifs = [];
          });
        return;
      }

      final pinjaman = await ApiService.getPinjamanNasabah(noCif);
      final items = <_NotifItem>[];

      for (final g in pinjaman) {
        if (g.status == 'lunas') continue;
        final h = g.sisaHari;

        if (h < 0) {
          items.add(_NotifItem(
            title: 'Jatuh Tempo Terlewat!',
            body:
                '${g.namaDisplay} (${g.noSbg}) melewati jatuh tempo ${h.abs()} hari.',
            tipe: 'danger',
            tgl: g.tglJatuhTempoLabel,
          ));
        } else if (h == 0) {
          items.add(_NotifItem(
            title: 'Jatuh Tempo Hari Ini!',
            body:
                '${g.namaDisplay} (${g.noSbg}) jatuh tempo hari ini. Segera bayar.',
            tipe: 'danger',
            tgl: g.tglJatuhTempoLabel,
          ));
        } else if (h == 1) {
          items.add(_NotifItem(
            title: 'Jatuh Tempo Besok!',
            body:
                '${g.namaDisplay} (${g.noSbg}) jatuh tempo besok, ${g.tglJatuhTempoLabel}.',
            tipe: 'danger',
            tgl: g.tglJatuhTempoLabel,
          ));
        } else if (h <= 3) {
          items.add(_NotifItem(
            title: 'Segera Jatuh Tempo (H-$h)',
            body:
                '${g.namaDisplay} (${g.noSbg}) jatuh tempo ${g.tglJatuhTempoLabel}.',
            tipe: 'warning',
            tgl: g.tglJatuhTempoLabel,
          ));
        } else if (h <= 7) {
          items.add(_NotifItem(
            title: 'Pengingat Jatuh Tempo (H-$h)',
            body:
                '${g.namaDisplay} (${g.noSbg}) akan jatuh tempo ${g.tglJatuhTempoLabel}.',
            tipe: 'info',
            tgl: g.tglJatuhTempoLabel,
          ));
        }
      }

      if (mounted)
        setState(() {
          _notifs = items;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB6D96C),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            const AppGreenHeader(title: 'Notifikasi'),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF555555))));
    }
    if (_notifs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: AppColors.primarySurface, shape: BoxShape.circle),
              child: Center(
                child: SvgPicture.asset('assets/icons/bell.svg',
                    width: 40,
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Belum Ada Notifikasi',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 8),
            const Text(
              'Notifikasi jatuh tempo dan transaksi akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  height: 1.6),
            ),
          ]),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _notifs.length,
        itemBuilder: (_, i) => _NotifCard(item: _notifs[i]),
      ),
    );
  }
}

class _NotifItem {
  final String title;
  final String body;
  final String tipe;
  final String tgl;
  const _NotifItem({
    required this.title,
    required this.body,
    required this.tipe,
    required this.tgl,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color iconBg;
    final Color iconColor;
    final Color borderColor;
    final IconData icon;

    switch (item.tipe) {
      case 'danger':
        iconBg = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        borderColor = const Color(0xFFFCA5A5);
        icon = Icons.warning_amber_rounded;
        break;
      case 'warning':
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        borderColor = const Color(0xFFFCD34D);
        icon = Icons.access_time_rounded;
        break;
      default:
        iconBg = AppColors.primarySurface;
        iconColor = AppColors.primary;
        borderColor = const Color(0xFFB6D96C);
        icon = Icons.notifications_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                const SizedBox(height: 4),
                Text(item.body,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF555555),
                        height: 1.5)),
                const SizedBox(height: 6),
                Text('Jatuh tempo: ${item.tgl}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
