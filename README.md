# WordPress AI Agent System

A **multi-agent framework** for automating WordPress project setup and development, powered by [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What is this?

This system uses specialized AI agents to:
- **Bootstrap WordPress projects** from a briefing document
- **Create pages, menus, CPTs, ACF fields, and Bricks templates** automatically
- **Generate content** (blog posts, service pages, legal pages)
- **Review and validate** all changes for quality and security
- **Document everything** with changelogs and living docs

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/YOUR_USER/wordpress-ai-agent-system.git
cd wordpress-ai-agent-system

# Configure your project
cp .env.example .env
cp agents/VARIABLES.example.md agents/VARIABLES.md
# Edit both files with your project values
```

### 2. Choose your WordPress environment

**Option A: Docker** (self-contained)
```bash
docker compose up -d
```

**Option B: Local WP** (recommended for Windows/Mac)
- Install [Local WP](https://localwp.com/)
- Configure WP-CLI path in `agents/VARIABLES.md`
- See [docs/environment.md](docs/environment.md) for WSL setup

### 3. Create a project briefing

```bash
cp docs/wordpress-briefings/briefing-template.md docs/wordpress-briefings/briefing-myproject.md
# Fill in your project details
```

### 4. Run with Claude Code

```bash
# Start orchestrator with your request
/project:run-orchestrator Execute the briefing at /docs/wordpress-briefings/briefing-myproject.md
```

## Architecture

```
User Request → Orchestrator → Analyzer → Specialists → Reviewer → Validator → Documenter
```

**9 specialized agents**, each with clear boundaries:

| Agent | Role | Domain |
|-------|------|--------|
| Orchestrator | Coordinator | Task routing and workflow |
| Analyzer | Requirements | Decomposition and planning |
| Backend Engineer | WordPress PHP | Hooks, CPTs, child themes |
| Frontend Designer | UI/UX | Templates, CSS, JavaScript |
| Scripter | Automation | WP-CLI and REST API scripts |
| Reviewer | Quality | Security, standards, performance |
| Validator | Testing | Integration verification |
| Documenter | Documentation | Changelog and living docs |
| Legacy Initializer | Forensics | Existing site analysis |

## Key Features

- **Briefing-driven**: Define your entire project in a single Markdown file
- **WP-CLI Scripts**: 8 reusable bash scripts for full WordPress bootstrapping
- **REST API Scripts**: Node.js scripts for remote WordPress automation
- **Child-theme only**: Never modifies WordPress core or parent themes
- **ACF in database**: Fields created in DB (not PHP) so they're editable in admin
- **Bricks support**: Template creation with proper conditions
- **Docker + Local WP**: Works with either environment

## Repository Structure

```
agents/              # Agent prompt definitions
docs/                # Documentation and briefings
scripts/
  wp-cli/            # Bash scripts for WordPress setup
    data/<project>/  # JSON data files per project
  wp-api/            # Node.js REST API scripts
.claude/             # Claude Code commands and permissions
```

See [docs/repo-structure.md](docs/repo-structure.md) for full details.

## Documentation

- [Environment Setup](docs/environment.md)
- [REST API Access](docs/api-access.md)
- [Agent System Overview](docs/agents/overview.md)
- [Script Catalog](scripts/catalog.md)

## License

Private repository. All rights reserved.
