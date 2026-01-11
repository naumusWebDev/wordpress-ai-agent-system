# Agent Roles and Responsibilities

Detailed breakdown of each agent's role, scope, and boundaries.

---

## Quick Reference

| Agent | Primary Domain | Can Modify | Cannot Modify |
|-------|---------------|------------|---------------|
| Orchestrator | Coordination | Docs (simple) | Code |
| Analyzer | Analysis | Analysis docs | Code (forbidden) |
| Backend Engineer | WordPress Backend | Child theme functions | Parent theme, core |
| Frontend Designer | UI/UX | Child theme templates/CSS | Parent theme, backend logic |
| Reviewer | Quality Assurance | Review reports | Code (reviews only) |
| Scripter | Automation | `/scripts/wp-api/`, catalog | WordPress code |
| Validator | Testing | Test reports | Code (tests only) |
| Documenter | Documentation | `/docs/`, CHANGELOG.md | Code |

---

## Detailed Agent Profiles

### Orchestrator 🎯

**Full Name**: Orchestrator Agent
**Command**: `/project:run-orchestrator`
**Definition**: `/agents/orchestrator.md`

#### Role
Single entry point for all user requests. Coordinates workflow between specialized agents.

#### Responsibilities
- Receive and classify user requests
- Assess complexity (simple vs complex)
- Create task plans with assignments
- Coordinate multi-agent workflows
- Track dependencies and progress
- Ensure proper hand-offs
- Report status to user

#### Authority
- Can handle simple tasks directly (docs, structure)
- Can delegate to any specialist agent
- Can invoke multiple agents in parallel
- Final arbiter of workflow decisions

#### Limitations
- Should not implement code (delegates to specialists)
- Cannot perform code reviews (delegates to Reviewer)
- Cannot test integrations (delegates to Validator)
- Cannot update CHANGELOG.md directly (delegates to Documenter)

#### Outputs
- Task plans (for complex requests)
- Task briefs (for each agent)
- Progress updates (to user)
- Completion summaries

---

### Analyzer 🔍

**Full Name**: Analyzer Agent
**Command**: `/project:analyze-requirement`
**Definition**: `/agents/analyzer.md`

#### Role
Converts high-level requirements into executable task plans with clear acceptance criteria.

#### Responsibilities
- Requirement analysis and clarification
- Task decomposition
- Acceptance criteria definition
- Impact analysis
- Risk assessment
- Implementation guidance (high-level)
- Recommend agent assignments

#### Authority
- Can explore codebase (read-only)
- Can ask clarifying questions
- Can propose approaches
- Can define task scope

#### Limitations
- **CRITICAL**: Absolutely forbidden from writing or modifying code
- Cannot implement features
- Cannot make code changes
- Cannot edit files (except analysis documents)

#### Outputs
- Analysis reports
- Task breakdowns
- Acceptance criteria
- Impact assessments
- Clarifying questions

---

### Backend Engineer ⚙️

**Full Name**: Backend Engineer Agent
**Command**: `/project:backend-task`
**Definition**: `/agents/backend-engineer.md`

#### Role
WordPress backend specialist implementing server-side functionality using WordPress best practices.

#### Responsibilities
- Custom post types and taxonomies
- WordPress hooks (actions and filters)
- AJAX handlers
- Custom REST API endpoints
- Child theme `functions.php` modifications
- Database operations (using WordPress APIs)
- Plugin integration

#### Authority
- Can modify `/wp-content/themes/organics-child/functions.php`
- Can create files in `/wp-content/themes/organics-child/inc/`
- Can enqueue scripts/styles
- Can register custom WordPress functionality

#### Limitations
- **CRITICAL**: Cannot modify parent theme (`/wp-content/themes/organics/`)
- Cannot modify WordPress core files
- Cannot edit plugin files directly
- Cannot create UI templates (Frontend Designer's job)
- Cannot create REST API scripts (Scripter's job)

#### Outputs
- Backend code (PHP)
- WordPress hooks and filters
- AJAX endpoints
- Custom functionality

---

### Frontend Designer 🎨

**Full Name**: Frontend Designer Agent
**Command**: `/project:frontend-task`
**Definition**: `/agents/frontend-designer.md`

#### Role
UI/UX specialist responsible for visual implementation and user interface components.

#### Responsibilities
- Template file creation and overrides
- CSS styling
- HTML structure
- Client-side JavaScript (UI interactions)
- Responsive design
- Accessibility implementation

#### Authority
- Can create/modify templates in `/wp-content/themes/organics-child/`
- Can modify `/wp-content/themes/organics-child/style.css`
- Can create CSS files in `/wp-content/themes/organics-child/css/`
- Can create JS files in `/wp-content/themes/organics-child/js/`

#### Limitations
- **CRITICAL**: Cannot modify parent theme (`/wp-content/themes/organics/`)
- Cannot implement backend logic (Backend Engineer's job)
- Cannot create AJAX handlers (Backend Engineer's job)
- Cannot modify `functions.php` without coordinating with Backend Engineer

#### Outputs
- Template files
- CSS stylesheets
- Client-side JavaScript
- UI components

---

### Reviewer ✅

**Full Name**: Reviewer Agent
**Command**: `/project:review-changes`
**Definition**: `/agents/reviewer.md`

#### Role
Quality assurance specialist ensuring code meets security, quality, and WordPress standards.

#### Responsibilities
- Security review (sanitization, escaping, nonces)
- WordPress Coding Standards compliance
- Performance review
- Accessibility review
- Code quality assessment
- Approve or reject changes with feedback

#### Authority
- Can approve changes
- Can require changes
- Can reject changes
- Final say on code quality

#### Limitations
- Does not implement fixes (provides feedback)
- Does not skip security checks
- Does not approve without thorough review

#### Outputs
- Code review reports
- Approval/rejection decisions
- Actionable feedback
- Security findings

---

### Scripter 🤖

**Full Name**: Scripter Agent
**Command**: `/project:create-wp-api-script`
**Definition**: `/agents/scripter.md`

#### Role
Automation specialist creating REST API scripts for batch operations and integrations.

#### Responsibilities
- Create REST API automation scripts
- Maintain `/scripts/catalog.md` (exclusive ownership)
- Document all scripts
- Provide usage examples
- Create rollback strategies
- Reuse existing scripts

#### Authority
- **Exclusive owner of `/scripts/catalog.md`**
- Full control of `/scripts/wp-api/`
- Can create utility libraries
- Can define script conventions

#### Limitations
- Cannot write WordPress backend code (Backend Engineer's job)
- Cannot modify theme files
- Cannot create UI components
- Cannot store credentials in scripts

#### Outputs
- Node.js/Python/Bash scripts
- Script documentation
- `/scripts/catalog.md` updates
- Usage examples

---

### Validator 🧪

**Full Name**: Validator Agent
**Command**: `/project:validate-integration`
**Definition**: `/agents/validator.md`

#### Role
Integration tester verifying end-to-end functionality across all components.

#### Responsibilities
- Functional testing
- Integration testing (backend + frontend + scripts)
- Verify acceptance criteria
- Test user workflows
- Validate API endpoints
- Declare PASS/FAIL with evidence

#### Authority
- Can approve implementations
- Can reject implementations
- Can require fixes
- Final gate before deployment

#### Limitations
- Does not fix bugs (reports them)
- Does not skip test cases
- Does not assume things work (verifies everything)

#### Outputs
- Test reports
- Validation checklists
- PASS/FAIL declarations
- Bug reports

---

### Documenter 📝

**Full Name**: Documenter Agent
**Command**: `/project:update-docs-and-changelog`
**Definition**: `/agents/documenter.md`

#### Role
Documentation specialist maintaining all project documentation and changelog.

#### Responsibilities
- **Exclusive owner of `/docs/CHANGELOG.md`**
- Update technical documentation
- Create usage guides
- Record architectural decisions
- Maintain consistency across docs
- Archive obsolete documentation

#### Authority
- **Exclusive ownership of `/docs/CHANGELOG.md`**
- Full control of `/docs/` directory
- Can create/update/archive documentation
- Can define documentation standards

#### Limitations
- Does not implement features (documents them)
- Does not skip changelog entries
- Does not let documentation become outdated

#### Outputs
- CHANGELOG.md updates
- Technical documentation
- Usage guides
- API documentation
- Runbooks

---

## Cross-Agent Collaboration

### Backend + Frontend (Common Scenario)

**Scenario**: Adding a contact form

**Backend Engineer**:
- Creates AJAX handler for form submission
- Implements nonce verification
- Processes and stores form data
- Returns JSON response

**Frontend Designer**:
- Creates form HTML in template
- Styles the form with CSS
- Implements client-side validation
- Handles AJAX submission (JavaScript)

**Coordination**: Via Orchestrator
- Orchestrator creates task plan
- Both agents work on their parts
- Reviewer checks both implementations
- Validator tests integration

### Backend + Scripter (API Development)

**Scenario**: Custom REST API endpoint with automation script

**Backend Engineer**:
- Creates custom REST API endpoint
- Implements authentication and permissions
- Returns appropriate data

**Scripter**:
- Creates script to consume the endpoint
- Documents the script
- Adds to catalog

**Coordination**: Backend creates endpoint first, Scripter builds script second

---

## Decision Framework: Which Agent?

### Question: Which agent should handle this?

#### Code Changes Needed?

**No** → Orchestrator (if simple docs) or Documenter

**Yes** → Continue...

#### What kind of code?

**Backend (PHP, hooks, AJAX, database)** → Backend Engineer

**Frontend (templates, CSS, UI JavaScript)** → Frontend Designer

**Scripts (REST API automation)** → Scripter

#### After Implementation?

**Always** → Reviewer → Validator → Documenter

---

## Exclusive Ownership Rules

### CHANGELOG.md
- **Owner**: Documenter
- **Others**: ❌ Cannot modify directly
- **Process**: Request Documenter to update

### /scripts/catalog.md
- **Owner**: Scripter
- **Others**: ❌ Cannot modify directly
- **Process**: Request Scripter to update

### Child Theme functions.php
- **Owner**: Backend Engineer
- **Others**: Can coordinate but Backend owns final implementation

### Child Theme Templates
- **Owner**: Frontend Designer
- **Others**: Can coordinate but Frontend owns final implementation

---

## Communication Flows

### User → Agent
```
❌ Direct (bypasses coordination)
✅ Via Orchestrator
```

### Agent → Agent
```
❌ Direct communication
✅ Via Orchestrator (centralized coordination)
```

### Agent → User
```
❌ Direct updates
✅ Via Orchestrator (maintains context)
```

**Exception**: Agents can ask clarifying questions via Orchestrator

---

## Summary

- **8 specialized agents**, each with clear domain
- **Orchestrator** coordinates everything
- **Analyzer** never writes code (analysis only)
- **Backend** and **Frontend** work in child theme only
- **Reviewer** is mandatory for all code
- **Validator** is final quality gate
- **Scripter** owns scripts and catalog
- **Documenter** owns CHANGELOG.md and documentation

**Golden Rule**: Respect boundaries, coordinate via Orchestrator, never skip review/validation/documentation.

---

**Last Updated**: 2026-01-11
**Maintained By**: Documenter Agent
