#!/usr/bin/env bash
# =============================================================================
# create-acf-fields.sh — Create ACF field groups via WP-CLI + DB
#
# Creates ACF field groups as real database entries (visible and editable
# in the ACF admin UI), NOT as local PHP code.
#
# Usage:
#   ./create-acf-fields.sh --wp-path=<path> --file=acf-fields.json
#
# JSON format:
#   {
#     "title": "Detalles del Servicio",
#     "key": "group_detalles_servicio",
#     "location": [
#       [{ "param": "post_type", "operator": "==", "value": "servicios" }]
#     ],
#     "position": "normal",
#     "style": "default",
#     "fields": [
#       {
#         "key": "field_duracion_sesion",
#         "label": "Duración de la sesión",
#         "name": "duracion_sesion",
#         "type": "text",
#         "required": 1,
#         "instructions": "Ej: 60 minutos"
#       },
#       {
#         "key": "field_precio",
#         "label": "Precio aproximado",
#         "name": "precio",
#         "type": "text",
#         "required": 0,
#         "instructions": "Ej: 50€"
#       },
#       {
#         "key": "field_beneficios",
#         "label": "Beneficios principales",
#         "name": "beneficios",
#         "type": "textarea",
#         "required": 1,
#         "instructions": "Lista los principales beneficios",
#         "rows": 5
#       },
#       {
#         "key": "field_para_quien",
#         "label": "¿Para quién está indicado?",
#         "name": "para_quien",
#         "type": "wysiwyg",
#         "required": 0,
#         "instructions": "Describe el perfil del paciente",
#         "tabs": "all",
#         "toolbar": "full",
#         "media_upload": 0
#       },
#       {
#         "key": "field_icono",
#         "label": "Icono del servicio",
#         "name": "icono_servicio",
#         "type": "image",
#         "required": 0,
#         "instructions": "Imagen cuadrada 200x200px",
#         "return_format": "id",
#         "preview_size": "thumbnail"
#       }
#     ]
#   }
#
# This script uses a PHP helper executed via WP-CLI eval-file to create
# ACF field groups natively in the database.
#
# Options:
#   --wp-path=<path>    WordPress installation path (required)
#   --file=<json>       JSON field group definition (required)
#   --skip-existing     Skip if group already exists (default)
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
    --no-skip-existing) SKIP_EXISTING=false ;;
    --dry-run)         DRY_RUN=true ;;
    --wp-path=*)       ;; # handled by common.sh
    *) ;;
  esac
done

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  log_error "Provide --file=<json> with a valid ACF field group JSON."
  exit 1
fi

if $DRY_RUN; then
  log_info "[DRY-RUN] Would create ACF field group from: $FILE"
  python3 -c "
import json
with open('$FILE') as f:
    data = json.load(f)
print(f'  Group: {data.get(\"title\",\"\")} (key: {data.get(\"key\",\"\")})')
for field in data.get('fields', []):
    print(f'    - {field.get(\"label\",\"\")} ({field.get(\"type\",\"\")}): {field.get(\"name\",\"\")}')
"
  exit 0
fi

# Check ACF is active
if ! wpcli plugin is-active advanced-custom-fields 2>/dev/null && \
   ! wpcli plugin is-active advanced-custom-fields-pro 2>/dev/null; then
  log_error "ACF plugin is not active. Activate it first."
  exit 1
fi

# ---------------------------------------------------------------------------
# Generate PHP helper that creates ACF group via native functions
# ---------------------------------------------------------------------------
TEMP_PHP=$(mktemp /tmp/acf-create-XXXX.php)

cat > "$TEMP_PHP" <<'EOPHP'
<?php
/**
 * Creates an ACF field group from a JSON definition file.
 * Run via: wp eval-file <this-file> -- <json-path>
 */

// ACF must be loaded
if ( ! function_exists( 'acf_get_field_groups' ) ) {
    WP_CLI::error( 'ACF is not active or not loaded.' );
}

// Get JSON path from args
$json_path = $args[0] ?? '';
if ( empty( $json_path ) || ! file_exists( $json_path ) ) {
    WP_CLI::error( "JSON file not found: $json_path" );
}

$data = json_decode( file_get_contents( $json_path ), true );
if ( ! $data ) {
    WP_CLI::error( 'Failed to parse JSON file.' );
}

$group_key   = $data['key'] ?? '';
$group_title = $data['title'] ?? 'Untitled';

if ( empty( $group_key ) ) {
    WP_CLI::error( 'Field group must have a "key".' );
}

// Check if group exists
$existing = acf_get_field_groups( array( 'title' => $group_title ) );
$group_exists = false;
foreach ( $existing as $eg ) {
    if ( $eg['key'] === $group_key ) {
        $group_exists = true;
        WP_CLI::warning( "Field group '$group_title' (key: $group_key) already exists. Skipping." );
        break;
    }
}

if ( $group_exists ) {
    exit( 0 );
}

// Build location rules
$location = array();
if ( ! empty( $data['location'] ) ) {
    foreach ( $data['location'] as $rule_group ) {
        $rules = array();
        foreach ( $rule_group as $rule ) {
            $rules[] = array(
                'param'    => $rule['param'] ?? 'post_type',
                'operator' => $rule['operator'] ?? '==',
                'value'    => $rule['value'] ?? 'post',
            );
        }
        $location[] = $rules;
    }
}

// Create the field group post
$group_data = array(
    'key'        => $group_key,
    'title'      => $group_title,
    'fields'     => array(),
    'location'   => $location,
    'menu_order' => intval( $data['menu_order'] ?? 0 ),
    'position'   => $data['position'] ?? 'normal',
    'style'      => $data['style'] ?? 'default',
    'active'     => $data['active'] ?? true,
);

// Import using acf_import_field_group (creates in DB)
$imported_group = acf_import_field_group( $group_data );

if ( ! $imported_group ) {
    WP_CLI::error( "Failed to create field group '$group_title'." );
}

WP_CLI::success( "Created field group '$group_title' (key: $group_key, ID: {$imported_group['ID']})" );

// Now create each field
$fields = $data['fields'] ?? array();
$field_order = 0;

foreach ( $fields as $field_def ) {
    $field_data = array(
        'key'          => $field_def['key'] ?? '',
        'label'        => $field_def['label'] ?? '',
        'name'         => $field_def['name'] ?? '',
        'type'         => $field_def['type'] ?? 'text',
        'required'     => intval( $field_def['required'] ?? 0 ),
        'instructions' => $field_def['instructions'] ?? '',
        'parent'       => $imported_group['ID'],
        'menu_order'   => $field_order++,
    );

    // Type-specific settings
    switch ( $field_data['type'] ) {
        case 'textarea':
            $field_data['rows']      = $field_def['rows'] ?? 4;
            $field_data['new_lines'] = $field_def['new_lines'] ?? 'wpautop';
            break;
        case 'wysiwyg':
            $field_data['tabs']         = $field_def['tabs'] ?? 'all';
            $field_data['toolbar']      = $field_def['toolbar'] ?? 'full';
            $field_data['media_upload'] = intval( $field_def['media_upload'] ?? 1 );
            break;
        case 'image':
            $field_data['return_format'] = $field_def['return_format'] ?? 'id';
            $field_data['preview_size']  = $field_def['preview_size'] ?? 'thumbnail';
            $field_data['library']       = $field_def['library'] ?? 'all';
            break;
        case 'select':
            $field_data['choices']       = $field_def['choices'] ?? array();
            $field_data['multiple']      = intval( $field_def['multiple'] ?? 0 );
            $field_data['allow_null']    = intval( $field_def['allow_null'] ?? 0 );
            break;
        case 'number':
            $field_data['min'] = $field_def['min'] ?? '';
            $field_data['max'] = $field_def['max'] ?? '';
            $field_data['step'] = $field_def['step'] ?? '';
            break;
        case 'true_false':
            $field_data['default_value'] = intval( $field_def['default_value'] ?? 0 );
            $field_data['ui']            = intval( $field_def['ui'] ?? 1 );
            break;
        case 'url':
        case 'email':
        case 'password':
        case 'text':
            $field_data['placeholder']   = $field_def['placeholder'] ?? '';
            $field_data['default_value'] = $field_def['default_value'] ?? '';
            break;
    }

    // Use acf_update_field to save to DB
    $result = acf_update_field( $field_data );

    if ( $result ) {
        WP_CLI::success( "  Created field: {$field_data['label']} ({$field_data['type']}: {$field_data['name']})" );
    } else {
        WP_CLI::warning( "  Failed to create field: {$field_data['label']}" );
    }
}

WP_CLI::success( "Field group '$group_title' created with " . count( $fields ) . " fields." );
EOPHP

# ---------------------------------------------------------------------------
# Execute the PHP helper via WP-CLI
# ---------------------------------------------------------------------------
log_info "Creating ACF field group from: $FILE"

# Get absolute path for the JSON file
ABS_FILE=$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")

wpcli eval-file "$TEMP_PHP" "$ABS_FILE" 2>&1

rm -f "$TEMP_PHP"

log_info "Done."
