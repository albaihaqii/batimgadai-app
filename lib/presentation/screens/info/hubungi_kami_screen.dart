import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/app_green_header.dart';

class HubungiKamiScreen extends StatelessWidget {
  const HubungiKamiScreen({super.key});

  static const _contacts = [
    _Contact('assets/icons/phone-bold.svg', 'Call Center', '(0331) 123-456'),
    _Contact('assets/icons/phone-bold.svg', 'WhatsApp', '0812-3456-7890'),
    _Contact('assets/icons/database.svg', 'Email', 'info@batimgadai.com'),
    _Contact('assets/icons/location-bold.svg', 'Kantor Pusat',
        'Jl. Mangli No. 10, Jember, Jawa Timur'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFB6D96C),
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppGreenHeader(title: 'Hubungi Kami'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        _contacts.length,
                        (i) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ContactTile(contact: _contacts[i]),
                                if (i < _contacts.length - 1)
                                  const Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      indent: 14,
                                      endIndent: 14,
                                      color: Color(0xFFE0E0E0)),
                              ],
                            ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Contact {
  final String icon, title, value;
  const _Contact(this.icon, this.title, this.value);
}

class _ContactTile extends StatelessWidget {
  final _Contact contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFF4F8EF),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(contact.icon,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.contact_support_outlined,
                  size: 20,
                  color: AppColors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(contact.title,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xFF9E9E9E))),
          const SizedBox(height: 2),
          Text(contact.value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ])),
      ]),
    );
  }
}
