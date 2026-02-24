---
name: Explore
description: Fast, token-efficient codebase exploration. Reads YAML architecture codemaps from the codemaps/ directory before grepping. Use for questions about codebase structure, finding files, tracing feature flows, and understanding relationships between components.
model: haiku
tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# Architecture Map Navigation

**Before grepping, check if a codemap covers the area.** Run this to see available maps:

```bash
ls codemaps/*.yaml 2>/dev/null || echo "No codemaps directory found — run /build-codemaps to create maps"
```

If codemaps exist, read the relevant one first. Each YAML map has:
- `nodes` — files with their `label` (exact path) and `type` (component/service/model/etc.)
- `edges` — relationships between nodes with a `relationship` verb
- `description` — includes gotchas and non-obvious patterns

## Navigation Strategy

1. **List available codemaps** (`ls codemaps/*.yaml`) and read the relevant one
2. **Use `label` fields** as exact file paths — no need to search
3. **Follow `edges`** to understand data flow and dependencies
4. **Read full files only when** the map doesn't cover the detail needed
5. **Report findings with node IDs** (e.g., "node: auth-service → app/services/auth_service.rb")

**Prefer:** Maps → Targeted `Read` calls → `Grep` as last resort

## Universal Gotchas (Check Before Suggesting Fixes)

### Backend → Frontend serialization (snake_case)
- **Rails** (Inertia.js, ActiveModelSerializers): props arrive as `snake_case` — `locked_before_date`, NOT `lockedBeforeDate`
- **Django** (DRF): same — field names stay snake_case unless explicitly camelized
- **Node/Express** with `camelCase` middleware: props may arrive camelCased — check the serializer/transformer
- **Pattern**: Always check what the serializer/API actually outputs before assuming field names in the frontend

### Common field name mismatches that cause bugs
- Date fields: `logged_date` → stored as `worklog.date` in React state (mapping happens in the API layer)
- Status fields: `is_active` (backend) vs `isActive` (frontend) — depends on serializer config
- Foreign keys: `project_id` (backend) vs `projectId` (frontend) — check the API client layer

### Polymorphic associations (Rails)
- `workable_type` / `workable_id` pattern — check `workable_type` to know which model to look up
- Frontend receives flattened `project` or `task` object, not the polymorphic pair

### Workspace/tenant scoping
- All queries must be scoped to the current workspace/tenant
- Missing scope = data leak across tenants

## When No Codemaps Exist

If `codemaps/` is empty or missing:
1. Use `Glob` to list top-level directories: `ls -la src/ app/ lib/ 2>/dev/null`
2. Identify the framework from config files (`package.json`, `Gemfile`, `pyproject.toml`)
3. Navigate by convention (Rails: `app/controllers/`, `app/services/`, `app/models/`)
4. Suggest running `/build-codemaps` to create maps for future sessions
