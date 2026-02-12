# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Owner**: Documenter Agent (exclusive)

---

## [1.0.0] - 2026-02-12

### Added
- **Multi-agent system** with 9 specialized agents (Orchestrator, Analyzer, Backend Engineer, Frontend Designer, Reviewer, Scripter, Validator, Documenter, Legacy Initializer)
- **WP-CLI automation scripts** (8 scripts) for full WordPress project bootstrapping:
  - `run-setup.sh` — Master orchestrator
  - `configure-wp.sh` — WordPress settings from JSON
  - `create-pages.sh` — Pages from JSON
  - `create-menus.sh` — Navigation menus from JSON
  - `register-cpt.sh` — Custom Post Types in child theme
  - `create-acf-fields.sh` — ACF fields in database (not PHP)
  - `create-bricks-templates.sh` — Bricks templates with conditions
  - `create-posts.sh` — Posts/CPTs with ACF field data
- **REST API scripts** (Node.js) for remote WordPress operations
- **Briefing system** — Template-driven project setup (`briefing-template.md`)
- **Docker infrastructure** — Parametrized docker-compose.yml with MySQL 8.0, WordPress PHP 8.3, WP-CLI
- **Local WP support** — WSL2 mirrored networking configuration
- **Agent variable system** — `VARIABLES.md` for project-specific values with `{{PLACEHOLDER}}` substitution
- **Claude Code integration** — Slash commands, permissions, runtime guide

### Technical Decisions
- ACF fields are created in the database via `acf_import_field_group()`, NOT via `acf_add_local_field_group()` in PHP. This ensures fields are editable in the ACF admin UI.
- Bricks template conditions use meta key `_bricks_template_conditions` (not `_bricks_conditions`).
- All scripts support `--dry-run` mode for safe preview.
- Child-theme-only development — parent theme and WordPress core are never modified.

---

## [0.1.0] - 2026-01-11

### Added
- Initial project structure and agent definitions
- Docker-based development environment
- REST API authentication setup
- Agent system documentation
