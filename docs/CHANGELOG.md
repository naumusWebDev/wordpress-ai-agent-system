# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- WordPress visual installation completion
- Application Password generation for REST API
- Sample content and theme configuration

---

## [1.0.0] - 2026-01-11

### Added
- **WordPress Core**: Latest stable WordPress installation (extracted to project root)
- **Docker Infrastructure**:
  - docker-compose.yml with PHP 8.3, MySQL 8.0, and WP-CLI
  - Environment variable support via `.env` file
  - `.env.example` template for configuration
- **Theme Installation**:
  - Organics parent theme (v1.6.12)
  - Organics child theme (v1.6.12)
  - Themes extracted to `/wp-content/themes/`
- **Multi-Agent System**:
  - 8 specialized agents with complete definitions
  - Agent catalog (`/agents.md`)
  - Individual agent prompts in `/agents/`:
    - Orchestrator (coordination and workflow)
    - Analyzer (requirement analysis)
    - Backend Engineer (WordPress backend)
    - Frontend Designer (UI/UX)
    - Reviewer (code quality)
    - Scripter (REST API automation)
    - Validator (integration testing)
    - Documenter (documentation management)
- **Documentation**:
  - `/docs/api-access.md` - REST API authentication guide
  - `/docs/environment.md` - Development environment setup
  - `/docs/repo-structure.md` - Repository organization
  - `/docs/agents/overview.md` - Agent system overview
  - `/docs/agents/roles.md` - Agent roles and boundaries
  - `/docs/initializer-runbook.md` - Initialization execution log
  - `/docs/CHANGELOG.md` - This file
  - `/docs/work/checklist-template.md` - Task checklist template
- **Scripts Infrastructure**:
  - `/scripts/wp-api/` directory for REST API scripts
  - `/scripts/catalog.md` - Script registry (owned by Scripter)
  - `/scripts/README.md` - Script usage guide
- **Configuration**:
  - `wp-config.php` with database configuration
  - WordPress security salts generated
  - `.gitignore` with WordPress-specific exclusions
  - Claude Code slash commands in `.claude/commands/`

### Configuration
- **Database**: organicstore (MySQL 8.0)
- **Site URL**: http://organicstore.local
- **PHP Version**: 8.3
- **Table Prefix**: wp_
- **Authentication Method**: Application Passwords (WordPress 5.6+)

### Infrastructure
- **Environment**: Docker (docker-compose)
- **Web Server**: Apache (in WordPress container)
- **Database**: MySQL 8.0
- **WP-CLI**: Available via dedicated container

### Documentation
- Complete agent system documentation
- REST API access guide
- Docker setup instructions
- Repository structure guide
- Script catalog template

---

**Maintained By**: Documenter Agent
**Project**: WordPress AI - Organic Store
**Repository**: wordpress-ai-sample
