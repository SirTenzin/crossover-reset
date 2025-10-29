#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "CrossOver Reset - Automated Setup"
echo "========================================"

# Target directory for installation (safe macOS application data location)
INSTALL_DIR="$HOME/Library/Application Support/crossover-reset"
REPO_URL="https://github.com/SirTenzin/crossover-reset.git"

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Clone or update the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR already exists."
    read -p "Do you want to update the existing installation? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Updating existing installation..."
        cd "$INSTALL_DIR"
        git pull origin main
    else
        echo "Setup cancelled."
        exit 0
    fi
else
    echo "Cloning repository to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Make the scheduler executable
echo "Making scheduler script executable..."
chmod +x "$INSTALL_DIR/crossover-reset-scheduler.sh"
chmod +x "$INSTALL_DIR/reset-crossover.sh"

# Create logs directory
echo "Creating logs directory..."
mkdir -p "$INSTALL_DIR/logs"

# Setup cron job
echo ""
echo "Setting up cron job..."
echo "(Note: On macOS, you may be prompted to grant Terminal access to cron)"

# Build the cron command
CRON_TIME="0 5 * * *"
CRON_MKDIR="mkdir -p \"$INSTALL_DIR/logs\""
CRON_EXEC="/usr/bin/env bash \"$INSTALL_DIR/crossover-reset-scheduler.sh\""
CRON_LOG="> \"$INSTALL_DIR/logs/reset-crossover.log\" 2>&1"
CRON_COMMAND="$CRON_TIME $CRON_MKDIR && $CRON_EXEC $CRON_LOG"

# Get current crontab (or empty if none exists)
if ! CURRENT_CRON=$(crontab -l 2>/dev/null); then
    CURRENT_CRON=""
fi

# Remove any existing crossover-reset-scheduler entries
if echo "$CURRENT_CRON" | grep -q "crossover-reset-scheduler.sh"; then
    echo "Updating existing cron job..."
    CURRENT_CRON=$(echo "$CURRENT_CRON" | grep -v "crossover-reset-scheduler.sh" || true)
else
    echo "Adding new cron job..."
fi

# Create the new crontab with our entry added
if [ -n "$CURRENT_CRON" ]; then
    NEW_CRON="$CURRENT_CRON"$'\n'"$CRON_COMMAND"
else
    NEW_CRON="$CRON_COMMAND"
fi

# Install the new crontab
echo "$NEW_CRON" | crontab - || {
    echo "Error: Failed to update crontab. You may need to grant Terminal permission to manage cron jobs."
    echo "On macOS 10.14+, go to: System Settings > Privacy & Security > Full Disk Access"
    exit 1
}

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo "Installation directory: $INSTALL_DIR"
echo "Cron job configured to run daily at 5:00 AM"
echo ""
echo "The script will automatically reset CrossOver every 13 days."
echo "Logs will be saved to: $INSTALL_DIR/logs/reset-crossover.log"
echo ""
echo "To manually run the reset now, execute:"
echo "  bash \"$INSTALL_DIR/reset-crossover.sh\""
echo ""
echo "To view the cron job, run: crontab -l"
echo "To remove the cron job, run: crontab -e"
echo "========================================"
