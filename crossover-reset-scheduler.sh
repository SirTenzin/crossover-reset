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

echo "========================================"
echo "CrossOver Reset Scheduler"
echo "Run time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"

# Read last-run timestamp if present (must be all digits)
if [[ -f "$STATE_FILE" ]]; then
    if read -r first <"$STATE_FILE"; then
        [[ "$first" =~ ^[0-9]+$ ]] && last="$first" || last=0
    fi
fi

# Calculate days since last reset
if ((last > 0)); then
    days_since=$(((now - last) / 86400))
    days_until=$((13 - days_since))
    echo "Last reset: $days_since days ago"

    # Skip if it hasn't been $THRESHOLD days yet
    if (((now - last) < THRESHOLD)); then
        echo "Status: SKIPPED (threshold: 13 days)"
        echo "Next reset in: $days_until days"
        echo "========================================"
        exit 0
    fi
else
    echo "Last reset: Never (no state file found)"
fi

echo "Status: RUNNING RESET (threshold reached)"
echo "----------------------------------------"

# Execute the local reset script
/bin/bash "$RESET_SCRIPT"

# Record success time
printf '%s\n' "$now" >"$STATE_FILE"

echo "----------------------------------------"
echo "State file updated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
