#!/usr/bin/env bash
# =============================================================================
# common.sh — Shared utilities for all WP-CLI scripts
#
# Source this file at the top of every script:
#   source "$(dirname "$0")/lib/common.sh"
#
# Expects WP_PATH env var or --wp-path=<path> argument.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve WP_PATH
# ---------------------------------------------------------------------------
# Priority: --wp-path argument > WP_PATH env var > error
for arg in "$@"; do
  case "$arg" in
    --wp-path=*) WP_PATH="${arg#*=}" ;;
  esac
done

if [[ -z "${WP_PATH:-}" ]]; then
  echo "ERROR: WP_PATH not set. Use --wp-path=<path> or export WP_PATH." >&2
  exit 1
fi

if [[ ! -f "$WP_PATH/wp-config.php" ]]; then
  echo "ERROR: No wp-config.php found at $WP_PATH" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# WP-CLI wrapper (adds --path automatically)
# ---------------------------------------------------------------------------
wpcli() {
  wp --path="$WP_PATH" "$@"
}

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
log_info()    { echo "[INFO]  $*"; }
log_success() { echo "[OK]    $*"; }
log_warn()    { echo "[WARN]  $*"; }
log_error()   { echo "[ERROR] $*" >&2; }

# ---------------------------------------------------------------------------
# Utility: check if a post exists by slug and post_type
# Returns the post ID if found, empty string otherwise
# ---------------------------------------------------------------------------
post_exists_by_slug() {
  local slug="$1"
  local post_type="${2:-page}"
  local result
  result=$(wpcli post list --post_type="$post_type" --name="$slug" --field=ID --format=ids 2>/dev/null || true)
  echo "$result"
}

# ---------------------------------------------------------------------------
# Utility: check if a menu exists by name
# Returns menu term_id if found
# ---------------------------------------------------------------------------
menu_exists() {
  local menu_name="$1"
  wpcli menu list --format=json 2>/dev/null | python3 -c "
import sys, json
menus = json.load(sys.stdin)
for m in menus:
    if m.get('name','').lower() == '${menu_name}'.lower():
        print(m['term_id'])
        break
" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Strip --wp-path from forwarded args
# ---------------------------------------------------------------------------
strip_wp_path_args() {
  local filtered=()
  for arg in "$@"; do
    case "$arg" in
      --wp-path=*) ;; # skip
      *) filtered+=("$arg") ;;
    esac
  done
  echo "${filtered[@]:-}"
}

log_info "WP_PATH=$WP_PATH"
