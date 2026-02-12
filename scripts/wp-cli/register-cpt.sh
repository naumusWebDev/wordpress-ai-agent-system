#!/usr/bin/env bash
# =============================================================================
# register-cpt.sh — Register a Custom Post Type in a child theme's functions.php
#
# Usage:
#   ./register-cpt.sh --wp-path=<path> --file=cpt.json
#   ./register-cpt.sh --wp-path=<path> --slug=servicios --singular=Servicio \
#                     --plural=Servicios --icon=dashicons-heart \
#                     --supports=title,editor,thumbnail,excerpt
#
# JSON format (single CPT):
#   {
#     "slug": "servicios",
#     "singular": "Servicio",
#     "plural": "Servicios",
#     "public": true,
#     "hierarchical": false,
#     "has_archive": true,
#     "show_in_rest": true,
#     "supports": ["title", "editor", "thumbnail", "excerpt"],
#     "icon": "dashicons-heart",
#     "text_domain": "bricks-child"
#   }
#
# The script generates a PHP file in the child theme's inc/ directory
# and adds an include in functions.php if not already present.
#
# Options:
#   --wp-path=<path>       WordPress installation path (required)
#   --file=<json>          JSON CPT definition file
#   --slug=<slug>          CPT slug (single mode)
#   --singular=<name>      Singular name
#   --plural=<name>        Plural name
#   --icon=<dashicon>      Menu icon (default: dashicons-admin-post)
#   --supports=<list>      Comma-separated supports (default: title,editor)
#   --hierarchical         Make hierarchical (default: false)
#   --no-archive           Disable archive (default: has_archive=true)
#   --child-theme=<slug>   Child theme directory name (auto-detected)
#   --dry-run              Show what would be created
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

FILE=""
SLUG=""
SINGULAR=""
PLURAL=""
ICON="dashicons-admin-post"
SUPPORTS="title,editor"
HIERARCHICAL=false
HAS_ARCHIVE=true
SHOW_IN_REST=true
CHILD_THEME=""
TEXT_DOMAIN=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --file=*)          FILE="${arg#*=}" ;;
    --slug=*)          SLUG="${arg#*=}" ;;
    --singular=*)      SINGULAR="${arg#*=}" ;;
    --plural=*)        PLURAL="${arg#*=}" ;;
    --icon=*)          ICON="${arg#*=}" ;;
    --supports=*)      SUPPORTS="${arg#*=}" ;;
    --hierarchical)    HIERARCHICAL=true ;;
    --no-archive)      HAS_ARCHIVE=false ;;
    --child-theme=*)   CHILD_THEME="${arg#*=}" ;;
    --dry-run)         DRY_RUN=true ;;
    --wp-path=*)       ;; # handled by common.sh
    *) ;;
  esac
done

# Auto-detect child theme
if [[ -z "$CHILD_THEME" ]]; then
  if $DRY_RUN; then
    CHILD_THEME="(dry-run)"
  else
    CHILD_THEME=$(wpcli theme list --status=active --field=name 2>/dev/null | head -1)
    if [[ -z "$CHILD_THEME" ]]; then
      log_error "Could not detect active child theme. Use --child-theme=<slug>"
      exit 1
    fi
  fi
fi

THEME_DIR="$WP_PATH/wp-content/themes/$CHILD_THEME"
if ! $DRY_RUN && [[ ! -d "$THEME_DIR" ]]; then
  log_error "Theme directory not found: $THEME_DIR"
  exit 1
fi

# ---------------------------------------------------------------------------
generate_cpt_php() {
  local slug="$1"
  local singular="$2"
  local plural="$3"
  local icon="$4"
  local supports_csv="$5"
  local hierarchical="$6"
  local has_archive="$7"
  local show_in_rest="$8"
  local text_domain="$9"

  [[ -z "$text_domain" ]] && text_domain="$CHILD_THEME"

  # Build supports array string
  local supports_php=""
  IFS=',' read -ra SPARTS <<< "$supports_csv"
  for s in "${SPARTS[@]}"; do
    supports_php="$supports_php'$(echo "$s" | xargs)', "
  done
  supports_php="array( ${supports_php% ,} )"

  local hier_php="false"
  [[ "$hierarchical" == "true" ]] && hier_php="true"
  local archive_php="true"
  [[ "$has_archive" == "false" ]] && archive_php="false"
  local rest_php="true"
  [[ "$show_in_rest" == "false" ]] && rest_php="false"

  local func_prefix
  func_prefix=$(echo "$text_domain" | tr '-' '_')

  cat <<EOPHP
<?php
/**
 * Custom Post Type: $plural
 *
 * @package ${CHILD_THEME}
 */

function ${func_prefix}_register_${slug}_cpt() {
    \$labels = array(
        'name'               => __( '$plural', '$text_domain' ),
        'singular_name'      => __( '$singular', '$text_domain' ),
        'menu_name'          => __( '$plural', '$text_domain' ),
        'add_new'            => __( 'Añadir nuevo', '$text_domain' ),
        'add_new_item'       => __( 'Añadir nuevo $singular', '$text_domain' ),
        'edit_item'          => __( 'Editar $singular', '$text_domain' ),
        'new_item'           => __( 'Nuevo $singular', '$text_domain' ),
        'view_item'          => __( 'Ver $singular', '$text_domain' ),
        'search_items'       => __( 'Buscar $plural', '$text_domain' ),
        'not_found'          => __( 'No se encontraron $plural', '$text_domain' ),
        'not_found_in_trash' => __( 'No se encontraron $plural en la papelera', '$text_domain' ),
        'all_items'          => __( 'Todos los $plural', '$text_domain' ),
    );

    \$args = array(
        'labels'             => \$labels,
        'public'             => true,
        'publicly_queryable' => true,
        'show_ui'            => true,
        'show_in_menu'       => true,
        'show_in_rest'       => $rest_php,
        'has_archive'        => $archive_php,
        'hierarchical'       => $hier_php,
        'rewrite'            => array( 'slug' => '$slug' ),
        'supports'           => $supports_php,
        'menu_icon'          => '$icon',
    );

    register_post_type( '$slug', \$args );
}
add_action( 'init', '${func_prefix}_register_${slug}_cpt' );
EOPHP
}

# ---------------------------------------------------------------------------
install_cpt() {
  local slug="$1"
  local singular="$2"
  local plural="$3"
  local icon="$4"
  local supports="$5"
  local hierarchical="$6"
  local has_archive="$7"
  local show_in_rest="$8"
  local text_domain="$9"

  local inc_dir="$THEME_DIR/inc"
  local cpt_file="$inc_dir/cpt-${slug}.php"
  local functions_file="$THEME_DIR/functions.php"

  if [[ -f "$cpt_file" ]]; then
    log_warn "CPT file already exists: inc/cpt-${slug}.php. Skipping."
    return 0
  fi

  if $DRY_RUN; then
    log_info "[DRY-RUN] Would create: inc/cpt-${slug}.php for CPT '$plural'"
    return 0
  fi

  mkdir -p "$inc_dir"

  generate_cpt_php "$slug" "$singular" "$plural" "$icon" "$supports" \
    "$hierarchical" "$has_archive" "$show_in_rest" "$text_domain" > "$cpt_file"

  log_success "Created CPT file: inc/cpt-${slug}.php"

  # Add include to functions.php if not present
  local include_line="require_once get_stylesheet_directory() . '/inc/cpt-${slug}.php';"
  if ! grep -qF "cpt-${slug}.php" "$functions_file" 2>/dev/null; then
    echo "" >> "$functions_file"
    echo "// Custom Post Type: $plural" >> "$functions_file"
    echo "$include_line" >> "$functions_file"
    log_success "Added include to functions.php"
  else
    log_warn "Include for cpt-${slug}.php already in functions.php"
  fi

  # Flush rewrite rules
  wpcli rewrite flush 2>/dev/null && log_success "Rewrite rules flushed" || true
}

# ---------------------------------------------------------------------------
if [[ -n "$FILE" ]]; then
  if [[ ! -f "$FILE" ]]; then
    log_error "File not found: $FILE"
    exit 1
  fi

  # Parse JSON
  eval "$(python3 -c "
import json
with open('$FILE') as f:
    cpt = json.load(f)
print(f'SLUG=\"{cpt.get(\"slug\",\"\")}\"')
print(f'SINGULAR=\"{cpt.get(\"singular\",\"\")}\"')
print(f'PLURAL=\"{cpt.get(\"plural\",\"\")}\"')
print(f'ICON=\"{cpt.get(\"icon\",\"dashicons-admin-post\")}\"')
print(f'SUPPORTS=\"{\",\".join(cpt.get(\"supports\",[\"title\",\"editor\"]))}\"')
print(f'HIERARCHICAL=\"{str(cpt.get(\"hierarchical\", False)).lower()}\"')
print(f'HAS_ARCHIVE=\"{str(cpt.get(\"has_archive\", True)).lower()}\"')
print(f'SHOW_IN_REST=\"{str(cpt.get(\"show_in_rest\", True)).lower()}\"')
print(f'TEXT_DOMAIN=\"{cpt.get(\"text_domain\",\"\")}\"')
")"
fi

if [[ -z "$SLUG" || -z "$SINGULAR" || -z "$PLURAL" ]]; then
  log_error "Required: --slug, --singular, --plural (or --file with JSON)"
  exit 1
fi

install_cpt "$SLUG" "$SINGULAR" "$PLURAL" "$ICON" "$SUPPORTS" \
  "$HIERARCHICAL" "$HAS_ARCHIVE" "$SHOW_IN_REST" "${TEXT_DOMAIN:-$CHILD_THEME}"

log_info "Done."
