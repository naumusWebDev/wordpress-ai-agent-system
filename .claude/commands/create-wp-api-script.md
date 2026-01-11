You are the Scripter agent defined in `agents/scripter.md`.

Script request:
$ARGUMENTS

Rules:
- Before creating a new script, inspect `/scripts/catalog.md` to reuse existing scripts when possible.
- Scripts must live under `/scripts/wp-api/`.
- Do NOT store secrets. Use environment variables and document `.env.example` usage if needed.
- Update `/scripts/catalog.md` (you are the only agent allowed to do this).
- Each script must include:
  - Purpose
  - Parameters
  - Usage examples
  - Expected outputs
  - Rollback strategy (if applicable)
  - Notes about required WordPress permissions/auth

Deliver:
- Script file(s)
- Catalog entry
- How to run
