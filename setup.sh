#!/usr/bin/env bash

if [ "$1" = "--check" ]; then
    echo "Checking environment..."

    command -v python3 >/dev/null || {
        echo "Python tidak ditemukan"
        exit 1
    }

    command -v pip >/dev/null || {
        echo "pip tidak ditemukan"
        exit 1
    }

    if lsof -i :5000 >/dev/null; then
        echo "Port 5000 sedang digunakan"
        exit 1
    fi

    echo "Environment siap"
    exit 0
fi

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$APP_DIR/.venv"
PORT="${PORT:-5000}"

while lsof -i:"$PORT" >/dev/null
do
    PORT=$((PORT+1))
done

echo "Menggunakan port $PORT"

echo "[1/5] Memeriksa prasyarat..."

command -v python3 >/dev/null || {
    echo "GAGAL: python3 tidak ditemukan."
    exit 1
}

python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' || {
    echo "GAGAL: dibutuhkan Python 3.10 atau lebih baru."
    exit 1
}

echo "[2/5] Menyiapkan virtual environment..."

[ -d "$VENV_DIR" ] || python3 -m venv "$VENV_DIR"

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "[3/5] Memasang dependensi..."

pip install --quiet --upgrade pip
pip install --quiet -r "$APP_DIR/requirements.txt"

echo "[4/5] Menjalankan aplikasi..."

PORT="$PORT" python3 "$APP_DIR/src/app.py" &
APP_PID=$!

trap 'kill "$APP_PID" 2>/dev/null || true' EXIT

sleep 3

echo "[5/5] Smoke test..."

for i in {1..5}
do 
  if curl -f "http://127.0.0.1:$PORT/health"
  then
      echo "Health check berhasil."
      exit 0
  fi

  echo "Percobaan $i gagal..."
  sleep 2
done

echo "Health check gagal"
exit 1
