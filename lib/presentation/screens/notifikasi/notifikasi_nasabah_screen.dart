import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
// import '../../../data/models/gadai_model.dart';
import '../../widgets/common/app_green_header.dart';

class NotifikasiNasabahScreen extends StatefulWidget {
  const NotifikasiNasabahScreen({super.key});

  @override
  State<NotifikasiNasabahScreen> createState() =>
      _NotifikasiNasabahScreenState();
}

class _NotifikasiNasabahScreenState extends State<NotifikasiNasabahScreen> {
  bool _loading = true;
  List<_NasabahNotif> _notifs = [];
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

      final items = <_NasabahNotif>[];

      // Notif dari data pinjaman lokal (jatuh tempo)
      if (noCif.isNotEmpty) {
        final pinjaman = await ApiService.getPinjamanNasabah(noCif);
        for (final g in pinjaman) {
          if (g.status == 'lunas') continue;
          final h = g.sisaHari;
          if (h > 7) continue;

          String title;
          String tipe;
          if (h < 0) {
            title = 'Jatuh Tempo Terlewat!';
            tipe = 'danger';
          } else if (h == 0) {
            title = 'Jatuh Tempo Hari Ini!';
            tipe = 'danger';
          } else if (h == 1) {
            title = 'Jatuh Tempo Besok!';
            tipe = 'danger';
          } else if (h <= 3) {
            title = 'Segera Jatuh Tempo (H-$h)';
            tipe = 'warning';
          } else {
            title = 'Pengingat Jatuh Tempo (H-$h)';
            tipe = 'info';
          }

          items.add(_NasabahNotif(
            title: title,
            body: h < 0
                ? '${g.namaDisplay} (${g.noSbg}) melewati jatuh tempo ${h.abs()} hari.'
                : '${g.namaDisplay} (${g.noSbg}) jatuh tempo ${g.tglJatuhTempoLabel}.',
            tipe: tipe,
            sub: 'Jatuh tempo: ${g.tglJatuhTempoLabel}',
            isRead: false,
          ));
        }
      }

      // Notif dari API backend (booking + info umum)
      final apiNotifs = await ApiService.getNotifikasi(noCif);
      for (final n in apiNotifs) {
        items.add(_NasabahNotif(
          title: n['judul'] as String? ?? 'Notifikasi',
          body: n['isi'] as String? ?? '',
          tipe: _mapTipe(n['tipe_notif'] as String? ?? 'info'),
          sub: n['created_at'] as String? ?? '',
          isRead: n['is_read'] as bool? ?? false,
          id: n['id'] as int?,
        ));
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

  String _mapTipe(String t) {
    switch (t) {
      case 'booking_kunjungan':
        return 'booking';
      case 'info':
        return 'info';
      default:
        return 'info';
    }
  }

  Future<void> _markRead(int id, int index) async {
    await ApiService.markNotifikasiRead(id);
    if (mounted) {
      setState(() {
        _notifs[index] = _notifs[index].copyWith(isRead: true);
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
        body: Column(children: [
          const AppGreenHeader(title: 'Notifikasi'),
          Expanded(child: _buildBody()),
        ]),
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
      return _buildError();
    }
    if (_notifs.isEmpty) {
      return _buildEmpty();
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _notifs.length,
        itemBuilder: (_, i) {
          final n = _notifs[i];
          return GestureDetector(
            onTap: n.id != null && !n.isRead ? () => _markRead(n.id!, i) : null,
            child: _NasabahNotifCard(notif: n),
          );
        },
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFFDC2626), size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Gagal Memuat Notifikasi',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F5C3A))),
            ),
          ]),
        ),
      );

  Widget _buildEmpty() => Center(
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
              'Notifikasi jatuh tempo, booking kunjungan, dan info terbaru akan muncul di sini.',
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

class _NasabahNotif {
  final String title, body, tipe, sub;
  final bool isRead;
  final int? id;

  const _NasabahNotif({
    required this.title,
    required this.body,
    required this.tipe,
    required this.sub,
    required this.isRead,
    this.id,
  });

  _NasabahNotif copyWith({bool? isRead}) => _NasabahNotif(
        title: title,
        body: body,
        tipe: tipe,
        sub: sub,
        isRead: isRead ?? this.isRead,
        id: id,
      );
}

class _NasabahNotifCard extends StatelessWidget {
  final _NasabahNotif notif;
  const _NasabahNotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final Color iconBg;
    final Color iconColor;
    final Color borderColor;
    final IconData icon;

    switch (notif.tipe) {
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
      case 'booking':
        iconBg = AppColors.primarySurface;
        iconColor = AppColors.primary;
        borderColor = const Color(0xFFB6D96C);
        icon = Icons.calendar_today_rounded;
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
        color: notif.isRead ? Colors.white : const Color(0xFFF8FFF4),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(notif.title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
            ]),
            const SizedBox(height: 4),
            Text(notif.body,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF555555),
                    height: 1.5)),
            if (notif.sub.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(notif.sub,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF9E9E9E))),
            ],
          ]),
        ),
      ]),
    );
  }
}
