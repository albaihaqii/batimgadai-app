# BATIM GADAI - Mobile App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Android-API_21+-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/Midtrans-Payment-003366?style=for-the-badge&logoColor=white" />
</p>

<p align="center">
  Aplikasi mobile nasabah untuk platform digital <strong>BATIM GADAI</strong>.<br>
  Mempermudah nasabah dalam memantau pinjaman, melakukan perpanjangan dan pelunasan,<br>
  serta melakukan simulasi gadai langsung dari genggaman.
</p>

---

## 🏦 Tentang Aplikasi

<p align="justify">
<strong>BATIM GADAI Mobile</strong> adalah aplikasi Android yang menjadi antarmuka utama bagi nasabah PT Bintang Timur dalam mengakses layanan gadai secara digital. Aplikasi ini terhubung langsung dengan sistem web BATIM GADAI melalui REST API berbasis Laravel Sanctum, memungkinkan nasabah memantau status pinjaman, melakukan pembayaran perpanjangan atau pelunasan secara online, serta melakukan simulasi nilai taksiran barang sebelum datang ke outlet.
</p>

Platform digital BATIM GADAI terdiri dari dua komponen utama:

| Platform   | Repo                        | Pengguna                   |
| ---------- | --------------------------- | -------------------------- |
| Web System | _(repo terpisah - Laravel)_ | Superadmin, Admin, Officer |
| Mobile App | _(repo ini)_                | Nasabah                    |

---

## ✨ Keunggulan Aplikasi

**🔐 Login Tanpa Password**

<p align="justify">Nasabah cukup input nomor handphone, terima OTP via WhatsApp, dan buat PIN 6 digit. Tidak perlu mengingat password yang rumit.</p>

**📋 Pantau Pinjaman Real-time**

<p align="justify">Seluruh transaksi gadai aktif, status pinjaman, tanggal jatuh tempo, dan riwayat pembayaran dapat dipantau langsung dari aplikasi kapan saja.</p>

**💳 Bayar Online Kapan Saja**

<p align="justify">Perpanjangan masa gadai dan pelunasan dapat dilakukan secara online melalui berbagai metode pembayaran yang didukung Midtrans tanpa perlu datang ke outlet.</p>

**🧮 Simulasi Sebelum Gadai**

<p align="justify">Fitur simulasi membantu nasabah mengetahui estimasi nilai pinjaman berdasarkan kategori, kondisi, dan harga pasar barang sebelum datang ke outlet.</p>

---

## 🛠️ Teknologi yang Dipakai

| Layer            | Teknologi              |
| ---------------- | ---------------------- |
| Framework        | Flutter 3.x            |
| Language         | Dart 3.x               |
| State Management | Flutter Riverpod 2.x   |
| HTTP Client      | Dio 5.x                |
| Navigation       | go_router 13.x         |
| Local Storage    | flutter_secure_storage |
| Font             | Poppins                |
| Icons            | Solar Icons (SVG)      |
| Payment Gateway  | Midtrans Flutter SDK   |
| Location         | Geolocator             |

---

## 🎨 Design System

| Token        | Value       |
| ------------ | ----------- |
| Primary      | `#1F5C3A`   |
| Accent       | `#B6D96C`   |
| Primary Dark | `#174a2e`   |
| Font Family  | Poppins     |
| Icon Set     | Solar Icons |

---

## 👤 Tipe Pengguna

| Tipe       | Deskripsi                                                      |
| ---------- | -------------------------------------------------------------- |
| Pengunjung | Login via OTP tapi belum verifikasi CIF — akses fitur terbatas |
| Nasabah    | Sudah verifikasi No KTP + No CIF — akses penuh semua fitur     |

### Perbedaan Akses

| Fitur               | Pengunjung  | Nasabah  |
| ------------------- | ----------- | -------- |
| Beranda             | ✅ Terbatas | ✅ Penuh |
| Simulasi cek harga  | ✅          | ✅       |
| Pinjaman            | 🔒          | ✅       |
| Perpanjangan online | 🔒          | ✅       |
| Pelunasan online    | 🔒          | ✅       |
| Lihat SBG           | 🔒          | ✅       |
| Booking kunjungan   | 🔒          | ✅       |
| Banner jatuh tempo  | ❌          | ✅       |

---

## 📋 Fitur Lengkap

### Beranda

- Banner verifikasi akun (pengunjung) / banner jatuh tempo (nasabah)
- 6 shortcut layanan: Gadai Baru, Lihat SBG, Cabang, Cara Gadai, Hubungi Kami, FAQ
- Carousel 3 slide info dan promo
- 5 card cabang terdekat berdasarkan lokasi GPS

### Pinjaman

- Filter chip: Semua, Aktif, Jatuh Tempo, Perpanjangan, Lunas
- List card transaksi gadai dengan status real-time
- Detail transaksi: info barang, nilai pinjaman, jatuh tempo, riwayat
- Aksi perpanjangan dan pelunasan langsung dari detail
- Download SBG PDF

### Simulasi

- Input kategori, nama barang, harga pasar, kondisi
- Hasil estimasi range nilai pinjaman + biaya jasa
- Booking kunjungan ke cabang (nasabah terverifikasi)

### Akun

- Profil nasabah dengan nomor CIF
- Riwayat pembayaran
- Booking kunjungan saya
- Ganti PIN, notifikasi, tentang aplikasi

---

## 👨‍💻 Tim Pengembang

Dikembangkan oleh mahasiswa **D4 Teknik Informatika, Politeknik Negeri Jember** angkatan 2024 — Kelompok 1 Golongan C.

| Peran   | Nama                        | NIM       | GitHub                                                         |
| ------- | --------------------------- | --------- | -------------------------------------------------------------- |
| Ketua   | Yohanes Fabian S            | E41241212 | [@yhfabian](https://github.com/yhfabian)                       |
| Anggota | Faiq Raihan Albaihaqi       | E41241011 | [@faiqraihanalbaihaqi](https://github.com/faiqraihanalbaihaqi) |
| Anggota | Abdillah Aziz Putra Susan   | E41241208 | [@azizaan](https://github.com/azizaan)                         |
| Anggota | Alviansyah Nurhidayat Yahya | E41241155 | [@alviansyahny](https://github.com/alviansyahny)               |
| Anggota | Juliana Intan Purwaningtyas | E41241036 | [@tintuntan06-dotcom](https://github.com/tintuntan06-dotcom)   |

---

## 🔗 Repositori Terkait

| Repo       | Deskripsi                     |
| ---------- | ----------------------------- |
| Web System | Laravel backend + admin panel |
| Mobile App | _(repo ini)_ Flutter Android  |

---

## 📄 Lisensi

Proyek ini dikembangkan untuk memenuhi tugas akhir semester akademik dan membantu operasional **PT Bintang Timur**. Seluruh hak cipta dilindungi.

---

<p align="center">Dikembangkan dengan ❤️ oleh Tim Kelompok 1 Golongan C &nbsp;·&nbsp; Politeknik Negeri Jember 2026</p>
