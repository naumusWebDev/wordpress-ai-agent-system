#!/usr/bin/env bash
# =============================================================================
# create-posts.sh — Create posts (any post type) with meta fields from JSON
#
# Usage:
#   ./create-posts.sh --wp-path=<path> --file=posts.json
#   ./create-posts.sh --wp-path=<path> --post-type=servicios --file=servicios.json
#
# JSON format (array of posts):
#   [
#     {
#       "title": "Rehabilitación deportiva",
#       "slug": "rehabilitacion-deportiva",
#       "content": "<p>Contenido HTML...</p>",
#       "content_file": "content/rehab.html",
#       "excerpt": "Breve descripción...",
#       "status": "publish",
#       "post_type": "servicios",
#       "categories": ["Tratamientos"],
#       "tags": ["fisioterapia", "deporte"],
#       "meta": {
#         "duracion_sesion": "60 minutos",
#         "precio": "55€",
#         "beneficios": "Beneficio 1\nBeneficio 2"
#       },
#       "acf": {
#         "duracion_sesion": "60 minutos",
#         "precio": "55€"
#       }
#     }
#   ]
#
# Options:
#   --wp-path=<path>       WordPress installation path (required)
#   --file=<json>          JSON post definitions (required)
#   --post-type=<type>     Default post type if not in JSON (default: post)
#   --status=<status>      Default status if not in JSON (default: publish)
#   --skip-existing        Skip posts that already exist by slug (default)
#   --dry-run              Show what would be created
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

FILE=""
DEFAULT_POST_TYPE="post"
DEFAULT_STATUS="publish"
SKIP_EXISTING=true
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --file=*)          FILE="${arg#*=}" ;;
    --post-type=*)     DEFAULT_POST_TYPE="${arg#*=}" ;;
    --status=*)        DEFAULT_STATUS="${arg#*=}" ;;
    --skip-existing)   SKIP_EXISTING=true ;;
    --no-skip-existing) SKIP_EXISTING=false ;;
    --dry-run)         DRY_RUN=true ;;
    --wp-path=*)       ;; # handled by common.sh
    *) ;;
  esac
done

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  log_error "Provide --file=<json> with post definitions."
  exit 1
fi

# ---------------------------------------------------------------------------
# Use PHP helper for full control (meta, ACF, categories, tags)
# ---------------------------------------------------------------------------
TEMP_PHP=$(mktemp /tmp/create-posts-XXXX.php)

cat > "$TEMP_PHP" <<'EOPHP'
<?php
/**
 * Creates posts with meta fields, ACF fields, categories, and tags.
 * Run via: wp eval-file <this-file> -- <json-path> <default_post_type> <default_status> <skip_existing>
 */

$json_path         = $args[0] ?? '';
$default_post_type = $args[1] ?? 'post';
$default_status    = $args[2] ?? 'publish';
$skip_existing     = ( $args[3] ?? 'true' ) === 'true';

if ( empty( $json_path ) || ! file_exists( $json_path ) ) {
    WP_CLI::error( "JSON file not found: $json_path" );
}

$posts = json_decode( file_get_contents( $json_path ), true );
if ( ! is_array( $posts ) ) {
    WP_CLI::error( 'Failed to parse JSON (expected array of posts).' );
}

$created = 0;
$skipped = 0;

foreach ( $posts as $post_def ) {
    $title     = $post_def['title'] ?? 'Untitled';
    $slug      = $post_def['slug'] ?? sanitize_title( $title );
    $post_type = $post_def['post_type'] ?? $default_post_type;
    $status    = $post_def['status'] ?? $default_status;
    $content   = $post_def['content'] ?? '';
    $excerpt   = $post_def['excerpt'] ?? '';
    $meta      = $post_def['meta'] ?? array();
    $acf       = $post_def['acf'] ?? array();
    $cats      = $post_def['categories'] ?? array();
    $tags      = $post_def['tags'] ?? array();

    // Load content from file if specified
    if ( ! empty( $post_def['content_file'] ) && file_exists( $post_def['content_file'] ) ) {
        $content = file_get_contents( $post_def['content_file'] );
    }

    // Check if post exists
    if ( $skip_existing ) {
        $existing = get_posts( array(
            'name'        => $slug,
            'post_type'   => $post_type,
            'post_status' => array( 'publish', 'draft', 'pending', 'private' ),
            'numberposts' => 1,
        ) );
        if ( ! empty( $existing ) ) {
            WP_CLI::warning( "[$post_type] '$title' (slug: $slug) already exists (ID: {$existing[0]->ID}). Skipping." );
            $skipped++;
            continue;
        }
    }

    // Create the post
    $post_data = array(
        'post_type'    => $post_type,
        'post_title'   => $title,
        'post_name'    => $slug,
        'post_status'  => $status,
        'post_content' => $content,
        'post_excerpt' => $excerpt,
    );

    $post_id = wp_insert_post( $post_data, true );

    if ( is_wp_error( $post_id ) ) {
        WP_CLI::error( "Failed to create '$title': " . $post_id->get_error_message() );
        continue;
    }

    // Set categories (create if they don't exist)
    if ( ! empty( $cats ) && $post_type === 'post' ) {
        $cat_ids = array();
        foreach ( $cats as $cat_name ) {
            $term = get_term_by( 'name', $cat_name, 'category' );
            if ( ! $term ) {
                $result = wp_insert_term( $cat_name, 'category' );
                if ( ! is_wp_error( $result ) ) {
                    $cat_ids[] = $result['term_id'];
                }
            } else {
                $cat_ids[] = $term->term_id;
            }
        }
        if ( ! empty( $cat_ids ) ) {
            wp_set_post_categories( $post_id, $cat_ids );
        }
    }

    // Set tags
    if ( ! empty( $tags ) && $post_type === 'post' ) {
        wp_set_post_tags( $post_id, $tags );
    }

    // Set custom meta fields
    foreach ( $meta as $key => $value ) {
        update_post_meta( $post_id, $key, $value );
    }

    // Set ACF fields (uses update_field if ACF is active)
    if ( ! empty( $acf ) && function_exists( 'update_field' ) ) {
        foreach ( $acf as $field_name => $field_value ) {
            update_field( $field_name, $field_value, $post_id );
        }
    } elseif ( ! empty( $acf ) ) {
        // Fallback: save as post meta with underscore prefix (ACF convention)
        foreach ( $acf as $field_name => $field_value ) {
            update_post_meta( $post_id, $field_name, $field_value );
        }
    }

    WP_CLI::success( "[$post_type] Created '$title' (ID: $post_id, slug: $slug)" );
    $created++;
}

WP_CLI::success( "Done. Created: $created, Skipped: $skipped" );
EOPHP

if $DRY_RUN; then
  log_info "[DRY-RUN] Posts to create from: $FILE"
  python3 -c "
import json
with open('$FILE') as f:
    posts = json.load(f)
for p in posts:
    pt = p.get('post_type', '$DEFAULT_POST_TYPE')
    print(f'  [{pt}] {p.get(\"title\",\"\")} (slug: {p.get(\"slug\",\"\")})')
    acf = p.get('acf', {})
    if acf:
        for k, v in acf.items():
            vstr = str(v)[:50]
            print(f'    ACF: {k} = {vstr}')
"
  rm -f "$TEMP_PHP"
  exit 0
fi

log_info "Creating posts from: $FILE"

ABS_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")

SKIP_FLAG="true"
$SKIP_EXISTING || SKIP_FLAG="false"

wpcli eval-file "$TEMP_PHP" "$ABS_FILE" "$DEFAULT_POST_TYPE" "$DEFAULT_STATUS" "$SKIP_FLAG" 2>&1

rm -f "$TEMP_PHP"

log_info "Done."
