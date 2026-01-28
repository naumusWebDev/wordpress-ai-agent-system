# Agent System Overview

This document provides a high-level overview of the multi-agent system used in this WordPress project.

---

## What is the Agent System?

This project uses a **multi-agent architecture** where specialized AI agents handle different aspects of WordPress development. Each agent has:
- A **specific domain of expertise**
- **Clear boundaries** and responsibilities
- **Defined inputs and outputs**
- **Hand-off protocols** with other agents

---

## Why Use Multiple Agents?

### Traditional Approach (Single Agent)
```
User Request → Single AI → Code + Docs + Tests + Everything
```

**Problems**:
- Loss of focus and context
- Inconsistent quality across domains
- Difficult to maintain standards
- No specialization or expertise

### Multi-Agent Approach (This Project)
```
User Request → Orchestrator → Specialized Agents → Coordinated Outcome
```

**Benefits**:
- ✅ **Specialization**: Each agent masters their domain
- ✅ **Quality**: Dedicated reviewers and validators
- ✅ **Consistency**: Standard workflows enforced
- ✅ **Accountability**: Clear ownership of deliverables
- ✅ **Scalability**: Easy to add new agent types

---

## The Nine Agents

### 1. Orchestrator 🎯
**Role**: Coordinator and workflow manager
**Domain**: Task classification and delegation
**Invocation**: `/project:run-orchestrator [request]`

**Responsibilities**:
- Single entry point for all user requests
- Classify tasks (simple vs complex)
- Create task plans with agent assignments
- Coordinate workflows
- Track progress

**Does NOT**:
- Implement code (delegates to specialists)
- Perform code reviews
- Write documentation

---

### 2. Analyzer 🔍
**Role**: Requirements analyst
**Domain**: Requirement decomposition and impact analysis
**Invocation**: `/project:analyze-requirement [requirement]`

**Responsibilities**:
- Convert high-level requirements into tasks
- Define acceptance criteria
- Assess impact and risks
- Recommend implementation approaches

**Does NOT**:
- **Write or modify code** (strictly forbidden)
- Implement features
- Perform testing

**Critical Rule**: The Analyzer **NEVER touches code**. Analysis only.

---

### 3. Backend Engineer ⚙️
**Role**: WordPress backend specialist
**Domain**: Server-side WordPress implementation
**Invocation**: `/project:backend-task [task]`

**Responsibilities**:
- Custom post types and taxonomies
- WordPress hooks (actions/filters)
- AJAX handlers
- REST API endpoints
- Child theme `functions.php`

**Does NOT**:
- Modify parent theme or WordPress core
- Create UI components (Frontend's job)
- Write REST API scripts (Scripter's job)

**Critical Rule**: **Child theme only, never parent theme.**

---

### 4. Frontend Designer 🎨
**Role**: UI/UX specialist
**Domain**: User interface and visual design
**Invocation**: `/project:frontend-task [task]`

**Responsibilities**:
- Template file overrides (child theme)
- CSS and styling
- HTML structure
- Client-side JavaScript (UI only)
- Responsive design
- Accessibility

**Does NOT**:
- Modify parent theme
- Implement backend logic
- Write server-side code

**Critical Rule**: **Child theme only, maintain visual consistency.**

---

### 5. Reviewer ✅
**Role**: Quality assurance specialist
**Domain**: Code review and standards compliance
**Invocation**: `/project:review-changes [changes]`

**Responsibilities**:
- Security review (sanitization, escaping, nonces)
- WordPress Coding Standards
- Performance review
- Accessibility review
- Approve or reject changes

**Does NOT**:
- Implement fixes (provides feedback instead)
- Skip security checks
- Approve without thorough review

**Critical Rule**: **No code proceeds without review.**

---

### 6. Scripter 🤖
**Role**: Automation specialist
**Domain**: REST API scripts and batch operations
**Invocation**: `/project:create-wp-api-script [task]`

**Responsibilities**:
- REST API automation scripts
- Bulk operations scripts
- Data import/export tools
- **Sole owner of `/scripts/catalog.md`**

**Does NOT**:
- Write WordPress backend code
- Modify theme files
- Store credentials in scripts

**Critical Rule**: **Exclusive owner of script catalog and `/scripts/wp-api/`**

---

### 7. Validator 🧪
**Role**: Integration tester
**Domain**: End-to-end testing and verification
**Invocation**: `/project:validate-integration [feature]`

**Responsibilities**:
- Functional testing
- Integration testing (frontend + backend + scripts)
- Verify acceptance criteria
- Declare PASS/FAIL with evidence

**Does NOT**:
- Fix bugs (reports them)
- Skip test cases
- Approve without proper testing

**Critical Rule**: **Validation is the final quality gate.**

---

### 8. Documenter 📝
**Role**: Documentation specialist
**Domain**: Documentation and changelog management
**Invocation**: `/project:update-docs-and-changelog [changes]`

**Responsibilities**:
- **Sole owner of `/docs/CHANGELOG.md`**
- Update technical documentation
- Create usage guides
- Record architectural decisions

**Does NOT**:
- Implement features
- Skip changelog entries
- Let documentation become outdated

**Critical Rule**: **Exclusive owner of CHANGELOG.md. No change is complete without documentation.**

---

### 9. Legacy Initializer 🔍
**Role**: Forensic analyst for legacy WordPress projects
**Domain**: Existing production site onboarding
**Invocation**: `/project:run-legacy-initializer`

**Responsibilities**:
- Forensic reconnaissance of existing WordPress installations
- Core, theme, and plugin divergence analysis
- Risk assessment and documentation
- Agent system installation with legacy constraints
- Operating Contract generation

**Does NOT**:
- Fix or refactor code (analysis only)
- Run without backup confirmation
- Modify existing files

**Critical Rules**:
- **Mutually exclusive** with `wordpress-initializer`
- **Requires backup confirmation** before any analysis
- **Read-only operation** — documents findings, never fixes

---

## Initializer Agents (Special Category)

The system includes two mutually exclusive initializer agents:

| Agent | Use Case | When to Use |
|-------|----------|-------------|
| `wordpress-initializer` | **New projects** | Starting fresh with a new WordPress installation |
| `legacy-initializer` | **Existing projects** | Adopting a production site or legacy codebase |

**Rule**: Only ONE initializer runs per project, ever. They cannot coexist.

### Legacy Mode Constraints

When `legacy-initializer` has run, it generates an **Operating Contract** that restricts future agent behavior:

| Finding | Constraint Applied |
|---------|-------------------|
| Core modified | Core updates blocked, extra review required |
| Parent theme modified | Theme updates blocked until child migration |
| No child theme | Must create before any customization |
| Security anomalies | Full audit required before deployment |

Agents must check `/docs/legacy/legacy-profile.json` before making changes.

---

## Standard Workflow

### For Simple Tasks

```
User Request
    ↓
Orchestrator
    ↓
[Handles directly or delegates to single agent]
    ↓
Documenter (update docs if needed)
    ↓
Complete
```

**Example**: "Update the README to explain Docker setup"
- Orchestrator → Documenter → Done

---

### For Complex Tasks (Full Cycle)

```
User Request
    ↓
Orchestrator (classify: complex)
    ↓
Analyzer (decompose requirements)
    ↓
Implementation Agents
    ├─ Backend Engineer (server-side)
    ├─ Frontend Designer (UI/UX)
    └─ Scripter (automation)
    ↓
Reviewer (quality check)
    ↓
Validator (integration test)
    ↓
Documenter (update docs + CHANGELOG)
    ↓
Orchestrator (summary to user)
    ↓
Complete
```

**Example**: "Add a product filtering feature"
1. **Orchestrator**: Classifies as complex
2. **Analyzer**: Breaks down into backend, frontend, and validation tasks
3. **Backend Engineer**: Creates filter query logic and AJAX endpoint
4. **Frontend Designer**: Builds filter UI and applies to template
5. **Reviewer**: Checks security, WordPress standards, accessibility
6. **Validator**: Tests filter functionality end-to-end
7. **Documenter**: Updates CHANGELOG and creates usage guide
8. **Orchestrator**: Reports completion to user

---

## Agent Boundaries

### Exclusive Ownership

| Resource | Owner | Others |
|----------|-------|--------|
| `/docs/CHANGELOG.md` | Documenter | ❌ Cannot modify |
| `/scripts/catalog.md` | Scripter | ❌ Cannot modify |
| `/agents/*.md` | Documenter | ✅ Can read |
| Child theme `functions.php` | Backend Engineer | ✅ Can read |
| Child theme templates | Frontend Designer | ✅ Can read |

### Collaboration Zones

| Task | Primary Agent | Supporting Agent |
|------|--------------|------------------|
| Form submission | Backend Engineer (handler) | Frontend Designer (UI) |
| Template with dynamic data | Frontend Designer (template) | Backend Engineer (data) |
| API script documentation | Scripter (script) | Documenter (docs) |

---

## Communication Protocols

### All Requests Enter via Orchestrator

```
❌ User → Backend Engineer directly
✅ User → Orchestrator → Backend Engineer
```

**Why**: Orchestrator ensures proper workflow, dependencies, and hand-offs.

### Agents Don't Talk Directly

```
❌ Backend Engineer → Documenter
✅ Backend Engineer → Orchestrator → Documenter
```

**Why**: Orchestrator maintains coordination and prevents chaos.

### Exception: Orchestrator May Invoke Multiple Agents

```
✅ Orchestrator → [Backend + Frontend + Scripter] in parallel
```

**Why**: Orchestrator can parallelize independent tasks.

---

## Quality Gates

### Gate 1: Analysis (Analyzer)
- **Question**: Are requirements clear and feasible?
- **Outcome**: Task plan or clarifying questions

### Gate 2: Implementation (Specialist Agents)
- **Question**: Is the code/UI/script implemented correctly?
- **Outcome**: Working implementation

### Gate 3: Review (Reviewer)
- **Question**: Does this meet quality and security standards?
- **Outcome**: Approved / Changes Required / Rejected

### Gate 4: Validation (Validator)
- **Question**: Does everything work together end-to-end?
- **Outcome**: PASS / FAIL

### Gate 5: Documentation (Documenter)
- **Question**: Is this properly documented?
- **Outcome**: CHANGELOG updated, docs complete

---

## Non-Negotiable Rules

### For All Agents

1. **Never modify WordPress core files**
2. **Never modify parent theme** (`/wp-content/themes/organics/`)
3. **Never commit secrets** (`.env`, passwords, API keys)
4. **Never skip human confirmation** for irreversible actions
5. **Always respect agent boundaries**

### For Specific Agents

**Analyzer**:
- ❌ **Absolutely forbidden to write code**

**Backend Engineer & Frontend Designer**:
- ❌ **Never touch parent theme, only child theme**

**Scripter**:
- ❌ **Never store credentials in script files**

**Reviewer**:
- ❌ **Never skip security checks**

**Documenter**:
- ❌ **Never skip CHANGELOG entries**

---

## Agent Interaction Patterns

### Sequential (One After Another)

```
Backend Engineer → Reviewer → Validator → Documenter
```

**When**: Changes depend on previous step completion

### Parallel (Simultaneous)

```
                 ┌─ Backend Engineer ─┐
Orchestrator ────┼─ Frontend Designer ─┼── Reviewer
                 └─ Scripter ─────────┘
```

**When**: Tasks are independent and can run concurrently

### Iterative (Feedback Loop)

```
Backend Engineer → Reviewer → [Issues Found] → Backend Engineer
```

**When**: Changes required after review

---

## Invoking Agents

### Via Slash Commands (Recommended)

```
/project:run-orchestrator Add a newsletter signup form
/project:analyze-requirement Implement product filtering
/project:backend-task Create custom post type for events
/project:frontend-task Style the contact form
/project:review-changes Check the latest changes
/project:create-wp-api-script Bulk import products from CSV
/project:validate-integration Test the newsletter feature
/project:update-docs-and-changelog Document the new API endpoint
```

### Via Direct Reference (in conversation)

```
"Please invoke the Analyzer to break down this requirement"
"Have the Backend Engineer implement the hook"
"Ask the Documenter to update the CHANGELOG"
```

---

## Success Metrics

### Agent System Working Well

✅ Clear task ownership
✅ No duplicated work
✅ Consistent quality across domains
✅ All changes reviewed before deployment
✅ Complete documentation
✅ User knows what's happening at each step

### Agent System Needs Improvement

❌ Confusion about who does what
❌ Agents stepping on each other's toes
❌ Quality inconsistencies
❌ Undocumented changes
❌ Skipped review or validation steps

---

## Troubleshooting

### "Which agent should I use?"

**Start with Orchestrator** (`/project:run-orchestrator`). It will route to the appropriate specialist.

### "Can I skip the Reviewer?"

❌ **No.** Code review is mandatory for all code changes.

### "What if a task involves multiple agents?"

✅ **Orchestrator coordinates multi-agent tasks.** It creates a plan, assigns agents, and manages hand-offs.

### "Can Frontend modify functions.php?"

❌ **No.** `functions.php` is Backend's domain. Frontend handles templates and styles. Coordinate via Orchestrator.

---

## Evolution of the System

### Adding New Agents

1. Define the agent's domain and boundaries
2. Create agent prompt in `/agents/[new-agent].md`
3. Update `/agents.md` catalog
4. Add slash command in `.claude/commands/`
5. Document in this overview

### Modifying Agent Roles

1. Update agent definition in `/agents/[agent].md`
2. Update `/docs/agents/roles.md`
3. Update CHANGELOG.md
4. Communicate changes to users

---

## Further Reading

- [Agent Roles and Responsibilities](./roles.md) - Detailed agent descriptions
- [CLAUDE.md](../../CLAUDE.md) - Runtime guide and project philosophy
- [agents.md](../../agents.md) - Quick agent catalog

---

**Last Updated**: 2026-01-15
**Maintained By**: Documenter Agent
