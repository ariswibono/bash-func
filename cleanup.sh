#!/usr/bin/env bash

# --- BATTLE-HARDENED HEADER ---
# -e: exit on error | -u: exit on unset variables | -o pipefail: catch pipe errors
set -euo pipefail

# --- CONFIGURATION ---
TARGET_DIR="${TARGET_DIR:-$HOME/Workspaces}"
APPLY=false
LOG_FILE="/tmp/workspace_cleanup_$(date +%Y%m%d).log"

# Professional Color Palette
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- LOGGING & SAFETY ---
log_info()  { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_ok()    { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
log_warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; }

# Trap signals (like Ctrl+C) to exit cleanly
cleanup_exit() {
    local exit_code=$?
    [[ $exit_code -ne 0 ]] && log_error "Script interrupted or failed."
    exit "$exit_code"
}
trap cleanup_exit EXIT SIGINT SIGTERM

# --- TARGET DEFINITIONS ---
PRUNE_DIRS=(
    ".terraform" "node_modules" ".yarn" ".pnpm-store" ".venv" "venv" 
    "__pycache__" ".pytest_cache" "dist" "build" "target" ".next" ".turbo"
)
PRUNE_FILES=(".DS_Store" "*.pyc" "*.pyo")

# --- CORE LOGIC ---
delete_safely() {
    local path="$1"
    if $APPLY; then
        # Handle read-only files (common in Go modules)
        if ! rm -rf -- "$path" 2>/dev/null; then
            chmod -R +w "$path" 2>/dev/null || true
            rm -rf -- "$path" || log_warn "Skipped: $path (Permission Denied)"
        fi
    else
        printf "  ${YELLOW}DRY-RUN:${NC} %s\n" "$path"
    fi
}

get_size_gb() {
    local kb
    kb=$(du -sk "$1" 2>/dev/null | awk '{print $1}')
    echo "scale=2; ${kb:-0} / 1048576" | bc
}

# --- MAIN EXECUTION ---
clear
printf "${BLUE}=============================================${NC}\n"
printf "   🚀 BATTLE-HARDENED WORKSPACE CLEANER      \n"
printf "${BLUE}=============================================${NC}\n"

# Verify Target Directory safely
if [[ ! -d "$TARGET_DIR" ]]; then
    log_error "Directory $TARGET_DIR does not exist."
    exit 1
fi

log_info "Target: $TARGET_DIR"
[[ "$APPLY" == "true" ]] && log_warn "MODE: DELETION ACTIVE" || log_info "MODE: PREVIEW ONLY"

# Build Single-Pass Find Command for Maximum Speed
FIND_ARGS=( "$TARGET_DIR" )
FIND_ARGS+=( "(" )
for d in "${PRUNE_DIRS[@]}"; do FIND_ARGS+=( -name "$d" -o ); done
unset 'FIND_ARGS[${#FIND_ARGS[@]}-1]' # Remove last -o
FIND_ARGS+=( ")" -prune -print0 -o "(" )
for f in "${PRUNE_FILES[@]}"; do FIND_ARGS+=( -name "$f" -o ); done
unset 'FIND_ARGS[${#FIND_ARGS[@]}-1]'
FIND_ARGS+=( ")" -print0 )

TOTAL_SIZE=0
log_info "Scanning file system..."

# Process results
while IFS= read -r -d '' match; do
    match_size=$(du -sk "$match" 2>/dev/null | awk '{print $1}' || echo 0)
    TOTAL_SIZE=$((TOTAL_SIZE + match_size))
    delete_safely "$match"
done < <(find "${FIND_ARGS[@]}" 2>/dev/null)

# Final Report
FINAL_GB=$(echo "scale=2; $TOTAL_SIZE / 1048576" | bc)
printf "${BLUE}---------------------------------------------${NC}\n"
log_ok "Cleanup Finished."
log_info "Total Space Processed: ${GREEN}${FINAL_GB} GB${NC}"
[[ "$APPLY" == "false" ]] && log_warn "Run with --apply to actually free up space."