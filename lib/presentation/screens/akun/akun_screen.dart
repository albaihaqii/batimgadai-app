import 'package:flutter/material.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Text('INI AKUN',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600))),
      );
}
