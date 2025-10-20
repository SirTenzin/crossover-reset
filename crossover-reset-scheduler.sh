#!/usr/bin/env bash
set -euo pipefail

# Paths (relative to this script)
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
STATE_FILE="$SCRIPT_DIR/.reset-crossover.last"
RESET_SCRIPT="$SCRIPT_DIR/reset-crossover.sh"

# 13 days in seconds
THRESHOLD=$((13 * 24 * 60 * 60))

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

# Execute the local reset script
/bin/bash "$RESET_SCRIPT"

# Record success time
printf '%s\n' "$now" >"$STATE_FILE"
