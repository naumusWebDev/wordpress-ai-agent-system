# Repository Structure

This document explains the organization of this WordPress project repository.

---

## Directory Tree

```
wordpress-ai-sample/
├── .claude/                        # Claude Code configuration
│   ├── commands/                   # Slash commands for agents
│   │   ├── run-orchestrator.md
│   │   ├── analyze-requirement.md
│   │   ├── create-wp-api-script.md
│   │   ├── review-changes.md
│   │   └── update-docs-and-changelog.md
│   ├── settings.json               # Claude Code permissions
│   └── settings.local.json         # Local overrides
├── .git/                           # Git version control
├── agents/                         # Agent definitions
│   ├── orchestrator.md
│   ├── analyzer.md
│   ├── backend-engineer.md
│   ├── frontend-designer.md
│   ├── reviewer.md
│   ├── scripter.md
│   ├── validator.md
│   └── documenter.md
├── docs/                           # Project documentation
│   ├── agents/                     # Agent system documentation
│   │   ├── overview.md
│   │   └── roles.md
│   ├── work/                       # Scratchpads and working docs
│   │   └── checklist-template.md
│   ├── api-access.md               # REST API authentication guide
│   ├── environment.md              # Development environment setup
│   ├── repo-structure.md           # This file
│   ├── initializer-runbook.md      # Initialization execution log
│   └── CHANGELOG.md                # Project changelog
├── resources/                      # Client materials, briefs, assets
│   └── (client provided files)
├── scripts/                        # Automation scripts
│   ├── wp-api/                     # REST API scripts
│   │   └── (scripts will be created by Scripter)
│   ├── catalog.md                  # Script registry (owned by Scripter)
│   └── README.md                   # Script usage guide
├── wp-admin/                       # WordPress admin (core)
├── wp-content/                     # WordPress content
│   ├── plugins/                    # WordPress plugins
│   ├── themes/                     # WordPress themes
│   │   ├── organics/               # Parent theme (DO NOT MODIFY)
│   │   ├── organics-child/         # Child theme (ALL CUSTOMIZATIONS)
│   │   ├── twentytwentyfive/      # Default WP theme
│   │   ├── twentytwentyfour/      # Default WP theme
│   │   └── twentytwentythree/     # Default WP theme
│   └── uploads/                    # Uploaded files (git-ignored)
├── wp-includes/                    # WordPress includes (core)
├── .env                            # Environment variables (git-ignored, SECRET)
├── .env.example                    # Environment template (safe to commit)
├── .gitignore                      # Git ignore rules
├── agents.md                       # Agent system catalog
├── CLAUDE.md                       # Claude Code runtime guide
├── docker-compose.yml              # Docker infrastructure
├── README.md                       # Project README
├── wp-config.php                   # WordPress configuration (git-ignored)
└── (WordPress core files)
```

---

## Key Directories

### `/agents/`
**Purpose**: Agent definition files
**Owner**: System (updated by Documenter)
**Content**: Markdown prompts for each specialized agent

**Files**:
- `orchestrator.md` - Coordination and workflow management
- `analyzer.md` - Requirement analysis and task decomposition
- `backend-engineer.md` - WordPress backend implementation
- `frontend-designer.md` - UI/UX implementation
- `reviewer.md` - Code quality and security review
- `scripter.md` - REST API automation scripts
- `validator.md` - Integration testing
- `documenter.md` - Documentation maintenance

**Versioned**: ✅ Yes

---

### `/docs/`
**Purpose**: Living project documentation
**Owner**: Documenter Agent
**Content**: Technical documentation, guides, runbooks

**Key Files**:
- `CHANGELOG.md` - **Authoritative change log** (owned by Documenter)
- `api-access.md` - REST API authentication setup
- `environment.md` - Development environment guide
- `repo-structure.md` - This file
- `initializer-runbook.md` - Initialization execution record

**Subdirectories**:
- `agents/` - Agent system documentation
- `work/` - Scratchpads for complex tasks

**Versioned**: ✅ Yes

---

### `/scripts/`
**Purpose**: Automation scripts for WordPress operations
**Owner**: Scripter Agent
**Content**: REST API scripts, utilities, batch operations

**Structure**:
- `wp-api/` - REST API automation scripts
- `catalog.md` - **Script registry** (owned by Scripter)
- `README.md` - Script usage conventions

**Versioned**: ✅ Yes (scripts only, not generated output)

---

### `/resources/`
**Purpose**: Client materials, design files, reference documents
**Owner**: Shared (project team)
**Content**: PDFs, design mockups, client briefs, specifications

**Examples**:
- Client briefs
- Design mockups
- Brand guidelines
- Reference documents

**Versioned**: ✅ Yes (non-sensitive materials only)

---

### `/wp-content/themes/organics-child/`
**Purpose**: Child theme (ALL WordPress customizations)
**Owner**: Backend Engineer + Frontend Designer
**Content**: Theme customizations, functions, templates, styles

**Structure**:
```
organics-child/
├── style.css           # Main stylesheet (required)
├── functions.php       # Theme functions (required)
├── templates/          # Custom page templates
├── template-parts/     # Template overrides
├── inc/                # Include files (organized functions)
├── css/                # Additional stylesheets
├── js/                 # JavaScript files
├── images/             # Theme images
└── languages/          # Translation files
```

**Golden Rule**: **ALL customizations go here, NEVER in the parent theme**

**Versioned**: ✅ Yes

---

### `/wp-content/uploads/`
**Purpose**: User-uploaded media files
**Owner**: WordPress (managed by users)
**Content**: Images, videos, documents uploaded via WordPress admin

**Versioned**: ❌ No (git-ignored)

**Why not version**:
- Large files
- Frequently changing
- Managed by users, not developers
- Should be backed up separately

---

## What to Version (Git)

### ✅ Always Version

- **Agent definitions** (`/agents/*.md`)
- **Documentation** (`/docs/**/*`)
- **Scripts** (`/scripts/**/*.js`, `/scripts/**/*.py`)
- **Child theme** (`/wp-content/themes/organics-child/`)
- **Configuration templates** (`.env.example`, `docker-compose.yml`)
- **Git configuration** (`.gitignore`)
- **Project files** (`CLAUDE.md`, `agents.md`, `README.md`)

### ❌ Never Version (Git-Ignored)

- **Secrets** (`.env`, `wp-config.php`)
- **Uploads** (`/wp-content/uploads/`)
- **Cache files** (`/wp-content/cache/`)
- **Logs** (`*.log`, `/wp-content/debug.log`)
- **Database dumps** (`*.sql`, `*.sqlite`)
- **Node modules** (`node_modules/`)
- **Temporary files** (`.DS_Store`, `Thumbs.db`)
- **Editor configs** (`.vscode/`, `.idea/`)
- **Docker volumes** (`/mysql-data/`)

### ⚠️ Optional (Project Decision)

- **WordPress core** (`/wp-admin/`, `/wp-includes/`, `wp-*.php`)
  - Current: ✅ Versioned (for reproducibility)
  - Alternative: Ignore core, version only `wp-content/`

- **Parent theme** (`/wp-content/themes/organics/`)
  - Current: ✅ Versioned (for reference)
  - Alternative: Ignore, document version in README

- **Default themes** (`twentytwentyfive`, etc.)
  - Current: ✅ Versioned (comes with WP)
  - Alternative: Ignore, not used

- **Plugins** (`/wp-content/plugins/`)
  - Current: ⚠️ Case-by-case
  - Custom plugins: ✅ Version
  - Third-party plugins: ❌ Usually not versioned (use composer or document)

---

## File Ownership Matrix

| Path | Owner | Can Modify | Can Read |
|------|-------|-----------|----------|
| `/agents/*.md` | Documenter | Documenter | All |
| `/docs/CHANGELOG.md` | Documenter | Documenter only | All |
| `/docs/**/*` (other) | Documenter | Documenter | All |
| `/scripts/catalog.md` | Scripter | Scripter only | All |
| `/scripts/wp-api/*` | Scripter | Scripter | All |
| `/wp-content/themes/organics-child/functions.php` | Backend Engineer | Backend Engineer | All |
| `/wp-content/themes/organics-child/templates/*` | Frontend Designer | Frontend Designer | All |
| `/wp-content/themes/organics-child/style.css` | Frontend Designer | Frontend Designer | All |
| `/wp-content/themes/organics/*` | Parent Theme | ❌ NOBODY | All (read-only) |
| `/.env` | Admin | Admin | Agents (read-only) |
| `CLAUDE.md` | Documenter | Documenter | All |

---

## Special Files

### `CLAUDE.md`
**Purpose**: Claude Code runtime guide (automatically loaded)
**Owner**: Documenter Agent
**Content**: Project philosophy, workflow, rules for Claude Code
**When updated**: When project conventions change

### `agents.md`
**Purpose**: Agent catalog (index of all agents)
**Owner**: Documenter Agent
**Content**: List of agents with descriptions and usage
**When updated**: When agents are added or modified

### `.gitignore`
**Purpose**: Specifies files Git should ignore
**Owner**: Documenter/Admin
**Content**: WordPress-specific exclusions, secrets, uploads, etc.
**When updated**: When new ignoreable patterns are needed

### `docker-compose.yml`
**Purpose**: Docker infrastructure definition
**Owner**: Admin/DevOps
**Content**: Service definitions (WordPress, MySQL, WP-CLI)
**When updated**: When infrastructure needs change

### `.env.example`
**Purpose**: Template for environment variables
**Owner**: Documenter
**Content**: Placeholder values (no secrets)
**When updated**: When new environment variables are needed

### `wp-config.php`
**Purpose**: WordPress configuration
**Owner**: Backend Engineer
**Content**: Database config, security keys, WordPress settings
**When updated**: Rarely (initial setup, major changes)
**Versioned**: ❌ No (contains secrets, generated from `.env`)

---

## Workflow-Specific Locations

### During Feature Development

**Working docs**: `/docs/work/feature-name.md`
- Scratchpad for complex features
- Temporary planning documents
- Deleted or archived after completion

**Test data**: `/resources/test-data/`
- Sample CSV files
- Test images
- Mock data

---

## Security & Secrets

### Where Secrets Live

- **Never in repository**:
  - `.env` (actual credentials)
  - `wp-config.php` (database credentials, salts)
  - Any files with passwords, API keys, tokens

### Safe Placeholders

- **Safe to commit**:
  - `.env.example` (placeholder values)
  - Documentation with `your_password_here` examples

### Accidental Commit

If secrets are committed:
1. **Immediately**: Rotate all exposed credentials
2. Remove from Git history: `git filter-branch` or BFG Repo-Cleaner
3. Force push (if private repo): `git push --force`
4. Update `.gitignore` to prevent recurrence

---

## Backup Strategy

### Version Controlled (Git)
- Code, scripts, documentation
- Backed up via Git (GitHub, GitLab, Bitbucket, etc.)

### Not Version Controlled
- **Database**: Export regularly via WP-CLI
- **Uploads**: Sync to cloud storage or backup service
- **`.env` file**: Store securely (password manager, encrypted vault)

### Recommended

```bash
# Daily database backup
docker compose run --rm wpcli db export \
  backups/db-$(date +%Y%m%d).sql

# Weekly full backup (code + database + uploads)
tar -czf backup-$(date +%Y%m%d).tar.gz \
  wp-content/uploads/ \
  backups/db-$(date +%Y%m%d).sql
```

---

## Summary

✅ **DO**:
- Customize in child theme (`organics-child`)
- Version documentation and scripts
- Use `.env` for secrets
- Follow directory ownership rules

❌ **DON'T**:
- Modify parent theme (`organics`)
- Commit `.env` or `wp-config.php`
- Version `uploads/` directory
- Ignore the agent system boundaries

---

**Last Updated**: 2026-01-11
**Maintained By**: Documenter Agent
