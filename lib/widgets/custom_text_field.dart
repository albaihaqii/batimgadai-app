import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Wajib import ini

class CustomTextField extends StatelessWidget {
  final String hintText;
  // Perubahan tipe data dari IconData menjadi String (untuk path file SVG)
  final String prefixIconPath;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIconPath, // Update nama parameter
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        // Mengganti widget Icon menjadi SvgPicture
        prefixIcon: Padding(
          // Memberikan padding agar ukuran icon SVG pas di dalam text field
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            prefixIconPath,
            // Memberikan warna hijau tua pada SVG secara dinamis
            colorFilter: const ColorFilter.mode(
              Color(0xFF1F5C3A),
              BlendMode.srcIn,
            ),
            width: 20,
            height: 20,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF1F5C3A)),
        ),
      ),
    );
  }
}
