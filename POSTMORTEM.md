# Blameless Postmortem - Insiden Kegagalan Deployment Manual

## Ringkasan Insiden

Pada proses deployment manual aplikasi Sentra Digital Batam,
terjadi kegagalan ketika aplikasi dipindahkan dari lingkungan
Developer ke lingkungan Operations. Kegagalan terjadi karena
perbedaan konfigurasi environment dan artefak deployment yang
belum lengkap.

## Kronologi (Timeline)

1. Developer membuat aplikasi Flask dan melakukan pengujian pada
   lingkungan lokal.

2. Developer membuat dokumen handover manual untuk Operations.

3. Artefak aplikasi dikirimkan kepada Operations.

4. Operations mencoba menjalankan aplikasi pada environment yang
   berbeda.

5. Deployment gagal karena dependency aplikasi belum tersedia.

6. Proses diperbaiki dengan menambahkan requirements.txt dan
   automation script setup.sh.

7. Deployment berhasil dilakukan menggunakan proses otomatis.

## Dampak

Dampak yang terjadi:

- Waktu deployment menjadi lebih lama.
- Operations membutuhkan proses troubleshooting tambahan.
- Terjadi komunikasi tambahan antara Developer dan Operations.

Lead Time sebelum otomasi:
[10 menit]

Lead Time setelah otomasi:
[2 menit]

## Akar Masalah pada Sistem

Permasalahan bukan disebabkan oleh individu tertentu, tetapi
disebabkan oleh proses deployment yang masih manual.

Beberapa faktor penyebab:

1. Dependency aplikasi tidak dikelola secara otomatis.
2. Informasi environment Developer dan Operations tidak sama.
3. Proses deployment bergantung pada instruksi manual.

## Tindakan Perbaikan (Action Items)

| Perbaikan | Penanggung Jawab |
|---|---|
| Membuat requirements.txt | Developer |
| Membuat automation setup.sh | Developer |
| Menggunakan Git repository | Developer dan Operations |
| Melakukan health check otomatis | Operations |

## Pelajaran yang Diambil

Deployment yang konsisten membutuhkan proses otomatisasi,
version control, dan komunikasi yang baik antara Developer
dan Operations.
