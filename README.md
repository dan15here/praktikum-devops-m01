# Praktikum DevOps Minggu 1–3

## Fondasi DevOps, Automasi, Monitoring, dan Version Control

Repository ini berisi hasil praktikum DevOps dari Minggu 1 sampai Minggu 3. Praktikum membahas proses deployment, shell scripting, monitoring layanan, penggunaan Git, keamanan repository, dan otomatisasi pemeriksaan commit.

Aplikasi yang digunakan adalah **Sentra Digital Batam**, yaitu aplikasi sederhana berbasis Flask untuk menyimulasikan proses deployment dalam Software Development Life Cycle (SDLC).

---

## 👥 Team

| Role | Member | NIM |
|---|---|---|
| Developer | Laila Rezky | 4332511025 |
| Operations | Muhammad Danish | 4332511020 |

---

# 📌 Project Overview

Pada tahap awal, deployment dilakukan secara manual melalui proses handover dari Developer kepada Operations.

Proses tersebut menimbulkan beberapa masalah:

- Dependency belum terdokumentasi dengan baik
- Environment Developer dan Operations berbeda
- Proses deployment masih manual
- Troubleshooting membutuhkan komunikasi tambahan
- Belum ada monitoring otomatis terhadap layanan

Permasalahan tersebut diperbaiki secara bertahap menggunakan automasi deployment, shell scripting, monitoring, version control, dan Git hooks.

---

# 🏗️ Workflow Praktikum

## 1. Manual Deployment

```text
Developer
    |
    | Serah-terima artefak manual
    |
    v
Operations
    |
    | Memasang dependency dan menjalankan aplikasi
    |
    v
Deployment Failure
```

Masalah yang ditemukan:

- Dependency belum tersedia
- Environment berbeda
- Instruksi deployment masih manual
- Risiko kesalahan manusia lebih tinggi

---

## 2. Automated Deployment

```text
Developer
    |
    v
Git Repository
    |
    v
Operations
    |
    v
Menjalankan ./setup.sh
```

Script `setup.sh` akan:

- Mengecek kebutuhan environment
- Membuat virtual environment
- Memasang dependency
- Menjalankan aplikasi
- Melakukan smoke test dan health check

---

## 3. Monitoring Layanan

```text
Aplikasi
    |
    v
healthwatch.sh
    |
    ├── Layanan sehat
    |
    └── Insiden terdeteksi
            |
            v
      Pencatatan waktu pemulihan
```

Script monitoring digunakan untuk memeriksa kesehatan layanan, mendeteksi insiden, dan menghitung waktu pemulihan atau MTTR.

---

# 📂 Project Structure

```text
app-sentra/
│
├── src/
│   └── app.py
│
├── lib/
│   └── common.sh
│
├── hooks/
│   ├── pre-commit
│   └── commit-msg
│
├── requirements.txt
├── setup.sh
├── teardown.sh
├── sysreport.sh
├── healthwatch.sh
├── buat-log.sh
├── .gitignore
├── HANDOVER.md
├── POSTMORTEM.md
└── README.md
```

---

# ⚙️ Requirements

Environment yang dibutuhkan:

- Linux atau WSL Ubuntu
- Python 3.10 atau lebih baru
- Git
- pip
- OpenSSH
- ShellCheck

---

# 🚀 Installation and Running

Clone repository menggunakan SSH:

```bash
git clone git@github.com:dan15here/praktikum-devops-m01.git
```

Masuk ke directory repository:

```bash
cd praktikum-devops-m01
```

Jalankan automated deployment:

```bash
./setup.sh
```

Jika berhasil, akan muncul pesan:

```text
SUKSES: aplikasi berjalan dan lulus health check.
```

Untuk menghentikan atau membersihkan environment:

```bash
./teardown.sh
```

---

# 🧪 Testing

Lakukan health check pada aplikasi:

```bash
curl http://127.0.0.1:5000/health
```

Respons yang diharapkan:

```json
{
  "status": "ok"
}
```

Jalankan laporan sistem:

```bash
./sysreport.sh
```

Jalankan monitoring layanan:

```bash
./healthwatch.sh
```

---

# 🔄 SDLC Comparison

## Waterfall Flow

```text
Requirement
      |
      v
Design
      |
      v
Implementation
      |
      v
Testing
      |
      v
Deployment
```

Pada model Waterfall, setiap tahap dilakukan secara berurutan. Perubahan pada tahap akhir dapat membutuhkan proses yang lebih panjang.

## DevOps Continuous Flow

```text
Backlog
   |
   v
In Progress
   |
   v
Review
   |
   v
Deployed
   |
   v
Monitored
   |
   v
Feedback
```

Pada DevOps, proses pengembangan, deployment, monitoring, dan perbaikan dilakukan secara berkelanjutan.

---

# 📊 DevOps Implementation

Implementasi DevOps pada project ini:

- Version control menggunakan Git
- Repository disimpan di GitHub
- Autentikasi GitHub menggunakan SSH
- Deployment otomatis menggunakan `setup.sh`
- Dependency dikelola melalui `requirements.txt`
- Environment dipisahkan menggunakan virtual environment
- Pemeriksaan aplikasi dilakukan dengan health check
- Monitoring layanan menggunakan `healthwatch.sh`
- Laporan sistem dibuat menggunakan `sysreport.sh`
- Dokumentasi insiden menggunakan Blameless Postmortem
- Pemeriksaan commit menggunakan Git hooks
- Pemeriksaan shell script menggunakan ShellCheck
- Pesan commit mengikuti Conventional Commits

---

# 📅 Perkembangan Praktikum

## Minggu 1 — Dasar DevOps dan Automasi Deployment

Pada Minggu 1 dilakukan simulasi proses deployment manual dan otomatis.

Kegiatan yang dilakukan:

- Memahami konsep DevOps dan Wall of Confusion
- Melakukan handover dari Developer ke Operations
- Mencoba deployment secara manual
- Mencatat masalah saat deployment
- Membuat script `setup.sh`
- Menggunakan virtual environment Python
- Melakukan health check aplikasi
- Membuat dokumentasi handover
- Membuat Blameless Postmortem

Hasil praktikum:

- Deployment menjadi lebih konsisten
- Dependency dapat dipasang secara otomatis
- Kesalahan manual dapat dikurangi
- Proses troubleshooting lebih mudah dilakukan

---

## Minggu 2 — Shell Scripting dan Monitoring

Pada Minggu 2 dilakukan pengembangan shell script untuk membantu operasi dan monitoring aplikasi.

Kegiatan yang dilakukan:

- Membuat fungsi bersama pada `lib/common.sh`
- Membuat laporan sistem menggunakan `sysreport.sh`
- Membuat monitoring layanan menggunakan `healthwatch.sh`
- Menggunakan logging yang konsisten
- Melakukan validasi perintah dan environment
- Mendeteksi kondisi layanan sehat atau bermasalah
- Mencatat waktu insiden dan pemulihan
- Menghitung Mean Time to Recovery atau MTTR
- Mengabaikan file log melalui `.gitignore`

Hasil praktikum:

- Script menjadi lebih modular dan mudah digunakan kembali
- Kondisi sistem dapat diperiksa secara otomatis
- Gangguan layanan dapat diketahui lebih cepat
- Informasi insiden dan waktu pemulihan dapat dicatat dengan jelas

---

## Minggu 3 — Git, GitHub, dan Keamanan Repository

Pada Minggu 3 dilakukan praktikum mengenai version control, keamanan repository, dan manipulasi riwayat Git.

Kegiatan yang dilakukan:

- Mengatur identitas dan konfigurasi Git
- Membuat SSH key khusus GitHub
- Mengubah remote repository dari HTTPS ke SSH
- Mempelajari working directory, staging area, dan repository
- Mempelajari kode `git status --short`
- Menggunakan `.gitignore`
- Memeriksa objek commit, tree, dan blob
- Membandingkan perubahan menggunakan `git diff`
- Memperbaiki commit menggunakan `git commit --amend`
- Mencoba `git reset --soft`
- Mencoba `git reset --mixed`
- Mencoba `git reset --hard`
- Memulihkan commit menggunakan `git reflog`
- Membatalkan perubahan menggunakan `git revert`
- Menggunakan Conventional Commits
- Membuat annotated tag `v1.0.0`
- Memindai riwayat Git untuk mencari kemungkinan kredensial
- Membuat Git hooks untuk memeriksa commit

Hasil praktikum:

- Akses GitHub dapat dilakukan tanpa memasukkan username dan token
- Perubahan file dapat dikontrol melalui staging area
- Riwayat Git dapat diperbaiki dan dipulihkan
- Commit dapat dibatalkan tanpa menghapus riwayat
- Versi stabil project dapat ditandai menggunakan tag
- Risiko kredensial masuk ke repository dapat dikurangi
- Kualitas shell script dapat diperiksa sebelum commit

---

# 🔐 Keamanan Repository

Repository menggunakan beberapa langkah keamanan:

## 1. SSH Authentication

Remote repository menggunakan SSH:

```text
git@github.com:dan15here/praktikum-devops-m01.git
```

SSH membuat proses autentikasi lebih aman dan tidak meminta username atau token setiap kali melakukan operasi Git.

## 2. Gitignore

File berikut tidak dimasukkan ke repository:

```gitignore
.venv/
__pycache__/
*.pyc
.env
*.log
app.log
ringkasan-log.txt
healthwatch.log
```

File `.env` dan file log diabaikan karena dapat berisi data rahasia atau data sementara.

## 3. Credential Scanning

Riwayat Git diperiksa menggunakan pola yang menyerupai token, access key, private key, dan password.

Contoh pemeriksaan:

```bash
git log -p --all \
  | grep -nEi '(ghp_|AKIA|BEGIN .*PRIVATE KEY|password *=)' \
  | head
```

Jika tidak ada output, berarti pola kredensial tersebut tidak ditemukan pada riwayat yang diperiksa.

---

# 🪝 Git Hooks

Repository menyediakan dua Git hook pada directory `hooks/`.

## Pre-commit Hook

File:

```text
hooks/pre-commit
```

Fungsinya:

- Memeriksa staged changes
- Menolak perubahan yang menyerupai kredensial
- Menjalankan ShellCheck pada shell script
- Menghentikan commit jika ditemukan masalah

Contoh pesan penolakan:

```text
ERROR: commit ditolak karena perubahan staged menyerupai kredensial.
```

atau:

```text
ERROR: commit ditolak karena ShellCheck menemukan masalah.
```

## Commit-msg Hook

File:

```text
hooks/commit-msg
```

Fungsinya adalah memeriksa agar pesan commit mengikuti format Conventional Commits.

Format yang digunakan:

```text
type: deskripsi singkat
```

Jenis commit yang diizinkan:

- `feat`
- `fix`
- `docs`
- `chore`
- `refactor`
- `test`

Contoh pesan yang benar:

```text
feat: tambahkan fitur baru
fix: perbaiki kesalahan health check
docs: perbarui dokumentasi penggunaan
chore: tambahkan hook pemeriksaan commit
```

Contoh pesan yang ditolak:

```text
pesan tidak sesuai
```

## Memasang Hooks

Salin hooks ke directory Git:

```bash
cp hooks/pre-commit .git/hooks/pre-commit
cp hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
```

---

# 🏷️ Version and Release

Versi pertama project ditandai menggunakan annotated tag:

```text
v1.0.0
```

Keterangan tag:

```text
Rilis pertama: deployment otomatis dan laporan sistem
```

Tag tersebut menunjuk ke commit:

```text
71066b9 docs: lengkapi panduan SSH dan daftar skrip
```

Halaman tag dapat dilihat pada:

```text
https://github.com/dan15here/praktikum-devops-m01/tags
```

---

# 📝 Postmortem

Dokumentasi analisis kegagalan deployment manual tersedia pada:

```text
POSTMORTEM.md
```

Dokumen tersebut berisi:

- Ringkasan insiden
- Timeline kejadian
- Dampak
- Root cause analysis
- Action items
- Lesson learned

Postmortem dibuat dengan pendekatan tanpa menyalahkan individu. Fokus utama adalah penyebab masalah dan perbaikan proses.

---

# 📜 Skrip yang Tersedia

| Berkas | Fungsi |
|---|---|
| `setup.sh` | Menyiapkan virtual environment, memasang dependency, dan menjalankan smoke test |
| `teardown.sh` | Menghentikan dan membersihkan environment aplikasi |
| `lib/common.sh` | Menyediakan fungsi logging dan validasi yang digunakan bersama |
| `sysreport.sh` | Membuat laporan kesehatan sistem |
| `healthwatch.sh` | Memantau kesehatan layanan dan mendeteksi insiden |
| `buat-log.sh` | Membantu membuat data log untuk kebutuhan praktikum |
| `hooks/pre-commit` | Memeriksa kredensial dan shell script sebelum commit |
| `hooks/commit-msg` | Memeriksa format pesan commit |

---

# 📚 Informasi Praktikum

**Jurusan:**
Teknik Informatika

**Program Studi:**
Rekayasa Keamanan Siber

**Semester:**
3

**Mata Kuliah:**  
DevOps

**Institusi:**  
Politeknik Negeri Batam

**Topik Minggu 1:**  
Introduction to DevOps: Filosofi, Budaya, dan SDLC

**Topik Minggu 2:**  
Shell Scripting, System Report, dan Monitoring Layanan

**Topik Minggu 3:**  
Version Control dengan Git, GitHub, SSH, dan Keamanan Repository


