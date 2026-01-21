# WordPress REST API Scripts Catalog

This is the **authoritative index** of all automation scripts in this project.

**Owner**: Scripter Agent (exclusive ownership)
**Last Updated**: 2026-01-11

---

## About This Catalog

### Purpose

This catalog serves as:
- **Registry** of all scripts in `/scripts/wp-api/`
- **Documentation** for script usage
- **Version tracking** for script changes
- **Discovery** tool (find existing scripts before creating new ones)

### Maintenance

- **Owner**: Scripter Agent (exclusive)
- **Updates**: Required when scripts are created, modified, or deleted
- **Format**: Keep consistent with template below

### Before Creating a New Script

1. ✅ **Check this catalog** - Does a similar script exist?
2. ✅ **Can you extend** an existing script instead?
3. ✅ **Is this reusable** or a one-time operation?

---

## Script Categories

- [Content Management](#content-management) - Posts, pages, custom post types
- [User Management](#user-management) - Users, roles, permissions
- [Media Management](#media-management) - Upload, organize media files
- [Data Operations](#data-operations) - Import, export, migrate data
- [Utilities](#utilities) - Helper scripts and tools

---

## Content Management

### create-post.js

**Purpose**: Create a new post in WordPress via REST API

**Location**: `/scripts/wp-api/create-post.js`

**Version**: 1.0.0

**Language**: Node.js

**Prerequisites**:
- Node.js 14+ (uses built-in modules only)
- WordPress REST API enabled
- User with post creation permissions
- Application Password or regular password for authentication

**Environment Variables**:
- `WP_API_BASE_URL` - WordPress REST API base URL (e.g., http://organicstore.local/wp-json)
- `WP_API_USER` - WordPress username with post creation permissions
- `WP_API_PASSWORD` - Application Password or regular user password

**Usage**:
```bash
node scripts/wp-api/create-post.js [options]

Options:
  --title=TITLE              Post title (required)
  --content=CONTENT          Post content in HTML
  --status=STATUS            Post status: draft, publish, pending, private (default: draft)
  --categories=IDS           Comma-separated category IDs (e.g., "1,3,5")
  --tags=IDS                 Comma-separated tag IDs
  --excerpt=TEXT             Post excerpt
  --featured-media=ID        Featured image media ID
  --format=FORMAT            Post format: standard, aside, gallery, etc.
  --meta-KEY=VALUE           Custom meta field (e.g., --meta-price=29.99)
  --file=FILE                Read post data from JSON file
  --output=FILE              Save created post info to JSON file (default: created-post.json)
  -h, --help                 Show help
```

**Examples**:
```bash
# Create a simple draft post
node scripts/wp-api/create-post.js \
  --title="My First Post" \
  --content="<p>Hello World</p>"

# Create and publish a post with categories
node scripts/wp-api/create-post.js \
  --title="Breaking News" \
  --content="<p>Important announcement</p>" \
  --status=publish \
  --categories=1,3

# Create from JSON file
node scripts/wp-api/create-post.js --file=post-data.json

# Create with custom meta fields
node scripts/wp-api/create-post.js \
  --title="Product Review" \
  --content="<p>Great product!</p>" \
  --meta-rating=4.5 \
  --meta-price=99.99
```

**Input Format** (when using --file):
```json
{
  "title": "Post Title",
  "content": "<p>Post content in HTML</p>",
  "status": "publish",
  "categories": [1, 3],
  "tags": [5, 7],
  "excerpt": "Brief summary of the post",
  "format": "standard",
  "meta": {
    "custom_field": "value",
    "another_field": "another value"
  }
}
```

**Output**:
- Creates a single post in WordPress
- Generates `created-post.json` (or custom filename) with:
  - Post ID
  - Title
  - Link (URL)
  - Status
  - Creation date
  - Categories and tags

**Rollback**:
```bash
# Delete the created post (requires delete-post.js script)
node scripts/wp-api/delete-post.js --id=POST_ID

# Or use the rollback command shown in script output
```

**Notes**:
- No dependencies required - uses only Node.js built-in modules (http/https)
- Supports both HTTP and HTTPS WordPress installations
- Application Passwords are recommended over regular passwords for security
- The script outputs the rollback command after successful creation
- HTML content should be properly escaped if from untrusted sources
- Category and tag IDs must exist in WordPress before use
- Custom meta fields require appropriate permissions and may need to be registered

**Security Considerations**:
- Never commit .env files with real credentials
- Use Application Passwords (WordPress 5.6+) instead of regular passwords
- Validate and sanitize user input when used programmatically
- Review WordPress user permissions before creating posts

**Change Log**:
- v1.0.0 (2026-01-21) - Initial version
  - Basic post creation functionality
  - Support for categories, tags, meta fields
  - JSON file input support
  - Command-line argument parsing

### Example Entry Format

```markdown
### script-name.js

**Purpose**: [One-line description]

**Location**: `/scripts/wp-api/script-name.js`

**Version**: 1.0.0

**Language**: Node.js / Python / Bash

**Prerequisites**:
- Node.js 18+
- Application Password configured
- [Other requirements]

**Environment Variables**:
- `WP_API_BASE_URL` - WordPress REST API base URL
- `WP_API_AUTH` - username:application_password
- [Other variables]

**Usage**:
```bash
node scripts/wp-api/script-name.js [options]

Options:
  --file=FILE    Input file path
  --limit=NUM    Maximum items to process
```

**Examples**:
```bash
# Example 1
node scripts/wp-api/script-name.js --file=data.csv

# Example 2
node scripts/wp-api/script-name.js --file=data.csv --limit=10
```

**Input Format** (if applicable):
```csv
title,content,status
"Post 1","Content here","publish"
"Post 2","More content","draft"
```

**Output**:
- Creates [X] items in WordPress
- Generates `rollback.json` with created IDs

**Rollback**:
```bash
node scripts/wp-api/delete-posts.js --file=rollback.json
```

**Notes**:
- [Important considerations]
- [Limitations]
- [Performance notes]

**Change Log**:
- v1.0.0 (2026-01-11) - Initial version
```

### create-product.js

**Purpose**: Create a new WooCommerce product via REST API

**Location**: `/scripts/wp-api/create-product.js`

**Version**: 1.0.0

**Language**: Node.js

**Prerequisites**:
- Node.js 14+ (uses built-in modules only)
- WooCommerce plugin installed and activated
- WordPress REST API enabled
- User with product creation permissions
- Application Password for authentication

**Environment Variables**:
- `WP_API_BASE_URL` - WordPress REST API base URL (e.g., http://organicstore.local/wp-json)
- `WP_API_USER` - WordPress username with product creation permissions
- `WP_API_PASSWORD` - Application Password

**Usage**:
```bash
node scripts/wp-api/create-product.js [options]

Options:
  --name=NAME                    Product name (required)
  --description=DESC             Full product description (HTML allowed)
  --short-description=DESC       Short description
  --type=TYPE                    Product type: simple, variable, grouped, external (default: simple)
  --regular-price=PRICE          Regular price
  --sale-price=PRICE             Sale price (optional)
  --sku=SKU                      Stock Keeping Unit
  --stock-status=STATUS          Stock status: instock, outofstock, onbackorder
  --manage-stock                 Enable stock management
  --stock-quantity=QTY           Stock quantity (requires --manage-stock)
  --categories=IDS               Comma-separated category IDs
  --tags=IDS                     Comma-separated tag IDs
  --images=URLS                  Comma-separated image URLs
  --meta-KEY=VALUE               Custom meta field (use JSON for complex values)
  --file=FILE                    Read product data from JSON file
  --output=FILE                  Save created product info to JSON file
  -h, --help                     Show help
```

**Examples**:
```bash
# Create a simple product
node scripts/wp-api/create-product.js \
  --name="Premium T-Shirt" \
  --description="<p>High quality cotton t-shirt</p>" \
  --regular-price=29.99 \
  --sku=TSHIRT-001

# Create product with categories and stock
node scripts/wp-api/create-product.js \
  --name="Blue Jeans" \
  --regular-price=59.99 \
  --categories=15,16 \
  --manage-stock \
  --stock-quantity=50

# Create from JSON file (recommended for complex products)
node scripts/wp-api/create-product.js --file=tarta-abuela.json

# Create cake product with configurator meta data
node scripts/wp-api/create-product.js \
  --name="Chocolate Cake" \
  --regular-price=25.00 \
  --meta-is_cake_product=yes \
  --meta-cake_sizes='{"small":{"servings":6,"price":15},"medium":{"servings":12,"price":25}}'
```

**Input Format** (when using --file):
```json
{
  "name": "Product Name",
  "description": "<p>Full product description with HTML</p>",
  "short_description": "Brief summary",
  "type": "simple",
  "regular_price": "29.99",
  "sale_price": "24.99",
  "sku": "PROD-001",
  "stock_status": "instock",
  "manage_stock": true,
  "stock_quantity": 100,
  "categories": [
    { "id": 15 },
    { "id": 16 }
  ],
  "tags": [
    { "id": 5 }
  ],
  "images": [
    { "src": "https://example.com/image1.jpg" },
    { "src": "https://example.com/image2.jpg" }
  ],
  "meta_data": [
    { "key": "_is_cake_product", "value": "yes" },
    { "key": "_cake_sizes", "value": {...} },
    { "key": "_cake_options", "value": [...] }
  ]
}
```

**Output**:
- Creates a single product in WooCommerce
- Generates `created-product.json` (or custom filename) with:
  - Product ID
  - Name
  - Permalink (URL)
  - Type
  - Price
  - SKU
  - Stock status
  - Categories and tags

**Rollback**:
```bash
# Delete via WooCommerce admin:
# Products > All Products > [Product] > Move to Trash

# Or use REST API DELETE (requires additional script)
```

**Notes**:
- No dependencies required - uses only Node.js built-in modules
- Supports both HTTP and HTTPS WordPress installations
- Uses WooCommerce REST API v3 (requires WooCommerce 3.5+)
- Meta data can be used for custom product configurations (e.g., cake configurator)
- Complex meta values should be passed as JSON strings
- For cake products, see cake configurator documentation in `/docs/features/`

**Special Use Case - Cake Products**:

To create a product that uses the Cake Product Configurator:
1. Set `_is_cake_product` meta to "yes"
2. Define `_cake_sizes` with size configuration
3. Define `_cake_options` with dietary options

See example JSON files in `/scripts/wp-api/examples/` (if available)

**Security Considerations**:
- Never commit .env files with real credentials
- Use Application Passwords instead of regular passwords
- Validate all input when used programmatically
- Review user permissions before creating products

**Change Log**:
- v1.0.0 (2026-01-21) - Initial version
  - Basic product creation functionality
  - Support for all standard WooCommerce product fields
  - Meta data support for custom configurations
  - JSON file input support

---

## User Management

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Media Management

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Data Operations

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Utilities

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Common Utilities (Shared)

### API Client Library

**Location**: `/scripts/wp-api/lib/wp-api-client.js` (to be created)

**Purpose**: Reusable WordPress REST API client

**Usage**:
```javascript
const WPAPIClient = require('./lib/wp-api-client');
const api = new WPAPIClient();

// Use in scripts
const posts = await api.getPosts({ per_page: 100 });
```

**Note**: Create this library when you have 3+ scripts to avoid code duplication.

---

## Script Statistics

**Total Scripts**: 2
**By Category**:
- Content Management: 2
- User Management: 0
- Media Management: 0
- Data Operations: 0
- Utilities: 0

**Last Script Added**: create-product.js (2026-01-21)
**Last Script Modified**: create-product.js (2026-01-21)

---

## Deprecated Scripts

*When scripts are deprecated, they will be documented here with replacement information.*

### Example Deprecation Entry

```markdown
### ~~old-script.js~~ (DEPRECATED)

**Deprecated**: 2026-01-XX
**Reason**: Replaced by new-script.js with better performance
**Replacement**: Use `new-script.js` instead
**Migration**: [How to migrate from old to new]
```

---

## Change History

### 2026-01-21
- Added `create-product.js` - Create WooCommerce products via REST API
  - Support for simple, variable, grouped, and external products
  - Full meta data support for custom configurations (e.g., cake configurator)
- Added `create-post.js` - First script in the catalog
  - Create posts via WordPress REST API with full parameter support

### 2026-01-11
- Created catalog structure
- Defined categories and templates
- Awaiting first script

---

## Script Submission Checklist

When adding a script to this catalog:

- [ ] Script tested with sample data
- [ ] Environment variables documented
- [ ] Usage examples provided
- [ ] Input/output formats documented
- [ ] Rollback strategy defined (if applicable)
- [ ] Error handling implemented
- [ ] No hardcoded credentials
- [ ] Code follows conventions in `/scripts/README.md`
- [ ] Catalog entry complete and accurate

---

## Finding Scripts

### By Purpose

**Need to create content in bulk?** → Look in [Content Management](#content-management)

**Need to manage users?** → Look in [User Management](#user-management)

**Need to import/export data?** → Look in [Data Operations](#data-operations)

### Search Tips

1. Use your editor's search (Ctrl+F / Cmd+F)
2. Search for keywords: "import", "export", "create", "delete", etc.
3. Check change history for recent additions

---

## Contributing Scripts

### Process

1. **Check catalog** - Avoid duplicates
2. **Develop script** - Follow templates in `/scripts/README.md`
3. **Test thoroughly** - Never skip testing
4. **Document** - Complete catalog entry
5. **Update catalog** - Add to appropriate category
6. **Update statistics** - Increment counts

### Naming Conventions

```
[verb]-[entity/operation].js

Good:
- create-bulk-posts.js
- export-products.js
- delete-old-comments.js

Bad:
- script1.js
- my-script.js
- utility.js
```

---

## Support

### Questions About Existing Scripts

1. Read the catalog entry
2. Check `/scripts/README.md` for general guidance
3. Invoke Scripter agent: `/project:create-wp-api-script`

### Requesting New Scripts

Invoke Scripter agent:
```
/project:create-wp-api-script [describe what you need]
```

Example:
```
/project:create-wp-api-script Create a script to bulk import products from a CSV file with title, price, and description fields
```

---

**Catalog Maintained By**: Scripter Agent
**Exclusive Ownership**: No other agent may modify this file
**Version**: 1.0.0
**Last Updated**: 2026-01-11
