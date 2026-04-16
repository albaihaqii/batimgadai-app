import 'package:flutter/material.dart';
import '../widgets/custom_keypad.dart';

enum PinMode { create, confirm }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? createdPin;

  const PinScreen({super.key, required this.mode, this.createdPin});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  final int _pinLength = 6;

  void _onNumberTapped(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == _pinLength) {
        _processPin();
      }
    }
  }

  void _onBackspaceTapped() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _processPin() {
    if (widget.mode == PinMode.create) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PinScreen(mode: PinMode.confirm, createdPin: _pin),
        ),
      ).then((_) {
        setState(() {
          _pin = '';
        });
      });
    } else {
      if (_pin == widget.createdPin) {
        _showLoadingOverlay();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN tidak cocok. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _pin = '';
        });
      }
    }
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F5C3A)),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        debugPrint("Navigate to Main Dashboard");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreate = widget.mode == PinMode.create;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Row(
              children: [
                Image.asset('assets/images/logo_onboard.png', width: 24),
                const SizedBox(width: 8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BATIM',
                      style: TextStyle(
                        color: Color(0xFF1F5C3A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'GADAI',
                      style: TextStyle(
                        color: Color(0xFF1F5C3A),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      isCreate ? 'Buat PIN' : 'Konfirmasi PIN',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isCreate
                          ? 'Silakan buat PIN 6 digit yang akan digunakan sebagai kode keamanan untuk mengakses aplikasi.'
                          : 'Masukkan kembali 6 digit PIN yang telah dibuat sebelumnya untuk melanjutkan penggunaan aplikasi.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 64),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pinLength,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _pin.length
                                ? const Color(0xFFB6D96C)
                                : const Color(0xFFE6EBE6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: CustomKeypad(
                onNumberTapped: _onNumberTapped,
                onBackspaceTapped: _onBackspaceTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
