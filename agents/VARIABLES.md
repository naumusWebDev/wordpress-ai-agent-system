# Agent Variables

All project-specific values referenced in agent prompts are defined here.
To reuse these agents on a new WordPress project, update the values in this file.
Every `{{VARIABLE_NAME}}` placeholder in the agent files maps to a row below.

---

## Theme Identity

| Variable | Value | Used as |
|---|---|---|
| `PARENT_THEME_SLUG` | `organics` | Parent theme directory name |
| `CHILD_THEME_SLUG` | `organics-child` | Child theme directory name and WordPress text domain |
| `CHILD_THEME_DISPLAY_NAME` | `Organics Child` | `Theme Name` header in style.css |
| `SITE_DESCRIPTION` | `Organic Store` | `Description` header in style.css |

## PHP Conventions

| Variable | Value | Used as |
|---|---|---|
| `PHP_FUNCTION_PREFIX` | `organics_child_` | Prefix for all custom PHP functions. The trailing underscore is part of the value. |
| `PHP_PACKAGE_NAME` | `Organics_Child` | `@package` tag in DocBlocks |

## JavaScript

| Variable | Value | Used as |
|---|---|---|
| `JS_LOCALIZATION_OBJECT` | `organicsAjax` | Object name in `wp_localize_script()` |

## REST API

| Variable | Value | Used as |
|---|---|---|
| `REST_API_NAMESPACE` | `organics/v1` | Namespace in `register_rest_route()` |

## Environment

| Variable | Value | Used as |
|---|---|---|
| `WP_SITE_URL` | `http://organicstore.local` | Base site URL in curl examples and test scenarios |
| `DB_USER` | `wordpress` | MySQL user in docker compose exec examples |
| `DB_NAME` | `organicstore` | MySQL database name in docker compose exec examples |

---

## Inline compositions

Some placeholders in agent files are composed from the variables above.
No separate variable is needed — the derivation is self-evident.

| Pattern in agent file | Resolves to | Example |
|---|---|---|
| `{{CHILD_THEME_SLUG}}-custom` | Enqueue handle for custom scripts/styles | `organics-child-custom` |
| `{{CHILD_THEME_SLUG}}-style` | Child theme stylesheet handle | `organics-child-style` |
| `{{CHILD_THEME_SLUG}}-ui` | UI script handle | `organics-child-ui` |
| `{{PARENT_THEME_SLUG}}-style` | Parent theme stylesheet handle | `organics-parent-style` |
| `{{WP_SITE_URL}}/wp-json` | REST API base URL | `http://organicstore.local/wp-json` |

---

## How to adapt for a new project

1. Update every **Value** cell in the tables above with your project's values.
2. That is all. Every `{{VARIABLE_NAME}}` in the agent files resolves to the value defined here.
