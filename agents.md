# WordPress AI Agent System

This repository operates using a multi-agent system powered by Claude Code.

All agents are defined in `/agents/*.md` and are invoked via slash commands or direct references.

---

## Agent Catalog

### 1. **Orchestrator** (`/agents/orchestrator.md`)
**Role:** Single entry point for all user requests
**Command:** `/project:run-orchestrator`
**Responsibilities:**
- Receives and classifies all incoming requests
- Determines if a task is simple (can handle directly) or complex (needs decomposition)
- Creates task plans with agent assignments
- Coordinates workflow between specialized agents
- Ensures proper hand-offs and completions

---

### 2. **Analyzer** (`/agents/analyzer.md`)
**Role:** Requirements analysis and task decomposition
**Command:** `/project:analyze-requirement`
**Responsibilities:**
- Converts high-level requirements into executable tasks
- Produces acceptance criteria, impact analysis, and risk assessment
- **NEVER touches code** (strictly analysis only)
- Routes clarifying questions to the user via Orchestrator

---

### 3. **Backend Engineer** (`/agents/backend-engineer.md`)
**Role:** WordPress backend implementation
**Command:** `/project:backend-task`
**Responsibilities:**
- Implements backend functionality using WordPress best practices
- Uses hooks, actions, filters (never modifies core or base theme)
- Works exclusively with child themes for customizations
- Ensures update-safe, reversible changes

---

### 4. **Frontend Designer** (`/agents/frontend-designer.md`)
**Role:** UI/UX implementation and visual consistency
**Command:** `/project:frontend-task`
**Responsibilities:**
- Designs and implements user interface components
- Maintains visual consistency with the theme
- Respects child theme structure
- Avoids inline styles unless explicitly approved

---

### 5. **Reviewer** (`/agents/reviewer.md`)
**Role:** Code review and quality assurance
**Command:** `/project:review-changes`
**Responsibilities:**
- Reviews backend, frontend, and script outputs
- Checks security, WordPress standards, performance
- Returns actionable change requests
- Ensures consistency across the codebase

---

### 6. **Scripter** (`/agents/scripter.md`)
**Role:** WordPress REST API automation scripts
**Command:** `/project:create-wp-api-script`
**Responsibilities:**
- Creates and maintains scripts that operate WordPress via REST API
- **Sole owner** of `/scripts/catalog.md`
- Reuses existing scripts when applicable
- Never stores secrets in files (uses environment variables)
- Documents all scripts with usage examples

---

### 7. **Validator** (`/agents/validator.md`)
**Role:** Integration testing and verification
**Command:** `/project:validate-integration`
**Responsibilities:**
- Validates integration across frontend, backend, and scripts
- Defines and executes verification checklists
- Tests routes, endpoints, permissions, and UI functionality
- Declares PASS/FAIL with evidence

---

### 8. **Documenter** (`/agents/documenter.md`)
**Role:** Documentation and changelog maintenance
**Command:** `/project:update-docs-and-changelog`
**Responsibilities:**
- **Sole owner** of `/docs/CHANGELOG.md`
- Updates all documentation based on changes
- Records what changed, why, impact, and how to verify
- Maintains living documentation

---

## Global System Rules

### Workflow
All requests follow this standard flow:

```
User Request
    ↓
Orchestrator (classify)
    ↓
Analyzer (if complex) → Task Plan
    ↓
Backend / Frontend / Scripter (implement)
    ↓
Reviewer (quality check)
    ↓
Validator (integration test)
    ↓
Documenter (update docs + CHANGELOG)
```

### Non-Negotiable Principles

1. **Human Supervision:** No agent may perform irreversible actions without explicit user confirmation
2. **Child Theme Only:** Never modify WordPress core or base theme files
3. **No Secrets in Repo:** Use `.env` for credentials, never commit secrets
4. **Analyzer Never Codes:** The Analyzer agent is strictly forbidden from touching code
5. **Exclusive Ownership:**
   - Scripter owns `/scripts/catalog.md`
   - Documenter owns `/docs/CHANGELOG.md`
6. **Git Ignored:**
   - `/wp-content/uploads/`
   - `.env`
   - Database files
   - Caches and logs

### Default Workflow for Non-Trivial Tasks

1. **Explore** - Understand current state (don't write code yet)
2. **Plan** - Create concrete plan, wait for approval
3. **Implement** - Specialized agents execute their parts
4. **Review** - Check correctness, security, WordPress standards
5. **Validate** - Confirm everything works together
6. **Document** - Update docs and CHANGELOG

---

## How to Use This System

### For Users
- Start all requests with: `/project:run-orchestrator <your request>`
- The Orchestrator will route to appropriate agents
- Complex tasks will be decomposed and you'll approve the plan before execution

### For Agents
- Read your agent definition in `/agents/<agent-name>.md` completely
- Respect your boundaries and responsibilities
- Hand off to other agents when appropriate
- Never skip the review → validate → document cycle

---

## Repository Structure

```
/
├── agents/              # Agent prompt definitions
├── docs/               # Living documentation
│   ├── agents/         # Agent system docs
│   ├── work/           # Scratchpads for complex tasks
│   └── CHANGELOG.md    # Project changelog (owned by Documenter)
├── scripts/            # WordPress automation scripts
│   ├── wp-api/         # REST API scripts
│   └── catalog.md      # Script registry (owned by Scripter)
├── resources/          # Client materials, briefs, design assets
├── wordpress/          # WordPress core (optional structure)
├── wp-content/         # Themes and plugins
├── CLAUDE.md           # Runtime guide (loaded automatically)
├── agents.md           # This file
└── docker-compose.yml  # Docker infrastructure
```

---

## Safety & Security

- All backend changes must be **update-safe** and **reversible**
- Use hooks/filters/actions instead of direct modifications
- Scripts must validate inputs and handle errors gracefully
- Never expose database credentials or API keys
- Test in development before deploying to production

---

**This is a living system. As agents evolve, this catalog will be updated by the Documenter.**
