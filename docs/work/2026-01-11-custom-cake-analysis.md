# Technical Analysis: Custom Cake Product Type

**Date:** 2026-01-11
**Analyzer:** Analyzer Agent
**Requirement:** `/docs/requirements/CustomCakeProductType.md`
**Status:** Analysis Complete

---

## Executive Summary

The requirement calls for a configurable "Cake" product type in WooCommerce with:
- Size selection (Small/Medium/Large) with distinct base prices
- Multi-select dietary options (Vegan, Dairy-free, Nut-free, Wheat-free, Sugar-free) with price modifiers
- Dynamic price calculation (base + modifiers)
- Full persistence across cart, checkout, orders, and emails
- Theme-integrated UI matching the Organics theme

**Complexity:** HIGH
**Estimated Components:** Backend (40%), Frontend (30%), Integration (20%), Testing (10%)

---

## Assumptions

1. **WooCommerce is installed and active** (confirmed by requirement)
2. **Organics theme is active** with child theme `organics-child`
3. **Only Simple Products will be converted to Cake products** (not Variable products)
4. **Currency and decimal handling** follow WooCommerce defaults
5. **Admin users** will manually configure which products are "Cake" products
6. **Size is mandatory**, options are optional
7. **No inventory tracking per size/option combination** (tracked at product level)
8. **Backward compatibility** not required (new feature)

---

## Questions for Client/Stakeholder

### Business Logic
1. **What happens if no size is selected and user tries to add to cart?**
   → Recommendation: Show validation error "Please select a size"

2. **Can a product have ONLY sizes without options?**
   → Recommendation: Yes, options are optional

3. **Should size/option pricing be editable per product or globally defined?**
   → Recommendation: Per product (more flexible for different cake types)

4. **What are the exact price modifiers for each option?**
   → Currently missing - need confirmation or should admin set them per product?

5. **Should the system support future expansion (e.g., custom messages, delivery dates)?**
   → Recommendation: Keep architecture extensible but implement only current requirements

### Technical
6. **Should there be a default size pre-selected?**
   → Recommendation: No default (forces user to make conscious choice)

7. **Should stock management be affected by size/options?**
   → Recommendation: No, stock tracks the base product only

---

## Technical Approach

### 1. Data Model

**Approach: Simple Product + Custom Meta Fields**

Rationale:
- Simpler than registering a custom WooCommerce product type
- Update-safe (meta fields are standard WP/WC pattern)
- Can be migrated to custom type later if needed

**Product-level Meta Fields** (stored in `wp_postmeta`):

| Meta Key | Type | Example Value | Purpose |
|----------|------|---------------|---------|
| `_is_cake_product` | string | `'yes'` or `'no'` | Flag to enable cake configuration |
| `_cake_sizes` | serialized array | `['small' => ['price' => 15, 'servings' => 6], ...]` | Size definitions and base prices |
| `_cake_options` | serialized array | `['vegan' => 3, 'dairy_free' => 2, ...]` | Option names and price modifiers |

**Cart Item Meta** (WooCommerce session):

| Key | Type | Example |
|-----|------|---------|
| `cake_size` | string | `'medium'` |
| `cake_options` | array | `['vegan', 'sugar_free']` |
| `cake_calculated_price` | float | `25.00` |

**Order Item Meta** (permanent storage in `wp_woocommerce_order_items`):

Same as cart item meta, plus:
- `_cake_size_label` (e.g., "Medium (12 servings)")
- `_cake_options_label` (e.g., "Vegan, Sugar-free")

---

### 2. Pricing Calculation Logic

**Formula:**
```
Final Price = Base Price (from selected size) + Σ(Selected Option Modifiers)
```

**Example:**
- Medium cake: €20
- Vegan option: +€3
- Sugar-free option: +€2
- **Total: €25**

**Implementation Hooks:**

1. **Capture user selections** (Frontend → Backend)
   - Hook: `woocommerce_add_cart_item_data`
   - Capture POST data: `cake_size`, `cake_options[]`
   - Validate selections exist
   - Calculate final price
   - Store in cart item data

2. **Override cart item price**
   - Hook: `woocommerce_before_calculate_totals`
   - Read `cake_calculated_price` from cart item meta
   - Set `$cart_item['data']->set_price()`

3. **Display in cart/checkout**
   - Hook: `woocommerce_get_item_data`
   - Return formatted size and options for display

4. **Save to order**
   - Hook: `woocommerce_checkout_create_order_line_item`
   - Copy cart item meta to order item meta
   - Add human-readable labels

---

### 3. Admin Interface (Product Edit Screen)

**Meta Box: "Cake Product Configuration"**

Location: Below product data tabs

**Fields:**

1. **Enable Cake Product** (checkbox)
   - When checked, shows configuration panel

2. **Size Pricing Table**
   ```
   | Size   | Servings | Price (€) |
   |--------|----------|-----------|
   | Small  | [6]      | [15.00]   |
   | Medium | [12]     | [20.00]   |
   | Large  | [24]     | [30.00]   |
   ```

3. **Option Pricing**
   ```
   | Option       | Price Modifier (€) |
   |--------------|-------------------|
   | Vegan        | [+3.00]           |
   | Dairy-free   | [+2.00]           |
   | Nut-free     | [+2.00]           |
   | Wheat-free   | [+2.50]           |
   | Sugar-free   | [+2.00]           |
   ```

**Save Logic:**
- Hook: `save_post_product`
- Sanitize and validate inputs
- Store as meta fields

---

### 4. Frontend UI (Product Page)

**Location:** Single product page, before "Add to Cart" button

**Components:**

1. **Size Selector**
   - Radio buttons (exactly one must be selected)
   - Display: Size name, servings, and base price
   - Example: `● Medium (12 servings) - €20.00`

2. **Options Selector**
   - Checkboxes (multiple selection allowed)
   - Display: Option name and price modifier
   - Example: `☑ Vegan (+€3.00)`

3. **Live Price Display**
   - Shows calculated total price
   - Updates in real-time via JavaScript when selections change
   - Example: `Total: €25.00`

**Template Override:**
- Create: `/wp-content/themes/organics-child/woocommerce/single-product/add-to-cart/simple.php`
- OR inject via `woocommerce_before_add_to_cart_button` action

**JavaScript:**
- File: `/wp-content/themes/organics-child/assets/js/cake-configurator.js`
- Enqueued only on single product pages where `_is_cake_product === 'yes'`
- Functionality:
  - Listen to size radio button changes
  - Listen to option checkbox changes
  - Calculate price client-side
  - Update price display
  - Validate size selection before allowing add to cart

**Styling:**
- File: `/wp-content/themes/organics-child/assets/css/cake-configurator.css`
- Match Organics theme:
  - Use theme's button styles
  - Use theme's form input styles
  - Use theme's typography
  - Ensure mobile responsiveness

---

### 5. Cart & Checkout Display

**Cart Table:**
- Display selected size under product name
- Display selected options as bullet list
- Show final calculated price

**Checkout:**
- Same display as cart

**Implementation:**
- Hook: `woocommerce_get_item_data`
- Return array of meta to display:
  ```php
  [
    ['name' => 'Size', 'value' => 'Medium (12 servings)'],
    ['name' => 'Options', 'value' => 'Vegan, Sugar-free']
  ]
  ```

---

### 6. Order Storage & Admin Display

**Order Item Meta:**

Stored permanently in database:
- `_cake_size` (e.g., `'medium'`)
- `_cake_size_label` (e.g., `'Medium (12 servings)'`)
- `_cake_options` (serialized array: `['vegan', 'sugar_free']`)
- `_cake_options_label` (e.g., `'Vegan, Sugar-free'`)
- `_cake_final_price` (e.g., `25.00`)

**Admin Order Screen:**
- Display in "Order Items" section
- Show size and options under product name

**Order Confirmation Email:**
- Automatically included via WooCommerce's order item meta display
- Shows size and options in email template

---

### 7. File Structure

All code must live in `/wp-content/themes/organics-child/`

```
organics-child/
├── functions.php (main entry point)
├── includes/
│   └── cake-product/
│       ├── admin-meta-box.php       (Product edit screen meta box)
│       ├── cart-integration.php     (Cart/checkout hooks)
│       ├── pricing-calculator.php   (Price calculation logic)
│       └── frontend-display.php     (Product page UI)
├── assets/
│   ├── css/
│   │   └── cake-configurator.css
│   └── js/
│       └── cake-configurator.js
└── woocommerce/
    └── single-product/
        └── add-to-cart/
            └── simple.php (template override, if needed)
```

**Alternative: MU-Plugin**

If functionality should be separate from theme:
```
/wp-content/mu-plugins/
└── cake-product-configurator/
    └── (same structure as above)
```

**Recommendation:** Start with child theme, migrate to mu-plugin if it becomes complex.

---

## Task Breakdown

### Task 1: Backend - Admin Meta Box
**Agent:** Backend Engineer
**Priority:** HIGH
**Dependencies:** None

**Subtasks:**
1. Create meta box UI on product edit screen
2. Add "Enable Cake Product" checkbox
3. Add size pricing table (Small/Medium/Large with price inputs)
4. Add option pricing fields (5 dietary options with price modifiers)
5. Implement save logic with sanitization and validation
6. Store data as post meta

**Acceptance Criteria:**
- [ ] Meta box appears on product edit screen
- [ ] Enabling "Cake Product" shows configuration fields
- [ ] Size prices can be set and saved
- [ ] Option modifiers can be set and saved
- [ ] Data persists correctly after saving product
- [ ] Input validation prevents negative prices or invalid data
- [ ] No PHP errors or warnings

**Files:**
- `organics-child/includes/cake-product/admin-meta-box.php`
- Updated `organics-child/functions.php` to load module

---

### Task 2: Backend - Pricing Calculation Logic
**Agent:** Backend Engineer
**Priority:** HIGH
**Dependencies:** Task 1 (needs meta structure defined)

**Subtasks:**
1. Hook into `woocommerce_add_cart_item_data` to capture POST data
2. Validate size selection (required)
3. Validate options selection (optional, but validate against defined options)
4. Calculate final price: base (size) + sum(option modifiers)
5. Store selections and price in cart item meta
6. Hook into `woocommerce_before_calculate_totals` to override cart item price
7. Hook into `woocommerce_get_item_data` to display size/options in cart
8. Hook into `woocommerce_checkout_create_order_line_item` to save to order

**Acceptance Criteria:**
- [ ] Size selection is mandatory (validation error if missing)
- [ ] Options are correctly captured (array of selected option keys)
- [ ] Price calculation is accurate
- [ ] Cart item price reflects calculated total
- [ ] Size and options display in cart and checkout
- [ ] Order stores all configuration data permanently
- [ ] No security vulnerabilities (sanitize all inputs, use nonces)

**Files:**
- `organics-child/includes/cake-product/pricing-calculator.php`
- `organics-child/includes/cake-product/cart-integration.php`

---

### Task 3: Frontend - Product Page UI
**Agent:** Frontend Designer
**Priority:** HIGH
**Dependencies:** Task 1 (needs to know data structure)

**Subtasks:**
1. Create size selector UI (radio buttons)
2. Create options selector UI (checkboxes)
3. Add price display element
4. Write JavaScript for live price calculation
5. Add client-side validation (size required before add to cart)
6. Style components to match Organics theme
7. Ensure mobile responsiveness
8. Enqueue JS/CSS only on cake product pages

**Acceptance Criteria:**
- [ ] Size selector displays all available sizes with prices
- [ ] Exactly one size can be selected (radio buttons)
- [ ] Options display with price modifiers
- [ ] Multiple options can be selected
- [ ] Price updates in real-time when selections change
- [ ] Add to cart is blocked if no size selected (with error message)
- [ ] UI matches Organics theme style (buttons, fonts, colors)
- [ ] UI is responsive on mobile devices
- [ ] No JavaScript console errors
- [ ] Graceful degradation if JS disabled (server-side validation still works)

**Files:**
- `organics-child/includes/cake-product/frontend-display.php`
- `organics-child/assets/js/cake-configurator.js`
- `organics-child/assets/css/cake-configurator.css`

---

### Task 4: Backend - Order & Email Display
**Agent:** Backend Engineer
**Priority:** MEDIUM
**Dependencies:** Task 2 (needs order meta structure)

**Subtasks:**
1. Ensure order item meta is saved with human-readable labels
2. Verify display in WooCommerce order admin screen
3. Verify display in customer order confirmation email
4. Test display in "My Account" order history

**Acceptance Criteria:**
- [ ] Order admin shows selected size and options
- [ ] Order confirmation email shows configuration
- [ ] Customer can see configuration in order history
- [ ] Data is permanently stored (not session-dependent)

**Files:**
- Updates to `organics-child/includes/cake-product/cart-integration.php`

---

### Task 5: Frontend - Theme Integration & Styling
**Agent:** Frontend Designer
**Priority:** MEDIUM
**Dependencies:** Task 3 (UI components exist)

**Subtasks:**
1. Analyze Organics theme's design system (colors, fonts, spacing)
2. Match button styles
3. Match form input styles
4. Match typography
5. Test on various screen sizes
6. Test with Organics theme's existing product page layout

**Acceptance Criteria:**
- [ ] Cake configurator looks native to Organics theme
- [ ] No visual inconsistencies
- [ ] Works with theme's existing product page structure
- [ ] No CSS conflicts
- [ ] Accessible (WCAG AA compliant for forms)

**Files:**
- `organics-child/assets/css/cake-configurator.css`

---

### Task 6: Testing & Validation
**Agent:** Validator
**Priority:** HIGH
**Dependencies:** All above tasks

**Test Scenarios:**

1. **Product Configuration (Admin)**
   - [ ] Can enable cake product on simple product
   - [ ] Can set size prices
   - [ ] Can set option modifiers
   - [ ] Changes persist after save

2. **Product Page (Frontend)**
   - [ ] Size selector displays correctly
   - [ ] Options selector displays correctly
   - [ ] Price updates when selections change
   - [ ] Validation prevents add to cart without size

3. **Cart**
   - [ ] Product shows selected size
   - [ ] Product shows selected options
   - [ ] Price is correct
   - [ ] Can change quantity
   - [ ] Can remove from cart

4. **Checkout**
   - [ ] Configuration is visible
   - [ ] Price is correct
   - [ ] Order can be completed

5. **Order (Admin)**
   - [ ] Order item shows size and options
   - [ ] Price matches calculation

6. **Order Confirmation Email**
   - [ ] Email shows size and options
   - [ ] Price is correct

7. **Edge Cases**
   - [ ] No size selected → validation error
   - [ ] No options selected → works (options optional)
   - [ ] All options selected → correct price
   - [ ] Large price modifiers → display correctly
   - [ ] Decimal prices → no rounding errors

**Files:**
- Validation report document

---

### Task 7: Documentation
**Agent:** Documenter
**Priority:** MEDIUM
**Dependencies:** All implementation tasks complete

**Deliverables:**

1. **User Guide:** How to configure a cake product (admin)
2. **Technical Documentation:** Architecture, hooks used, file structure
3. **CHANGELOG Entry:** Feature addition
4. **Maintenance Guide:** How to add new sizes, modify options, change pricing

**Acceptance Criteria:**
- [ ] `/docs/CHANGELOG.md` updated
- [ ] Architecture documented in `/docs/`
- [ ] Admin user guide created
- [ ] Code is commented where complex logic exists

**Files:**
- `/docs/CHANGELOG.md`
- `/docs/features/cake-product-configurator.md`
- Updated comments in PHP files

---

## Risks & Edge Cases

### Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| WooCommerce updates break hooks | HIGH | Use stable, well-documented hooks; test after WC updates |
| Theme updates override child theme | MEDIUM | Keep all code in child theme; document template overrides |
| Cart session data loss | HIGH | Store minimal data in session, recalculate from product meta if needed |
| Price calculation errors (floating point) | MEDIUM | Use WooCommerce price functions (`wc_format_decimal`) |
| Security: malicious POST data | HIGH | Sanitize all inputs, validate against product meta, use nonces |
| Performance: too many meta queries | LOW | Cache product meta, use transients if needed |

### Edge Cases

| Case | Handling |
|------|----------|
| Product is cake, but has no sizes defined | Validation: Don't allow enabling cake if sizes not defined |
| User selects size, changes mind to different product | Standard WC behavior: cart item is separate |
| Admin changes prices after order placed | Order stores final price, not recalculated (intentional) |
| Currency symbol formatting | Use WooCommerce functions (`wc_price()`) |
| Decimal rounding | Use 2 decimal places consistently |
| Product is cake AND on sale | Cake price overrides; sale price ignored (document this) |
| Product is cake AND has product add-ons (other plugins) | Potential conflict; test and document compatibility |
| JavaScript disabled | Server-side validation ensures size is selected; no live price update |
| Mobile device touch interactions | Ensure radio/checkbox are touch-friendly |

### Business Logic Edge Cases

| Case | Decision Needed |
|------|----------------|
| Can admin disable cake after orders exist? | YES, but existing orders preserve data |
| Can admin change size prices after orders? | YES, but existing orders keep original price |
| What if product price field is also set? | Ignore base product price, use size price (document) |
| Can a product be BOTH cake and variable product? | NO, only simple products (validate) |
| Should cake config apply to product variations? | NO, current scope is simple products only |

---

## Dependencies

### External
- WordPress (assumed latest stable)
- WooCommerce (assumed 8.x or 9.x)
- Organics theme (parent)
- jQuery (for JavaScript functionality)

### Internal
- Child theme must be active
- WooCommerce must be active
- Simple product type must be used

---

## Performance Considerations

1. **Meta queries:** Minimal impact (1 product at a time)
2. **JavaScript:** Load only on cake product pages (conditional enqueue)
3. **CSS:** Inline critical CSS or combine with theme styles
4. **Database:** No new tables needed (uses existing `wp_postmeta`, `wp_woocommerce_order_itemmeta`)
5. **Caching:** Use WP object cache for product meta if available

---

## Security Checklist

- [ ] All POST data sanitized (`sanitize_text_field`, `floatval`, etc.)
- [ ] Nonces used for admin saves
- [ ] Capability checks (`current_user_can('edit_products')`)
- [ ] Validate selections against actual product meta (prevent price manipulation)
- [ ] Escape output (`esc_html`, `esc_attr`, `wp_kses`)
- [ ] No SQL injection risk (use WP meta APIs)
- [ ] No XSS risk (escape all user input)

---

## Extensibility Considerations

Future enhancements that this architecture supports:

1. **Custom messages on cake** (new meta field + textarea)
2. **Delivery date selection** (new meta field + date picker)
3. **Image upload for custom design** (media upload field)
4. **Different size options per product** (already supported)
5. **Regional pricing** (extend options array with currency)
6. **Recipe selection** (new meta field + dropdown)

Current implementation should not block these additions.

---

## Recommended Implementation Order

1. **Backend Engineer** → Task 1 (Admin meta box)
2. **Backend Engineer** → Task 2 (Pricing logic)
3. **Frontend Designer** → Task 3 (Product page UI) [can start after Task 1]
4. **Backend Engineer** → Task 4 (Order display)
5. **Frontend Designer** → Task 5 (Theme styling) [can run parallel with Task 4]
6. **Validator** → Task 6 (Testing)
7. **Documenter** → Task 7 (Documentation)

Tasks 3 and 4 can overlap once data structure is defined.

---

## Questions Requiring Immediate Answers

Before implementation begins, confirm:

1. **Option price modifiers:** Are they the same for all products, or per-product?
   - If global: Store in options table
   - If per-product: Store in product meta (current recommendation)

2. **Size servings:** Are these fixed (6, 12, 24) or should admin be able to customize?
   - Current design: Fixed labels in UI, admin sets prices only
   - Alternative: Make servings editable fields

3. **Maximum number of options:** Fixed at 5, or should admin be able to add more?
   - Current design: Fixed 5 (Vegan, Dairy-free, Nut-free, Wheat-free, Sugar-free)
   - Alternative: Dynamic option builder

**Recommendation:** Proceed with current assumptions (per-product pricing, fixed sizes, fixed 5 options) and design for easy extension later.

---

## Conclusion

This feature is **feasible and well-scoped** for the multi-agent system.

**Complexity:** High (requires coordination across backend, frontend, and WooCommerce)
**Risk:** Medium (depends on WooCommerce stability and theme compatibility)
**Effort:** ~7 tasks across 4 agents

**Ready for implementation:** YES (after confirming questions above)

---

## Next Steps

1. **Orchestrator:** Review this analysis
2. **Stakeholder:** Answer questions in "Questions Requiring Immediate Answers"
3. **Backend Engineer:** Begin Task 1 (Admin meta box)
4. **Frontend Designer:** Study Organics theme design system (prepare for Task 3)
5. **Orchestrator:** Update work tracker at `/docs/work/2026-01-11-custom-cake-product-type.md`

---

**Analysis Status:** ✅ Complete
**Approved by:** [Pending Orchestrator review]
**Implementation Start:** [Pending approval]
