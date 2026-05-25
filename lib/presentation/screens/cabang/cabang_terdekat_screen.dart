import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/cabang_model.dart';

class CabangTerdekatScreen extends StatefulWidget {
  const CabangTerdekatScreen({super.key});

  @override
  State<CabangTerdekatScreen> createState() => _CabangTerdekatScreenState();
}

class _CabangTerdekatScreenState extends State<CabangTerdekatScreen> {
  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();

  List<CabangModel> _all = [];
  List<CabangModel> _filtered = [];
  LatLng? _userPos;
  CabangModel? _selected;
  bool _loading = true;
  bool _gpsLoading = false;
  String? _error;

  static const _defaultCenter = LatLng(-8.1845, 113.6820);

  // openstreetmap via MapTiler → tampil semua POI (toko, jalan, landmark)
  String get _tileUrl =>
      'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.jpg?key=${AppConstants.mapTilerKey}';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Inisialisasi ─────────────────────────────────────────────────────────

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getCabang();
      if (mounted)
        setState(() {
          _all = data;
          _filtered = List.from(data);
        });
      await _requestGps();
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  Future<void> _requestGps() async {
    if (mounted) setState(() => _gpsLoading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted)
          setState(() {
            _loading = false;
            _gpsLoading = false;
          });
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted)
          setState(() {
            _loading = false;
            _gpsLoading = false;
          });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      final latlng = LatLng(pos.latitude, pos.longitude);

      // Hitung jarak masing-masing cabang
      for (final c in _all) {
        if (c.hasCoords) {
          c.jarakKm = CabangModel.haversine(
              pos.latitude, pos.longitude, c.latitude!, c.longitude!);
        }
      }
      _all.sort((a, b) => (a.jarakKm ?? 9999).compareTo(b.jarakKm ?? 9999));

      if (mounted) {
        setState(() {
          _userPos = latlng;
          _filtered = List.from(_all);
          _loading = false;
          _gpsLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) _mapCtrl.move(latlng, 15);
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _gpsLoading = false;
        });
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void _onSearch(String q) {
    setState(() {
      _filtered = q.trim().isEmpty
          ? List.from(_all)
          : _all
              .where((c) =>
                  c.nama.toLowerCase().contains(q.toLowerCase()) ||
                  c.alamat.toLowerCase().contains(q.toLowerCase()))
              .toList();
    });
  }

  void _select(CabangModel c) {
    setState(() => _selected = c);
    if (c.hasCoords) _mapCtrl.move(LatLng(c.latitude!, c.longitude!), 16);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2))
            : _error != null
                ? _buildError()
                : _buildMap(),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _init,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6D96C),
                foregroundColor: const Color(0xFF1F5C3A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _buildMap() {
    final safeTop = MediaQuery.of(context).padding.top;
    final screenH = MediaQuery.of(context).size.height;

    return Stack(children: [
      // ── PETA FULL ──────────────────────────────────────────────────────────
      Positioned.fill(
        child: FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _userPos ?? _defaultCenter,
            initialZoom: 15,
            minZoom: 8,
            maxZoom: 19,
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.batimgadai.app',
              tileProvider: NetworkTileProvider(),
              // Retina tiles agar lebih HD
              retinaMode: true,
            ),
            // Marker user (biru ala Google Maps)
            if (_userPos != null)
              MarkerLayer(markers: [
                Marker(
                  point: _userPos!,
                  width: 48,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x4D1A73E8),
                            blurRadius: 14,
                            spreadRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ]),
            // Marker cabang
            MarkerLayer(
              markers: _all.where((c) => c.hasCoords).map((c) {
                final active = _selected?.id == c.id;
                return Marker(
                  point: LatLng(c.latitude!, c.longitude!),
                  width: 54,
                  height: 64,
                  child: GestureDetector(
                    onTap: () => _select(c),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 48 : 38,
                          height: active ? 48 : 38,
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary,
                                width: active ? 0 : 2.5),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: active ? 0.45 : 0.2),
                                  blurRadius: active ? 16 : 6,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Icon(Icons.location_on_rounded,
                              size: active ? 24 : 18,
                              color: active ? Colors.white : AppColors.primary),
                        ),
                        // Tangkai pin
                        Container(
                            width: 2,
                            height: 8,
                            color: AppColors.primary.withValues(alpha: 0.6)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      // ── TOMBOL BACK ────────────────────────────────────────────────────────
      Positioned(
        top: safeTop + 12,
        left: 16,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 8,
                    offset: Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black, size: 18),
          ),
        ),
      ),

      // ── TOMBOL GPS ─────────────────────────────────────────────────────────
      Positioned(
        right: 16,
        bottom: screenH * 0.235,
        child: GestureDetector(
          onTap: _requestGps,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ],
            ),
            child: _gpsLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : const Icon(Icons.my_location_rounded,
                    color: AppColors.primary, size: 22),
          ),
        ),
      ),

      // ── BOTTOM SHEET ───────────────────────────────────────────────────────
      DraggableScrollableSheet(
        initialChildSize: 0.22,
        minChildSize: 0.22,
        maxChildSize: 0.80,
        snap: true,
        snapSizes: const [0.22, 0.55, 0.80],
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16,
                  offset: Offset(0, -4))
            ],
          ),
          child: Column(children: [
            // Handle drag
            Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(2)),
              ),
            )),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xFF1F5C3A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearch,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Cari cabang…',
                        hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF9E9E9E)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ]),
              ),
            ),

            // Label jumlah
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                const Text('Daftar Cabang',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                const Spacer(),
                Text('${_filtered.length} cabang',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF9E9E9E))),
              ]),
            ),

            // List
            Expanded(
              child: _filtered.isEmpty
                  ? _emptyList(sc)
                  : ListView.builder(
                      controller: sc,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _CabangCard(
                        cabang: _filtered[i],
                        isSelected: _selected?.id == _filtered[i].id,
                        onTap: () => _select(_filtered[i]),
                      ),
                    ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _emptyList(ScrollController sc) => SingleChildScrollView(
        controller: sc,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(children: [
            const Icon(Icons.location_off_rounded,
                size: 48, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            const Text('Cabang Tidak Ditemukan',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 6),
            const Text('Coba gunakan kata kunci lain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E))),
          ]),
        ),
      );
}

// ── List card — hari & jam sejajar, tanpa halaman detail ─────────────────────
class _CabangCard extends StatelessWidget {
  final CabangModel cabang;
  final bool isSelected;
  final VoidCallback onTap;
  const _CabangCard({
    required this.cabang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFEDEDED)),
          boxShadow: [
            if (!isSelected)
              const BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFB6D96C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_rounded,
                  size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 12),

            // Nama + alamat + operasional (1 baris)
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cabang.nama,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.black)),
                const SizedBox(height: 2),
                Text(cabang.alamat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF9E9E9E))),
                const SizedBox(height: 5),
                // hari + jam sejajar dalam satu Row
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 11, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(cabang.hariBuka,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Color(0xFF555555))),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time_rounded,
                      size: 11, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Flexible(
                      child: Text(
                    '${cabang.jamBuka}–${cabang.jamTutup} WIB',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF555555)),
                  )),
                ]),
              ],
            )),
            const SizedBox(width: 8),

            // Jarak + badge selected
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (cabang.jarakLabel.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cabang.jarakLabel,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
