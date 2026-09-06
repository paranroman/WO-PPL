# E-Venture

E-Venture adalah aplikasi mobile yang dirancang untuk mempermudah pengelolaan acara kampus secara
digital dan terintegrasi. Aplikasi ini membantu panitia dalam membuat dan mengelola event, membuka
pendaftaran online, serta mencatat kehadiran peserta menggunakan sistem QR Code yang cepat dan
akurat.

Melalui E-Venture, proses administrasi acara menjadi lebih efisien karena data peserta diolah secara
otomatis dan tersimpan dengan aman. Panitia dapat memantau pendaftaran, kehadiran, dan laporan acara
secara real-time, tanpa perlu pencatatan manual.

Bagi peserta, E-Venture memberikan pengalaman yang praktis dan modern. Seluruh proses, mulai dari
registrasi event hingga absensi kehadiran, dapat dilakukan langsung melalui smartphone, sehingga
acara kampus menjadi lebih tertata, transparan, dan profesional.

# Overview

E-Venture didesain untuk mendukung 2 role utama dalam manajemen event, seperti:

* **Pengguna**: Mencari dan mendaftar event yang tersedia.
* **Panitia**: Membuat dan memonitor event yang sudah dibuat.

# Project Structure

```agsl
lib/
├── api/                  # Layanan interaksi dengan Database & Auth (Firebase)
├── models/               # Model data (User, Event, Attendance)
├── navigation/           # Konfigurasi routing aplikasi (GoRouter)
├── providers/            # State management (Provider)
├── screens/              # Halaman antarmuka pengguna (UI)
│   ├── auth/             # Autentikasi (Login, Register, Splash)
│   ├── dashboard/        # Halaman dashboard user
│   ├── event/            # Manajemen Event (Create, Edit, Detail, Maps)
│   ├── home/             # Halaman utama (List Event)
│   ├── profile/          # Profil pengguna & Pengaturan
│   └── qr/               # Fitur Scanner QR Code
├── services/             # Layanan pendukung (Maps, CSV, Format Date, QR)
├── utils/                # Utilitas umum (Validators, Toast, Exit Confirm)
├── widgets/              # Komponen UI reusable (Button, Card, Input)
├── firebase_options.dart # Konfigurasi otomatis Firebase
└── main.dart             # Entry point aplikasi
```

# Key Features

## Pengguna

* **Event Discovery & Search**: Menjelajahi berbagai event yang tersedia dengan fitur pencarian yang
  responsif.
* **Easy RSVP System**: Melakukan pendaftaran (RSVP) ke event yang diinginkan hanya dengan satu
  tombol, serta memantau status kehadiran.
    * **Location Integration**: Offline Event: Integrasi langsung dengan Google Maps untuk melihat
      lokasi acara secara akurat.
    * **Online Event**: Akses mudah ke link meeting untuk acara webinar/online.
* **Event Details**: Informasi lengkap mencakup deskripsi, penyelenggara, waktu, banner visual, dan
  kategori event.

## Panitia

* **Comprehensive Event Creation**:
    * Mendukung pembuatan event tipe Online (Link) maupun Offline (Lokasi via Maps & Geocoding).
    * Upload dokumen pendukung seperti Banner, Foto, dan Surat Keputusan (SK).
* **Real-time Dashboard**: Memantau performa event dengan visualisasi data:
    * Metrik total pendaftar vs total kehadiran.
    * **Pie Chart** interaktif untuk persentase kehadiran peserta.
* **QR Code Attendance System**: Mencatat kehadiran peserta secara instan menggunakan fitur Scan QR
  Code bawaan aplikasi atau input manual jika diperlukan.
* **Event Control**: Kemudahan untuk mengubah informasi event (Edit) atau menghapusnya (Delete) jika
  event dibatalkan.

# Tech Stack

Aplikasi ini dibangun menggunakan teknologi dan library berikut:

## Core & Framework

* **Framework**: Flutter (SDK 3.9.2) - UI Toolkit untuk membangun aplikasi multi-platform.
* **Language**: Dart - Bahasa pemrograman utama.

## Backend & Services (Firebase)

* **Authentication**: firebase_auth & google_sign_in - Manajemen login pengguna (Email & Google).
* **Database**: firebase_database - Penyimpanan data event dan pengguna secara realtime.
* **Storage**: firebase_storage - Menyimpan file media seperti banner event, foto profil, dan
  dokumen SK.
* **Core**: firebase_core - Inisialisasi layanan Firebase.

## Architecture & State Management

* **State Management**: provider - Mengelola state aplikasi (seperti sesi user) secara efisien.
* **Routing**: go_router - Manajemen navigasi antar halaman berbasis URL/Deep Link.

## Key Features & Libraries

### Maps & Location:

* **Maps_flutter**: Menampilkan peta lokasi event.
* **geocoding**: Mengubah koordinat menjadi alamat dan sebaliknya.

### QR System:

* **qr_flutter**: Generate QR Code untuk tiket peserta.
* **mobile_scanner**: Fitur kamera untuk memindai (scan) QR Code kehadiran.

### Utilities:

* **csv**: Export data kehadiran peserta ke format CSV.
* **intl**: Format tanggal dan mata uang.
* **file_picker & image_picker**: Memilih file dan gambar dari galeri.
* **url_launcher**: Membuka link eksternal (misal: link meeting online).
* **fluttertoast**: Menampilkan notifikasi singkat (toast).
* **flutter_launcher_icons**: Mengatur ikon aplikasi.

## UI Assets

* **Fonts**: Poppins (Regular, SemiBold, Bold, ExtraBold).

# Team Members

* Rafi Fauzan Tsany Lubis - 231401120
* Daffa Prawira Akbar - 231401093
* Farhan Ar Rahman - 231401081

# [Software Requirement System](https://drive.google.com/drive/folders/1Wy7YiPv5rtjolW2Re_0jElb9DOPPBXP-?usp=sharing)
