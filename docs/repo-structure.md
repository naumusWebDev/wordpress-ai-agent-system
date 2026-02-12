# Repository Structure

Organization of the WordPress AI Agent System repository.

---

## Directory Tree

```
/
├── .claude/                        # Claude Code configuration
│   ├── commands/                   # Slash commands for agents
│   └── settings.json               # Permissions
├── agents/                         # Agent prompt definitions
│   ├── orchestrator.md             # Coordination and routing
│   ├── analyzer.md                 # Requirement analysis
│   ├── backend-engineer.md         # WordPress backend
│   ├── frontend-designer.md        # UI/UX implementation
│   ├── reviewer.md                 # Code review and QA
│   ├── scripter.md                 # Automation scripts
│   ├── validator.md                # Integration testing
│   ├── documenter.md               # Documentation
│   ├── legacy-initializer.md       # Existing site onboarding
│   ├── wordpress-initializer.md    # New project setup
│   ├── VARIABLES.md                # Project-specific values (gitignored)
│   └── VARIABLES.example.md        # Template for VARIABLES.md
├── docs/                           # Documentation
│   ├── agents/                     # Agent system docs
│   │   ├── overview.md
│   │   └── roles.md
│   ├── wordpress-briefings/        # Project briefings
│   │   └── briefing-template.md
│   ├── work/                       # Scratchpads for complex tasks
│   ├── api-access.md               # REST API authentication guide
│   ├── environment.md              # Environment setup guide
│   ├── repo-structure.md           # This file
│   └── CHANGELOG.md                # Project changelog
├── scripts/                        # Automation scripts
│   ├── wp-api/                     # REST API scripts (Node.js)
│   │   ├── create-post.js
│   │   ├── update-post.js
│   │   ├── upload-media.js
│   │   ├── create-product.js
│   │   └── update-product.js
│   ├── wp-cli/                     # WP-CLI bash scripts
│   │   ├── lib/common.sh           # Shared utilities
│   │   ├── data/                   # Project-specific JSON data
│   │   │   └── <project>/          # One directory per project
│   │   ├── run-setup.sh            # Master orchestrator
│   │   ├── configure-wp.sh         # WordPress settings
│   │   ├── create-pages.sh         # Create pages
│   │   ├── create-menus.sh         # Create navigation menus
│   │   ├── register-cpt.sh         # Register Custom Post Types
│   │   ├── create-acf-fields.sh    # Create ACF field groups
│   │   ├── create-bricks-templates.sh  # Create Bricks templates
│   │   └── create-posts.sh         # Create posts/CPTs with ACF data
│   ├── catalog.md                  # Script registry (owned by Scripter)
│   └── README.md                   # Script usage guide
├── wp-content/                     # WordPress content
│   └── themes/                     # Child theme goes here
├── .env.example                    # Environment template
├── .gitignore
├── agents.md                       # Agent catalog
├── CLAUDE.md                       # Claude Code runtime guide
├── docker-compose.yml              # Docker infrastructure (optional)
└── README.md                       # Project README
```

---

## Key Directories

### `agents/`

Agent definition files (Markdown prompts). Each agent has a single responsibility. `VARIABLES.md` holds project-specific values and is gitignored — copy from `VARIABLES.example.md`.

### `docs/`

Living documentation maintained by the Documenter agent. `CHANGELOG.md` is the authoritative change log. `work/` holds temporary scratchpads for complex multi-step tasks.

### `scripts/wp-cli/`

Bash scripts that operate WordPress via WP-CLI. Each script accepts `--wp-path` and `--file` for the data JSON. `data/<project>/` contains per-project JSON definitions (pages, menus, CPTs, ACF fields, etc.).

### `scripts/wp-api/`

Node.js scripts for REST API operations. No external dependencies — uses only built-in `http`/`https` modules. Credentials come from environment variables.

### `wp-content/themes/`

Child theme directory. All WordPress customizations go in the child theme — never modify the parent theme or WordPress core.

---

## Ownership

| Path | Owner |
|------|-------|
| `agents/*.md` | System / Documenter |
| `docs/CHANGELOG.md` | Documenter (exclusive) |
| `scripts/catalog.md` | Scripter (exclusive) |
| `scripts/wp-api/*` | Scripter |
| `scripts/wp-cli/*` | Scripter |
| `wp-content/themes/<child>/` | Backend + Frontend |

---

## What Gets Versioned

**Always version**: agent definitions, docs, scripts, child theme, config templates, `.gitignore`, `CLAUDE.md`, `agents.md`.

**Never version** (gitignored): `.env`, `wp-config.php`, `wp-content/uploads/`, cache files, logs, database dumps, `agents/VARIABLES.md`.
