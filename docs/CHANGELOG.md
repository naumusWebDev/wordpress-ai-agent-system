# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- WordPress visual installation completion
- Application Password generation for REST API
- Sample content and theme configuration

---

## [1.1.1] - 2026-01-15

### Fixed
- **Cake Configurator: Dietary options price not summing** - Fixed JavaScript bug in `updateSelectedOptions()` function where selected extras were not being added to the total price
  - **Symptom**: Frontend showed only size price (e.g., €10.00) even when dietary options were selected (Vegan +€3.00, Nut-free +€2.00)
  - **Root cause**: JavaScript `this` context binding issue. Using `.bind(this)` on the jQuery `.each()` callback caused `$(this).val()` to reference the `CakeConfigurator` object instead of the checkbox DOM element
  - **Fix**: Replaced `.bind(this)` pattern with `var self = this` closure pattern, which is consistent with the rest of the codebase
  - **Modified**: `wp-content/themes/organics-child/includes/cake-product/assets/cake-configurator.js` (lines 102-108)
  - **How to verify**:
    1. Go to any cake product page
    2. Select a size (e.g., Small €10.00)
    3. Select dietary options (e.g., Vegan +€3.00, Nut-free +€2.00)
    4. Verify total shows €15.00 (not €10.00)

---

## [1.1.0] - 2026-01-12

### Added
- **Cake Product Configurator** - Complete WooCommerce custom product configuration system
  - **Admin Interface**:
    - Meta box for product edit screen with enable/disable toggle
    - Size pricing table (Small/Medium/Large with servings and prices)
    - Dynamic dietary options builder (add/remove custom options)
    - Full data validation and security (nonces, capability checks, sanitization)
  - **Frontend Configurator**:
    - Visual size selector with radio button cards
    - Multi-select dietary options with checkboxes
    - Live price calculation (updates as user selects)
    - Client-side and server-side validation
    - Mobile-responsive design
    - Accessibility features (keyboard navigation, focus states)
  - **Cart & Checkout Integration**:
    - Configuration persistence in cart items
    - Dynamic price override based on selections
    - Display of size and options in cart and checkout
    - Unique cart item keys prevent merging different configurations
  - **Order Integration**:
    - Configuration saved to order item meta
    - Display in WP Admin order details
    - Display in order confirmation emails
    - Display in customer account order history
  - **Theme Integration**:
    - Styled to match Organics theme design system
    - Colors: #222222, #7fb77e, #e6e9eb, #da6f5b
    - Typography and spacing matched
    - Pulse animation on size selection

### Technical Details
- **Files Created** (7 new files):
  - `wp-content/themes/organics-child/includes/cake-product/admin-meta-box.php` (287 lines)
  - `wp-content/themes/organics-child/includes/cake-product/cart-integration.php` (230 lines)
  - `wp-content/themes/organics-child/includes/cake-product/frontend-display.php` (210 lines)
  - `wp-content/themes/organics-child/includes/cake-product/assets/admin-cake-meta-box.js` (50 lines)
  - `wp-content/themes/organics-child/includes/cake-product/assets/admin-cake-meta-box.css` (76 lines)
  - `wp-content/themes/organics-child/includes/cake-product/assets/cake-configurator.js` (180 lines)
  - `wp-content/themes/organics-child/includes/cake-product/assets/cake-configurator.css` (313 lines, v1.1.0)
- **Files Modified**:
  - `wp-content/themes/organics-child/functions.php` (added 3 module requires)
  - `.gitignore` (fixed child theme tracking)

### Data Model
- **Product Meta Fields**:
  - `_is_cake_product` - Enable/disable flag ('yes'/'no')
  - `_cake_sizes` - Array: `['small' => ['servings' => 6, 'price' => 15.00], ...]`
  - `_cake_options` - Array: `[['key' => 'vegan', 'label' => 'Vegan', 'modifier' => 3.00], ...]`
- **Cart Item Meta**:
  - `cake_size` - Selected size key
  - `cake_options` - Array of selected option keys
  - `cake_final_price` - Calculated price
  - `unique_key` - MD5 hash for cart item uniqueness
- **Order Item Meta**: Same as cart + human-readable display labels

### Pricing Formula
```
Final Price = Base Price (selected size) + Σ(selected option modifiers)
Example: Medium (€25) + Vegan (+€5) + Sugar-free (+€4) = €34
```

### WooCommerce Hooks Used
- `add_meta_boxes` - Register admin meta box
- `save_post_product` - Save configuration data
- `woocommerce_add_cart_item_data` - Capture user selections
- `woocommerce_before_calculate_totals` - Override cart item price
- `woocommerce_get_item_data` - Display in cart
- `woocommerce_checkout_create_order_line_item` - Save to order
- `woocommerce_before_add_to_cart_button` - Inject frontend UI
- `wp_enqueue_scripts` - Load assets conditionally

### Security Features
- Nonce verification on all saves
- Capability checks (`edit_product`)
- Input sanitization (`sanitize_text_field`, `floatval`, `sanitize_key`)
- Output escaping (`esc_html`, `esc_attr`, `wp_json_encode`)
- Server-side price recalculation (client price ignored)

### Architecture
- **Location**: `/wp-content/themes/organics-child/includes/cake-product/`
- **Pattern**: Modular architecture (admin, cart, frontend)
- **Update Safety**: No parent theme or core modifications
- **Extensibility**: Hook-based, can be extended via filters/actions

### Documentation
- Test product setup guide: `/docs/work/test-product-setup-guide.md`
- Validation testing guide: `/docs/work/2026-01-11-validation-testing-guide.md` (35 test cases)
- Technical specification: `/docs/work/2026-01-11-custom-cake-analysis.md`
- Implementation reports:
  - `/docs/work/2026-01-11-task1-backend-implementation.md`
  - `/docs/work/2026-01-11-task2-backend-implementation.md`
  - `/docs/work/2026-01-11-task3-frontend-implementation.md`
- Feature documentation: `/docs/features/cake-product-configurator.md`

### Fixed
- `.gitignore` - Corrected pattern to properly track child theme contents

---

## [1.0.0] - 2026-01-11

### Added
- **WordPress Core**: Latest stable WordPress installation (extracted to project root)
- **Docker Infrastructure**:
  - docker-compose.yml with PHP 8.3, MySQL 8.0, and WP-CLI
  - Environment variable support via `.env` file
  - `.env.example` template for configuration
- **Theme Installation**:
  - Organics parent theme (v1.6.12)
  - Organics child theme (v1.6.12)
  - Themes extracted to `/wp-content/themes/`
- **Multi-Agent System**:
  - 8 specialized agents with complete definitions
  - Agent catalog (`/agents.md`)
  - Individual agent prompts in `/agents/`:
    - Orchestrator (coordination and workflow)
    - Analyzer (requirement analysis)
    - Backend Engineer (WordPress backend)
    - Frontend Designer (UI/UX)
    - Reviewer (code quality)
    - Scripter (REST API automation)
    - Validator (integration testing)
    - Documenter (documentation management)
- **Documentation**:
  - `/docs/api-access.md` - REST API authentication guide
  - `/docs/environment.md` - Development environment setup
  - `/docs/repo-structure.md` - Repository organization
  - `/docs/agents/overview.md` - Agent system overview
  - `/docs/agents/roles.md` - Agent roles and boundaries
  - `/docs/initializer-runbook.md` - Initialization execution log
  - `/docs/CHANGELOG.md` - This file
  - `/docs/work/checklist-template.md` - Task checklist template
- **Scripts Infrastructure**:
  - `/scripts/wp-api/` directory for REST API scripts
  - `/scripts/catalog.md` - Script registry (owned by Scripter)
  - `/scripts/README.md` - Script usage guide
- **Configuration**:
  - `wp-config.php` with database configuration
  - WordPress security salts generated
  - `.gitignore` with WordPress-specific exclusions
  - Claude Code slash commands in `.claude/commands/`

### Configuration
- **Database**: organicstore (MySQL 8.0)
- **Site URL**: http://organicstore.local
- **PHP Version**: 8.3
- **Table Prefix**: wp_
- **Authentication Method**: Application Passwords (WordPress 5.6+)

### Infrastructure
- **Environment**: Docker (docker-compose)
- **Web Server**: Apache (in WordPress container)
- **Database**: MySQL 8.0
- **WP-CLI**: Available via dedicated container

### Documentation
- Complete agent system documentation
- REST API access guide
- Docker setup instructions
- Repository structure guide
- Script catalog template

---

**Maintained By**: Documenter Agent
**Project**: WordPress AI - Organic Store
**Repository**: wordpress-ai-sample
