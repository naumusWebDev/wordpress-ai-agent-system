# Cake Product Configurator

**Version:** 1.1.0
**Date:** 2026-01-12
**Status:** Production Ready
**Requirement:** `/docs/requirements/CustomCakeProductType.md`

---

## Overview

The Cake Product Configurator is a complete WooCommerce product customization system that allows customers to configure cakes with:
- **Size selection** (Small/Medium/Large) with different base prices
- **Dietary options** (Vegan, Dairy-free, etc.) with price modifiers
- **Live price calculation** showing total price as selections change
- **Full persistence** through cart, checkout, orders, and emails

---

## Features

### For Customers
- Visual size selector with servings information
- Checkbox-based dietary options
- Live price updates as they configure
- Validation prevents incomplete orders
- Mobile-responsive interface
- Accessible keyboard navigation

### For Store Admins
- Easy product configuration via meta box
- Fixed sizes (Small=6, Medium=12, Large=24 servings)
- Custom price per size
- Dynamic dietary options (add/remove as needed)
- Per-product option pricing
- Configuration visible in order admin

### For Developers
- Hook-based architecture
- Update-safe (no core/theme modifications)
- Modular file structure
- Extensible via WordPress filters/actions
- Well-documented codebase

---

## User Guide (Store Admins)

### Creating a Cake Product

1. **Create New Product**
   - Go to: `Products > Add New`
   - Enter title, description, images as normal
   - Set Product Data type: **Simple product**
   - Set a base price (will be overridden by size selection)

2. **Enable Cake Configuration**
   - Scroll to: **Cake Product Configuration** meta box
   - Check: ✅ **Enable Cake Product Configuration**
   - Configuration panel will slide down

3. **Configure Sizes**
   - Size labels are fixed: Small (6), Medium (12), Large (24 servings)
   - Enter prices for each size:
     - Small Price: `15.00`
     - Medium Price: `25.00`
     - Large Price: `45.00`

4. **Configure Dietary Options**
   - Default options appear: Vegan, Dairy-free, Nut-free, Wheat-free, Sugar-free
   - Adjust price modifiers (can be positive or zero):
     - Vegan: `5.00` (adds €5)
     - Dairy-free: `3.00` (adds €3)
     - Nut-free: `2.50` (adds €2.50)
     - Wheat-free: `3.50` (adds €3.50)
     - Sugar-free: `4.00` (adds €4)
   - **Add Custom Options**: Click "+ Add Option"
     - Label: `Organic Ingredients`
     - Price Modifier: `8.00`
   - **Remove Options**: Click "×" button next to any option

5. **Publish**
   - Click: **Publish** (or **Update**)
   - View product page to verify configurator appears

### Managing Existing Cake Products

- Edit any product with cake configuration enabled
- Modify prices or options as needed
- Changes apply immediately to frontend
- **Note**: Existing orders are not affected by price changes

### Viewing Orders

When a customer orders a configured cake:
- **Order Admin**: Shows "Size: Medium (12 servings)" and "Dietary Options: Vegan, Sugar-free"
- **Order Emails**: Configuration included in line item details
- **Customer Account**: Configuration visible in order history

---

## Technical Documentation

### Architecture

```
wp-content/themes/organics-child/
├── functions.php (loads modules)
└── includes/
    └── cake-product/
        ├── admin-meta-box.php        (Admin UI)
        ├── cart-integration.php      (Cart/Orders)
        ├── frontend-display.php      (Product page UI)
        └── assets/
            ├── admin-cake-meta-box.js
            ├── admin-cake-meta-box.css
            ├── cake-configurator.js
            └── cake-configurator.css
```

### Data Model

#### Product Meta Fields

```php
// Enable/disable flag
_is_cake_product: 'yes' | 'no'

// Size configuration
_cake_sizes: [
    'small' => [
        'servings' => 6,
        'price' => 15.00
    ],
    'medium' => [
        'servings' => 12,
        'price' => 25.00
    ],
    'large' => [
        'servings' => 24,
        'price' => 45.00
    ]
]

// Dynamic dietary options
_cake_options: [
    [
        'key' => 'vegan',
        'label' => 'Vegan',
        'modifier' => 5.00
    ],
    [
        'key' => 'dairy-free',
        'label' => 'Dairy-free',
        'modifier' => 3.00
    ],
    // ... more options
]
```

#### Cart Item Meta

```php
[
    'cake_size' => 'medium',                      // Selected size key
    'cake_options' => ['vegan', 'sugar-free'],    // Selected option keys
    'cake_final_price' => 34.00,                  // Calculated price
    'unique_key' => 'md5_hash_of_config',         // Uniqueness key
]
```

#### Order Item Meta

```php
// Same as cart meta, plus display-ready labels
'Size' => 'Medium (12 servings)'
'Dietary Options' => 'Vegan, Sugar-free'
'_cake_size' => 'medium'                // Hidden (for programmatic access)
'_cake_options' => ['vegan', 'sugar-free']  // Hidden
```

### Pricing Logic

```php
/**
 * Pricing Formula
 *
 * Final Price = Base Price (from selected size)
 *             + Σ(Price modifiers from selected options)
 */

// Example Calculation:
// Size: Medium (€25.00)
// Options: Vegan (+€5.00) + Sugar-free (+€4.00)
// Final Price = €25.00 + €5.00 + €4.00 = €34.00
```

**Security**: Price is ALWAYS recalculated server-side. Client-submitted prices are ignored.

### WooCommerce Hooks Reference

#### Admin Hooks

```php
// Register meta box
add_action( 'add_meta_boxes', 'organics_child_add_cake_meta_box' );

// Save meta box data
add_action( 'save_post_product', 'organics_child_save_cake_meta_box' );

// Enqueue admin assets
add_action( 'admin_enqueue_scripts', 'organics_child_enqueue_cake_admin_assets' );
```

#### Frontend Hooks

```php
// Display configurator UI
add_action( 'woocommerce_before_add_to_cart_button',
    'organics_child_display_cake_configurator', 10 );

// Enqueue frontend assets
add_action( 'wp_enqueue_scripts',
    'organics_child_enqueue_cake_frontend_assets' );

// Validation
add_filter( 'woocommerce_add_to_cart_validation',
    'organics_child_validate_cake_add_to_cart', 10, 2 );
```

#### Cart Hooks

```php
// Capture configuration when adding to cart
add_filter( 'woocommerce_add_cart_item_data',
    'organics_child_add_cake_data_to_cart', 10, 3 );

// Override cart item price
add_action( 'woocommerce_before_calculate_totals',
    'organics_child_set_cake_cart_item_price', 10, 1 );

// Display configuration in cart
add_filter( 'woocommerce_get_item_data',
    'organics_child_display_cake_cart_item_data', 10, 2 );
```

#### Order Hooks

```php
// Save configuration to order
add_action( 'woocommerce_checkout_create_order_line_item',
    'organics_child_save_cake_order_item_meta', 10, 4 );
```

### JavaScript API

#### Frontend Configurator (cake-configurator.js)

```javascript
var CakeConfigurator = {
    config: {
        sizes: {...},      // From PHP
        options: [...],    // From PHP
        currency_symbol: '€',
        currency_position: 'left'
    },

    selectedSize: null,
    selectedOptions: [],

    // Calculate total price
    calculatePrice: function() {
        var basePrice = this.config.sizes[this.selectedSize].price;
        var optionsPrice = 0;

        this.selectedOptions.forEach(function(optionKey) {
            var option = this.findOption(optionKey);
            if (option) {
                optionsPrice += parseFloat(option.modifier);
            }
        }.bind(this));

        return basePrice + optionsPrice;
    },

    // Update price display
    updatePriceDisplay: function() {
        var totalPrice = this.calculatePrice();
        var formattedPrice = this.formatPrice(totalPrice);
        $('#cake-total-price').html(formattedPrice);
    },

    // Validate before submit
    validateSelection: function() {
        if (!this.selectedSize) {
            $('.cake-size-error').slideDown();
            return false;
        }
        return true;
    }
};
```

### CSS Styling

The configurator uses the Organics theme design system:

```css
/* Theme Colors */
--primary-text: #222222;
--accent-green: #7fb77e;
--background: #f4f7f9;
--border: #e6e9eb;
--error: #da6f5b;

/* Design Patterns */
border-radius: 4px;
transition: all 0.3s ease;

/* Animations */
@keyframes cakePulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.03); }
    100% { transform: scale(1); }
}
```

---

## Extension Guide

### Adding Custom Validation

```php
/**
 * Add custom validation rule
 */
add_filter( 'woocommerce_add_to_cart_validation', 'my_custom_cake_validation', 20, 2 );

function my_custom_cake_validation( $passed, $product_id ) {
    $is_cake_product = get_post_meta( $product_id, '_is_cake_product', true );

    if ( 'yes' !== $is_cake_product ) {
        return $passed;
    }

    // Example: Prevent ordering vegan + dairy-free together
    if ( isset( $_POST['cake_options'] ) && is_array( $_POST['cake_options'] ) ) {
        $options = $_POST['cake_options'];

        if ( in_array( 'vegan', $options ) && in_array( 'dairy-free', $options ) ) {
            wc_add_notice( __( 'Vegan option already includes dairy-free.', 'my-theme' ), 'error' );
            return false;
        }
    }

    return $passed;
}
```

### Modifying Price Calculation

```php
/**
 * Apply volume discount to large cakes
 */
add_filter( 'organics_child_cake_final_price', 'my_cake_volume_discount', 10, 3 );

function my_cake_volume_discount( $final_price, $size, $options ) {
    // 10% discount on large cakes
    if ( 'large' === $size ) {
        $final_price = $final_price * 0.9;
    }

    return $final_price;
}
```

**Note**: This filter doesn't exist yet. You would need to add it to `cart-integration.php`:

```php
// In organics_child_add_cake_data_to_cart() function
$final_price = apply_filters( 'organics_child_cake_final_price',
    $final_price, $size_key, $selected_options );
```

### Adding Custom Display in Cart

```php
/**
 * Add custom cart item display
 */
add_filter( 'woocommerce_get_item_data', 'my_custom_cake_cart_display', 20, 2 );

function my_custom_cake_cart_display( $item_data, $cart_item ) {
    if ( ! isset( $cart_item['cake_size'] ) ) {
        return $item_data;
    }

    // Add estimated preparation time
    $prep_times = [
        'small' => '2 hours',
        'medium' => '3 hours',
        'large' => '4 hours'
    ];

    $item_data[] = [
        'name' => __( 'Preparation Time', 'my-theme' ),
        'value' => $prep_times[ $cart_item['cake_size'] ]
    ];

    return $item_data;
}
```

---

## Troubleshooting

### Configurator Doesn't Appear

**Symptoms**: Meta box visible in admin, but configurator not showing on product page

**Checklist**:
1. ✅ Check: Child theme "Organics Child" is active
2. ✅ Check: Product has "Enable Cake Product" checkbox checked
3. ✅ Check: Product type is "Simple Product" (not Variable)
4. ✅ Check: At least one size has a price set
5. ✅ Try: Hard refresh page (Ctrl+F5 or Cmd+Shift+R)
6. ✅ Check: Browser console for JavaScript errors (F12)

**Debug Code**:
```php
// Add to functions.php temporarily
add_action( 'wp_footer', function() {
    global $product;
    if ( $product ) {
        $is_cake = get_post_meta( $product->get_id(), '_is_cake_product', true );
        echo '<!-- Debug: is_cake_product = ' . $is_cake . ' -->';
    }
});
```

### Price Not Updating

**Symptoms**: Configurator shows but price doesn't change when selecting

**Checklist**:
1. ✅ Open browser console (F12) and check for JavaScript errors
2. ✅ Verify jQuery is loaded: Type `jQuery` in console, should not be "undefined"
3. ✅ Clear browser cache
4. ✅ Disable browser extensions (ad blockers can interfere)
5. ✅ Check that sizes have valid prices in product meta box

**Debug Code**:
```javascript
// Paste in browser console to test
console.log('Config:', CakeConfigurator.config);
console.log('Selected size:', CakeConfigurator.selectedSize);
console.log('Price:', CakeConfigurator.calculatePrice());
```

### Cart Shows Wrong Price

**Symptoms**: Configurator shows correct price but cart shows different amount

**Cause**: This should NEVER happen due to server-side recalculation

**Fix**:
1. Check product configuration has correct prices
2. Clear cart and re-add item
3. Check for conflicting plugins that modify cart prices
4. Check error logs: `/wp-content/debug.log`

**Debug Code**:
```php
// Add to cart-integration.php temporarily in organics_child_add_cake_data_to_cart()
error_log( 'Cake Price Debug: ' . print_r( [
    'size' => $size_key,
    'base_price' => $base_price,
    'options_price' => $options_price,
    'final_price' => $final_price
], true ) );
```

### Configuration Not Showing in Orders

**Symptoms**: Order placed but configuration not visible in admin/emails

**Checklist**:
1. ✅ Check: Order item meta in database (`wp_woocommerce_order_itemmeta`)
2. ✅ Check: Email template cache (regenerate if using custom templates)
3. ✅ Test: Create new test order

**Database Query**:
```sql
-- Check order item meta
SELECT * FROM wp_woocommerce_order_itemmeta
WHERE meta_key IN ('Size', 'Dietary Options', '_cake_size', '_cake_options')
ORDER BY order_item_id DESC
LIMIT 20;
```

### Meta Box Not Saving

**Symptoms**: Set configuration but disappears after saving product

**Checklist**:
1. ✅ Check: User has `edit_product` capability
2. ✅ Check: No JavaScript errors on product edit screen
3. ✅ Check: Nonce field is present in HTML
4. ✅ Check: PHP error logs

**Debug Code**:
```php
// Add to admin-meta-box.php temporarily in organics_child_save_cake_meta_box()
error_log( 'Saving cake meta: ' . print_r( $_POST, true ) );
```

---

## Performance Considerations

### Asset Loading

Assets are loaded **conditionally** only on cake product pages:

```php
function organics_child_enqueue_cake_frontend_assets() {
    // Only on single product pages
    if ( ! is_product() ) {
        return;
    }

    // Only if product is a cake product
    $is_cake_product = get_post_meta( get_the_ID(), '_is_cake_product', true );
    if ( 'yes' !== $is_cake_product ) {
        return;
    }

    // Now load assets
    wp_enqueue_script( ... );
    wp_enqueue_style( ... );
}
```

This prevents unnecessary HTTP requests on non-cake product pages.

### Database Queries

The system adds **3 meta queries** per cake product:
- `_is_cake_product`
- `_cake_sizes`
- `_cake_options`

These are cached by WordPress object cache. On high-traffic sites, consider:
1. Using persistent object cache (Redis, Memcached)
2. Caching product configuration in transients

### Cart Performance

Each cart item with different configuration is stored separately. This is intentional to prevent merging items with different configs, but it means:
- More cart items = more database rows
- Cart calculations run for each unique configuration

This is standard WooCommerce behavior and should not cause issues.

---

## Security

### Input Validation

All user input is validated and sanitized:

```php
// Size validation
$size_key = isset( $_POST['cake_size'] ) ? sanitize_key( $_POST['cake_size'] ) : '';

// Options validation
$selected_options = isset( $_POST['cake_options'] ) && is_array( $_POST['cake_options'] )
    ? array_map( 'sanitize_key', $_POST['cake_options'] )
    : [];

// Price recalculation (never trust client)
$base_price = floatval( $sizes[ $size_key ]['price'] );
```

### Output Escaping

All output is escaped appropriately:

```php
// HTML content
echo esc_html( $option_label );

// HTML attributes
echo esc_attr( $size_key );

// JSON data
echo esc_attr( wp_json_encode( $js_data ) );

// Prices (use WooCommerce function)
echo wc_price( $price );
```

### Nonce Protection

All admin saves use WordPress nonces:

```php
// Generate nonce
wp_nonce_field( 'organics_cake_product_meta_box', 'organics_cake_product_nonce' );

// Verify nonce
if ( ! isset( $_POST['organics_cake_product_nonce'] ) ||
     ! wp_verify_nonce( $_POST['organics_cake_product_nonce'], 'organics_cake_product_meta_box' ) ) {
    return;
}
```

### Capability Checks

Only users with proper capabilities can edit:

```php
if ( ! current_user_can( 'edit_product', $post_id ) ) {
    return;
}
```

### Price Manipulation Prevention

The system NEVER trusts client-submitted prices:

```php
// Client sends: cake_size = 'medium'
// Server recalculates: base_price = $sizes['medium']['price']
// Client-submitted prices are completely ignored
```

This prevents malicious users from modifying prices via browser dev tools.

---

## Testing

### Manual Testing Checklist

See `/docs/work/2026-01-11-validation-testing-guide.md` for comprehensive 35-test checklist covering:
- Product configuration (admin)
- Frontend display
- Price calculations
- Cart integration
- Checkout process
- Order persistence
- Email notifications
- Edge cases
- Security
- Performance

### Quick Smoke Test

```
1. Create cake product ✓
2. Set sizes and options ✓
3. Save product ✓
4. View product page ✓
5. Select size + options ✓
6. Verify price updates ✓
7. Add to cart ✓
8. View cart ✓
9. Checkout ✓
10. Check order admin ✓
```

**Time**: ~5 minutes

---

## Changelog

### v1.1.1 - 2026-01-15
- **Fixed**: Dietary options price not summing in frontend
  - Bug: `updateSelectedOptions()` had JavaScript `this` context issue
  - Fix: Changed from `.bind(this)` to `var self = this` closure pattern

### v1.1.0 - 2026-01-12
- Matched Organics theme styling
- Updated colors, typography, spacing
- Added pulse animation on selection
- Enhanced accessibility
- Added print styles

### v1.0.0 - 2026-01-11
- Initial release
- Admin meta box with dynamic options
- Frontend configurator with live price
- Cart and order integration
- Complete WooCommerce integration

---

## Credits

**Developed by**: Multi-Agent System
**Agents**: Analyzer, Backend Engineer, Frontend Designer, Documenter
**Date**: 2026-01-11 to 2026-01-12
**Repository**: wordpress-ai-sample
**Theme**: Organics Child (based on Organics v1.6.12)

---

## Support

For issues, questions, or feature requests:
1. Check this documentation
2. Review troubleshooting section
3. Check work reports in `/docs/work/`
4. Review validation guide
5. Contact development team

---

## License

This feature is part of the wordpress-ai-sample project.
All code follows WordPress and WooCommerce licensing.
