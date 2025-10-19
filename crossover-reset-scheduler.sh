#!/usr/bin/env bash
set -euo pipefail

# Paths (relative to this script)
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
STATE_FILE="$SCRIPT_DIR/.reset-crossover.last"

# 13 days in seconds
THRESHOLD=$((13 * 24 * 60 * 60))

URL="https://raw.githubusercontent.com/av1155/crossover-reset/refs/heads/main/resetCrossoverTrial.sh"

now=$(date +%s)
last=0

# Read last-run timestamp if present (must be all digits)
if [[ -f "$STATE_FILE" ]]; then
    if read -r first <"$STATE_FILE"; then
        [[ "$first" =~ ^[0-9]+$ ]] && last="$first" || last=0
    fi
fi

# Skip if it hasn't been $THRESHOLD days yet
if ((last > 0 && (now - last) < THRESHOLD)); then
    exit 0
fi

# Simple quick run: fetch latest and execute
/usr/bin/curl -fsSL "$URL" | /bin/bash

# Record success time
printf '%s\n' "$now" >"$STATE_FILE"
