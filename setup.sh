#!/usr/bin/env bash
# setup.sh - setup & jalankan aplikasi Sentra (versi modular)

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "$APP_DIR/lib/common.sh"

VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

# Mode pengecekan environment dari Minggu 1
if [[ "${1:-}" == "--check" ]]; then
    log_info "Checking environment..."

    require_cmd python3
    require_cmd pip
    require_cmd curl
    require_cmd ss

    if port_is_free "$PORT"; then
        log_info "Port $PORT tersedia."
    else
        log_error "Port $PORT sedang digunakan."
        exit 1
    fi

    log_info "Environment siap."
    exit 0
fi

log_info "[1/5] Memeriksa prasyarat..."

require_cmd python3
require_cmd curl
require_cmd ss

python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' \
    || die "dibutuhkan Python 3.10 atau lebih baru."

# Pertahankan mekanisme dynamic port dari Minggu 1
while ! port_is_free "$PORT"; do
    log_warn "Port $PORT sedang digunakan, mencoba port berikutnya..."
    PORT=$((PORT + 1))
done

log_info "Menggunakan port $PORT"

log_info "[2/5] Menyiapkan virtual environment..."

if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
    log_info "Virtual environment berhasil dibuat."
else
    log_info "Virtual environment sudah tersedia."
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

log_info "[3/5] Memasang dependensi..."

pip install --quiet --upgrade pip
pip install --quiet -r "$APP_DIR/requirements.txt"

log_info "[4/5] Menjalankan aplikasi..."

PORT="$PORT" python3 "$APP_DIR/src/app.py" &
APP_PID=$!

log_info "Aplikasi berjalan dengan PID $APP_PID pada port $PORT."

trap 'kill "$APP_PID" 2>/dev/null || true' EXIT

sleep 3

log_info "[5/5] Smoke test..."

HEALTH_OK=false

for i in {1..5}; do
    if curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null; then
        log_info "SUKSES: aplikasi berjalan dan lulus health check."
        HEALTH_OK=true
        break
    fi

    log_warn "Percobaan health check ke-$i gagal."
    sleep 2
done

[[ "$HEALTH_OK" == true ]] || die "aplikasi tidak merespons health check setelah 5 percobaan."

log_info "Tekan Ctrl+C untuk menghentikan aplikasi."

wait "$APP_PID"
