import 'package:flutter/material.dart';

class PinjamanScreen extends StatelessWidget {
  const PinjamanScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Text('INI PINJAMAN',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600))),
      );
}
