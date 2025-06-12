#!/bin/bash

# Cleanup function for partial installations
cleanup_on_error() {
    echo "🧹 Cleaning up partial installation..."
    rm -f "$USER_HOME/bin/clean-exfat.sh" "$USER_HOME/bin/eject-clean.sh"
    rm -f "$USER_HOME/Library/LaunchAgents/com.rkn.cleanexfat.plist"
    launchctl unload "$USER_HOME/Library/LaunchAgents/com.rkn.cleanexfat.plist" 2>/dev/null || true
}

# Set up error handling
set -e
trap cleanup_on_error ERR

# Retrieve current user name and home directory
USERNAME=$(whoami)
USER_HOME=$(eval echo ~"$USERNAME")

# Verify home directory exists
if [ ! -d "$USER_HOME" ]; then
    echo "❌ Error: Could not determine user home directory" >&2
    exit 1
fi

# Check for required dependencies
if ! command -v launchctl >/dev/null 2>&1; then
    echo "❌ Error: launchctl not found. This script requires macOS." >&2
    exit 1
fi

# Create directories if necessary
mkdir -p "$USER_HOME/bin" || {
    echo "❌ Error: Failed to create $USER_HOME/bin" >&2
    exit 1
}

mkdir -p "$USER_HOME/Library/LaunchAgents" || {
    echo "❌ Error: Failed to create $USER_HOME/Library/LaunchAgents" >&2
    exit 1
}

# Verify script files exist before copying
if [ ! -f "bin/clean-exfat.sh" ] || [ ! -f "bin/eject-clean.sh" ]; then
    echo "❌ Error: Script files not found in bin/" >&2
    exit 1
fi

# Copy scripts with error checking
if ! cp -f bin/clean-exfat.sh "$USER_HOME/bin/clean-exfat.sh" || \
   ! cp -f bin/eject-clean.sh "$USER_HOME/bin/eject-clean.sh"; then
    echo "❌ Error: Failed to copy script files" >&2
    exit 1
fi

chmod +x "$USER_HOME/bin/clean-exfat.sh" "$USER_HOME/bin/eject-clean.sh" || {
    echo "❌ Error: Failed to make scripts executable" >&2
    exit 1
}

# Verify plist template exists
if [ ! -f "Library/LaunchAgents/com.rkn.cleanexfat.plist" ]; then
    echo "❌ Error: plist template not found" >&2
    exit 1
fi

# Copying and customizing LaunchAgent
if ! sed "s|/Users/YOUR_USERNAME|$USER_HOME|g" Library/LaunchAgents/com.rkn.cleanexfat.plist > "$USER_HOME/Library/LaunchAgents/com.rkn.cleanexfat.plist"; then
    echo "❌ Error: Failed to customize plist file" >&2
    exit 1
fi

# Loading LaunchAgent (unload first if it exists)
launchctl unload "$USER_HOME/Library/LaunchAgents/com.rkn.cleanexfat.plist" 2>/dev/null || true
if ! launchctl load "$USER_HOME/Library/LaunchAgents/com.rkn.cleanexfat.plist"; then
    echo "❌ Error: Failed to load LaunchAgent" >&2
    exit 1
fi

# Function to add alias to shell configuration files
add_alias() {
    local config_file=$1
    if [ -f "$config_file" ]; then
        if ! grep -q "alias eject='$USER_HOME/bin/eject-clean.sh'" "$config_file"; then
            echo "alias eject='$USER_HOME/bin/eject-clean.sh'" >> "$config_file"
            echo "✓ Added eject alias to $config_file"
        else
            echo "✓ Eject alias already exists in $config_file"
        fi
    fi
}

# Detect current shell and add alias appropriately
CURRENT_SHELL=$(basename "$SHELL")
echo "🔍 Detected shell: $CURRENT_SHELL"

case "$CURRENT_SHELL" in
    zsh)
        add_alias "$USER_HOME/.zshrc"
        # Also check .zprofile for login shells
        add_alias "$USER_HOME/.zprofile"
        ;;
    bash)
        add_alias "$USER_HOME/.bashrc"
        add_alias "$USER_HOME/.bash_profile"
        ;;
    fish)
        # For fish shell, we need a different approach
        FISH_CONFIG_DIR="$USER_HOME/.config/fish"
        if [ -d "$FISH_CONFIG_DIR" ]; then
            mkdir -p "$FISH_CONFIG_DIR/functions"
            echo "function eject --description 'Clean and eject volume'
    $USER_HOME/bin/eject-clean.sh \$argv
end" > "$FISH_CONFIG_DIR/functions/eject.fish"
            echo "✓ Added eject function to fish shell"
        fi
        ;;
    *)
        echo "⚠️  Unknown shell: $CURRENT_SHELL"
        echo "   Please manually add this alias to your shell configuration:"
        echo "   alias eject='$USER_HOME/bin/eject-clean.sh'"
        # Still try common config files as fallback
        add_alias "$USER_HOME/.bashrc"
        add_alias "$USER_HOME/.zshrc"
        ;;
esac

# Disable error trap for successful completion
trap - ERR

echo "✅ Installation complete.
- The scripts are installed in ~/bin/
- Automatic cleaning LaunchAgent is active
- Added 'eject' command for your shell ($CURRENT_SHELL)
- Usage: eject VolumeName
- Restart your terminal or run 'source ~/.${CURRENT_SHELL}rc' to use the new alias"

# Provide shell-specific instructions
case "$CURRENT_SHELL" in
    zsh)
        echo "💡 To use immediately: source ~/.zshrc"
        ;;
    bash)
        echo "💡 To use immediately: source ~/.bashrc"
        ;;
    fish)
        echo "💡 Fish function is ready to use immediately"
        ;;
esac