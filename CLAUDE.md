# WORDPRESS-AI — Claude Code Runtime Guide

This repository is operated using **Claude Code** and a **multi-agent system** defined in `/agents`.

Claude automatically loads this file into context.  
Treat it as the **living contract** between humans and agents.

---

## 1) Project philosophy

This is not a traditional WordPress repo.

This is a **reproducible, agent-driven WordPress system** where:
- Humans define intent and approve decisions
- Agents analyze, plan, implement, validate, and document
- Everything is auditable and versioned

No agent may take irreversible actions without confirmation.

---

## 2) Repository structure (source of truth)

/agents → Agent definitions (prompts)
/docs → Living documentation
/scripts → Scripts that operate WordPress via API
/resources → Client materials, briefs, PDFs, notes
/wp-content → Themes and plugins (uploads excluded)

Never version:
- `wp-content/uploads`
- caches
- logs
- real databases
- secrets

---

## 2b) Project variables

All project-specific values used inside agent prompts (theme slugs, URLs, prefixes, etc.)
are defined in `/agents/VARIABLES.md`. When adapting this system for a different WordPress
project, that is the only file that needs updating. Every `{{PLACEHOLDER}}` in an agent file
maps to a value in that file.

---

## 3) How this system works

All requests enter through the **Orchestrator**.

Flow:
User
↓
Orchestrator
↓
Analyzer (if complex)
↓
Backend / Frontend / Scripter
↓
Reviewer
↓
Validator
↓
Documenter (updates docs + CHANGELOG)

The Analyzer **never touches code**.  
The Scripter is the **only agent** that may write or modify scripts.  
The Documenter is the **only agent** that may update `/docs/CHANGELOG.md`.

---

## 4) Default workflow (IMPORTANT)

For any non-trivial task:

1. **Explore**
   - Read relevant files
   - Understand the current state
   - Do NOT write code yet

2. **Plan**
   - Propose a concrete plan
   - Break into tasks
   - Assign to agents
   - Wait for human approval

3. **Implement**
   - Backend / Frontend / Scripter do their parts

4. **Review**
   - Reviewer checks correctness, security, WordPress best practices

5. **Validate**
   - Validator confirms everything works together

6. **Document**
   - Documenter updates docs and CHANGELOG

Skipping steps leads to broken systems.

---

## 5) WordPress engineering rules

Always:
- Use **child themes** for any UI or template change
- Use **hooks, filters, and actions**
- Never modify theme base files
- Never modify WordPress core
- Prefer plugins or mu-plugins for behavior

All backend work must be:
- Update-safe
- Reversible
- Documented

---

## 6) WordPress API & Scripts

### WP-CLI Scripts (preferred for Local WP)

For projects with direct filesystem and DB access (e.g., Local WP, Docker),
use the **reusable WP-CLI scripts** in:

```
/scripts/wp-cli/
```

These scripts handle the full WordPress project bootstrapping:

| Script | Purpose |
|---|---|
| `run-setup.sh` | Orchestrator — runs all steps in order |
| `configure-wp.sh` | WordPress settings (timezone, language, permalinks) |
| `create-pages.sh` | Create pages from JSON |
| `create-menus.sh` | Create navigation menus from JSON |
| `register-cpt.sh` | Register Custom Post Types in child theme |
| `create-acf-fields.sh` | Create ACF field groups **in database** |
| `create-bricks-templates.sh` | Create Bricks templates with conditions |
| `create-posts.sh` | Create posts/CPT entries with ACF fields |

Data files go in `/scripts/wp-cli/data/<project-name>/` (JSON).

**CRITICAL RULES for WP-CLI scripts:**
- **ACF fields MUST be created in the database** (via `create-acf-fields.sh`), NOT via `acf_add_local_field_group()` in PHP. Local field groups are not editable in the ACF admin UI.
- **Bricks templates** require proper `_bricks_template_type` and `_bricks_template_conditions` meta. Use `create-bricks-templates.sh` to ensure correct format.
- All scripts support `--dry-run` for safe preview.

### REST API Scripts (remote access)

For projects where only REST API access is available:

```
/scripts/wp-api/
```

The **Scripter** maintains `/scripts/catalog.md`.

Before creating a new script:
- Check if one already exists in the catalog
- Reuse if possible
- Otherwise create a new one and register it

Scripts must:
- Use environment variables for auth
- Never store secrets
- Include usage examples
- Be logged in catalog.md

### Briefing-driven project setup

For new WordPress projects, a **briefing file** defines all content and structure.
Briefings live in `/docs/wordpress-briefings/` using the template `briefing-template.md`.

The recommended workflow is:
1. Fill out the briefing with pages, menus, CPTs, ACF fields, Bricks templates, content
2. Create JSON data files in `/scripts/wp-cli/data/<project>/` matching the briefing
3. Run `run-setup.sh --data-dir=data/<project>` to bootstrap everything

---

## 7) Secrets & credentials

Never store:
- API keys
- passwords
- tokens

Use:
- `.env.example` (placeholders only)
- real secrets via environment variables or secret managers

---

## 8) Claude Code usage

Claude Code automatically:
- Loads this file
- Loads `/agents/*.md` when referenced
- Has access to shell and filesystem (with permissions)

Use slash commands from `.claude/commands/`.

Examples:
- `/project:run-orchestrator`
- `/project:analyze-requirement`
- `/project:create-wp-api-script`
- `/project:review-changes`
- `/project:update-docs-and-changelog`

---

## 9) Context hygiene

For long sessions:
- Use `/clear` between tasks
- Use scratchpads in `/docs/work/`
- Keep one feature = one work file

---

## 10) Safety

Never:
- Run destructive commands blindly
- Bypass permissions unless in a disposable environment
- Delete production data
- Expose secrets in logs or docs

This system is designed to be powerful **and** safe.

Follow it.