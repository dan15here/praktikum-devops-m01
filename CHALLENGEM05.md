# CHALLENGE MINGGU 5 (JS-DVO-05): "CONTAINER YANG RAMPING DAN AMAN"

- **Nama Lengkap:** Muhammad Danish
- **NIM:** 4332511020
- **Kelas:** RKS 3A Malam
- **Mata Kuliah:** DevOps (RKS305) — Program Studi Rekayasa Keamanan Siber, Politeknik Negeri Batam
- **Dosen Pengampu:** Antoni Haikal, S.T., M.T.
- **Lingkungan Pengujian:** Ubuntu 24.04.3 LTS (WSL2) · Host `DanzyyyPC` · Docker Engine `29.10.1`
- **Aplikasi Target:** `~/praktikum-devops/minggu-01/app-sentra` (`flask==3.0.3`, tanpa `Dockerfile`)

---

## 1. Perbandingan Tiga Basis Image Python (`python:3.11`, `python:3.11-slim`, `python:3.11-alpine`)

### Perintah yang Dijalankan (Reproducible)
```bash
cd ~/praktikum-devops/minggu-01/app-sentra

docker pull python:3.11
docker pull python:3.11-slim
docker pull python:3.11-alpine
docker images | grep -E "IMAGE|REPOSITORY|python"

for img in python:3.11 python:3.11-slim python:3.11-alpine; do
  echo "=== Menguji $img ==="
  START=$(date +%s)
  docker run -d --name uji-bench -p 8080:5000 \
    -e HOST=0.0.0.0 -e PORT=5000 -e BUILD_ID="bench-$img" \
    -v "$PWD":/app -w /app "$img" \
    sh -c "pip install --quiet -r requirements.txt && python3 src/app.py" >/dev/null
  until curl -sf http://127.0.0.1:8080/health >/dev/null 2>&1; do
    sleep 1
  done
  END=$(date +%s)
  echo "Image: $img | Waktu siap: $((END - START)) detik"
  curl -s http://127.0.0.1:8080/ ; echo
  docker rm -f uji-bench >/dev/null
done
```

### Tabel Hasil Perbandingan

| Basis Image | Image ID | Ukuran Disk Usage | Content Size (Compressed) | Waktu Siap Melayani (`/health`) | Basis OS & C Library |
| :--- | :--- | ---: | ---: | ---: | :--- |
| `python:3.11` | `1829edfddfa9` | **1,62 GB** | 428 MB | **7 detik** | Debian penuh (`glibc`, build tools, compiler, git, curl) |
| `python:3.11-slim` | `61e01f72680f` | **189 MB** | 47,8 MB | **9 detik** | Debian minimal (`glibc`, tanpa compiler/utilitas berlebih) |
| `python:3.11-alpine` | `7fbad8e4652e` | **84,6 MB** | 21,1 MB | **9 detik** | Alpine Linux (`musl libc` + BusyBox) |

### Bukti Keluaran Benchmark
```text
IMAGE               ID             DISK USAGE   CONTENT SIZE
python:3.11         1829edfddfa9   1.62GB       428MB
python:3.11-alpine  7fbad8e4652e   84.6MB       21.1MB
python:3.11-slim    61e01f72680f   189MB        47.8MB

=== Menguji python:3.11 ===
Image: python:3.11 | Waktu siap: 7 detik
{"build":"bench-python:3.11","service":"sentra-digital-batam-v2","status":"running","time":"2026-11-26T01:08:14"}

=== Menguji python:3.11-slim ===
Image: python:3.11-slim | Waktu siap: 9 detik
{"build":"bench-python:3.11-slim","service":"sentra-digital-batam-v2","status":"running","time":"2026-11-26T01:08:24"}

=== Menguji python:3.11-alpine ===
Image: python:3.11-alpine | Waktu siap: 9 detik
{"build":"bench-python:3.11-alpine","service":"sentra-digital-batam-v2","status":"running","time":"2026-11-26T01:08:34"}
```

**Temuan Kunci:** `python:3.11` berukuran **8,5× lebih besar** dari `python:3.11-slim` dan **19,1× lebih besar** dari `python:3.11-alpine`, namun selisih waktu siapnya hanya 2 detik (`7 detik` vs `9 detik`).

---

## 2–5. Menjalankan Container Hardened (Non-Root, Read-Only + tmpfs, Resource Limits, & Healthcheck)

Seluruh persyaratan pengamanan (Butir 2, 3, 4, dan 5) digabungkan dalam satu konfigurasi `docker run` mendekati standar produksi tanpa `Dockerfile`:

- **Butir 2 (Non-root):** `--user 65534:65534` (pengguna `nobody`, grup `nogroup`).
- **Butir 3 (Read-only + tmpfs):** `--read-only` pada root filesystem, `-v "$PWD":/app:ro` untuk bind mount kode sumber bersifat baca-saja, serta `--tmpfs /tmp:rw,exec,nosuid,nodev,size=128m` (menyediakan direktori sementara di RAM untuk `pip install --target /tmp/pylibs`, cache pip, dan ekstensi `.so` MarkupSafe) ditambah `PYTHONDONTWRITEBYTECODE=1` agar Python tidak menulis `__pycache__` ke `/app`.
- **Butir 4 (Batas Sumber Daya):** `--memory=256m` dan `--cpus=0.5`.
- **Butir 5 (Healthcheck Bawaan Docker):** `--health-cmd` memanfaatkan pustaka standar Python `urllib.request` (sehingga tidak perlu memasang `curl` ke dalam image minimal) untuk memanggil `http://127.0.0.1:5000/health` setiap 5 detik.

### Perintah Lengkap (Reproducible)
```bash
docker run -d --name sentra-aman \
  --user 65534:65534 \
  --read-only \
  --tmpfs /tmp:rw,exec,nosuid,nodev,size=128m \
  --memory=256m \
  --cpus=0.5 \
  -p 8080:5000 \
  -e HOST=0.0.0.0 -e PORT=5000 -e BUILD_ID=challenge-m05 \
  -e HOME=/tmp -e PIP_CACHE_DIR=/tmp/pip-cache \
  -e PYTHONDONTWRITEBYTECODE=1 -e PYTHONPATH=/tmp/pylibs \
  -v "$PWD":/app:ro -w /app \
  --health-cmd='python3 -c "import urllib.request; urllib.request.urlopen(\"http://127.0.0.1:5000/health\", timeout=2)"' \
  --health-interval=5s --health-timeout=3s --health-start-period=15s --health-retries=3 \
  python:3.11-slim \
  sh -c "pip install --quiet --no-warn-script-location --target /tmp/pylibs -r requirements.txt && python3 src/app.py"
```

---

### Bukti Butir 2 — Pengguna Non-Root (`--user 65534:65534`)

```bash
docker exec sentra-aman whoami
docker exec sentra-aman id
```

**Keluaran Aktual:**
```text
danish@DanzyyyPC:~/praktikum-devops/minggu-01/app-sentra$ docker exec sentra-aman whoami
nobody
danish@DanzyyyPC:~/praktikum-devops/minggu-01/app-sentra$ docker exec sentra-aman id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)
```

Proses berjalan sepenuhnya sebagai pengguna tak berhak istimewa (`uid=65534(nobody)`), bukan `root` (`uid=0`), sehingga memperkecil dampak apabila terjadi kerentanan di dalam aplikasi.

---

### Bukti Butir 3 — Sistem Berkas `--read-only` & `--tmpfs`

```bash
docker exec sentra-aman touch /uji-ro.txt || true
docker exec sentra-aman sh -c 'echo "tmpfs-ok" > /tmp/uji-rw.txt && cat /tmp/uji-rw.txt'
curl -s http://127.0.0.1:8080/ ; echo
curl -s http://127.0.0.1:8080/health ; echo
```

**Keluaran Aktual:**
```text
danish@DanzyyyPC:~/praktikum-devops/minggu-01/app-sentra$ docker exec sentra-aman touch /uji-ro.txt || true
touch: cannot touch '/uji-ro.txt': Read-only file system
danish@DanzyyyPC:~/praktikum-devops/minggu-01/app-sentra$ docker exec sentra-aman sh -c 'echo "tmpfs-ok" > /tmp/uji-rw.txt && cat /tmp/uji-rw.txt'
tmpfs-ok
danish@DanzyyyPC:~/praktikum-devops/minggu-01/app-sentra$ curl -s http://127.0.0.1:8080/ ; echo
{"build":"challenge-m05","service":"sentra-digital-batam-v2","status":"running","time":"2026-11-26T01:24:21"}
danish@DanzyyyPC:~/praktikum-devops/minggu-01/app-sentra$ curl -s http://127.0.0.1:8080/health ; echo
{"status":"ok"}
```

Root filesystem menolak penulisan (`Read-only file system`), hanya mount `--tmpfs` pada `/tmp` yang dapat ditulisi (berbasis RAM dan bersifat volatil), dan aplikasi Sentra tetap melayani endpoint `/` maupun `/health` secara normal.

---

### Bukti Butir 4 — Pembatasan Sumber Daya (`--memory=256m`, `--cpus=0.5`)

```bash
sh -c 'for i in $(seq 1 20); do curl -s http://127.0.0.1:8080/ >/dev/null; done' &
docker stats --no-stream sentra-aman
wait
```

**Keluaran Aktual:**
```text
CONTAINER ID   NAME          CPU %     MEM USAGE / LIMIT   MEM %     NET I/O           BLOCK I/O     PIDS
8f3e37f3a435   sentra-aman   0.02%     45.48MiB / 256MiB   17.77%    1.04MB / 71.6kB   34.3MB / 0B   2
```

Batas memori pada Cgroup v2 aktif di **256 MiB** (turun dari kapasitas penuh host `6.645 GiB`). Saat melayani 20 permintaan HTTP beruntun, aplikasi Sentra hanya mengonsumsi **45,48 MiB (17,77%)** memori dan **0,02% CPU** (jauh di bawah batas 0,5 core / 50%).

---

### Bukti Butir 5 — Pemeriksaan Kesehatan Bawaan Docker (`starting` → `healthy`)

```bash
# Cek sesaat setelah container dijalankan:
docker ps --filter name=sentra-aman --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

# Tunggu transisi status menjadi healthy:
until [ "$(docker inspect --format '{{.State.Health.Status}}' sentra-aman)" = "healthy" ]; do
  sleep 2
done
docker ps --filter name=sentra-aman --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

# Pembersihan container uji:
docker rm -f sentra-aman
```

**Transisi Status Teramati pada `docker ps`:**
1. **Tahap awal (`health: starting`):** Sesaat setelah `docker run`, status container berada pada `Up ... (health: starting)` selama periode `--health-start-period=15s` ketika `pip install` menyiapkan Flask dan server mulai mengikat porta `0.0.0.0:5000`.
2. **Tahap siap (`healthy`):** Setelah Flask merespons HTTP 200 OK pada `http://127.0.0.1:5000/health`, `docker ps` memperbarui status menjadi `(healthy)`:
```text
CONTAINER ID   IMAGE              COMMAND                CREATED          STATUS                    PORTS                                         NAMES
040468e933d7   python:3.11-slim   "sh -c 'pip install …" 42 seconds ago   Up 42 seconds (healthy)   0.0.0.0:8080->5000/tcp, [::]:8080->5000/tcp   sentra-aman
```

---

## 6. Rekomendasi Basis Image untuk Minggu ke-6 (`Dockerfile`)

### Rekomendasi: **`python:3.11-slim`**

Berdasarkan hasil benchmark dan pengujian pengamanan di atas, basis image yang direkomendasikan untuk penyusunan `Dockerfile` aplikasi Sentra pada Minggu ke-6 adalah **`python:3.11-slim`**, dengan pertimbangan dari tiga aspek utama:

1. **Ditinjau dari Ukuran (Efisiensi Penyimpanan & Distribusi):**
   - `python:3.11-slim` hanya memakai **189 MB** (Content Size **47,8 MB**), memangkas ukuran hingga **88,3%** dibanding image penuh `python:3.11` (**1,62 GB** / Content **428 MB**).
   - Walaupun `python:3.11-alpine` lebih kecil (**84,6 MB** / Content **21,1 MB**), selisih ~104 MB pada disk (`~26,7 MB` saat diunduh) sangat kecil dibandingkan risiko biaya waktu build dan ukuran tambahan yang muncul apabila proyek kelak membutuhkan paket Python berbasis ekstensi C yang harus dikompilasi ulang dari sumber pada Alpine.

2. **Ditinjau dari Kecepatan (Startup & Kompatibilitas Ekosistem Python):**
   - Pada pengujian aktual, `python:3.11-slim` dan `python:3.11-alpine` mencatat waktu siap identik (**9 detik**), hanya terpaut 2 detik dari `python:3.11` (**7 detik**).
   - Keunggulan krusial `python:3.11-slim` adalah penggunaan **`glibc`** standar Debian, sehingga seluruh pustaka Python modern di PyPI (`manylinux` binary wheels seperti `cryptography`, `psycopg2-binary`, `numpy`, `gunicorn`) dapat dipasang instan tanpa memasang `gcc`, `musl-dev`, atau `build-base` (yang pada Alpine sering memperlambat build CI/CD dan justru memperbesar image).
   - Ketika dependensi dibekukan di tahap `RUN pip install` dalam `Dockerfile` pada Minggu ke-6 (terutama dengan *multi-stage build*), waktu startup container `python:3.11-slim` akan turun dari 9 detik menjadi **< 2 detik**.

3. **Ditinjau dari Permukaan Serangan (Attack Surface & Hardening):**
   - Dibandingkan `python:3.11` penuh yang menyertakan puluhan utilitas pengembangan (`gcc`, `g++`, `git`, `curl`, `wget`, `make`, *header* pengembangan) yang dapat dimanfaatkan penyerang pasca-eksploitasi (*living-off-the-land*), `python:3.11-slim` membuang seluruh perkakas kompilasi dan jaringan yang tidak diperlukan.
   - Sebagaimana dibuktikan pada pengujian `sentra-aman`, `python:3.11-slim` bekerja mulus dengan praktik *container hardening* ketat: pengguna non-root (`nobody`), root filesystem `--read-only` + `--tmpfs`, pembatasan Cgroup v2 (`--memory=256m --cpus=0.5`), dan `--health-cmd` berbasis Python stdlib tanpa memasang `curl`.

### Ringkasan Keputusan

| Kriteria | `python:3.11` | `python:3.11-slim` *(Dipilih)* | `python:3.11-alpine` |
| :--- | :---: | :---: | :---: |
| Ukuran & Kecepatan Pull | Buruk (1,62 GB) | **Sangat Baik (189 MB)** | Terbaik (84,6 MB) |
| Kompatibilitas Wheel PyPI | Terbaik (`glibc`) | **Terbaik (`glibc`)** | Sedang (`musl`, rawan compile) |
| Permukaan Serangan | Luas (banyak tools) | **Minimal** | Sangat Minimal |
| Kesiapan Produksi Python | Kurang Efisien | **Paling Seimbang & Direkomendasikan** | Cocok jika 100% pure-Python |
