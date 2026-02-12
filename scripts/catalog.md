# WordPress Automation Scripts Catalog

**Authoritative index** of all automation scripts in this project.

**Owner**: Scripter Agent (exclusive)
**Last Updated**: 2026-02-12

---

## Before Creating a New Script

1. Check this catalog — does a similar script already exist?
2. Can you extend an existing script instead?
3. Is this reusable or a one-time operation?

---

## WP-CLI Scripts (`scripts/wp-cli/`)

Bash scripts that operate WordPress via WP-CLI. All scripts require `--wp-path=<path>`.

### run-setup.sh

**Purpose**: Full project setup orchestrator — runs all scripts in correct order.

```bash
# Full setup
./scripts/wp-cli/run-setup.sh \
  --wp-path="/path/to/wordpress" \
  --data-dir=data/myproject

# Dry run (preview only)
./scripts/wp-cli/run-setup.sh \
  --wp-path="/path/to/wordpress" \
  --data-dir=data/myproject --dry-run

# Resume from step 5
./scripts/wp-cli/run-setup.sh \
  --wp-path="/path/to/wordpress" \
  --data-dir=data/myproject --step=5
```

**Execution order**: settings → pages → CPTs → ACF fields → Bricks templates → menus → content.

---

### configure-wp.sh

**Purpose**: Configure WordPress settings (timezone, language, permalinks, front page, etc.).

```bash
# From JSON
./scripts/wp-cli/configure-wp.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/settings.json

# Inline
./scripts/wp-cli/configure-wp.sh --wp-path="/path/to/wordpress" \
  --timezone="Europe/Madrid" --lang=es_ES --permalink="/%postname%/"
```

**JSON format** (`settings.json`):
```json
{
  "blogname": "My Project",
  "timezone_string": "Europe/Madrid",
  "WPLANG": "es_ES",
  "permalink_structure": "/%postname%/",
  "show_on_front": "page",
  "page_on_front_slug": "home",
  "page_for_posts_slug": "blog"
}
```

---

### create-pages.sh

**Purpose**: Create WordPress pages from JSON.

```bash
./scripts/wp-cli/create-pages.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/pages.json
```

**JSON format** (`pages.json`):
```json
[
  { "title": "Home", "slug": "home", "status": "publish" },
  { "title": "About", "slug": "about", "status": "publish" },
  { "title": "Contact", "slug": "contact", "status": "publish" }
]
```

**Options**: `--file`, `--title`, `--slug`, `--status`, `--skip-existing`, `--dry-run`

---

### create-menus.sh

**Purpose**: Create WordPress navigation menus with items from JSON.

```bash
./scripts/wp-cli/create-menus.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/menus.json
```

**JSON format** (`menus.json`):
```json
[
  {
    "name": "Primary Menu",
    "location": "primary",
    "items": [
      { "title": "Home", "type": "page", "slug": "home" },
      { "title": "About", "type": "page", "slug": "about" },
      { "title": "External", "type": "custom", "url": "https://example.com" }
    ]
  }
]
```

**Item types**: `page`, `post`, `custom`, `cpt`

---

### register-cpt.sh

**Purpose**: Register a Custom Post Type in the child theme.

```bash
# From JSON
./scripts/wp-cli/register-cpt.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/cpt-services.json

# Inline
./scripts/wp-cli/register-cpt.sh --wp-path="/path/to/wordpress" \
  --slug=services --singular=Service --plural=Services \
  --icon=dashicons-heart --supports=title,editor,thumbnail
```

**JSON format** (`cpt-services.json`):
```json
{
  "slug": "services",
  "singular": "Service",
  "plural": "Services",
  "supports": ["title", "editor", "thumbnail", "excerpt"],
  "icon": "dashicons-heart",
  "has_archive": true,
  "show_in_rest": true
}
```

Generates `inc/cpt-<slug>.php` in the child theme and adds the include to `functions.php`.

---

### create-acf-fields.sh

**Purpose**: Create ACF field groups in the database (editable in ACF admin).

```bash
./scripts/wp-cli/create-acf-fields.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/acf-services.json
```

**JSON format** (`acf-services.json`):
```json
{
  "title": "Service Details",
  "key": "group_service_details",
  "location": [
    [{ "param": "post_type", "operator": "==", "value": "services" }]
  ],
  "fields": [
    { "key": "field_duration", "label": "Duration", "name": "duration", "type": "text", "required": 1 },
    { "key": "field_price", "label": "Price", "name": "price", "type": "number" }
  ]
}
```

Creates fields **in the database** (not PHP), making them visible and editable in the ACF admin UI.

**Supported field types**: `text`, `textarea`, `wysiwyg`, `image`, `select`, `number`, `true_false`, `url`, `email`

---

### create-bricks-templates.sh

**Purpose**: Create Bricks Builder templates with display conditions.

```bash
./scripts/wp-cli/create-bricks-templates.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/bricks-templates.json
```

**JSON format** (`bricks-templates.json`):
```json
[
  { "title": "Main Header", "type": "header", "conditions": { "type": "entireWebsite" } },
  { "title": "Main Footer", "type": "footer", "conditions": { "type": "entireWebsite" } },
  { "title": "Single - Service", "type": "single", "conditions": { "type": "postType", "value": "services" } },
  { "title": "Archive - Services", "type": "archive", "conditions": { "type": "archivePostType", "value": "services" } }
]
```

**Template types**: `header`, `footer`, `single`, `archive`, `section`, `popup`

**Condition types**: `entireWebsite`, `postType`, `archivePostType`, `frontPage`, `page`

---

### create-posts.sh

**Purpose**: Create posts or CPT entries with meta/ACF fields from JSON.

```bash
# Create CPT entries
./scripts/wp-cli/create-posts.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/services.json

# Create blog posts
./scripts/wp-cli/create-posts.sh --wp-path="/path/to/wordpress" \
  --file=data/myproject/blog-posts.json --post-type=post
```

**JSON format**:
```json
[
  {
    "title": "Service Title",
    "slug": "service-title",
    "post_type": "services",
    "status": "publish",
    "content": "<p>HTML content...</p>",
    "excerpt": "Short description",
    "acf": {
      "duration": "60 minutes",
      "price": "50"
    }
  }
]
```

**Features**: auto-creates categories/tags, sets ACF fields, skip-existing by default.

---

### lib/common.sh

**Purpose**: Shared utilities sourced by all WP-CLI scripts.

**Provides**:
- `wpcli()` — WP-CLI wrapper with automatic `--path`
- `post_exists_by_slug()` — Check if a post exists
- `menu_exists()` — Check if a menu exists
- `log_info()`, `log_success()`, `log_warn()`, `log_error()` — Colored logging
- `WP_PATH` resolution from `--wp-path` arg or `$WP_PATH` env var

---

## Data Files

Project-specific JSON data files are stored in `scripts/wp-cli/data/<project>/`.

Each project directory contains the JSON definitions consumed by the scripts above. Typical files:

| File | Used by |
|------|---------|
| `settings.json` | `configure-wp.sh` |
| `pages.json` | `create-pages.sh` |
| `cpt-*.json` | `register-cpt.sh` |
| `acf-*.json` | `create-acf-fields.sh` |
| `bricks-templates.json` | `create-bricks-templates.sh` |
| `menus.json` | `create-menus.sh` |
| `*.json` (content) | `create-posts.sh` |

---

## REST API Scripts (`scripts/wp-api/`)

Node.js scripts for REST API operations. No external dependencies — uses built-in `http`/`https` modules.

**Environment variables** (from `.env`):
- `WP_API_BASE_URL` — e.g. `http://myproject.local/wp-json`
- `WP_API_USER` — WordPress username
- `WP_API_PASSWORD` — Application Password (no spaces)

### create-post.js

**Purpose**: Create a post via REST API.

```bash
node scripts/wp-api/create-post.js --title="My Post" --content="<p>Hello</p>" --status=publish
node scripts/wp-api/create-post.js --file=post-data.json
```

**Options**: `--title`, `--content`, `--status`, `--categories`, `--tags`, `--excerpt`, `--meta-KEY=VALUE`, `--file`, `--output`

---

### update-post.js

**Purpose**: Update an existing post via REST API.

```bash
node scripts/wp-api/update-post.js --id=42 --title="Updated Title"
node scripts/wp-api/update-post.js --id=42 --status=publish --meta-featured=true
```

**Options**: `--id` (required), `--title`, `--content`, `--status`, `--categories`, `--tags`, `--meta-KEY=VALUE`

---

### upload-media.js

**Purpose**: Upload media files to WordPress.

```bash
node scripts/wp-api/upload-media.js --file=./images/photo.jpg --title="Photo"
node scripts/wp-api/upload-media.js --file=./banner.png --alt="Site banner"
```

**Options**: `--file` (required), `--title`, `--alt`, `--caption`, `--output`

---

### create-product.js

**Purpose**: Create a WooCommerce product via REST API.

```bash
node scripts/wp-api/create-product.js \
  --name="Product Name" --regular-price=29.99 --sku=PROD-001

node scripts/wp-api/create-product.js --file=product-data.json
```

**Options**: `--name`, `--description`, `--type`, `--regular-price`, `--sale-price`, `--sku`, `--stock-quantity`, `--categories`, `--images`, `--meta-KEY=VALUE`, `--file`, `--output`

**Requires**: WooCommerce plugin installed and activated.

---

### update-product.js

**Purpose**: Update an existing WooCommerce product via REST API.

```bash
node scripts/wp-api/update-product.js --id=99 --regular-price=24.99
node scripts/wp-api/update-product.js --id=99 --stock-quantity=50 --sale-price=19.99
```

**Options**: `--id` (required), `--name`, `--regular-price`, `--sale-price`, `--sku`, `--stock-quantity`, `--meta-KEY=VALUE`

**Requires**: WooCommerce plugin installed and activated.
