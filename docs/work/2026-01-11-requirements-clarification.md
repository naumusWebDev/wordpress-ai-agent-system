# Requirements Clarification - Custom Cake Product Type

**Date:** 2026-01-11
**Status:** Confirmed by stakeholder

---

## Confirmed Decisions

### 1. Option Pricing Strategy
**Decision:** Per-product pricing
**Rationale:** Allows flexibility for different cake types to have different option modifiers

**Implementation:**
- Each product stores its own option pricing in meta field `_cake_options`
- Admin can set different prices per product
- Example: Product A Vegan option = +€3, Product B Vegan option = +€5

---

### 2. Size Configuration
**Decision:** Fixed labels, admin sets prices only

**Fixed Size Labels:**
- Small (6 servings)
- Medium (12 servings)
- Large (24 servings)

**Admin Control:**
- Admin sets base price for each size per product
- Servings are display-only labels (not editable)

**Implementation:**
- UI shows three price input fields (one per size)
- Stored in `_cake_sizes` as: `['small' => ['servings' => 6, 'price' => 15.00], ...]`

---

### 3. Dietary Options Configuration
**Decision:** Dynamic option builder (admin can add/remove custom options)

**Change from original analysis:**
- Original: Fixed 5 options (Vegan, Dairy-free, Nut-free, Wheat-free, Sugar-free)
- **New:** Admin can define custom options with labels and price modifiers

**Default Options (suggested presets):**
- Vegan
- Dairy-free
- Nut-free
- Wheat-free
- Sugar-free

**Admin can:**
- Add new options (e.g., "Organic", "Gluten-free", "Keto-friendly")
- Remove unused options
- Set unique price modifier per option
- Set display labels per option

**Implementation:**
- Admin meta box has "Add Option" button
- Each option row has: Label input + Price modifier input + Remove button
- Stored in `_cake_options` as: `[['label' => 'Vegan', 'modifier' => 3.00], ['label' => 'Organic', 'modifier' => 5.00], ...]`
- Frontend iterates over this array to display checkboxes

**Data Structure:**
```php
// Product Meta: _cake_options
[
  [
    'label' => 'Vegan',
    'key' => 'vegan', // sanitized key for form inputs
    'modifier' => 3.00
  ],
  [
    'label' => 'Dairy-free',
    'key' => 'dairy_free',
    'modifier' => 2.00
  ],
  // ... admin can add more
]
```

**Architectural Impact:**
- ✅ Backend: Admin UI needs JavaScript for add/remove option rows
- ✅ Backend: Save logic must handle variable-length arrays
- ✅ Frontend: UI must iterate over options array (not hardcoded 5)
- ✅ Cart/Orders: No change (already stores selected option keys)
- ⚠️ Complexity: Slightly higher (+10-15% effort for dynamic UI)

---

## Updated Task Requirements

### Backend Engineer - Task 1 (Admin Meta Box)

**Updated Requirements:**

1. **Size Configuration UI:**
   - Three fixed rows (Small, Medium, Large)
   - Each row: Label (readonly) + Servings (readonly) + Price (input)
   - Servings are hardcoded display values

2. **Option Configuration UI (DYNAMIC):**
   - "Add Option" button
   - Each option row: Label (input) + Price Modifier (input) + Remove (button)
   - JavaScript to add/remove rows
   - Minimum 0 options, no maximum
   - Default: Show 5 preset options (Vegan, Dairy-free, etc.) as suggestions

3. **Save Logic:**
   - Sanitize option labels
   - Generate keys (sanitize_title)
   - Validate price inputs (numeric, can be 0 or negative)
   - Store as serialized arrays

---

### Frontend Designer - Task 3 (Product Page UI)

**Updated Requirements:**

1. **Options Selector:**
   - Iterate over `_cake_options` array (variable length)
   - Generate checkbox for each option
   - Display: `[Checkbox] Label (+€X.XX)`
   - If product has 0 options, don't show options section

2. **JavaScript Price Calculation:**
   - Read option modifiers from data attributes
   - Sum selected option modifiers dynamically
   - No hardcoded option list

---

## Edge Cases

1. **Product with no options defined:**
   - Show only size selector
   - Price = size base price only

2. **Admin removes all options after product has orders:**
   - Existing orders preserve original option data
   - New orders won't have options section

3. **Option with 0 or negative modifier:**
   - Allowed (e.g., discount for removing ingredients)
   - Display: `Sugar-free (-€1.00)`

---

## No Blockers

All decisions are implementable within current architecture.

Ready to proceed to Backend Engineer implementation.

---

**Status:** Requirements confirmed and clarified
**Next Phase:** Backend Implementation (Task 1)
