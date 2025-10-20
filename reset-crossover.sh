#!/usr/bin/env bash

BOTTLES_PATH="$HOME/Library/Application Support/CrossOver/Bottles"
BOTTLES_PATH="${BOTTLES_PATH}/*"

# Kill CrossOver processes
while true; do
    pids=$(pgrep -f "CrossOver")

    unique_pids=()
    for pid in $pids; do
        # shellcheck disable=SC2076
        if [[ -n "$pid" && ! " ${unique_pids[*]} " =~ " $pid " ]]; then
            unique_pids+=("$pid")
        fi
    done

    if [ ${#unique_pids[@]} -gt 0 ]; then
        echo "Killing CrossOver processes: ${unique_pids[*]}"
        kill -9 "${unique_pids[@]}" >/dev/null 2>&1
    else
        echo "No CrossOver processes found."
        break
    fi

    sleep 3
done

# Reset trial start date of CrossOver
while true; do
    if /usr/libexec/PlistBuddy -c "Print :FirstRunDate" ~/Library/Preferences/com.codeweavers.CrossOver.plist &>/dev/null; then
        defaults delete com.codeweavers.CrossOver FirstRunDate
        sleep 0.3
        plutil -remove FirstRunDate ~/Library/Preferences/com.codeweavers.CrossOver.plist
    fi

    sleep 1

    if ! /usr/libexec/PlistBuddy -c "Print :FirstRunDate" ~/Library/Preferences/com.codeweavers.CrossOver.plist &>/dev/null; then
        echo "FirstRunDate not found in plist file. Deletion successful."
        break
    fi
done

# Reset trial start date of the bottles
IFS=$'\n'
# shellcheck disable=SC2086
find $BOTTLES_PATH -type d -maxdepth 0 | while IFS= read -r bottle; do
    while true; do
        echo "Checking $bottle"
        if [ -d "$bottle" ]; then
            sed -i '' '/\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\].*/,+5d' "$bottle/system.reg"
        fi

        sleep 0.3

        if ! grep -q '\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\]' "$bottle/system.reg"; then
            echo "Bottle trial reset successful."
            break
        fi
    done
done

/usr/bin/osascript -e "display notification \"Crossover Trial Updated\""
