# Task Checklist Template

Use this template for complex features that require multiple steps and coordination across agents.

**Copy this file** when starting a new feature: `cp checklist-template.md feature-name-checklist.md`

---

## Feature: [Feature Name]

**Date Started**: YYYY-MM-DD
**Requested By**: [User/Stakeholder]
**Orchestrator**: [Agent handling coordination]
**Status**: 🟡 In Progress / ✅ Complete / ❌ Blocked

---

## Quick Summary

**What**: [One-line description of what this feature does]

**Why**: [Why this feature is needed]

**Impact**: [Who/what will be affected]

---

## Requirements

### Functional Requirements
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

### Non-Functional Requirements
- [ ] Performance: [Criteria]
- [ ] Security: [Criteria]
- [ ] Accessibility: [Criteria]
- [ ] Responsive: [Devices to support]

---

## Task Breakdown

### Phase 1: Analysis
- [ ] Requirements analyzed (Analyzer)
- [ ] Task plan created
- [ ] Acceptance criteria defined
- [ ] Impact assessment complete
- [ ] User questions answered

**Owner**: Analyzer
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Complete
**Deliverable**: Analysis document in `/docs/work/feature-name-analysis.md`

---

### Phase 2: Backend Implementation
- [ ] Custom post type created (if applicable)
- [ ] AJAX handlers implemented
- [ ] WordPress hooks registered
- [ ] Data validation implemented
- [ ] Security (nonces, sanitization) implemented
- [ ] Functions added to child theme

**Owner**: Backend Engineer
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Complete
**Files Modified**:
- `/wp-content/themes/organics-child/functions.php`
- `/wp-content/themes/organics-child/inc/[feature-name].php`

---

### Phase 3: Frontend Implementation
- [ ] Template files created/modified
- [ ] CSS styling implemented
- [ ] Client-side JavaScript added
- [ ] Responsive design verified
- [ ] Accessibility features added
- [ ] UI matches design specifications

**Owner**: Frontend Designer
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Complete
**Files Modified**:
- `/wp-content/themes/organics-child/template-parts/[template].php`
- `/wp-content/themes/organics-child/style.css`
- `/wp-content/themes/organics-child/js/[script].js`

---

### Phase 4: Scripts (if applicable)
- [ ] Script requirements defined
- [ ] REST API endpoint documented
- [ ] Script implemented
- [ ] Script tested
- [ ] Script documented
- [ ] Catalog updated

**Owner**: Scripter
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Complete / ⬜ N/A
**Files Created**:
- `/scripts/wp-api/[script-name].js`
- `/scripts/catalog.md` (updated)

---

### Phase 5: Code Review
- [ ] Security review complete
- [ ] WordPress standards verified
- [ ] Performance check complete
- [ ] Accessibility review complete
- [ ] Feedback addressed

**Owner**: Reviewer
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Approved / ❌ Changes Required
**Review Report**: `/docs/work/feature-name-review.md`

**Issues Found**:
- [ ] [Issue 1] - Priority: Critical/Major/Minor
- [ ] [Issue 2] - Priority: Critical/Major/Minor

---

### Phase 6: Integration Testing
- [ ] Test plan created
- [ ] Happy path tested
- [ ] Edge cases tested
- [ ] Error conditions tested
- [ ] Cross-browser tested
- [ ] Mobile/tablet tested
- [ ] All acceptance criteria verified

**Owner**: Validator
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Pass / ❌ Fail
**Test Report**: `/docs/work/feature-name-validation.md`

**Test Results**:
- Backend: ⬜ Not Tested / ✅ Pass / ❌ Fail
- Frontend: ⬜ Not Tested / ✅ Pass / ❌ Fail
- Integration: ⬜ Not Tested / ✅ Pass / ❌ Fail
- Scripts: ⬜ Not Tested / ✅ Pass / ❌ Fail / ⬜ N/A

---

### Phase 7: Documentation
- [ ] CHANGELOG.md updated
- [ ] Feature documentation written
- [ ] Usage guide created (if applicable)
- [ ] API documentation updated (if applicable)
- [ ] Code comments added
- [ ] README updated (if needed)

**Owner**: Documenter
**Status**: ⬜ Not Started / 🟡 In Progress / ✅ Complete
**Documents Updated**:
- [ ] `/docs/CHANGELOG.md`
- [ ] `/docs/features/[feature-name].md`
- [ ] Other: __________

---

## Acceptance Criteria

From the original requirement analysis:

- [ ] Criterion 1: [Description] - [How to verify]
- [ ] Criterion 2: [Description] - [How to verify]
- [ ] Criterion 3: [Description] - [How to verify]

**All Met**: ⬜ No / ✅ Yes

---

## Dependencies

### Blocked By
- [ ] [Task/Feature that must be completed first]

### Blocks
- [ ] [Task/Feature waiting on this]

### External Dependencies
- [ ] [Plugin, service, or external factor]

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [How to prevent/address] |
| [Risk 2] | High/Med/Low | High/Med/Low | [How to prevent/address] |

---

## Timeline

| Phase | Estimated | Actual | Status |
|-------|-----------|--------|--------|
| Analysis | - | - | |
| Backend | - | - | |
| Frontend | - | - | |
| Scripts | - | - | |
| Review | - | - | |
| Validation | - | - | |
| Documentation | - | - | |

**Note**: Estimates are for planning only. Actual time may vary.

---

## Notes & Decisions

### Decision Log

**Decision 1**: [What was decided]
- **Date**: YYYY-MM-DD
- **Rationale**: [Why]
- **Alternatives Considered**: [Other options]

**Decision 2**: [What was decided]
- **Date**: YYYY-MM-DD
- **Rationale**: [Why]
- **Alternatives Considered**: [Other options]

### Implementation Notes

- [Note 1]
- [Note 2]
- [Note 3]

### Open Questions

- [ ] [Question 1] - Asked to: [User/Stakeholder] - Answered: [Yes/No]
- [ ] [Question 2] - Asked to: [User/Stakeholder] - Answered: [Yes/No]

---

## Rollback Plan

### If Something Goes Wrong

**Rollback Steps**:
1. [Step 1 to undo changes]
2. [Step 2]
3. [Step 3]

**Database Changes**:
- [How to revert database changes if any]

**Git**:
```bash
# If committed but not deployed
git revert [commit-hash]

# If in development
git reset --hard [previous-commit]
```

**Scripts**:
- [How to rollback script actions if applicable]

---

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Documentation complete
- [ ] Changelog updated
- [ ] Backup created

### Deployment
- [ ] Changes merged to main branch
- [ ] Database migrations run (if applicable)
- [ ] Theme/plugin activated (if applicable)
- [ ] Cache cleared
- [ ] Permalinks flushed (if needed)

### Post-Deployment
- [ ] Smoke test in production
- [ ] Monitor for errors
- [ ] Verify analytics/tracking (if applicable)
- [ ] User notification (if needed)

---

## Final Sign-Off

- [ ] **Orchestrator**: Feature complete and coordinated
- [ ] **Analyzer**: Requirements met (if complex)
- [ ] **Backend Engineer**: Backend implementation approved (if applicable)
- [ ] **Frontend Designer**: Frontend implementation approved (if applicable)
- [ ] **Scripter**: Scripts complete and cataloged (if applicable)
- [ ] **Reviewer**: Code quality approved
- [ ] **Validator**: Integration testing passed
- [ ] **Documenter**: Documentation complete

**Feature Status**: ⬜ In Progress / ✅ Complete / ❌ Cancelled

**Completion Date**: YYYY-MM-DD

---

**Template Version**: 1.0
**Last Updated**: 2026-01-11
**Maintained By**: Documenter Agent
