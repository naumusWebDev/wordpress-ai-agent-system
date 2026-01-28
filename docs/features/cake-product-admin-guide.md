# Cake Product Admin Guide

**Quick Start Guide for Store Administrators**

---

## What is a Cake Product?

A Cake Product allows customers to customize their cake order by selecting:
- **Size** (Small, Medium, or Large) with different prices
- **Dietary options** (Vegan, Dairy-free, Nut-free, etc.) with additional charges
- The system automatically calculates the total price based on their selections

---

## Creating Your First Cake Product

### Step 1: Create a New Product

1. Go to: **Products > Add New**
2. Enter product details:
   - **Product name**: `Chocolate Birthday Cake`
   - **Description**: Describe your cake
   - **Short description**: Brief summary
   - **Product image**: Upload a cake image

3. **Product Data** panel:
   - Select: **Simple product** (not Variable)
   - **Regular price**: Enter any price (e.g., `15.00`) - this will be overridden by size pricing
   - **SKU**: Optional product code (e.g., `CAKE-CHOC-001`)
   - **Stock status**: In stock

### Step 2: Enable Cake Configuration

1. Scroll down to: **Cake Product Configuration** meta box
2. Check the box: ✅ **Enable Cake Product Configuration**
3. The configuration panel will slide open

### Step 3: Set Size Prices

You'll see a table with three sizes:

| Size   | Servings | Price    |
|--------|----------|----------|
| Small  | 6        | [Enter]  |
| Medium | 12       | [Enter]  |
| Large  | 24       | [Enter]  |

**Example pricing:**
- Small (6 servings): `15.00`
- Medium (12 servings): `25.00`
- Large (24 servings): `45.00`

The servings numbers are fixed. You only set the prices.

### Step 4: Set Dietary Options

You'll see 5 default options:
- Vegan
- Dairy-free
- Nut-free
- Wheat-free
- Sugar-free

**For each option**, enter a price modifier:
- Vegan: `5.00` (adds €5 to the price)
- Dairy-free: `3.00` (adds €3)
- Nut-free: `2.50` (adds €2.50)
- Wheat-free: `3.50` (adds €3.50)
- Sugar-free: `4.00` (adds €4)

**Adding custom options:**
1. Click: **+ Add Option**
2. Enter label: `Organic Ingredients`
3. Enter price modifier: `8.00`
4. The option appears in the list

**Removing options:**
- Click the **×** button next to any option to remove it

### Step 5: Publish

1. Click: **Publish** (or **Update** if editing existing product)
2. Click: **View Product** to see your cake configurator in action

---

## How Customers See It

When a customer visits your cake product page, they will see:

### 1. Size Selector
Three visual cards showing:
```
┌─────────────┬─────────────┬─────────────┐
│   Small     │   Medium    │    Large    │
│ (6 servings)│(12 servings)│(24 servings)│
│   €15.00    │   €25.00    │   €45.00    │
└─────────────┴─────────────┴─────────────┘
```

### 2. Dietary Options
Checkboxes with prices:
```
☐ Vegan                  +€5.00
☐ Dairy-free             +€3.00
☐ Nut-free               +€2.50
☐ Wheat-free             +€3.50
☐ Sugar-free             +€4.00
☐ Organic Ingredients    +€8.00
```

### 3. Live Price Display
Shows total price as they select:
```
TOTAL PRICE: €30.00
```

**Example**: Customer selects Medium (€25) + Vegan (+€5) = €30.00

---

## Managing Cake Products

### Editing an Existing Cake Product

1. Go to: **Products > All Products**
2. Click: **Edit** on your cake product
3. Scroll to: **Cake Product Configuration**
4. Make your changes:
   - Update prices
   - Add/remove dietary options
   - Modify option prices
5. Click: **Update**

Changes take effect immediately on the product page.

**Note**: Existing orders are NOT affected by price changes.

### Disabling Cake Configuration

If you want to turn a cake product back into a regular product:

1. Edit the product
2. Uncheck: ☐ **Enable Cake Product Configuration**
3. Click: **Update**

The configurator will disappear from the product page.

---

## Viewing Orders

When a customer orders a configured cake, you'll see their selections in:

### Order Admin

1. Go to: **WooCommerce > Orders**
2. Click on any order with a cake product
3. In the **Items** section, you'll see:
   ```
   Chocolate Birthday Cake
   Size: Medium (12 servings)
   Dietary Options: Vegan, Sugar-free
   Price: €34.00
   ```

### Order Emails

Configuration details are automatically included in:
- Order confirmation emails (to customer)
- New order notifications (to admin)

### Customer Account

Customers can see their configuration in:
- **My Account > Orders > View Order**

---

## Pricing Examples

Here's how pricing works:

### Example 1: Simple Order
- Size: Small (€15.00)
- Options: None
- **Total: €15.00**

### Example 2: With One Option
- Size: Medium (€25.00)
- Options: Vegan (+€5.00)
- **Total: €30.00**

### Example 3: Multiple Options
- Size: Large (€45.00)
- Options: Vegan (+€5.00), Sugar-free (+€4.00)
- **Total: €54.00**

### Example 4: All Options
- Size: Medium (€25.00)
- Options: Vegan (+€5) + Dairy-free (+€3) + Nut-free (+€2.50) + Wheat-free (+€3.50) + Sugar-free (+€4)
- **Total: €43.00**

The system automatically calculates: **Base price + sum of all selected options**

---

## Common Questions

### Can I have different dietary options for different cakes?

**Yes!** Each cake product has its own dietary options and prices.

Example:
- **Chocolate Cake**: Vegan (+€5), Gluten-free (+€4)
- **Carrot Cake**: Vegan (+€3), Nut-free (+€2), Sugar-free (+€5)

### Can I change the servings numbers?

**No**, the servings are fixed:
- Small = 6 servings
- Medium = 12 servings
- Large = 24 servings

You can only change the **prices** for each size.

### Can I add more than 3 sizes?

**No**, the system supports exactly 3 sizes (Small, Medium, Large).

If you need different sizes, consider:
- Adjusting the prices to match your needs
- Creating multiple cake products for different size ranges

### Can I add unlimited dietary options?

**Yes!** You can add as many custom dietary options as you need using the "+ Add Option" button.

### What happens if I change prices after someone ordered?

Existing orders keep their original prices. Only new orders use the updated prices.

### Can customers order without selecting a size?

**No**, size selection is required. The system shows an error if they try to add to cart without selecting a size.

### Can customers select multiple sizes?

**No**, only one size per cart item. If they want multiple sizes, they need to add the product to cart multiple times with different configurations.

Example:
- Add to cart: Medium + Vegan = €30.00
- Add to cart again: Small + Dairy-free = €18.00
- Cart total: €48.00 (2 items)

### Do dietary options have to cost extra?

**No**, you can set price modifier to `0.00` for free options.

Example:
- Nut-free: `0.00` (no extra charge)

---

## Troubleshooting

### Configurator doesn't appear on product page

**Check:**
1. ✅ Is "Organics Child" theme active? (Appearance > Themes)
2. ✅ Is "Enable Cake Product" checkbox checked?
3. ✅ Is product type "Simple product"?
4. ✅ Try: Clear your browser cache (Ctrl+F5)

### Configuration not saving

**Check:**
1. ✅ Did you click "Update" or "Publish"?
2. ✅ Do you see any error messages?
3. ✅ Try: Refresh the page and check if data is there

### Price not updating on product page

**Check:**
1. ✅ Open browser console (F12) and look for red errors
2. ✅ Try: Clear browser cache
3. ✅ Try: View in private/incognito window

### Configuration not showing in order

**Check:**
1. ✅ View the order in WP Admin (not just the email)
2. ✅ Look in "Items" section for "Size" and "Dietary Options"

If issues persist, check the full troubleshooting guide in `/docs/features/cake-product-configurator.md`

---

## Tips and Best Practices

### Pricing Strategy

1. **Size pricing**: Base prices on ingredient cost and servings
2. **Option pricing**: Charge based on extra ingredient cost
3. **Psychology**: Round numbers (€15, €25, €45) work well
4. **Value**: Make larger sizes better value (encourage upsell)

Example:
- Small (6 servings): €15.00 = €2.50/serving
- Medium (12 servings): €25.00 = €2.08/serving ✓ Better value
- Large (24 servings): €45.00 = €1.88/serving ✓ Best value

### Option Naming

- Use clear, customer-friendly names
- "Dairy-free" instead of "No lactose"
- "Nut-free" instead of "Without nuts"
- Be specific: "Gluten-free" not "Wheat-free" if appropriate

### Product Descriptions

Include in your description:
- What makes your cakes special
- Ingredient quality
- How long cakes stay fresh
- Advance order requirements
- Pickup/delivery information

### Product Images

- Use high-quality cake photos
- Show the actual product (if possible)
- Consider multiple images for different sizes
- Show cross-section to display quality

---

## Next Steps

Now that you know how to create cake products:

1. **Create your first cake product** using the steps above
2. **Test it yourself** by placing a test order
3. **Create more cake varieties** (Chocolate, Vanilla, Carrot, etc.)
4. **Adjust pricing** based on your costs and market
5. **Promote your configurable cakes** to customers

For detailed technical information, see: `/docs/features/cake-product-configurator.md`

---

**Need Help?** Contact your development team or check the full documentation.
