# Agent Variables

All project-specific values referenced in agent prompts are defined here.
To reuse these agents on a new WordPress project, update the values in this file.
Every `{{VARIABLE_NAME}}` placeholder in the agent files maps to a row below.

> **Setup:** Copy `VARIABLES.example.md` to `VARIABLES.md` and fill in your project values.

---

## Theme Identity

| Variable | Value | Used as |
|---|---|---|
| `PARENT_THEME_SLUG` | `your-parent-theme` | Parent theme directory name |
| `CHILD_THEME_SLUG` | `your-child-theme` | Child theme directory name and WordPress text domain |
| `CHILD_THEME_DISPLAY_NAME` | `Your Child Theme` | `Theme Name` header in style.css |
| `SITE_DESCRIPTION` | `Your site description` | `Description` header in style.css |

## PHP Conventions

| Variable | Value | Used as |
|---|---|---|
| `PHP_FUNCTION_PREFIX` | `myproject_` | Prefix for all custom PHP functions. The trailing underscore is part of the value. |
| `PHP_PACKAGE_NAME` | `My_Project` | `@package` tag in DocBlocks |

## JavaScript

| Variable | Value | Used as |
|---|---|---|
| `JS_LOCALIZATION_OBJECT` | `myprojectAjax` | Object name in `wp_localize_script()` |

## REST API

| Variable | Value | Used as |
|---|---|---|
| `REST_API_NAMESPACE` | `myproject/v1` | Namespace in `register_rest_route()` |

## Environment

| Variable | Value | Used as |
|---|---|---|
| `WP_SITE_URL` | `http://myproject.local` | Base site URL in curl examples and test scenarios |
| `WP_PATH` | `/path/to/wordpress` | WordPress root for WP-CLI |
| `DB_HOST` | `127.0.0.1:3306` | MySQL host and port |
| `DB_USER` | `root` | MySQL user |
| `DB_NAME` | `wordpress` | MySQL database name |
| `PROJECT_DATA_DIR` | `data/myproject` | JSON data directory under scripts/wp-cli/ |

---

## Inline compositions

Some placeholders in agent files are composed from the variables above.
No separate variable is needed — the derivation is self-evident.

| Pattern in agent file | Resolves to | Example |
|---|---|---|
| `{{CHILD_THEME_SLUG}}-custom` | Enqueue handle for custom scripts/styles | `your-child-theme-custom` |
| `{{CHILD_THEME_SLUG}}-style` | Child theme stylesheet handle | `your-child-theme-style` |
| `{{CHILD_THEME_SLUG}}-ui` | UI script handle | `your-child-theme-ui` |
| `{{PARENT_THEME_SLUG}}-style` | Parent theme stylesheet handle | `your-parent-theme-style` |
| `{{WP_SITE_URL}}/wp-json` | REST API base URL | `http://myproject.local/wp-json` |

---

## How to adapt for a new project

1. Update every **Value** cell in the tables above with your project's values.
2. That is all. Every `{{VARIABLE_NAME}}` in the agent files resolves to the value defined here.
