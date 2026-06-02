import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/cabang_model.dart';

class DetailCabangScreen extends StatefulWidget {
  final CabangModel cabang;
  const DetailCabangScreen({super.key, required this.cabang});

  @override
  State<DetailCabangScreen> createState() => _DetailCabangScreenState();
}

class _DetailCabangScreenState extends State<DetailCabangScreen> {
  final _mapCompleter = Completer<GoogleMapController>();
  CabangModel get _c => widget.cabang;

  static const _green = Color(0xFF2DB84B);

  Future<void> _openMaps() async {
    if (!_c.hasCoords) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_c.latitude},${_c.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call() async {
    final n = _c.noTelp.replaceAll(RegExp(r'[^0-9+]'), '');
    if (n.isEmpty || n == '-') return;
    final uri = Uri(scheme: 'tel', path: n);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  bool get _isBuka {
    try {
      final now = TimeOfDay.now();
      final bp = _c.jamBuka.replaceAll('.', ':').split(':');
      final tp = _c.jamTutup.replaceAll('.', ':').split(':');
      final b = int.parse(bp[0]) * 60 + int.parse(bp[1]);
      final t = int.parse(tp[0]) * 60 + int.parse(tp[1]);
      final n = now.hour * 60 + now.minute;
      if (DateTime.now().weekday == 7) return false;
      return n >= b && n <= t;
    } catch (_) {
      return true;
    }
  }

  // Bangun widget konten modal
  Widget _buildModalContent(bool buka, double safeBottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 16, 14, safeBottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Nama cabang
          Text(
            _c.nama,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191C1E)),
          ),

          // Jarak
          if (_c.jarakLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              SvgPicture.asset(
                'assets/icons/location.svg',
                width: 12,
                height: 12,
                colorFilter:
                    const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
              Text(
                '${_c.jarakLabel} dari lokasi Anda',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500),
              ),
            ]),
          ],
          const SizedBox(height: 14),

          // Card info
          _buildCard([
            _buildField('assets/icons/location-bold.svg', 'Alamat', _c.alamat),
            _buildField('assets/icons/phone-bold.svg', 'Telepon', _c.noTelp),
            _buildField('assets/icons/calendar-bold.svg', 'Hari Operasional',
                _c.hariBuka),
            _buildField(
              'assets/icons/clock-circle.svg',
              'Jam Operasional',
              '${_c.jamBuka} – ${_c.jamTutup} WIB',
              valueColor: buka ? const Color(0xFF16A34A) : null,
            ),
          ]),
          const SizedBox(height: 14),

          // Tombol Buka Maps
          if (_c.hasCoords)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _openMaps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB6D96C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Buka Maps',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F5C3A))),
              ),
            ),
          if (_c.hasCoords && _c.noTelp != '-' && _c.noTelp.isNotEmpty)
            const SizedBox(height: 8),

          // Tombol Hubungi
          if (_c.noTelp != '-' && _c.noTelp.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _call,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hubungi',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buka = _isBuka;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        // Column: maps Expanded di atas, modal wrap konten di bawah
        body: Column(
          children: [
            // Maps — mengisi sisa ruang setelah modal
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                  child: _c.hasCoords
                      ? GoogleMap(
                          onMapCreated: (ctrl) => _mapCompleter.complete(ctrl),
                          initialCameraPosition: CameraPosition(
                              target: LatLng(_c.latitude!, _c.longitude!),
                              zoom: 16),
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          myLocationButtonEnabled: false,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          markers: {
                            Marker(
                              markerId: const MarkerId('pin'),
                              position: LatLng(_c.latitude!, _c.longitude!),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen),
                              infoWindow: InfoWindow(title: _c.nama),
                            ),
                          },
                        )
                      : Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Center(
                            child: Icon(Icons.map_rounded,
                                size: 56, color: Color(0xFFCCCCCC)),
                          ),
                        ),
                ),

                // Tombol back
                Positioned(
                  top: safeTop + 10,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 17, color: Colors.black),
                    ),
                  ),
                ),

                // Badge buka/tutup pojok kanan bawah maps
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: buka ? _green : const Color(0xFF6B7280),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        buka ? 'Sedang Buka' : 'Sedang Tutup',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),

            // Modal fix — tinggi mengikuti konten, tidak bisa di-drag
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 20,
                      offset: Offset(0, -4)),
                ],
              ),
              child: _buildModalContent(buka, safeBottom),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            children.length,
            (i) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                children[i],
                if (i < children.length - 1)
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 14,
                      endIndent: 14,
                      color: Color(0xFFE0E0E0)),
              ],
            ),
          ),
        ),
      );

  Widget _buildField(
    String iconPath,
    String label,
    String value, {
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: const Color(0xFFF4F8EF),
                borderRadius: BorderRadius.circular(9)),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(iconPath,
                errorBuilder: (_, __, ___) => const Icon(Icons.circle,
                    size: 18, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF9E9E9E))),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? Colors.black)),
              ],
            ),
          ),
        ]),
      );
}
