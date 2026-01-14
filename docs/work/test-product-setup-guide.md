# Test Cake Product Setup Guide

**Date:** 2026-01-11
**Purpose:** Create a test product to verify Cake Product functionality

---

## Step-by-Step Instructions

### Step 1: Create New Product

1. Go to WordPress Admin: `http://organicstore.local/wp-admin`
2. Navigate to: **Products > Add New**
3. Enter Product Details:
   - **Title:** `Chocolate Birthday Cake`
   - **Description:**
     ```
     Delicious chocolate birthday cake made fresh daily with premium ingredients.
     Choose your preferred size and dietary options to customize your perfect cake.
     ```
   - **Short Description:**
     ```
     Premium chocolate cake - customizable size and dietary options
     ```

4. **Product Data Section:**
   - Select: **Simple product**
   - **Regular price:** `15.00` (this will be overridden by cake sizes)
   - **SKU:** `CAKE-CHOC-001`
   - **Stock status:** In stock

5. **Product Image:**
   - Use any cake image you have, or skip for now

---

### Step 2: Enable Cake Product Configuration

1. Scroll down to: **Cake Product Configuration** meta box
2. Check: ✅ **Enable Cake Product Configuration**
3. Configuration panel will slide down

---

### Step 3: Configure Cake Sizes

In the **"Cake Sizes & Pricing"** table, enter:

| Size   | Servings | Price  |
|--------|----------|--------|
| Small  | 6        | 15.00  |
| Medium | 12       | 25.00  |
| Large  | 24       | 45.00  |

---

### Step 4: Configure Dietary Options

The default 5 options should appear. Update the prices:

| Option      | Price Modifier |
|-------------|----------------|
| Vegan       | 5.00           |
| Dairy-free  | 3.00           |
| Nut-free    | 2.50           |
| Wheat-free  | 3.50           |
| Sugar-free  | 4.00           |

**Optional:** Add a custom option:
1. Click **"+ Add Option"**
2. Label: `Organic Ingredients`
3. Price Modifier: `8.00`
4. This demonstrates the dynamic option functionality

---

### Step 5: Save Product

1. Click: **Publish** (or **Update** if editing existing)
2. Wait for success message
3. Click: **View Product** (in admin bar at top)

---

## Expected Results on Product Page

When you visit the product page, you should see:

### 1. Cake Configurator Section
- Appears above "Add to Cart" button
- Light background (#f4f7f9)
- Clean, professional design

### 2. Size Selector
```
┌─────────────────────────────────────────────────┐
│ SELECT SIZE *                                   │
├───────────────┬──────────────┬──────────────────┤
│   Small       │   Medium     │    Large         │
│ (6 servings)  │ (12 servings)│ (24 servings)    │
│   €15.00      │   €25.00     │   €45.00         │
└───────────────┴──────────────┴──────────────────┘
```

### 3. Dietary Options
```
┌─────────────────────────────────────────────────┐
│ DIETARY OPTIONS (optional)                      │
├─────────────────────────────────────────────────┤
│ ☐ Vegan                          +€5.00         │
│ ☐ Dairy-free                     +€3.00         │
│ ☐ Nut-free                       +€2.50         │
│ ☐ Wheat-free                     +€3.50         │
│ ☐ Sugar-free                     +€4.00         │
│ ☐ Organic Ingredients            +€8.00         │
└─────────────────────────────────────────────────┘
```

### 4. Live Price Display
```
┌─────────────────────────────────────────────────┐
│      TOTAL PRICE: Select a size                 │
└─────────────────────────────────────────────────┘
```

---

## Functionality Tests

### Test 1: Size Selection
1. Click on **Medium** size card
2. **Expected:**
   - Card highlights with green border
   - Total price updates to: **€25.00**

### Test 2: Add Options
1. Keep Medium selected (€25.00)
2. Check: ✅ Vegan (+€5.00)
3. **Expected:** Total price updates to: **€30.00**
4. Check: ✅ Sugar-free (+€4.00)
5. **Expected:** Total price updates to: **€34.00**

### Test 3: Change Size
1. Keep Vegan and Sugar-free checked
2. Click: **Large** (€45.00)
3. **Expected:** Total price updates to: **€54.00** (45 + 5 + 4)

### Test 4: Validation
1. Reload page (clears selections)
2. Don't select any size
3. Click: **Add to Cart**
4. **Expected:**
   - Error message appears: "Please select a size before adding to cart"
   - Product NOT added to cart

### Test 5: Add to Cart
1. Select: **Medium** (€25.00)
2. Check: ✅ Vegan (+€5.00)
3. Click: **Add to Cart**
4. **Expected:**
   - Success message
   - Product added to cart
   - Cart shows:
     - Size: Medium (12 servings)
     - Dietary Options: Vegan
     - Price: €30.00

### Test 6: Multiple Configurations
1. Go back to product page
2. Select: **Small** (€15.00)
3. Check: ✅ Dairy-free (+€3.00)
4. Click: **Add to Cart**
5. **Expected:**
   - Cart now has 2 items:
     - Item 1: Medium + Vegan = €30.00
     - Item 2: Small + Dairy-free = €18.00
   - Cart total: €48.00

---

## Troubleshooting

### Configurator Doesn't Appear
- ✅ Check: Child theme "Organics Child" is active
- ✅ Check: "Enable Cake Product" checkbox is checked
- ✅ Check: Product is type "Simple Product" (not Variable)
- ✅ Try: Hard refresh page (Ctrl+F5)

### JavaScript Errors
- Open browser DevTools (F12)
- Check Console tab for errors
- Should see no red errors

### Price Doesn't Update
- Check JavaScript console for errors
- Verify jQuery is loaded
- Clear browser cache

---

## Success Criteria

✅ Product page loads without errors
✅ Cake configurator appears
✅ Size cards display correctly
✅ Options checkboxes display correctly
✅ Price updates when selections change
✅ Validation prevents adding without size
✅ Add to cart works correctly
✅ Cart displays configuration
✅ Multiple configurations can be added

---

## Next Steps After Verification

Once you've confirmed everything works:

1. **Test Checkout Flow**
   - Proceed to checkout
   - Complete order
   - Verify order shows configuration

2. **Test Order Admin**
   - Check order in WP Admin
   - Verify size and options are visible

3. **Test Order Email** (if configured)
   - Check order confirmation email
   - Verify configuration details are included

4. **Document Results**
   - Create validation report
   - Screenshot successful tests
   - Note any issues found

---

## Quick Test Summary

**Minimum viable test:**
1. Create product ✅
2. Enable cake config ✅
3. Set sizes and options ✅
4. Save ✅
5. View product page ✅
6. Select size and options ✅
7. See price update ✅
8. Add to cart ✅
9. Verify cart display ✅

**Total time:** ~5-10 minutes

---

**Status:** Ready for manual testing
**Product URL:** `http://organicstore.local/product/chocolate-birthday-cake/`
