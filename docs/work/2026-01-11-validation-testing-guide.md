# Cake Product Feature - Validation Testing Guide

**Date:** 2026-01-11
**Agent:** Validator
**Status:** Testing in Progress

---

## Pre-Testing Checklist

Before starting, verify:
- ✅ Child theme "Organics Child" is active
- ✅ WooCommerce is installed and active
- ✅ At least one simple product exists
- ✅ All cake product files are in place (7 files)

---

## TEST SUITE 1: Admin Configuration

### Test 1.1: Meta Box Appears
**Steps:**
1. Go to WordPress Admin
2. Navigate to: **Products > All Products**
3. Click **Edit** on any simple product
4. Scroll down below the product editor

**Expected Result:**
- ✅ You should see a meta box titled **"Cake Product Configuration"**
- ✅ Meta box contains checkbox: "Enable Cake Product Configuration"

**Screenshot Location:** `docs/requirements/test-1.1-meta-box-visible.png`

---

### Test 1.2: Enable Cake Product
**Steps:**
1. Check the box: **"Enable Cake Product Configuration"**

**Expected Result:**
- ✅ Configuration panel slides down (smooth animation)
- ✅ Panel shows:
  - "Cake Sizes & Pricing" section with 3 rows (Small, Medium, Large)
  - "Dietary Options" section with example options
  - "+ Add Option" button

**Screenshot Location:** `docs/requirements/test-1.2-config-panel-open.png`

---

### Test 1.3: Configure Sizes
**Steps:**
1. In the "Cake Sizes & Pricing" table, enter prices:
   - Small: `15.00`
   - Medium: `20.00`
   - Large: `30.00`

**Expected Result:**
- ✅ Inputs accept decimal numbers
- ✅ Currency symbol (€) is visible in table header

---

### Test 1.4: Configure Options
**Steps:**
1. You should see 5 default option rows:
   - Vegan: 3.00
   - Dairy-free: 2.00
   - Nut-free: 2.00
   - Wheat-free: 2.50
   - Sugar-free: 2.00
2. Click **"+ Add Option"** button
3. In the new row, enter:
   - Label: `Organic`
   - Price Modifier: `5.00`

**Expected Result:**
- ✅ New row appears with empty inputs
- ✅ Can type in both fields
- ✅ "Remove" button appears on the new row

---

### Test 1.5: Remove Option
**Steps:**
1. Click **"Remove"** button on the "Organic" option you just added
2. Click **OK** in the confirmation dialog

**Expected Result:**
- ✅ Confirmation dialog appears
- ✅ Row fades out and disappears

---

### Test 1.6: Save Product
**Steps:**
1. Click **"Update"** button (top right)
2. Wait for "Product updated" message
3. Reload the page (F5 or Ctrl+R)

**Expected Result:**
- ✅ "Product updated" success message appears
- ✅ After reload:
  - "Enable Cake Product" checkbox is still checked
  - Size prices are preserved (15.00, 20.00, 30.00)
  - Options are preserved (5 default options)
  - "Organic" option is gone (we removed it)

**Screenshot Location:** `docs/requirements/test-1.6-data-persisted.png`

---

## TEST SUITE 2: Frontend Product Page

### Test 2.1: View Product Page
**Steps:**
1. While still editing the product, click **"View Product"** (top admin bar)
   OR
2. Go to frontend: `http://organicstore.local` and find the product

**Expected Result:**
- ✅ Product page loads normally
- ✅ Below product description, above "Add to Cart" button, you see:
  - **"Cake Configurator"** section
  - Section has light gray background
  - Section contains "Select Size" heading
  - Section contains "Dietary Options" heading
  - Section contains "Total Price" display

**Screenshot Location:** `docs/requirements/test-2.1-frontend-configurator.png`

---

### Test 2.2: Size Selector Display
**Steps:**
1. Look at the "Select Size" section

**Expected Result:**
- ✅ You see 3 size cards in a row (or stacked on mobile)
- ✅ Each card shows:
  - Size name (Small, Medium, Large)
  - Servings (6 servings, 12 servings, 24 servings)
  - Price (€15.00, €20.00, €30.00)
- ✅ Cards have white background with border
- ✅ Red asterisk (*) next to "Select Size" (indicates required)

---

### Test 2.3: Size Selection - Hover
**Steps:**
1. Hover your mouse over the "Medium" size card

**Expected Result:**
- ✅ Card border changes to green
- ✅ Card has slight shadow effect
- ✅ Cursor changes to pointer (hand)

---

### Test 2.4: Size Selection - Click
**Steps:**
1. Click on the "Medium" size card

**Expected Result:**
- ✅ Card gets green border
- ✅ Card background changes to light green
- ✅ Radio button is selected (visual indicator)
- ✅ "Total Price" display updates to: **€20.00** (in green, bold)

**Screenshot Location:** `docs/requirements/test-2.4-size-selected.png`

---

### Test 2.5: Options Selector Display
**Steps:**
1. Scroll down to "Dietary Options" section

**Expected Result:**
- ✅ You see 5 option rows (Vegan, Dairy-free, Nut-free, Wheat-free, Sugar-free)
- ✅ Each row has:
  - Checkbox on the left
  - Option label
  - Price modifier (e.g., "+€3.00")
- ✅ "(optional)" text next to "Dietary Options" heading

---

### Test 2.6: Select Single Option
**Steps:**
1. Check the "Vegan" checkbox

**Expected Result:**
- ✅ Checkbox becomes checked
- ✅ "Total Price" updates to: **€23.00** (20 + 3)

**Screenshot Location:** `docs/requirements/test-2.6-option-selected.png`

---

### Test 2.7: Select Multiple Options
**Steps:**
1. Keep "Vegan" checked
2. Also check "Sugar-free"

**Expected Result:**
- ✅ Both checkboxes are checked
- ✅ "Total Price" updates to: **€25.00** (20 + 3 + 2)

**Screenshot Location:** `docs/requirements/test-2.7-multiple-options.png`

---

### Test 2.8: Change Size After Options
**Steps:**
1. Keep "Vegan" and "Sugar-free" checked
2. Click the "Large" size card

**Expected Result:**
- ✅ "Large" card becomes selected (green)
- ✅ "Medium" card deselects
- ✅ "Total Price" updates to: **€35.00** (30 + 3 + 2)
- ✅ Options remain checked

---

### Test 2.9: Uncheck Options
**Steps:**
1. Uncheck "Vegan"
2. Keep "Sugar-free" checked

**Expected Result:**
- ✅ "Total Price" updates to: **€32.00** (30 + 2)

---

### Test 2.10: Deselect All (No Size)
**Steps:**
1. Click on the currently selected size card again to try to deselect
   (Note: Radio buttons can't be deselected in HTML, so this won't work)
2. Reload the page to reset

**Expected Result:**
- ✅ After reload, no size is selected
- ✅ "Total Price" shows: "Select a size" (in gray, italic)
- ✅ No options are checked

---

## TEST SUITE 3: Add to Cart Validation

### Test 3.1: Try Adding Without Size
**Steps:**
1. Make sure NO size is selected (reload page if needed)
2. Scroll down to "Add to Cart" button
3. Click **"Add to Cart"**

**Expected Result:**
- ✅ Page does NOT reload/redirect
- ✅ Error message appears: "Please select a size before adding to cart"
- ✅ Error message is in red/orange color
- ✅ Product is NOT added to cart
- ✅ Page scrolls to the error message

**Screenshot Location:** `docs/requirements/test-3.1-validation-error.png`

---

### Test 3.2: Add with Size Only (No Options)
**Steps:**
1. Select "Small" size (€15.00)
2. Do NOT check any options
3. Ensure "Total Price" shows: **€15.00**
4. Click **"Add to Cart"**

**Expected Result:**
- ✅ Success message appears: "Product added to cart" (or similar)
- ✅ Cart icon/counter updates (shows "1")
- ✅ No error message

**Screenshot Location:** `docs/requirements/test-3.2-added-size-only.png`

---

## TEST SUITE 4: Cart Display

### Test 4.1: View Cart
**Steps:**
1. After adding to cart, click **"View Cart"** or navigate to cart page
   URL: `http://organicstore.local/cart`

**Expected Result:**
- ✅ Product appears in cart table
- ✅ Under product name, you see:
  - **Size: Small (6 servings)**
  - **Dietary Options: None**
- ✅ Product price shows: **€15.00**
- ✅ Subtotal: **€15.00**

**Screenshot Location:** `docs/requirements/test-4.1-cart-size-only.png`

---

### Test 4.2: Add Same Product with Different Config
**Steps:**
1. Go back to the product page
2. Select "Medium" size (€20.00)
3. Check "Vegan" (+€3.00) and "Sugar-free" (+€2.00)
4. Verify "Total Price" shows: **€25.00**
5. Click **"Add to Cart"**

**Expected Result:**
- ✅ Success message
- ✅ Cart counter shows "2"

---

### Test 4.3: View Cart Again (Two Items)
**Steps:**
1. Go to cart page

**Expected Result:**
- ✅ Cart shows TWO separate line items:

**Item 1:**
- Size: Small (6 servings)
- Dietary Options: None
- Price: €15.00
- Quantity: 1

**Item 2:**
- Size: Medium (12 servings)
- Dietary Options: Vegan, Sugar-free
- Price: €25.00
- Quantity: 1

- ✅ Cart subtotal: **€40.00** (15 + 25)

**Screenshot Location:** `docs/requirements/test-4.3-cart-two-configs.png`

---

### Test 4.4: Update Quantity
**Steps:**
1. Change quantity of Item 2 (Medium, Vegan, Sugar-free) to **2**
2. Click **"Update Cart"**

**Expected Result:**
- ✅ Quantity updates to 2
- ✅ Item 2 subtotal: **€50.00** (25 × 2)
- ✅ Cart total: **€65.00** (15 + 50)
- ✅ Configuration (Size, Options) still visible

---

### Test 4.5: Remove Item
**Steps:**
1. Click the "×" (remove) button on Item 1 (Small, None)

**Expected Result:**
- ✅ Item 1 is removed
- ✅ Cart now shows only Item 2
- ✅ Cart total: **€50.00**

---

## TEST SUITE 5: Checkout

### Test 5.1: Proceed to Checkout
**Steps:**
1. Click **"Proceed to Checkout"** button
2. Fill in billing details:
   - First Name: `Test`
   - Last Name: `User`
   - Email: `test@example.com`
   - Address: `123 Test St`
   - City: `Test City`
   - Postcode: `12345`

**Expected Result:**
- ✅ Checkout page loads
- ✅ Order review section shows:
  - Product name
  - **Size: Medium (12 servings)**
  - **Dietary Options: Vegan, Sugar-free**
  - Price: **€25.00**
  - Quantity: 2
  - Subtotal: **€50.00**

**Screenshot Location:** `docs/requirements/test-5.1-checkout-display.png`

---

### Test 5.2: Place Order
**Steps:**
1. Scroll to bottom of checkout page
2. Click **"Place Order"**

**Expected Result:**
- ✅ Page redirects to "Order Received" page
- ✅ Success message: "Thank you. Your order has been received."
- ✅ Order number is displayed (e.g., #123)

**Screenshot Location:** `docs/requirements/test-5.2-order-received.png`

---

## TEST SUITE 6: Order Details

### Test 6.1: View Order on Thank You Page
**Steps:**
1. On the "Order Received" page, look at order details

**Expected Result:**
- ✅ Order details table shows:
  - Product name × 2
  - **Size: Medium (12 servings)**
  - **Dietary Options: Vegan, Sugar-free**
  - Total: **€50.00**

**Screenshot Location:** `docs/requirements/test-6.1-order-details-frontend.png`

---

### Test 6.2: View Order in Admin
**Steps:**
1. Go to WordPress Admin
2. Navigate to: **WooCommerce > Orders**
3. Click on the order you just placed

**Expected Result:**
- ✅ Order edit screen shows order items
- ✅ Under product name, you see:
  - **Size: Medium (12 servings)**
  - **Dietary Options: Vegan, Sugar-free**
- ✅ Item total: **€50.00** (€25 × 2)

**Screenshot Location:** `docs/requirements/test-6.2-order-admin.png`

---

### Test 6.3: Check Order Email (if emails configured)
**Steps:**
1. Check the email sent to `test@example.com`
   OR
2. Use a plugin like "WP Mail Logging" to view sent emails
   OR
3. Check email logs in Docker/local mail catcher

**Expected Result:**
- ✅ Email contains order confirmation
- ✅ Email shows:
  - Product name
  - **Size: Medium (12 servings)**
  - **Dietary Options: Vegan, Sugar-free**
  - Price and quantity

**Screenshot Location:** `docs/requirements/test-6.3-order-email.png`

---

## TEST SUITE 7: Edge Cases

### Test 7.1: Product Without Options
**Steps:**
1. Edit the same product
2. Remove all dietary options (click Remove on each)
3. Save product
4. View product page on frontend

**Expected Result:**
- ✅ "Dietary Options" section does NOT appear
- ✅ Only "Select Size" section is visible
- ✅ Can still select size and add to cart
- ✅ Price = size price only (no option modifiers)

---

### Test 7.2: Negative Price Modifier
**Steps:**
1. Edit product
2. Add option: "Simple Recipe" with modifier: `-2.00` (negative)
3. Save product
4. View product page
5. Select "Medium" (€20.00)
6. Check "Simple Recipe"

**Expected Result:**
- ✅ Option shows: "Simple Recipe -€2.00"
- ✅ "Total Price" shows: **€18.00** (20 - 2)
- ✅ Can add to cart successfully

---

### Test 7.3: Zero Price Modifier
**Steps:**
1. Edit product
2. Add option: "Standard" with modifier: `0.00`
3. Save product
4. View product page
5. Check "Standard" option

**Expected Result:**
- ✅ Option appears without price display (or shows €0.00)
- ✅ Total price does NOT change when checked

---

### Test 7.4: Very Large Price
**Steps:**
1. Edit product
2. Set Large size price to: `999.99`
3. Add option: "Premium" with modifier: `100.00`
4. Save, view frontend
5. Select Large + Premium

**Expected Result:**
- ✅ Total Price shows: **€1,099.99** (999.99 + 100)
- ✅ No errors, price formats correctly

---

### Test 7.5: Mobile Responsiveness
**Steps:**
1. Open product page on mobile device
   OR
2. In browser, open DevTools (F12) and toggle device toolbar
3. Select "iPhone 12 Pro" or similar mobile size

**Expected Result:**
- ✅ Size cards stack vertically
- ✅ Options stack in single column
- ✅ All text is readable
- ✅ Touch targets are large enough
- ✅ "Add to Cart" button is visible
- ✅ Can select sizes and options on mobile

**Screenshot Location:** `docs/requirements/test-7.5-mobile-view.png`

---

## TEST SUITE 8: JavaScript Console Errors

### Test 8.1: Browser Console Check
**Steps:**
1. Open product page
2. Open browser DevTools (F12)
3. Go to "Console" tab
4. Reload page
5. Interact with configurator (select sizes, options)

**Expected Result:**
- ✅ NO red errors in console
- ✅ NO warnings about missing functions/variables
- ✅ Only normal WooCommerce/WordPress messages (if any)

**Screenshot Location:** `docs/requirements/test-8.1-console-clean.png`

---

## TEST SUITE 9: Admin Product List

### Test 9.1: Product List Display
**Steps:**
1. Go to: **Products > All Products**
2. Look for the cake product in the list

**Expected Result:**
- ✅ Product appears normally
- ✅ No special indicator needed (cake status is internal)
- ✅ Can edit, trash, view normally

---

### Test 9.2: Disable Cake Product
**Steps:**
1. Edit the cake product
2. Uncheck "Enable Cake Product Configuration"
3. Save product
4. View product on frontend

**Expected Result:**
- ✅ Cake configurator does NOT appear
- ✅ Standard WooCommerce "Add to Cart" button shows
- ✅ Product acts like normal simple product
- ✅ Can still add to cart (uses standard product price)

---

### Test 9.3: Re-Enable Cake Product
**Steps:**
1. Edit product again
2. Check "Enable Cake Product Configuration"
3. Verify sizes and options are still there (data preserved)
4. Save
5. View frontend

**Expected Result:**
- ✅ Configurator appears again
- ✅ All previous size/option data is intact
- ✅ Works as expected

---

## VALIDATION SUMMARY

### Completed Tests: __ / 35

### Critical Issues Found: __
(List any blocking issues)

### Minor Issues Found: __
(List any cosmetic or minor issues)

### Performance Notes:
- Page load time: ____
- JavaScript execution: ____
- Admin save time: ____

### Browser Compatibility:
- [ ] Chrome
- [ ] Firefox
- [ ] Safari
- [ ] Edge

### Device Compatibility:
- [ ] Desktop (1920×1080)
- [ ] Tablet (768×1024)
- [ ] Mobile (375×667)

---

## Next Steps

After completing all tests:

1. **If all tests PASS:**
   - ✅ Mark validation phase as complete
   - ✅ Proceed to Reviewer for code review
   - ✅ Prepare documentation

2. **If tests FAIL:**
   - ❌ Document failures in detail
   - ❌ Return to appropriate agent (Backend/Frontend) for fixes
   - ❌ Re-test after fixes

---

## Test Report Location

Save screenshots and detailed results to:
- `/docs/requirements/validation-test-results/`

Create a final summary report:
- `/docs/work/2026-01-11-validation-report.md`

---

**Validator:** Ready to begin testing
**Date:** 2026-01-11
**Testing Environment:** organicstore.local (Docker)
