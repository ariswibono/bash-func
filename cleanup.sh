#!/usr/bin/env bash

# --- PRODUCTION HEADER ---
set -euo pipefail

# --- CONFIG ---
TARGET_DIR="${TARGET_DIR:-$HOME/Workspaces}"
APPLY=false
LOG_FILE="/tmp/workspace_cleanup_$(date +%Y%m%d).log"

# UI Colors
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

msg() { printf "${BLUE}==>${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}wait:${NC} %s\n" "$1"; }
err() { printf "${RED}err:${NC} %s\n" "$1" >&2; }

# Initialize Log
echo "--- Cleanup Log $(date) ---" > "$LOG_FILE"

# --- SIGNALS & PRIVILEGES ---
cleanup_exit() {
    local exit_code=$?
    [[ -n "${SUDO_PID:-}" ]] && kill "$SUDO_PID" 2>/dev/null || true
    if [[ $exit_code -ne 0 ]]; then
        err "Process interrupted. Audit log: $LOG_FILE"
    fi
    exit "$exit_code"
}
trap cleanup_exit EXIT SIGINT SIGTERM

# Check for the --apply flag
for arg in "$@"; do [[ "$arg" == "--apply" ]] && APPLY=true; done

if $APPLY; then
    warn "DELETION MODE ACTIVE. Authenticating sudo..."
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_PID=$!
else
    msg "DRY-RUN MODE. No files will be deleted."
fi

# --- SCANNING DEFINITIONS ---
PRUNE_DIRS=(".terraform" "node_modules" ".yarn" ".pnpm-store" ".venv" "venv" "__pycache__" ".pytest_cache" "dist" "build" "target" ".next" ".turbo")
PRUNE_FILES=(".DS_Store" "*.pyc" "*.pyo" ".coverage")

msg "Scanning $TARGET_DIR..."

FIND_ARGS=( "$TARGET_DIR" "(" )
for d in "${PRUNE_DIRS[@]}"; do FIND_ARGS+=( -name "$d" -o ); done
unset 'FIND_ARGS[${#FIND_ARGS[@]}-1]' 
FIND_ARGS+=( ")" -prune -print0 -o "(" )
for f in "${PRUNE_FILES[@]}"; do FIND_ARGS+=( -name "$f" -o ); done
unset 'FIND_ARGS[${#FIND_ARGS[@]}-1]'
FIND_ARGS+=( ")" -print0 )

TOTAL_KB=0
COUNT=0

# --- EXECUTION ---
while IFS= read -r -d '' match; do
    ((COUNT++))
    
    # Live visual feedback in terminal
    if (( COUNT % 5 == 0 )); then
        printf "\r${BLUE}[Scanning]${NC} Found %d targets..." "$COUNT"
    fi

    size=$(du -sk "$match" 2>/dev/null | awk '{print $1}' || echo 0)
    TOTAL_KB=$((TOTAL_KB + size))
    
    # Log everything to the temp file for record-keeping
    echo "[$((COUNT))] Found ($size KB): $match" >> "$LOG_FILE"
    
    if $APPLY; then
        # Handle Go mod cache and permissions
        if [[ "$match" == *"/go/pkg/mod/"* ]] && command -v go >/dev/null 2>&1; then
            go clean -modcache >/dev/null 2>&1 || true
        fi
        
        if rm -rf -- "$match" 2>/dev/null || sudo rm -rf -- "$match"; then
            echo "   -> DELETED" >> "$LOG_FILE"
        else
            echo "   -> FAILED" >> "$LOG_FILE"
        fi
    else
        # In dry-run, we also print found items to the console for visibility
        printf "\n  ${YELLOW}dry-run:${NC} %s" "$match"
    fi
done < <(find "${FIND_ARGS[@]}" 2>/dev/null)

# --- SUMMARY ---
FINAL_GB=$(echo "scale=2; $TOTAL_KB / 1048576" | bc)
printf "\r" # Clear the scanning line
msg "Finished. Scanned $COUNT items."
msg "Total Size: ${GREEN}${FINAL_GB} GB${NC}"
msg "Log created: $LOG_FILE"

if ! $APPLY; then
    warn "No files were deleted. Use --apply to execute."
else
    msg "System cleanup complete."
fi
