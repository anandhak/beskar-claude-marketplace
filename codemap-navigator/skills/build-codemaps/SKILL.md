---
name: build-codemaps
description: Scan the codebase, detect project type, and generate YAML architecture codemaps for each major feature area. Saves maps to codemaps/ directory. Run this once to bootstrap navigation for a new project.
disable-model-invocation: false
---

# Build Codemaps

Scan the current codebase and generate YAML architecture codemaps for each major feature area.

## Step 1: Detect Project Type

Check for framework indicators:
```bash
ls Gemfile package.json pyproject.toml go.mod pom.xml Cargo.toml 2>/dev/null
cat package.json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d.get('dependencies',{}).keys())[:10])" 2>/dev/null
```

Framework conventions:
- **Rails**: `app/controllers/`, `app/models/`, `app/services/`, `app/frontend/` or `app/javascript/`
- **Django**: `*/views.py`, `*/models.py`, `*/serializers.py`
- **Next.js**: `app/` or `pages/`, `components/`, `lib/` or `utils/`
- **Express/Node**: `src/routes/`, `src/controllers/`, `src/middleware/`
- **Generic**: `src/`, `lib/`, detect by file extensions

## Step 2: Identify Major Feature Areas

List the top-level source directories and identify natural feature groupings:
```bash
ls app/controllers/api/v1/ 2>/dev/null || ls src/routes/ 2>/dev/null || ls app/views/ 2>/dev/null
```

Group files into feature areas (aim for 4–10 nodes per map):
- One map per major domain (e.g., authentication, worklogs, reports, calendar)
- Each map should trace one complete user-facing flow from frontend to backend
- Skip: generated files, migrations, tests (unless the test structure itself is being mapped)

## Step 3: Generate YAML Codemaps

For each feature area, create `codemaps/<feature-slug>.yaml` using this schema:

```yaml
codemap:
  id: feature-slug
  title: Human Readable Feature Title
  description: |
    What this feature does and what the map covers.
    Include non-obvious gotchas here (e.g., field name conventions, polymorphism).
  nodes:
    - id: node-id
      label: path/to/file.rb    # relative from project root
      type: entry|component|hook|service|controller|model|job|utility|script|doc|config
      description: One-line role description
  edges:
    - from: node-id
      to: other-node-id
      relationship: calls|renders|delegates_to|imports|uses|depends_on|tests|configures
```

**Node type guide:**
- `entry` — page-level entry points, route handlers
- `component` — React/Vue/Angular UI components
- `hook` — React hooks, composables
- `service` — service objects, business logic classes
- `controller` — HTTP controllers, route handlers
- `model` — data models, ActiveRecord, Django models
- `job` — background jobs, workers, crons
- `utility` — helper modules, utilities, date/string formatters
- `config` — configuration files

**Keep each map under 1,000 tokens:** 4–12 nodes, 4–12 edges is ideal.

## Step 4: Generate Derived Mermaid Files

After creating YAML files:
```bash
# If Rails project with the script:
if [ -f "scripts/codemap_to_mermaid.rb" ]; then
  ruby scripts/codemap_to_mermaid.rb
else
  # Generate basic .mmd inline for each .yaml
  echo "No codemap_to_mermaid.rb found — generating basic Mermaid inline"
  for yaml in codemaps/*.yaml; do
    slug=$(basename "$yaml" .yaml)
    echo "flowchart LR" > "codemaps/${slug}.mmd"
    echo "  %% Generated from ${yaml}" >> "codemaps/${slug}.mmd"
    echo "  %% Run: ruby scripts/codemap_to_mermaid.rb for full diagram" >> "codemaps/${slug}.mmd"
  done
fi
```

## Step 5: Output Summary

After creating all maps, output:
- List of maps created with node/edge counts
- Total source files now covered
- Suggested next steps (run `/codemap-status` to see coverage)

## Example Output

```
✅ Created 4 codemaps:
   auth.yaml          — 8 nodes, 7 edges (OAuth → SessionController → User)
   worklogs.yaml      — 10 nodes, 9 edges (TrackerUI → WorklogService → DB)
   reports.yaml       — 7 nodes, 6 edges (ReportsSection → ReportsService)
   calendar.yaml      — 11 nodes, 10 edges (Calendar → WeeklyView → Serializers)

Run /codemap-status to see coverage and identify gaps.
```

Create the `codemaps/` directory if it doesn't exist:
```bash
mkdir -p codemaps
```
