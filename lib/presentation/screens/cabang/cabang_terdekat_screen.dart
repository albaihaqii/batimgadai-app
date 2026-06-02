import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/cabang_model.dart';
import 'detail_cabang_screen.dart';

const _kGreen = Color(0xFF2DB84B);
const _kGreenLight = Color(0xFF5CE06D);
const _kGreenDark = Color(0xFF1A9A38);
const _kOnSurface = Color(0xFF191C1E);
const _kGrey400 = Color(0xFF9CA3AF);
const _kSecondaryContainer = Color(0xFFD6E7DB);

class CabangTerdekatScreen extends StatefulWidget {
  const CabangTerdekatScreen({super.key});

  @override
  State<CabangTerdekatScreen> createState() => _CabangTerdekatScreenState();
}

class _CabangTerdekatScreenState extends State<CabangTerdekatScreen>
    with SingleTickerProviderStateMixin {
  final _mapCompleter = Completer<GoogleMapController>();
  final _searchCtrl = TextEditingController();
  late final AnimationController _sheetCtrl;

  List<CabangModel> _all = [];
  List<CabangModel> _filtered = [];
  Set<Marker> _markers = {};
  LatLng? _userPos;
  CabangModel? _selected;
  bool _loading = true;
  bool _gpsLoading = false;
  String? _error;

  static const _defaultCenter = LatLng(-8.1845, 113.6820);

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 0.0,
    );
    _init();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
        _finishLoading();
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied)
        perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _finishLoading();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      for (final c in _all) {
        if (c.hasCoords) {
          c.jarakKm = CabangModel.haversine(
              pos.latitude, pos.longitude, c.latitude!, c.longitude!);
        }
      }
      _all.sort((a, b) => (a.jarakKm ?? 9999).compareTo(b.jarakKm ?? 9999));
      final latlng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _userPos = latlng;
          _filtered = List.from(_all);
          _loading = false;
          _gpsLoading = false;
        });
        await _buildMarkers();
        await Future.delayed(const Duration(milliseconds: 300));
        _moveCamera(latlng, 14);
      }
    } catch (_) {
      _finishLoading();
    }
  }

  void _finishLoading() {
    if (mounted)
      setState(() {
        _loading = false;
        _gpsLoading = false;
      });
    _buildMarkers();
  }

  Future<void> _buildMarkers() async {
    final Set<Marker> markers = {};
    for (final c in _all) {
      if (!c.hasCoords) continue;
      final active = _selected?.id == c.id;
      final open = _isCabangOpen(c);
      markers.add(Marker(
        markerId: MarkerId('c_${c.id}'),
        position: LatLng(c.latitude!, c.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(active
            ? BitmapDescriptor.hueGreen
            : open
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueAzure),
        alpha: active ? 1.0 : 0.85,
        infoWindow: InfoWindow(
            title: c.nama,
            snippet: c.jarakLabel.isNotEmpty ? c.jarakLabel : c.alamat),
        onTap: () => _select(c),
      ));
    }
    if (mounted) setState(() => _markers = markers);
  }

  void _moveCamera(LatLng target, double zoom) async {
    final ctrl = await _mapCompleter.future;
    ctrl.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom)));
  }

  bool _isCabangOpen(CabangModel c) {
    try {
      final now = TimeOfDay.now();
      final b = _parseTime(c.jamBuka);
      final t = _parseTime(c.jamTutup);
      if (b == null || t == null) return true;
      final n = now.hour * 60 + now.minute;
      if (DateTime.now().weekday == 7) return false;
      return n >= b.hour * 60 + b.minute && n <= t.hour * 60 + t.minute;
    } catch (_) {
      return true;
    }
  }

  TimeOfDay? _parseTime(String s) {
    try {
      final p = s.replaceAll('.', ':').replaceAll(' ', '').split(':');
      return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    } catch (_) {
      return null;
    }
  }

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
    _buildMarkers();
    if (c.hasCoords) _moveCamera(LatLng(c.latitude!, c.longitude!), 16);
  }

  void _adjustMap() {
    final t = (_selected?.hasCoords == true)
        ? LatLng(_selected!.latitude!, _selected!.longitude!)
        : _userPos;
    if (t != null) _moveCamera(t, 14);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: _loading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: _kGreen, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text('Memuat peta...',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 13, color: _kGrey400)),
        ]),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(
                  color: Color(0xFFFFDAD6), shape: BoxShape.circle),
              child: Icon(Icons.location_off_rounded,
                  color: const Color(0xFFBA1A1A), size: 36.r),
            ),
            SizedBox(height: 20.h),
            Text('Gagal Memuat Peta',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurface)),
            SizedBox(height: 8.h),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: _kGrey400,
                    height: 1.5)),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _init,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              ),
              child: Text('Coba Lagi',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp)),
            ),
          ]),
        ),
      );

  Widget _buildContent() {
    final safeTop = MediaQuery.of(context).padding.top;
    final screenH = MediaQuery.of(context).size.height;
    final collapsedH = screenH * 0.38;
    final expandedH = screenH * 0.66;

    return Stack(children: [
      // Google Maps
      Positioned.fill(
        child: GoogleMap(
          onMapCreated: (ctrl) => _mapCompleter.complete(ctrl),
          initialCameraPosition:
              CameraPosition(target: _userPos ?? _defaultCenter, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: _markers,
          onTap: (_) => setState(() => _selected = null),
          padding: EdgeInsets.only(bottom: collapsedH),
        ),
      ),

      // Tombol back
      Positioned(
        top: safeTop + 12,
        left: 16.w,
        child: _FloatButton(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18.r, color: _kOnSurface),
        ),
      ),

      // Tombol lokasi saya
      Positioned(
        top: safeTop + 12,
        right: 16.w,
        child: GestureDetector(
          onTap: () {
            setState(() => _selected = null);
            if (_userPos != null)
              _moveCamera(_userPos!, 15);
            else
              _requestGps();
          },
          child: Container(
            height: 40.r,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      const LinearGradient(colors: [_kGreenLight, _kGreen]),
                  boxShadow: [
                    BoxShadow(
                        color: _kGreen.withValues(alpha: 0.3),
                        blurRadius: 0,
                        spreadRadius: 3)
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _gpsLoading
                  ? SizedBox(
                      width: 14.r,
                      height: 14.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: _kGreen))
                  : Text('Lokasi Saya',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _kOnSurface)),
            ]),
          ),
        ),
      ),

      // Bottom sheet
      AnimatedBuilder(
        animation: _sheetCtrl,
        builder: (ctx, child) {
          final h = collapsedH + (expandedH - collapsedH) * _sheetCtrl.value;
          return Positioned(
              left: 0, right: 0, bottom: 0, height: h, child: child!);
        },
        child: _buildSheet(collapsedH, expandedH),
      ),
    ]);
  }

  Widget _buildSheet(double collapsedH, double expandedH) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, -6))
        ],
      ),
      child: Column(children: [
        // Drag zone
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (d) {
            final range = expandedH - collapsedH;
            _sheetCtrl.value =
                (_sheetCtrl.value + (-d.delta.dy) / range).clamp(0.0, 1.0);
          },
          onVerticalDragEnd: (d) {
            final vel = d.primaryVelocity ?? 0;
            final target = vel < -300
                ? 1.0
                : vel > 300
                    ? 0.0
                    : (_sheetCtrl.value > 0.5 ? 1.0 : 0.0);
            _sheetCtrl
                .animateTo(target, curve: Curves.easeOut)
                .then((_) => _adjustMap());
          },
          onTap: () => _sheetCtrl
              .animateTo(_sheetCtrl.value < 0.5 ? 1.0 : 0.0,
                  curve: Curves.easeOut)
              .then((_) => _adjustMap()),
          child: Column(children: [
            // Handle bar
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: const Color(0xFFE1E2E4),
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),

            // Header — hanya title + subtitle, tanpa icon/shape
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cabang Terdekat',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: _kOnSurface)),
                        Text(
                          _userPos != null
                              ? 'Jelajahi outlet Batim Gadai di sekitarmu'
                              : 'Temukan outlet Batim Gadai terdekat',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.sp,
                              color: _kGrey400),
                        ),
                      ]),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: _kSecondaryContainer,
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text('${_filtered.length}',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _kGreenDark)),
                ),
              ]),
            ),
          ]),
        ),

        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r)),
            child: Row(children: [
              SizedBox(width: 12.w),
              SvgPicture.asset('assets/icons/search.svg',
                  width: 18.r,
                  height: 18.r,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF9CA3AF), BlendMode.srcIn)),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: _kOnSurface),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau alamat cabang...',
                    hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: _kGrey400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ]),
          ),
        ),

        const Divider(height: 1, color: Color(0xFFF0F0F0)),

        // List
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.search_off_rounded,
                        size: 52.r, color: const Color(0xFFCCCCCC)),
                    SizedBox(height: 12.h),
                    Text('Cabang Tidak Ditemukan',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _kOnSurface)),
                    SizedBox(height: 6.h),
                    Text('Coba gunakan kata kunci lain.',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            color: _kGrey400)),
                  ]),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final c = _filtered[i];
                    return _CabangCard(
                      cabang: c,
                      index: i,
                      isSelected: _selected?.id == c.id,
                      isOpen: _isCabangOpen(c),
                      showRank: _userPos != null,
                      onTap: () => _select(c),
                      onDetail: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailCabangScreen(cabang: c))),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class _FloatButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _FloatButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Center(child: child),
        ),
      );
}

class _CabangCard extends StatelessWidget {
  final CabangModel cabang;
  final int index;
  final bool isSelected;
  final bool isOpen;
  final bool showRank;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  const _CabangCard({
    required this.cabang,
    required this.index,
    required this.isSelected,
    required this.isOpen,
    required this.showRank,
    required this.onTap,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Parse jarak
    String jarakValue = '';
    String jarakUnit = '';
    if (cabang.jarakLabel.isNotEmpty) {
      final parts = cabang.jarakLabel.split(' ');
      jarakValue = parts.isNotEmpty ? parts[0] : cabang.jarakLabel;
      jarakUnit = parts.length > 1 ? parts[1] : '';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F8E8) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon store + badge nomor
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2DB84B), AppColors.primary])
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFD9EDB3), Color(0xFFB6D96C)]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(10.r),
                    child: SvgPicture.asset(
                      'assets/icons/store.svg',
                      colorFilter: ColorFilter.mode(
                          isSelected ? Colors.white : AppColors.primary,
                          BlendMode.srcIn),
                    ),
                  ),
                  if (showRank)
                    Positioned(
                      top: -5.r,
                      right: -5.r,
                      child: Container(
                        width: 17.r,
                        height: 17.r,
                        decoration: BoxDecoration(
                          color: _kSecondaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 10.w),

              // Kolom kiri: nama + alamat + hari + jam
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris nama + badge | jarak di kanan atas (tetap)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama + badge — gunakan Column agar badge tidak
                        // menambah lebar dan nama bisa wrap
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama cabang — lebih besar 2x dari baris info
                              Text(
                                cabang.nama,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : _kOnSurface,
                                    height: 1.3),
                              ),
                              SizedBox(height: 3.h),
                              // Badge buka/tutup di bawah nama
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: isOpen
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  isOpen ? 'Buka' : 'Tutup',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isOpen
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF6B7280)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Jarak — pojok kanan atas, tidak diubah
                        if (jarakValue.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: jarakValue,
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                              if (jarakUnit.isNotEmpty)
                                TextSpan(
                                  text: ' $jarakUnit',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: _kGrey400),
                                ),
                            ]),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Baris alamat — maxLines 1, overflow ellipsis
                    Row(children: [
                      SvgPicture.asset(
                        'assets/icons/location.svg',
                        width: 11.r,
                        height: 11.r,
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          cabang.alamat,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              color: const Color(0xFF9E9E9E)),
                        ),
                      ),
                    ]),

                    SizedBox(height: 5.h),

                    // Baris hari
                    Row(children: [
                      SvgPicture.asset(
                        'assets/icons/calendar.svg',
                        width: 11.r,
                        height: 11.r,
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          cabang.hariBuka,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              color: const Color(0xFF555555)),
                        ),
                      ),
                    ]),

                    SizedBox(height: 5.h),

                    // Baris jam + arrow-right pojok kanan bawah (tidak diubah)
                    Row(children: [
                      SvgPicture.asset(
                        'assets/icons/clock-linier.svg',
                        width: 11.r,
                        height: 11.r,
                        colorFilter: const ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${cabang.jamBuka} – ${cabang.jamTutup} WIB',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              color: const Color(0xFF555555)),
                        ),
                      ),
                      GestureDetector(
                        onTap: onDetail,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: SvgPicture.asset(
                            'assets/icons/arrow-right.svg',
                            width: 14.r,
                            height: 14.r,
                            colorFilter: const ColorFilter.mode(
                                AppColors.primary, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
