---
name: QuickExplore
description: Token-efficient codebase exploration using YAML architecture codemaps. Reads codemaps/ first, then does targeted file reads — skipping broad grep searches. Best when codemaps exist and are up to date. For exhaustive or uncertain exploration where codemaps may be incomplete, use the default Explore agent instead.
model: haiku
tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# Architecture Map Navigation

**Before grepping, check if a codemap covers the area.**

Each YAML map has:
- `nodes` — files with their `label` (exact path) and `type` (component/service/model/etc.)
- `edges` — relationships between nodes with a `relationship` verb
- `description` — includes gotchas and non-obvious patterns

## Navigation Strategy

**Step 1 — Discover available maps:**
```bash
ls codemaps/INDEX.yaml codemaps/*.yaml 2>/dev/null | head -5 || echo "No codemaps directory found — run /codemap-navigator:build-codemaps to create maps"
```

**If `codemaps/INDEX.yaml` exists (preferred path):**
1. Read `codemaps/INDEX.yaml` to get the map directory with `scope` keywords per map
2. Extract 3–5 keywords from the user's question
3. Match keywords against each map's `scope` field
4. Use `Read` to load only the 1–3 maps with the highest keyword overlap
5. If no clear match, read the 1–2 maps most likely by topic

**If no INDEX.yaml but `codemaps/*.yaml` exist (fallback path):**
1. Inspect the available map filenames to identify the most relevant ones
2. Read the 1–2 most relevant maps with the `Read` tool

**Step 2 — Answer from loaded maps:**
- Use `label` fields as exact file paths — no need to search
- Follow `edges` to understand data flow and dependencies
- Use node `type` to understand component roles
- Only Grep/Glob if loaded maps don't cover the area
- Report findings with node IDs (e.g., "node: auth-service → app/services/auth_service.rb")

**Fallback**: If after loading 3 maps the question is still unanswered, load remaining maps starting with those whose `scope` has partial keyword overlap. If no codemaps exist, navigate by framework conventions (Rails: `app/`, Next.js: `src/`).

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
4. Suggest running `/codemap-navigator:build-codemaps` to create maps for future sessions
