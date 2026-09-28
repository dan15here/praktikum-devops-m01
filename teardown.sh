#!/bin/bash

set -euo pipefail

APP_DIR=$(pwd)

if [[ "$APP_DIR" != *"app-sentra"* ]]; then
    echo "Direktori tidak valid"
    exit 1
fi


pkill -f "python3 src/app.py" || true

if [ -d ".venv" ]; then
    rm -rf .venv
    echo "Virtual environment dihapus"
fi

echo "Cleanup selesai"
