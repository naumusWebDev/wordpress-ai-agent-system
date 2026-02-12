#!/usr/bin/env bash
# =============================================================================
# create-menus.sh — Create WordPress navigation menus from JSON
#
# Usage:
#   ./create-menus.sh --wp-path=<path> --file=menus.json
#
# JSON format:
#   [
#     {
#       "name": "Menu Principal",
#       "location": "primary",
#       "items": [
#         { "title": "Inicio",    "type": "page", "slug": "inicio" },
#         { "title": "Blog",      "type": "page", "slug": "blog" },
#         { "title": "Externo",   "type": "custom", "url": "https://example.com" }
#       ]
#     }
#   ]
#
# Item types:
#   - "page"   → links to an existing page by slug
#   - "post"   → links to an existing post by slug
#   - "custom" → custom URL (requires "url" field)
#   - "cpt"    → links to a CPT entry (requires "post_type" and "slug")
#
# Options:
#   --wp-path=<path>    Path to WordPress installation (required)
#   --file=<json>       JSON file with menu definitions (required)
#   --skip-existing     Skip menus that already exist (default)
#   --dry-run           Show what would be created
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

FILE=""
SKIP_EXISTING=true
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --file=*)          FILE="${arg#*=}" ;;
    --skip-existing)   SKIP_EXISTING=true ;;
    --dry-run)         DRY_RUN=true ;;
    --wp-path=*)       ;; # handled by common.sh
    *) ;;
  esac
done

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  log_error "Provide --file=<json> with a valid menus JSON file."
  exit 1
fi

# ---------------------------------------------------------------------------
# Process each menu
# ---------------------------------------------------------------------------
python3 -c "
import json
with open('$FILE') as f:
    data = json.load(f)
for i, menu in enumerate(data):
    name = menu.get('name', '')
    location = menu.get('location', '')
    items = menu.get('items', [])
    print(f'MENU|{name}|{location}|{len(items)}')
    for item in items:
        itype = item.get('type', 'page')
        title = item.get('title', '')
        slug = item.get('slug', '')
        url = item.get('url', '')
        post_type = item.get('post_type', 'page')
        print(f'ITEM|{itype}|{title}|{slug}|{url}|{post_type}')
    print('END_MENU')
" | {
  current_menu_id=""
  current_menu_name=""

  while IFS='|' read -r record_type f1 f2 f3 f4 f5; do
    case "$record_type" in
      MENU)
        current_menu_name="$f1"
        local_location="$f2"
        item_count="$f3"

        log_info "Processing menu: $current_menu_name (location: $local_location, items: $item_count)"

        if $DRY_RUN; then
          log_info "[DRY-RUN] Would create menu: $current_menu_name at $local_location"
          current_menu_id="DRY"
          continue
        fi

        # Check if menu exists
        existing_id=$(menu_exists "$current_menu_name")

        if [[ -n "$existing_id" && "$SKIP_EXISTING" == true ]]; then
          log_warn "Menu '$current_menu_name' already exists (ID: $existing_id). Skipping."
          current_menu_id=""
          continue
        fi

        # Create menu
        current_menu_id=$(wpcli menu create "$current_menu_name" --porcelain 2>/dev/null)
        log_success "Created menu '$current_menu_name' (ID: $current_menu_id)"

        # Assign to location if specified
        if [[ -n "$local_location" ]]; then
          wpcli menu location assign "$current_menu_id" "$local_location" 2>/dev/null && \
            log_success "  Assigned to location: $local_location" || \
            log_warn "  Could not assign to location: $local_location (location may not exist in theme)"
        fi
        ;;

      ITEM)
        if [[ -z "$current_menu_id" ]]; then
          continue # Skip items for skipped menus
        fi

        item_type="$f1"
        item_title="$f2"
        item_slug="$f3"
        item_url="$f4"
        item_post_type="$f5"

        if $DRY_RUN; then
          log_info "[DRY-RUN]   Would add item: $item_title ($item_type: $item_slug)"
          continue
        fi

        case "$item_type" in
          page|post)
            # Find the page/post by slug
            local_post_type="$item_type"
            [[ "$item_type" == "page" ]] && local_post_type="page"
            post_id=$(post_exists_by_slug "$item_slug" "$local_post_type")
            if [[ -n "$post_id" ]]; then
              wpcli menu item add-post "$current_menu_id" "$post_id" --title="$item_title" 2>/dev/null
              log_success "  Added page/post item: $item_title (post ID: $post_id)"
            else
              # Fallback: add as custom link
              site_url=$(wpcli option get siteurl 2>/dev/null)
              wpcli menu item add-custom "$current_menu_id" "$item_title" "${site_url}/${item_slug}/" 2>/dev/null
              log_warn "  Page '$item_slug' not found. Added as custom link."
            fi
            ;;
          custom)
            wpcli menu item add-custom "$current_menu_id" "$item_title" "$item_url" 2>/dev/null
            log_success "  Added custom item: $item_title → $item_url"
            ;;
          cpt)
            post_id=$(post_exists_by_slug "$item_slug" "$item_post_type")
            if [[ -n "$post_id" ]]; then
              wpcli menu item add-post "$current_menu_id" "$post_id" --title="$item_title" 2>/dev/null
              log_success "  Added CPT item: $item_title (post ID: $post_id)"
            else
              log_warn "  CPT entry '$item_slug' (type: $item_post_type) not found. Skipped."
            fi
            ;;
        esac
        ;;

      END_MENU)
        current_menu_id=""
        ;;
    esac
  done
}

log_info "Done."
