# Aplikasi Sentra Digital Batam (`app-sentra`) — Praktikum DevOps

Repository proyek praktikum mata kuliah **DevOps (`RKS305`)**, Program Studi **Rekayasa Keamanan Siber**, Jurusan Teknik Informatika, **Politeknik Negeri Batam**.

Repository ini mendokumentasikan evolusi pengelolaan dan *deployment* aplikasi layanan web **PT Sentra Digital Batam** (`Flask`) secara bertahap—mulai dari serah-terima manual dan skrip otomasi (`setup.sh`) pada Minggu ke-1, pemantauan sistem Linux pada Minggu ke-2, hingga kontainerisasi menggunakan **Docker Engine** pada **Minggu ke-5 (JS-DVO-05)**.

---

## Identitas

| Keterangan | Detail |
| :--- | :--- |
| **Mahasiswa** | Muhammad Danish (`4332511020`) — [@dan15here](https://github.com/dan15here) |
| **Kelas / Prodi** | RKS 3A Malam · Rekayasa Keamanan Siber |
| **Mata Kuliah** | DevOps (`RKS305`) — Semester 3 / 2026–2027 |
| **Dosen Pengampu** | Antoni Haikal, S.T., M.T. |

---

## Struktur Repository

```text
app-sentra/
├── src/
│   └── app.py            # Aplikasi Flask Sentra (endpoint / dan /health, mendukung env HOST, PORT, BUILD_ID)
├── lib/                  # Pustaka fungsi bantu skrip shell
├── hooks/                # Git hooks lokal
├── requirements.txt      # Dependensi Python terkunci (flask==3.0.3)
├── setup.sh              # Skrip otomasi penyiapan venv, instalasi, & smoke test (Minggu 1)
├── teardown.sh           # Skrip pembersihan proses dan virtual environment (Minggu 1)
├── healthwatch.sh        # Skrip pemantauan kesehatan layanan berkala (Minggu 2)
├── sysreport.sh          # Skrip pelaporan kondisi sistem (Minggu 2)
├── buat-log.sh           # Skrip simulasi/pengelolaan log (Minggu 2)
├── HANDOVER.md           # Dokumen serah terima Dev -> Ops (Minggu 1)
├── POSTMORTEM.md         # Blameless Postmortem kegagalan deployment manual (Minggu 1)
├── CHALLENGEM05.md       # Laporan Challenge Minggu 5: "Container yang Ramping dan Aman" (+10 poin)
└── README.md             # Dokumentasi utama proyek
```

---

## Endpoint Aplikasi

| Endpoint | Metode | Contoh Respons JSON |
| :--- | :---: | :--- |
| `/` | `GET` | `{"build":"container-m05","service":"sentra-digital-batam","status":"running","time":"..."}` |
| `/health` | `GET` | `{"status":"ok"}` (HTTP `200`) |

### Variabel Lingkungan (`src/app.py`)

| Variabel | Nilai Default | Fungsi |
| :--- | :--- | :--- |
| `HOST` | `127.0.0.1` | Alamat dengar Flask (gunakan `0.0.0.0` di dalam Docker container) |
| `PORT` | `5000` | Porta layanan Flask di dalam host / container |
| `BUILD_ID` | `dev-local` | Penanda identitas build yang ditampilkan pada endpoint `/` |

---

## Cara Menjalankan

### A. Mode Skrip Otomasi Lokal (Minggu 1)
```bash
./setup.sh --check   # Verifikasi prasyarat lingkungan host
./setup.sh           # Menyiapkan .venv, memasang dependensi, menjalankan Flask, & smoke test
./teardown.sh        # Menghentikan layanan dan membersihkan .venv
```

### B. Mode Docker Container tanpa Dockerfile (Minggu 5 — JS-DVO-05)
Menjalankan aplikasi di atas official image `python:3.11-slim` dengan pemetaan porta `8080:5000` dan *bind mount* kode sumber:

```bash
docker run -d --name sentra \
  -p 8080:5000 \
  -e HOST=0.0.0.0 -e PORT=5000 -e BUILD_ID=container-m05 \
  -v "$PWD":/app -w /app \
  python:3.11-slim \
  sh -c "pip install --quiet -r requirements.txt && python3 src/app.py"
```

Verifikasi layanan dari mesin induk:
```bash
curl -s http://127.0.0.1:8080/ ; echo
curl -s http://127.0.0.1:8080/health ; echo
```

Hentikan dan bersihkan container:
```bash
docker rm -f sentra
```

### C. Mode Hardened Container — Challenge Minggu 5 (Bagian 9.2)
Aplikasi juga telah diuji dengan konfigurasi mendekati standar produksi: pengguna non-root (`--user 65534:65534`), root filesystem baca-saja (`--read-only`) + `--tmpfs /tmp`, batas sumber daya (`--memory=256m --cpus=0.5`), dan pemeriksaan kesehatan bawaan (`--health-cmd`).

Detail lengkap benchmark tiga basis image (`python:3.11`, `python:3.11-slim`, `python:3.11-alpine`), perintah *reproducible*, bukti keluaran, serta rekomendasi basis image untuk `Dockerfile` Minggu ke-6 (**`python:3.11-slim`**) tersedia di:
👉 **[`CHALLENGEM05.md`](./CHALLENGEM05.md)**

---

## Ringkasan Progres Mingguan

- **Minggu 1:** Simulasi *Wall of Confusion*, *Value Stream Mapping*, otomasi `setup.sh`/`teardown.sh`, dan *Blameless Postmortem*.
- **Minggu 2:** Manajemen proses, sinyal (`SIGTERM`/`SIGKILL`), *exit code*, serta skrip pemantauan (`healthwatch.sh`, `sysreport.sh`).
- **Minggu 3:** Pengelolaan repositori Git dan *Git hooks*.
- **Minggu 5 (JS-DVO-05):** Instalasi Docker Engine tanpa `sudo`, pembuktian isolasi *namespace*, batas memori *cgroup v2* (`exit code 137`), bedah lapisan image (`overlayfs`), kontainerisasi aplikasi Sentra tanpa `Dockerfile`, persistensi *volume*, *user-defined network*, serta penyelesaian Challenge [`CHALLENGEM05.md`](./CHALLENGEM05.md).
