import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/cabang_model.dart';
import '../../widgets/common/app_green_header.dart';

class DetailCabangScreen extends StatelessWidget {
  final CabangModel cabang;
  const DetailCabangScreen({super.key, required this.cabang});

  String get _mapTileUrl =>
      'https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=${AppConstants.mapTilerKey}';

  Future<void> _openGoogleMaps() async {
    if (!cabang.hasCoords) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${cabang.latitude},${cabang.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call() async {
    final uri = Uri(
        scheme: 'tel', path: cabang.noTelp.replaceAll(RegExp(r'[^0-9+]'), ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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
            AppGreenHeader(title: cabang.nama),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Mini maps
                    if (cabang.hasCoords)
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter:
                                LatLng(cabang.latitude!, cabang.longitude!),
                            initialZoom: 16,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: _mapTileUrl,
                              userAgentPackageName: 'com.batimgadai.app',
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point:
                                    LatLng(cabang.latitude!, cabang.longitude!),
                                width: 52,
                                height: 64,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              spreadRadius: 2)
                                        ],
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/location.svg',
                                          width: 22,
                                          height: 22,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                  Icons.location_on_rounded,
                                                  color: Colors.white,
                                                  size: 22),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: 2,
                                        height: 8,
                                        color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              children: [
                                _tile(Icons.storefront_rounded, 'Nama Cabang',
                                    cabang.nama),
                                _divider(),
                                _tile(Icons.location_on_rounded, 'Alamat',
                                    cabang.alamat),
                                _divider(),
                                _tile(Icons.phone_rounded, 'Telepon',
                                    cabang.noTelp),
                                _divider(),
                                _tile(Icons.calendar_today_rounded, 'Hari Buka',
                                    cabang.hariBuka),
                                _divider(),
                                _tile(
                                    Icons.access_time_rounded,
                                    'Jam Operasional',
                                    '${cabang.jamBuka} – ${cabang.jamTutup} WIB'),
                                if (cabang.jarakLabel.isNotEmpty) ...[
                                  _divider(),
                                  _tile(Icons.directions_walk_rounded,
                                      'Jarak dari Anda', cabang.jarakLabel,
                                      valueColor: AppColors.primary),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (cabang.hasCoords)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _openGoogleMaps,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB6D96C),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map_rounded,
                                        color: Color(0xFF1F5C3A), size: 18),
                                    SizedBox(width: 8),
                                    Text('Buka di Google Maps',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F5C3A))),
                                  ],
                                ),
                              ),
                            ),
                          if (cabang.hasCoords) const SizedBox(height: 10),
                          if (cabang.noTelp != '-')
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _call,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xFFE0E0E0)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone_rounded,
                                        color: Colors.black, size: 18),
                                    SizedBox(width: 8),
                                    Text('Hubungi Cabang',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 18, color: AppColors.primary),
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
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF0F0F0));
}
