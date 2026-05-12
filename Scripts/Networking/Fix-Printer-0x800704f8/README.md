# Printer Sharing Fix (Error 0x800704f8)

Solusi automasi untuk mengatasi kendala koneksi *Shared Printer* pada Windows 10 dan Windows 11 yang disebabkan oleh pengetatan protokol keamanan RPC (*Remote Procedure Call*).

---

## Analisis Masalah (Error 0x800704f8)
Kode error `0x800704f8` sering muncul setelah pembaruan keamanan Windows tertentu. Masalah ini biasanya berakar pada:
*   **RPC Authentication Level:** Windows mengharuskan tingkat otentikasi yang lebih tinggi untuk *Remote RPC*.
*   **Insecure Guest Auth:** Kebijakan yang memblokir akses tamu (*guest*) tanpa enkripsi.
*   **Restricted RPC Clients:** Konfigurasi *Group Policy* yang terlalu ketat pada *host* printer.

## Apa yang Dilakukan Skrip Ini?
Skrip ini melakukan modifikasi pada tiga pilar utama konfigurasi Windows:
1.  **Registry Editor:** Mengaktifkan `AllowInsecureGuestAuth` dan menyesuaikan `RpcAuthnLevelPrivacyEnabled`.
2.  **Group Policy (gpedit):** Mengaplikasikan `Registry.pol` untuk memastikan kebijakan sistem tidak menolak koneksi dari *client*.
3.  **Security Policy (secpol):** Mengonfigurasi hak akses jaringan melalui file `.inf` khusus untuk Windows 11.

## Perhatian Sebelum Eksekusi
*   **Backup:** Meskipun skrip hanya menyentuh parameter terkait printer, sangat disarankan melakukan *System Restore Point* terlebih dahulu.
*   **Antivirus:** Matikan sementara Windows Defender atau Antivirus lain agar perubahan *Registry* tidak diblokir.
*   **Auto-Reboot:** Sistem akan melakukan **Restart otomatis** setelah proses selesai untuk mengaplikasikan konfigurasi baru. Pastikan tidak ada pekerjaan yang belum tersimpan.

## Cara Penggunaan
1. Buka File Explorer.
2. Navigasi ke folder ini.
3. Klik kanan pada file `install.bat`.
4. Pilih **Run as Administrator**.

---
*Dibuat untuk mempermudah tugas IT Support dalam menangani masalah printer sharing yang repetitif.*
