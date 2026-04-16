import 'package:flutter/material.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onNumberTapped;
  final VoidCallback onBackspaceTapped;

  const CustomKeypad({
    super.key,
    required this.onNumberTapped,
    required this.onBackspaceTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 72, height: 72),
            _buildButton('0'),
            SizedBox(
              width: 72,
              height: 72,
              child: IconButton(
                onPressed: onBackspaceTapped,
                icon: const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFF1F5C3A),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) => _buildButton(num)).toList(),
    );
  }

  Widget _buildButton(String number) {
    return InkWell(
      onTap: () => onNumberTapped(number),
      borderRadius: BorderRadius.circular(36.0),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F4),
          shape: BoxShape.circle,
        ),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F5C3A),
          ),
        ),
      ),
    );
  }
}
