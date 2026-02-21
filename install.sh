#!/bin/bash

# Detect the current shell
CURRENT_SHELL=$(basename "$SHELL")
RC_FILE=""

case "$CURRENT_SHELL" in
"zsh")
    RC_FILE="$HOME/.zshrc"
    ;;
"bash")
    RC_FILE="$HOME/.bashrc"
    ;;
*)
    echo "Detected shell: $CURRENT_SHELL"
    read -r -p "Enter the path to your shell RC file: " RC_FILE
    ;;
esac

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add source commands to RC file if they aren't already present
if ! grep -q '# Mataberat Bash functions, aliases, and helpers script' "$RC_FILE"; then
    {
        echo ""
        echo "# Mataberat Bash functions, aliases, and helpers script"
        echo "[ -f $SCRIPT_DIR/func.sh ] && source $SCRIPT_DIR/func.sh"
        echo "[ -f $SCRIPT_DIR/config.sh ] && source $SCRIPT_DIR/config.sh"
    } >>"$RC_FILE"
    echo "Installation complete! Helper functions added to $RC_FILE"
    echo "Please restart your shell or run: source $RC_FILE"
else
    echo "RC file $RC_FILE already contains Mataberat helper sourcing; skipping."
fi

# Install aerospace.toml only on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    cp -R config/.aerospace.toml ~/.aerospace.toml
    aerospace reload-config
else
    echo "Skipping aerospace configuration: not running on macOS (detected $(uname))."
fi