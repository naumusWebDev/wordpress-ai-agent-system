#!/usr/bin/env bash
# =============================================================================
# create-pages.sh — Create WordPress pages from a JSON definition
#
# Usage:
#   ./create-pages.sh --wp-path=<path> --file=pages.json
#   ./create-pages.sh --wp-path=<path> --title="Mi Página" --slug=mi-pagina
#
# JSON format (array of pages):
#   [
#     { "title": "Inicio", "slug": "inicio", "status": "publish", "content": "" },
#     { "title": "Blog",   "slug": "blog",   "status": "publish" }
#   ]
#
# Options:
#   --wp-path=<path>    Path to WordPress installation (required)
#   --file=<json>       JSON file with page definitions
#   --title=<title>     Page title (single page mode)
#   --slug=<slug>       Page slug (single page mode)
#   --status=<status>   Page status: publish, draft (default: publish)
#   --content=<html>    Page content HTML (single page mode)
#   --skip-existing     Skip pages that already exist (default behavior)
#   --dry-run           Show what would be created without creating
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Parse arguments
FILE=""
TITLE=""
SLUG=""
STATUS="publish"
CONTENT=""
SKIP_EXISTING=true
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --file=*)          FILE="${arg#*=}" ;;
    --title=*)         TITLE="${arg#*=}" ;;
    --slug=*)          SLUG="${arg#*=}" ;;
    --status=*)        STATUS="${arg#*=}" ;;
    --content=*)       CONTENT="${arg#*=}" ;;
    --skip-existing)   SKIP_EXISTING=true ;;
    --no-skip-existing) SKIP_EXISTING=false ;;
    --dry-run)         DRY_RUN=true ;;
    --wp-path=*)       ;; # handled by common.sh
    *) ;;
  esac
done

# ---------------------------------------------------------------------------
create_single_page() {
  local title="$1"
  local slug="$2"
  local status="${3:-publish}"
  local content="${4:-}"

  if $DRY_RUN; then
    log_info "[DRY-RUN] Would create page: '$title' (slug: $slug, status: $status)"
    return 0
  fi

  # Check if page already exists
  local existing_id
  existing_id=$(post_exists_by_slug "$slug" "page")

  if [[ -n "$existing_id" ]]; then
    if $SKIP_EXISTING; then
      log_warn "Page '$title' (slug: $slug) already exists (ID: $existing_id). Skipping."
      return 0
    fi
  fi

  local cmd=(wpcli post create
    --post_type=page
    --post_title="$title"
    --post_name="$slug"
    --post_status="$status"
    --porcelain
  )

  if [[ -n "$content" ]]; then
    local page_id
    page_id=$(echo "$content" | "${cmd[@]}" -)
    log_success "Created page '$title' (ID: $page_id, slug: $slug)"
  else
    local page_id
    page_id=$("${cmd[@]}" --post_content="")
    log_success "Created page '$title' (ID: $page_id, slug: $slug)"
  fi
}

# ---------------------------------------------------------------------------
if [[ -n "$FILE" ]]; then
  if [[ ! -f "$FILE" ]]; then
    log_error "File not found: $FILE"
    exit 1
  fi

  log_info "Creating pages from $FILE..."

  # Read JSON and create each page
  python3 -c "
import json, sys
with open('$FILE') as f:
    pages = json.load(f)
for p in pages:
    title = p.get('title', '')
    slug = p.get('slug', '')
    status = p.get('status', 'publish')
    content_file = p.get('content_file', '')
    print(f'{title}\t{slug}\t{status}\t{content_file}')
" | while IFS=$'\t' read -r title slug status content_file; do
    content=""
    if [[ -n "$content_file" && -f "$content_file" ]]; then
      content=$(cat "$content_file")
    fi
    create_single_page "$title" "$slug" "$status" "$content"
  done

elif [[ -n "$TITLE" ]]; then
  if [[ -z "$SLUG" ]]; then
    # Auto-generate slug from title
    SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
  fi
  create_single_page "$TITLE" "$SLUG" "$STATUS" "$CONTENT"
else
  log_error "Provide --file=<json> or --title=<title>"
  exit 1
fi

log_info "Done."
