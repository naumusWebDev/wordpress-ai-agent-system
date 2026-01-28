# Task: Create Legacy Initializer Agent

**Date**: 2026-01-15
**Classification**: COMPLEX
**Status**: COMPLETED

---

## Objective

Create a new agent called **Legacy Initializer** (`legacy-initializer`) for onboarding existing WordPress projects in production (or production clones) into the agent system.

This agent is **mutually exclusive** with the standard `wordpress-initializer`:
- `wordpress-initializer` → New projects from scratch
- `legacy-initializer` → Existing production projects

---

## Deliverables (in THIS repo)

1. [ ] `agents/legacy-initializer.md` — Full agent prompt
2. [ ] Update `agents.md` — Add new agent to catalog
3. [ ] `.claude/commands/run-legacy-initializer.md` — Slash command
4. [ ] Update `docs/agents/overview.md` — Add section for legacy initializer
5. [ ] Update `docs/agents/roles.md` — Document role and boundaries

---

## Agent Responsibilities (Summary)

### Phase 0 — Safety / Preconditions
- Verify .git exists (or confirm to continue)
- Verify WordPress structure (wp-admin/wp-includes/wp-content)
- Confirm: clone/local vs production server
- Confirm backup/snapshot exists
- Confirm permission to download WP core + theme for comparison

### Phase 1 — Version & Baseline
- Detect WordPress version (`wp-includes/version.php` or WP-CLI)
- Detect PHP version (if possible)
- Download exact official WP version for comparison

### Phase 2 — Core Divergence Analysis
- File-by-file diff vs official core
- Generate Core Divergence Report:
  - Modified files
  - Added files
  - Deleted files
  - Severity and recommendations

### Phase 3 — Theme Analysis
- Detect active theme
- Request original theme package (if available)
- Compare parent theme vs production
- Check for child theme
- Generate Theme Divergence Report

### Phase 4 — Plugin Landscape
- Inventory plugins (active/inactive)
- Detect mu-plugins
- Detect drop-ins (advanced-cache.php, object-cache.php, db.php)
- Detect custom scripts outside standard locations
- Classify risks

### Phase 5 — .gitignore Strategy
- Build versioning strategy based on reality:
  - Modified core → version it
  - Modified parent theme → version it
- Always ignore: uploads, caches, logs, DB dumps, secrets
- Detect anomalies (e.g., PHP files in uploads)

### Phase 6 — Agent System Installation
- Create standard structure: /docs, /scripts, /resources, /agents
- Generate legacy-specific docs:
  - `/docs/legacy/forensic-report.md`
  - `/docs/legacy/core-divergence.md`
  - `/docs/legacy/theme-divergence.md`
  - `/docs/legacy/plugin-landscape.md`
  - `/docs/legacy/risk-map.md`
  - `/docs/legacy/legacy-profile.json`

### Phase 7 — Operating Contract
- Generate rules for future agents:
  - Core modified → prohibitions
  - Parent theme modified → policies
  - Hacks detected → extra reviews required
- Update agents.md, docs/agents/overview.md with "legacy mode constraints"

---

## Critical Constraints

- **Does NOT refactor or fix** — Only detects and documents
- **Never irreversible actions** without explicit confirmation
- **Assumes backup/snapshot exists** before running
- **Mutually exclusive** with wordpress-initializer

---

## Agent Assignments

| Task | Agent | Notes |
|------|-------|-------|
| Structure design & checklist validation | Analyzer | No code |
| Write prompt (`agents/legacy-initializer.md`) | Orchestrator (direct) | Pure documentation |
| Update `agents.md` | Orchestrator (direct) | Catalog update |
| Create slash command | Orchestrator (direct) | Template |
| Update `docs/agents/*.md` | Documenter | Proper integration |
| Security & alignment review | Reviewer | Final validation |

---

## Questions Before Implementation

None — User has provided complete specification.

---

## Progress Log

- [x] Phase 1: Create `agents/legacy-initializer.md` ✅
- [x] Phase 2: Update `agents.md` ✅
- [x] Phase 3: Create `.claude/commands/run-legacy-initializer.md` ✅
- [x] Phase 4: Update `docs/agents/overview.md` ✅
- [x] Phase 5: Update `docs/agents/roles.md` ✅
- [x] Phase 6: Reviewer validation ✅ APPROVED
- [x] Phase 7: Final confirmation ✅

---

**Completed**: 2026-01-15

## Reviewer Notes

**Status**: APPROVED

**Key validations**:
- Security alignment: PASS (backup confirmation, irreversible action prevention, no secrets)
- System consistency: PASS (follows agent patterns, respects workflow)
- Boundary respect: PASS (mutual exclusion clear, Documenter ownership respected, read-only)
- Completeness: PASS (all 7 phases well-defined, outputs specified, Operating Contract documented)

**Minor enhancement applied**: Added note about preserving existing CHANGELOG.md.
