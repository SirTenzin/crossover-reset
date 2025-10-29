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

# Check if cron job already exists
CRON_COMMAND="0 5 * * * mkdir -p \"$INSTALL_DIR/logs\" && /usr/bin/env bash \"$INSTALL_DIR/crossover-reset-scheduler.sh\" > \"$INSTALL_DIR/logs/reset-crossover.log\" 2>&1"

# Get current crontab (or empty if none exists)
CURRENT_CRON=$(crontab -l 2>/dev/null || echo "")

# Check if our cron job is already installed
if echo "$CURRENT_CRON" | grep -q "crossover-reset-scheduler.sh"; then
    echo "Cron job already exists. Updating..."
    # Remove old cron job
    NEW_CRON=$(echo "$CURRENT_CRON" | grep -v "crossover-reset-scheduler.sh")
    echo "$NEW_CRON" | crontab -
fi

# Add the new cron job
(echo "$CURRENT_CRON" | grep -v "crossover-reset-scheduler.sh" || true; echo "$CRON_COMMAND") | crontab -

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
