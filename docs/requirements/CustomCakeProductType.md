Client Requirement — Custom Cake Product Type
Context

The WordPress project is running the Organics theme with demo content installed.
WooCommerce is active and products already exist.

The client requires a new configurable product type called “Cake” (Tarta) with dynamic options that affect pricing and must be preserved in orders.

This is a complex feature involving:

Data modeling

Pricing logic

Frontend UI

Cart and order persistence

Theme-consistent design

Therefore this must be decomposed and delegated to multiple specialized agents.

Business Requirement (Client Language)

The client wants a special type of product called Cake (Tarta).

When a product is of type Cake, the customer must be able to choose:

1. Size

Exactly one size must be selected:

Size	Servings
Small	6 servings
Medium	12 servings
Large	24 servings

Each size has its own base price.

2. Cake options (multi-select)

The customer can choose zero, one, or multiple of the following:

Vegan

Dairy-free

Nut-free

Wheat-free

Sugar-free

These options are not exclusive.
Any combination is allowed (e.g. Vegan + Sugar-free, or Dairy-free + Wheat-free, etc).

Each selected option may increase the price.

3. Pricing behavior

The final product price is:

Base price (size) + sum of selected option price modifiers


Example:

Medium cake (base €20)

Vegan (+€3)

Sugar-free (+€2)

Final price = €25

4. Cart and order persistence

When the product is added to cart and later purchased:

The selected size

The selected options

The calculated final price

must be stored and visible in:

The cart

The checkout

The order details in admin

The order confirmation email

So the bakery knows exactly what was ordered.

5. Product page UI

The product page must show:

Size selector (Small / Medium / Large)

Multi-select option list (Vegan, Dairy-free, etc)

Live price update when selections change

The UI must:

Match the Organics theme style

Look native (not a raw form)

Be mobile-friendly

Orchestrator Classification

This is a COMPLEX FEATURE.

It requires coordinated work across:

Data model

WooCommerce pricing logic

Frontend UI

Order storage

Theme integration

It must be split into tasks and delegated.

High-Level Plan

The Orchestrator will coordinate the following workstreams:

Phase 1 — Analysis (Analyzer)

Define:

How to model “Cake” in WooCommerce (custom product type vs standard product with meta)

How to store sizes and options

How to calculate price

What data must be stored in orders

Phase 2 — Backend (Backend Engineer)

Implement:

Cake product type or Cake configuration system

Custom fields for size and options

Price calculation logic

Hooks to inject values into cart and order

All code must live in the child theme or a safe plugin.

Phase 3 — Frontend (Frontend Designer)

Implement:

Size selector UI

Option multi-select UI

Live price update

Theme-consistent styling

Must integrate into the Organics child theme product template.

Phase 4 — Review (Reviewer)

Verify:

Pricing correctness

Data persistence

WooCommerce best practices

Theme safety

Phase 5 — Scripts (Scripter, if needed)

If required:

Provide scripts to mass-convert existing products to “Cake”

Or to batch-edit prices via the WP REST API

All scripts must be registered in /scripts/catalog.md.

Phase 6 — Validation (Validator)

Verify:

UI works

Cart works

Orders store the right data

Emails show correct info

Admin sees correct configuration

Phase 7 — Documentation (Documenter)

Update:

Feature documentation

Architecture

CHANGELOG

How Cake products work

How to modify sizes and option prices

Orchestrator Next Action

Start with:

Delegate this requirement to the Analyzer to break it down into:
- Data model
- Pricing logic
- UI needs
- Storage & order representation
- Risks & edge cases


No code must be written yet.