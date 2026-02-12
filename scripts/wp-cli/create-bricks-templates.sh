#!/usr/bin/env bash
# =============================================================================
# create-bricks-templates.sh — Create Bricks Builder templates with conditions
#
# Usage:
#   ./create-bricks-templates.sh --wp-path=<path> --file=templates.json
#
# JSON format (array of templates):
#   [
#     {
#       "title": "Header Principal",
#       "type": "header",
#       "conditions": {
#         "type": "entireWebsite"
#       }
#     },
#     {
#       "title": "Footer Principal",
#       "type": "footer",
#       "conditions": {
#         "type": "entireWebsite"
#       }
#     },
#     {
#       "title": "Single - Post Blog",
#       "type": "single",
#       "conditions": {
#         "type": "postType",
#         "value": "post"
#       }
#     },
#     {
#       "title": "Single - Servicio",
#       "type": "single",
#       "conditions": {
#         "type": "postType",
#         "value": "servicios"
#       }
#     },
#     {
#       "title": "Archive - Servicios",
#       "type": "archive",
#       "conditions": {
#         "type": "archivePostType",
#         "value": "servicios"
#       }
#     }
#   ]
#
# Bricks template types: header, footer, single, archive, section, popup
#
# Condition types:
#   - entireWebsite         → applies everywhere
#   - postType              → specific post type (value = post type slug)
#   - archivePostType       → archive of a post type
#   - frontPage             → front page only
#   - page                  → specific page (value = page ID or slug)
#
# Options:
#   --wp-path=<path>    WordPress installation path (required)
#   --file=<json>       JSON template definitions (required)
#   --skip-existing     Skip templates that already exist (default)
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
  log_error "Provide --file=<json> with Bricks template definitions."
  exit 1
fi

# Check Bricks is active (skip in dry-run mode)
if ! $DRY_RUN; then
  if ! wpcli post type exists bricks_template 2>/dev/null; then
    # Try checking if Bricks is active
    if ! wpcli theme list --status=active --format=json 2>/dev/null | grep -q "bricks"; then
      log_warn "Bricks theme may not be active. Attempting anyway..."
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Generate PHP helper for creating Bricks templates with proper meta
# ---------------------------------------------------------------------------
TEMP_PHP=$(mktemp /tmp/bricks-templates-XXXX.php)

cat > "$TEMP_PHP" <<'EOPHP'
<?php
/**
 * Creates Bricks Builder templates with proper conditions.
 * Run via: wp eval-file <this-file> -- <json-path>
 */

$json_path = $args[0] ?? '';
if ( empty( $json_path ) || ! file_exists( $json_path ) ) {
    WP_CLI::error( "JSON file not found: $json_path" );
}

$templates = json_decode( file_get_contents( $json_path ), true );
if ( ! is_array( $templates ) ) {
    WP_CLI::error( 'Failed to parse JSON or invalid format (expected array).' );
}

foreach ( $templates as $tpl ) {
    $title = $tpl['title'] ?? 'Untitled Template';
    $type  = $tpl['type'] ?? 'section';
    $cond  = $tpl['conditions'] ?? array();
    $skip  = $tpl['skip_existing'] ?? true;

    // Check if template already exists
    $existing = get_posts( array(
        'post_type'   => 'bricks_template',
        'title'       => $title,
        'post_status' => array( 'publish', 'draft' ),
        'numberposts' => 1,
    ) );

    if ( ! empty( $existing ) && $skip ) {
        WP_CLI::warning( "Template '$title' already exists (ID: {$existing[0]->ID}). Skipping." );
        continue;
    }

    // Create the template post
    $post_id = wp_insert_post( array(
        'post_type'   => 'bricks_template',
        'post_title'  => $title,
        'post_status' => 'publish',
        'post_content' => '',
    ) );

    if ( is_wp_error( $post_id ) ) {
        WP_CLI::error( "Failed to create template '$title': " . $post_id->get_error_message() );
        continue;
    }

    // Set template type
    update_post_meta( $post_id, '_bricks_template_type', $type );

    // Build and set conditions
    $conditions_meta = array();
    $cond_type = $cond['type'] ?? '';
    $cond_value = $cond['value'] ?? '';

    switch ( $cond_type ) {
        case 'entireWebsite':
            $conditions_meta[] = array(
                'main' => 'entireWebsite',
            );
            break;

        case 'postType':
            $conditions_meta[] = array(
                'main'    => 'postType',
                'sub'     => $cond_value,
            );
            break;

        case 'archivePostType':
            $conditions_meta[] = array(
                'main'    => 'archivePostType',
                'sub'     => $cond_value,
            );
            break;

        case 'frontPage':
            $conditions_meta[] = array(
                'main' => 'frontPage',
            );
            break;

        case 'page':
            $page_id = $cond_value;
            // If slug, resolve to ID
            if ( ! is_numeric( $page_id ) ) {
                $page_obj = get_page_by_path( $page_id );
                $page_id = $page_obj ? $page_obj->ID : 0;
            }
            $conditions_meta[] = array(
                'main'    => 'postType',
                'sub'     => 'page',
                'subSub'  => intval( $page_id ),
            );
            break;

        default:
            WP_CLI::warning( "Unknown condition type '$cond_type' for template '$title'." );
    }

    if ( ! empty( $conditions_meta ) ) {
        update_post_meta( $post_id, '_bricks_template_conditions', $conditions_meta );
    }

    // Set empty Bricks content (ready for visual editing)
    update_post_meta( $post_id, '_bricks_page_content_2', array() );

    WP_CLI::success( "Created template '$title' (ID: $post_id, type: $type, condition: $cond_type" . ( $cond_value ? " → $cond_value" : '' ) . ')' );
}

WP_CLI::success( 'All templates processed.' );
EOPHP

if $DRY_RUN; then
  log_info "[DRY-RUN] Templates to create:"
  python3 -c "
import json
with open('$FILE') as f:
    templates = json.load(f)
for t in templates:
    cond = t.get('conditions', {})
    ctype = cond.get('type', '')
    cval = cond.get('value', '')
    condstr = f'{ctype}' + (f' → {cval}' if cval else '')
    print(f'  [{t.get(\"type\",\"\")}] {t.get(\"title\",\"\")} (condition: {condstr})')
"
  rm -f "$TEMP_PHP"
  exit 0
fi

log_info "Creating Bricks templates from: $FILE"

ABS_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")

wpcli eval-file "$TEMP_PHP" "$ABS_FILE" 2>&1

rm -f "$TEMP_PHP"

log_info "Done."
