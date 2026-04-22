import 'package:flutter/material.dart';

enum LoanStatus { aktif, lunas }

class LoanItem {
  final String id;
  final String category;
  final String productName;
  final LoanStatus status;
  final int loanAmount;
  final String dueDate;
  final IconData icon;
  final String? imei;
  final String? ram;
  final String? rom;
  final String? kondisiFisik;
  final String? kelengkapan;

  const LoanItem({
    required this.id,
    required this.category,
    required this.productName,
    required this.status,
    required this.loanAmount,
    required this.dueDate,
    required this.icon,
    this.imei,
    this.ram,
    this.rom,
    this.kondisiFisik,
    this.kelengkapan,
  });
}

// Dummy Data
final List<LoanItem> dummyLoans = [
  const LoanItem(
    id: 'GDA001',
    category: 'Ponsel',
    productName: 'Samsung A54',
    status: LoanStatus.aktif,
    loanAmount: 2500000,
    dueDate: '15 Mei 2024',
    icon: Icons.phone_android_rounded,
    imei: '356789123456789',
    ram: '8 GB',
    rom: '256 GB',
    kondisiFisik: 'Mulus 95%, baret halus pemakaian',
    kelengkapan: 'Fullset (Box, Charger Ori, Kabel)',
  ),
  const LoanItem(
    id: 'GDA002',
    category: 'Laptop',
    productName: 'Asus ROG Strix',
    status: LoanStatus.lunas,
    loanAmount: 12000000,
    dueDate: '01 April 2024',
    icon: Icons.laptop_chromebook_rounded,
    imei: 'SN: R4N0CV123456',
    ram: '16 GB DDR5',
    rom: '1 TB SSD',
    kondisiFisik: 'Mulus Like New, No Minus',
    kelengkapan: 'Unit, Charger Ori, Tas Backpack ROG',
  ),
];
