#!/usr/bin/env bash
# =============================================================================
# run-setup.sh — Full project setup orchestrator
#
# Runs all setup scripts in the correct order for a project.
# Expects a data directory with JSON definition files.
#
# Usage:
#   ./run-setup.sh --wp-path=<path> --data-dir=data/fisiosens
#   ./run-setup.sh --wp-path=<path> --data-dir=data/fisiosens --dry-run
#   ./run-setup.sh --wp-path=<path> --data-dir=data/fisiosens --step=3
#
# Expected files in data directory:
#   settings.json           → WordPress configuration
#   pages.json              → Pages to create
#   cpt-*.json              → CPT definitions (one per file)
#   acf-*.json              → ACF field groups (one per file)
#   bricks-templates.json   → Bricks templates
#   menus.json              → Navigation menus
#   servicios.json          → CPT posts (or any *-posts.json / servicios.json)
#   blog-posts.json         → Blog entries
#
# Options:
#   --wp-path=<path>      WordPress installation path (required)
#   --data-dir=<dir>      Data directory with JSON files (required)
#   --step=<n>            Start from step N (skip previous steps)
#   --dry-run             Preview everything without executing
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DATA_DIR=""
START_STEP=1
DRY_RUN=""
WP_PATH_ARG=""

for arg in "$@"; do
  case "$arg" in
    --data-dir=*)   DATA_DIR="${arg#*=}" ;;
    --step=*)       START_STEP="${arg#*=}" ;;
    --dry-run)      DRY_RUN="--dry-run" ;;
    --wp-path=*)    WP_PATH_ARG="$arg" ;;
    *) ;;
  esac
done

if [[ -z "$WP_PATH_ARG" ]]; then
  echo "[ERROR] --wp-path is required." >&2
  exit 1
fi

# Resolve data dir relative to script dir if not absolute
if [[ "${DATA_DIR:0:1}" != "/" ]]; then
  DATA_DIR="$SCRIPT_DIR/$DATA_DIR"
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "[ERROR] Data directory not found: $DATA_DIR" >&2
  exit 1
fi

echo "╔══════════════════════════════════════════════════╗"
echo "║     WordPress Project Setup Orchestrator        ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  Data: $(basename "$DATA_DIR")"
echo "║  Mode: ${DRY_RUN:-LIVE}"
echo "╚══════════════════════════════════════════════════╝"
echo ""

STEP=0
run_step() {
  STEP=$((STEP + 1))
  local description="$1"
  shift

  if [[ $STEP -lt $START_STEP ]]; then
    echo "[STEP $STEP] SKIPPED: $description"
    return 0
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[STEP $STEP] $description"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  "$@"

  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Step $STEP failed: $description" >&2
    echo "  Resume from this step with: --step=$STEP"
    exit 1
  fi
}

# ── STEP 1: Configure WordPress settings ──
if [[ -f "$DATA_DIR/settings.json" ]]; then
  run_step "Configure WordPress settings" \
    bash "$SCRIPT_DIR/configure-wp.sh" "$WP_PATH_ARG" --file="$DATA_DIR/settings.json" $DRY_RUN
fi

# ── STEP 2: Create pages ──
if [[ -f "$DATA_DIR/pages.json" ]]; then
  run_step "Create pages" \
    bash "$SCRIPT_DIR/create-pages.sh" "$WP_PATH_ARG" --file="$DATA_DIR/pages.json" $DRY_RUN
fi

# ── STEP 3: Register CPTs ──
for cpt_file in "$DATA_DIR"/cpt-*.json; do
  [[ -f "$cpt_file" ]] || continue
  cpt_name=$(basename "$cpt_file" .json | sed 's/^cpt-//')
  run_step "Register CPT: $cpt_name" \
    bash "$SCRIPT_DIR/register-cpt.sh" "$WP_PATH_ARG" --file="$cpt_file" $DRY_RUN
done

# ── STEP 4: Create ACF field groups ──
for acf_file in "$DATA_DIR"/acf-*.json; do
  [[ -f "$acf_file" ]] || continue
  acf_name=$(basename "$acf_file" .json | sed 's/^acf-//')
  run_step "Create ACF fields: $acf_name" \
    bash "$SCRIPT_DIR/create-acf-fields.sh" "$WP_PATH_ARG" --file="$acf_file" $DRY_RUN
done

# ── STEP 5: Create Bricks templates ──
if [[ -f "$DATA_DIR/bricks-templates.json" ]]; then
  run_step "Create Bricks templates" \
    bash "$SCRIPT_DIR/create-bricks-templates.sh" "$WP_PATH_ARG" --file="$DATA_DIR/bricks-templates.json" $DRY_RUN
fi

# ── STEP 6: Create menus ──
if [[ -f "$DATA_DIR/menus.json" ]]; then
  run_step "Create navigation menus" \
    bash "$SCRIPT_DIR/create-menus.sh" "$WP_PATH_ARG" --file="$DATA_DIR/menus.json" $DRY_RUN
fi

# ── STEP 7: Create CPT content ──
for content_file in "$DATA_DIR"/*.json; do
  [[ -f "$content_file" ]] || continue
  fname=$(basename "$content_file")

  # Skip non-content files
  case "$fname" in
    settings.json|pages.json|menus.json|bricks-templates.json|cpt-*|acf-*)
      continue ;;
  esac

  # Determine post type from filename
  post_type=$(echo "$fname" | sed 's/\.json$//' | sed 's/-posts$//')

  run_step "Create content: $fname" \
    bash "$SCRIPT_DIR/create-posts.sh" "$WP_PATH_ARG" --file="$content_file" --post-type="$post_type" $DRY_RUN
done

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Setup complete!                               ║"
echo "╚══════════════════════════════════════════════════╝"
