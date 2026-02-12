#!/usr/bin/env bash
# =============================================================================
# configure-wp.sh — Configure WordPress settings via WP-CLI
#
# Usage:
#   ./configure-wp.sh --wp-path=<path> --file=settings.json
#   ./configure-wp.sh --wp-path=<path> --timezone="Europe/Madrid" --lang=es_ES
#
# JSON format:
#   {
#     "blogname": "FisioSens",
#     "blogdescription": "Centro de Fisioterapia en Palma de Mallorca",
#     "timezone_string": "Europe/Madrid",
#     "date_format": "d/m/Y",
#     "time_format": "H:i",
#     "WPLANG": "es_ES",
#     "posts_per_page": "9",
#     "permalink_structure": "/%postname%/",
#     "show_on_front": "page",
#     "page_on_front_slug": "inicio",
#     "page_for_posts_slug": "blog",
#     "default_comment_status": "open",
#     "comments_on_pages": false
#   }
#
# Options:
#   --wp-path=<path>       WordPress installation path (required)
#   --file=<json>          JSON settings file
#   --timezone=<tz>        Timezone (e.g., Europe/Madrid)
#   --lang=<locale>        Language locale (e.g., es_ES)
#   --permalink=<struct>   Permalink structure (e.g., /%postname%/)
#   --front-page=<slug>    Static front page slug
#   --blog-page=<slug>     Blog page slug
#   --posts-per-page=<n>   Posts per page
#   --dry-run              Show settings without applying
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

FILE=""
TIMEZONE=""
LANG_LOCALE=""
PERMALINK=""
FRONT_PAGE=""
BLOG_PAGE=""
POSTS_PER_PAGE=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --file=*)            FILE="${arg#*=}" ;;
    --timezone=*)        TIMEZONE="${arg#*=}" ;;
    --lang=*)            LANG_LOCALE="${arg#*=}" ;;
    --permalink=*)       PERMALINK="${arg#*=}" ;;
    --front-page=*)      FRONT_PAGE="${arg#*=}" ;;
    --blog-page=*)       BLOG_PAGE="${arg#*=}" ;;
    --posts-per-page=*)  POSTS_PER_PAGE="${arg#*=}" ;;
    --dry-run)           DRY_RUN=true ;;
    --wp-path=*)         ;; # handled by common.sh
    *) ;;
  esac
done

# ---------------------------------------------------------------------------
apply_option() {
  local key="$1"
  local value="$2"
  if $DRY_RUN; then
    log_info "[DRY-RUN] Would set: $key = $value"
    return 0
  fi
  wpcli option update "$key" "$value" 2>/dev/null
  log_success "Set $key = $value"
}

set_permalink() {
  local structure="$1"
  if $DRY_RUN; then
    log_info "[DRY-RUN] Would set permalink structure: $structure"
    return 0
  fi
  wpcli rewrite structure "$structure" 2>/dev/null
  wpcli rewrite flush 2>/dev/null
  log_success "Permalink structure set to: $structure"
}

set_static_front_page() {
  local front_slug="$1"
  local blog_slug="$2"

  if $DRY_RUN; then
    log_info "[DRY-RUN] Would set static front page: $front_slug, blog: $blog_slug"
    return 0
  fi

  apply_option "show_on_front" "page"

  if [[ -n "$front_slug" ]]; then
    local front_id
    front_id=$(post_exists_by_slug "$front_slug" "page")
    if [[ -n "$front_id" ]]; then
      apply_option "page_on_front" "$front_id"
    else
      log_warn "Page '$front_slug' not found for front page."
    fi
  fi

  if [[ -n "$blog_slug" ]]; then
    local blog_id
    blog_id=$(post_exists_by_slug "$blog_slug" "page")
    if [[ -n "$blog_id" ]]; then
      apply_option "page_for_posts" "$blog_id"
    else
      log_warn "Page '$blog_slug' not found for blog page."
    fi
  fi
}

disable_comments_on_pages() {
  if $DRY_RUN; then
    log_info "[DRY-RUN] Would disable comments on all existing pages"
    return 0
  fi

  # Get all page IDs and disable comments
  local page_ids
  page_ids=$(wpcli post list --post_type=page --field=ID --format=ids 2>/dev/null || true)
  if [[ -n "$page_ids" ]]; then
    for pid in $page_ids; do
      wpcli post update "$pid" --comment_status=closed 2>/dev/null
    done
    log_success "Disabled comments on all pages"
  fi
}

install_language() {
  local locale="$1"
  if $DRY_RUN; then
    log_info "[DRY-RUN] Would install and activate language: $locale"
    return 0
  fi
  wpcli language core install "$locale" 2>/dev/null || true
  wpcli site switch-language "$locale" 2>/dev/null && \
    log_success "Language set to: $locale" || \
    log_warn "Could not switch language to: $locale"
}

# ---------------------------------------------------------------------------
# Process from JSON file
# ---------------------------------------------------------------------------
if [[ -n "$FILE" && -f "$FILE" ]]; then
  log_info "Applying settings from: $FILE"

  # Parse JSON and apply every setting
  eval "$(python3 -c "
import json, shlex
with open('$FILE') as f:
    data = json.load(f)

simple_options = [
    'blogname', 'blogdescription', 'timezone_string', 'date_format',
    'time_format', 'posts_per_page', 'default_comment_status',
    'start_of_week', 'use_smilies', 'default_ping_status'
]

for key in simple_options:
    if key in data:
        val = shlex.quote(str(data[key]))
        print(f'apply_option \"{key}\" {val}')

if 'WPLANG' in data:
    print(f'install_language \"{data[\"WPLANG\"]}\"')

if 'permalink_structure' in data:
    print(f'set_permalink \"{data[\"permalink_structure\"]}\"')

front = data.get('page_on_front_slug', '')
blog = data.get('page_for_posts_slug', '')
if data.get('show_on_front') == 'page' or front or blog:
    print(f'set_static_front_page \"{front}\" \"{blog}\"')

if data.get('comments_on_pages') == False:
    print('disable_comments_on_pages')
")"
fi

# ---------------------------------------------------------------------------
# Process from arguments (overrides / standalone)
# ---------------------------------------------------------------------------
[[ -n "$TIMEZONE" ]]       && apply_option "timezone_string" "$TIMEZONE"
[[ -n "$LANG_LOCALE" ]]    && install_language "$LANG_LOCALE"
[[ -n "$PERMALINK" ]]      && set_permalink "$PERMALINK"
[[ -n "$POSTS_PER_PAGE" ]] && apply_option "posts_per_page" "$POSTS_PER_PAGE"

if [[ -n "$FRONT_PAGE" || -n "$BLOG_PAGE" ]]; then
  set_static_front_page "$FRONT_PAGE" "$BLOG_PAGE"
fi

log_info "Done."
