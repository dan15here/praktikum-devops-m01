#!/usr/bin/env bash
# healthwatch.sh - pemantau endpoint kesehatan aplikasi Sentra

set -euo pipefail

INTERVAL=5
URL="http://127.0.0.1:5000/health"
LOG_FILE="${LOG_FILE:-healthwatch.log}"

TOTAL_CHECKS=0
INCIDENTS=0
TOTAL_DOWNTIME=0

PREV_STATUS="UNKNOWN"
INCIDENT_START=0
SESSION_START=$(date +%s)

usage() {
    cat <<EOF
Penggunaan:
  $0 [--interval N] [--url URL]

Opsi:
  --interval N   Interval pemeriksaan dalam detik (default: 5)
  --url URL      Endpoint yang dipantau
                 (default: http://127.0.0.1:5000/health)
  --help         Tampilkan bantuan
EOF
}

die() {
    printf 'GALAT: %s\n' "$*" >&2
    exit 1
}

validate_args() {
    [[ "$INTERVAL" =~ ^[0-9]+$ ]] \
        || die "--interval harus berupa angka"

    (( INTERVAL >= 1 && INTERVAL <= 3600 )) \
        || die "--interval harus antara 1 sampai 3600 detik"

    [[ "$URL" =~ ^https?:// ]] \
        || die "--url harus diawali http:// atau https://"

    command -v curl >/dev/null 2>&1 \
        || die "curl tidak ditemukan"
}

parse_args() {
    while (( $# > 0 )); do
        case "$1" in
            --interval)
                (( $# >= 2 )) || die "--interval membutuhkan nilai"
                INTERVAL="$2"
                shift 2
                ;;
            --url)
                (( $# >= 2 )) || die "--url membutuhkan nilai"
                URL="$2"
                shift 2
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                die "argumen tidak dikenal: $1"
                ;;
        esac
    done
}

iso_timestamp() {
    date '+%Y-%m-%dT%H:%M:%S%z'
}

check_endpoint() {
    local result http_code time_total response_ms status event now mttr

    result="$(
        curl \
            --silent \
            --show-error \
            --output /dev/null \
            --write-out '%{http_code} %{time_total}' \
            --max-time 3 \
            "$URL" 2>/dev/null || true
    )"

    http_code="$(awk '{print $1}' <<< "$result")"
    time_total="$(awk '{print $2}' <<< "$result")"

    http_code="${http_code:-000}"
    time_total="${time_total:-0}"

    response_ms="$(
        awk -v t="$time_total" \
            'BEGIN { printf "%.0f", t * 1000 }'
    )"

    if [[ "$http_code" =~ ^[23][0-9][0-9]$ ]]; then
        status="UP"
    else
        status="DOWN"
    fi

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    event="-"
    now=$(date +%s)

    if [[ "$status" == "DOWN" && "$PREV_STATUS" != "DOWN" ]]; then
        INCIDENTS=$((INCIDENTS + 1))
        INCIDENT_START="$now"
        event="INCIDENT_START"

        printf '[INSIDEN] Layanan DOWN pada %s\n' \
            "$(iso_timestamp)"
    fi

    if [[ "$status" == "UP" && "$PREV_STATUS" == "DOWN" ]]; then
        mttr=$((now - INCIDENT_START))
        TOTAL_DOWNTIME=$((TOTAL_DOWNTIME + mttr))

        event="RESTORED_MTTR_${mttr}s"

        printf '[PULIH] Layanan kembali UP. MTTR: %d detik\n' \
            "$mttr"

        INCIDENT_START=0
    fi

    printf '%s status=%s http=%s response_ms=%s event=%s url=%s\n' \
        "$(iso_timestamp)" \
        "$status" \
        "$http_code" \
        "$response_ms" \
        "$event" \
        "$URL" \
        | tee -a "$LOG_FILE"

    PREV_STATUS="$status"
}

print_summary() {
    local now session_duration effective_downtime uptime_seconds availability exit_code

    now=$(date +%s)
    session_duration=$((now - SESSION_START))
    effective_downtime="$TOTAL_DOWNTIME"

    if [[ "$PREV_STATUS" == "DOWN" && "$INCIDENT_START" -gt 0 ]]; then
        effective_downtime=$(
            (effective_downtime + now - INCIDENT_START)
        )
    fi

    if (( session_duration < 1 )); then
        session_duration=1
    fi

    uptime_seconds=$((session_duration - effective_downtime))

    if (( uptime_seconds < 0 )); then
        uptime_seconds=0
    fi

    availability="$(
        awk \
            -v up="$uptime_seconds" \
            -v total="$session_duration" \
            'BEGIN { printf "%.2f", (up / total) * 100 }'
    )"

    printf '\n'
    printf '===== RINGKASAN HEALTH WATCHER =====\n'
    printf 'Total pemeriksaan : %d\n' "$TOTAL_CHECKS"
    printf 'Jumlah insiden    : %d\n' "$INCIDENTS"
    printf 'Total waktu padam : %d detik\n' "$effective_downtime"
    printf 'Durasi sesi       : %d detik\n' "$session_duration"
    printf 'Ketersediaan      : %s%%\n' "$availability"
    printf 'Log               : %s\n' "$LOG_FILE"

    if (( INCIDENTS > 0 )); then
        exit_code=2
    else
        exit_code=0
    fi

    printf 'Exit code          : %d\n' "$exit_code"

    exit "$exit_code"
}

on_interrupt() {
    print_summary
}

main() {
    parse_args "$@"
    validate_args

    : > "$LOG_FILE"

    trap on_interrupt INT

    printf 'Health Watcher dimulai\n'
    printf 'URL      : %s\n' "$URL"
    printf 'Interval : %s detik\n' "$INTERVAL"
    printf 'Log      : %s\n' "$LOG_FILE"
    printf 'Tekan Ctrl+C untuk menghentikan.\n\n'

    while true; do
        check_endpoint
        sleep "$INTERVAL"
    done
}

main "$@"
