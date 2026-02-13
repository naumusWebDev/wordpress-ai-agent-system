#!/usr/bin/env bash
# =============================================================================
# update-page-bricks-content.sh — Inject Bricks layout JSON into a page
#
# Usage:
#   ./update-page-bricks-content.sh --wp-path=<path> --slug=<page-slug> --file=<layout.json>
#
# Takes a nested layout JSON (same format as hero-section.json / bricks-catalog
# tree) and converts it to the flat array Bricks stores in _bricks_page_content_2.
#
# Options:
#   --wp-path=<path>    WordPress installation path (required)
#   --slug=<slug>       Page slug to update (required)
#   --file=<json>       Nested layout JSON file (required)
#   --dry-run           Show what would be written without modifying the DB
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

SLUG=""
FILE=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --slug=*)   SLUG="${arg#*=}" ;;
    --file=*)   FILE="${arg#*=}" ;;
    --dry-run)  DRY_RUN=true ;;
    --wp-path=*) ;; # handled by common.sh
    *) ;;
  esac
done

if [[ -z "$SLUG" ]]; then
  log_error "Provide --slug=<page-slug>."
  exit 1
fi

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  log_error "Provide --file=<json> with a valid layout JSON."
  exit 1
fi

# ---------------------------------------------------------------------------
# Resolve page by slug
# ---------------------------------------------------------------------------
PAGE_ID=$(post_exists_by_slug "$SLUG" "page")

if [[ -z "$PAGE_ID" ]]; then
  log_error "Page with slug '$SLUG' not found."
  exit 1
fi

log_info "Found page '$SLUG' (ID: $PAGE_ID)"

ABS_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")

# ---------------------------------------------------------------------------
# PHP helper: convert nested layout JSON → Bricks flat format and save meta
# ---------------------------------------------------------------------------
TEMP_PHP=$(mktemp /tmp/bricks-page-content-XXXX.php)
trap 'rm -f "$TEMP_PHP"' EXIT

cat > "$TEMP_PHP" <<'EOPHP'
<?php
/**
 * Converts a nested layout JSON tree into the flat array Bricks uses
 * for _bricks_page_content_2 and updates the given post.
 *
 * Run via: wp eval-file <this-file> -- <json-path> <post-id> [--dry-run]
 */

$json_path = $args[0] ?? '';
$post_id   = intval( $args[1] ?? 0 );
$dry_run   = in_array( 'dry-run', $args, true );

if ( empty( $json_path ) || ! file_exists( $json_path ) ) {
    WP_CLI::error( "JSON file not found: $json_path" );
}

if ( ! $post_id || ! get_post( $post_id ) ) {
    WP_CLI::error( "Invalid post ID: $post_id" );
}

$tree = json_decode( file_get_contents( $json_path ), true );
if ( ! is_array( $tree ) || empty( $tree['element'] ) ) {
    WP_CLI::error( 'Invalid layout JSON: expected object with "element" key.' );
}

/**
 * Generate a random 6-char alphanumeric ID (matches Bricks convention).
 */
function bricks_random_id() {
    $chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    $id = '';
    for ( $i = 0; $i < 6; $i++ ) {
        $id .= $chars[ wp_rand( 0, 35 ) ];
    }
    return $id;
}

/**
 * Map catalog setting names to Bricks internal meta keys.
 */
function map_settings( $settings ) {
    $mapped = array();

    foreach ( $settings as $key => $value ) {
        switch ( $key ) {
            case 'class':
                $mapped['_cssClasses'] = $value;
                break;
            case 'level':
                $mapped['tag'] = $value;
                break;
            default:
                $mapped[ $key ] = $value;
                break;
        }
    }

    return $mapped;
}

/**
 * Recursively flatten the nested tree into a Bricks-compatible flat array.
 */
function flatten_node( $node, $parent_id, &$flat ) {
    $id = bricks_random_id();

    $element = array(
        'id'       => $id,
        'name'     => $node['element'],
        'parent'   => $parent_id,
        'settings' => map_settings( $node['settings'] ?? array() ),
    );

    $child_ids = array();
    if ( ! empty( $node['children'] ) && is_array( $node['children'] ) ) {
        foreach ( $node['children'] as $child ) {
            $child_id    = flatten_node( $child, $id, $flat );
            $child_ids[] = $child_id;
        }
    }

    if ( ! empty( $child_ids ) ) {
        $element['children'] = $child_ids;
    }

    $flat[] = $element;

    return $id;
}

$flat = array();
flatten_node( $tree, 0, $flat );

if ( $dry_run ) {
    WP_CLI::line( '[DRY-RUN] Would set _bricks_page_content_2 on post ' . $post_id . ':' );
    WP_CLI::line( json_encode( $flat, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE ) );
    return;
}

update_post_meta( $post_id, '_bricks_page_content_2', $flat );

WP_CLI::success( "Updated _bricks_page_content_2 on post $post_id with " . count( $flat ) . ' element(s).' );
EOPHP

if $DRY_RUN; then
  log_info "[DRY-RUN] Preview of Bricks content for page '$SLUG' (ID: $PAGE_ID):"
  wpcli eval-file "$TEMP_PHP" -- "$ABS_FILE" "$PAGE_ID" "dry-run" 2>&1
else
  log_info "Injecting Bricks content into page '$SLUG' (ID: $PAGE_ID)..."
  wpcli eval-file "$TEMP_PHP" -- "$ABS_FILE" "$PAGE_ID" 2>&1
fi

log_info "Done."
