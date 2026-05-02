import 'package:flutter/material.dart';

class SimulasiScreen extends StatelessWidget {
  const SimulasiScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Text('INI SIMULASI',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600))),
      );
}
