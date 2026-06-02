import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../widgets/common/app_green_header.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];
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
        if (mounted) setState(() => _loading = false);
        return;
      }
      final data = await ApiService.getBookingList(noCif);
      if (mounted)
        setState(() {
          _bookings = data;
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
        body: Column(children: [
          const AppGreenHeader(title: 'Booking Kunjungan'),
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
    if (_bookings.isEmpty) {
      return _buildEmpty();
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _bookings.length,
        itemBuilder: (_, i) => _BookingCard(booking: _bookings[i]),
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
            const Text('Gagal Memuat Data',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
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
              child: const Icon(Icons.calendar_today_outlined,
                  color: AppColors.primary, size: 38),
            ),
            const SizedBox(height: 20),
            const Text('Belum Ada Booking',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 8),
            const Text(
                'Lakukan simulasi estimasi gadai dan booking kunjungan ke cabang terdekat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    height: 1.6)),
          ]),
        ),
      );
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String? ?? 'menunggu';
    final cfg = _statusConfig(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(
            child: Text(booking['no_booking'] as String? ?? '-',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: cfg['bg'] as Color,
                borderRadius: BorderRadius.circular(20)),
            child: Text(cfg['label'] as String,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cfg['color'] as Color)),
          ),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        const SizedBox(height: 10),

        // Info
        _InfoRow(
            icon: Icons.store_rounded,
            label: booking['cabang'] as String? ?? '-'),
        const SizedBox(height: 6),
        _InfoRow(
          icon: Icons.calendar_today_rounded,
          label: '${booking['tgl_kunjungan']}  •  ${booking['jam_kunjungan']}',
        ),
        const SizedBox(height: 6),
        _InfoRow(
            icon: Icons.task_alt_rounded,
            label: booking['keperluan'] as String? ?? '-'),

        // Catatan admin jika ada
        if ((booking['catatan_admin'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline,
                  size: 14, color: Color(0xFF9E9E9E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Catatan: ${booking['catatan_admin']}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF555555),
                        height: 1.5)),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Map<String, dynamic> _statusConfig(String status) {
    switch (status) {
      case 'dikonfirmasi':
        return {
          'label': 'Dikonfirmasi',
          'color': AppColors.primary,
          'bg': AppColors.primarySurface
        };
      case 'ditolak':
        return {
          'label': 'Ditolak',
          'color': const Color(0xFFDC2626),
          'bg': const Color(0xFFFEE2E2)
        };
      case 'selesai':
        return {
          'label': 'Selesai',
          'color': const Color(0xFF6B7280),
          'bg': const Color(0xFFF3F4F6)
        };
      default:
        return {
          'label': 'Menunggu',
          'color': const Color(0xFFD97706),
          'bg': const Color(0xFFFEF3C7)
        };
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF555555)))),
      ]);
}
