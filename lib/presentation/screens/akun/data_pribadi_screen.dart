import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/nasabah_provider.dart';
import '../../widgets/common/app_green_header.dart';

class DataPribadiScreen extends ConsumerWidget {
  const DataPribadiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nasabah = ref.watch(nasabahProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppGreenHeader(title: 'Data Pribadi'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('DATA DIRI'),
              const SizedBox(height: 8),
              _buildCard([
                _buildField('Nama Lengkap', nasabah.nama ?? '-',
                    'assets/icons/user-bold.svg'),
                _buildField('No. KTP', nasabah.noKtp ?? '-',
                    'assets/icons/id-card.svg'),
                _buildField('No. CIF', nasabah.noCif ?? '-',
                    'assets/icons/file-check.svg'),
                _buildField('No. HP', nasabah.noHp ?? '-',
                    'assets/icons/phone-bold.svg'),
              ]),
              const SizedBox(height: 20),
              _label('CABANG & ALAMAT'),
              const SizedBox(height: 8),
              _buildCard([
                _buildField('Cabang Terdaftar', nasabah.cabang ?? '-',
                    'assets/icons/location.svg'),
                _buildField('Alamat', nasabah.alamat ?? '-',
                    'assets/icons/location.svg'),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCE8CF)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset('assets/icons/info-circle.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              AppColors.primary, BlendMode.srcIn)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                            'Untuk mengubah data diri, silakan kunjungi cabang BATIM GADAI terdekat.',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.primary,
                                height: 1.55)),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF898A8D),
                letterSpacing: 0.3)),
      );

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
                (i) => Column(mainAxisSize: MainAxisSize.min, children: [
                      children[i],
                      if (i < children.length - 1)
                        const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 14,
                            endIndent: 14,
                            color: Color(0xFFE0E0E0)),
                    ]))),
      );

  Widget _buildField(String label, String value, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: const Color(0xFFF4F8EF),
              borderRadius: BorderRadius.circular(9)),
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(icon,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.circle, size: 18, color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xFF9E9E9E))),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
        ])),
      ]),
    );
  }
}
