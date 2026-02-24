# codemap-navigator
**Last Updated**: 2026-02-24
---

## Overview

codemap-navigator is a Claude Code plugin that enables token-efficient codebase navigation via lightweight YAML architecture maps. Instead of expensive grep searches across hundreds of files, you maintain small codemap files (4–12 nodes, ~1,000 tokens each) that describe feature areas and relationships. The included QuickExplore agent reads these maps first, then does targeted file reads — reducing token spend by ~70% compared to exhaustive file search.

## Quick Start

1. **Install the plugin**:
```bash
claude plugin marketplace add kadlekai-marketplace https://gitlab.beskar.tech/beskar-marketplace/beskar-claude-marketplace.git
claude plugin install codemap-navigator@kadlekai-marketplace
```

2. **Bootstrap codemaps** (one-time setup):
```
/codemap-navigator:build-codemaps
```
Scans your codebase, detects framework type (Rails, Django, Next.js, Express, etc.), and generates YAML maps in `codemaps/` directory.

3. **Use the QuickExplore agent**:
- Ask Claude Code to explore a feature area
- Request agent: `@QuickExplore` or ask Claude to use it automatically for familiar features
- Agent reads `codemaps/*.yaml` first, then does targeted file reads
- Falls back to basic conventions if maps are incomplete

4. **Keep maps current**:
```
/codemap-navigator:update-codemaps
```
Detects changed files since last commit, updates only affected maps, regenerates Mermaid diagrams.

---

## Architecture

### Codemaps (`.yaml` format)

Each map describes one feature area — e.g., authentication flow, worklog tracking, reporting pipeline.

**Schema:**
```yaml
codemap:
  id: feature-slug
  title: Human Readable Feature Title
  description: |
    What this feature does. Include non-obvious gotchas.
  nodes:
    - id: node-id
      label: path/to/file.rb          # exact path from project root
      type: entry|component|hook|service|controller|model|job|utility|config
      description: One-line role
  edges:
    - from: node-id
      to: other-node-id
      relationship: calls|renders|delegates_to|imports|uses|depends_on
```

**Node types:**
- `entry` — page entry points, route handlers
- `component` — React, Vue, Angular UI components
- `hook` — React hooks, composables
- `service` — service objects, business logic classes
- `controller` — HTTP controllers, API endpoints
- `model` — data models, ORM entities
- `job` — background jobs, workers, crons
- `utility` — helpers, formatters, utilities
- `config` — configuration files

**Keep each map lean**: 4–12 nodes, 4–12 edges, under 1,000 tokens. One map = one user-facing feature flow from frontend to backend.

### QuickExplore Agent

Haiku-based agent that prioritizes codemaps over grep:

| Aspect | QuickExplore | Default Explore |
|--------|-------------|-----------------|
| Token cost | ~70% lower | Full cost |
| Model | Haiku | Configurable |
| Works without codemaps | Falls back to conventions | Yes, always |
| Best for | Known features with current maps | Discovery, uncertain scope |

**Strategy:**
1. Lists available codemaps (`ls codemaps/*.yaml`)
2. Reads relevant map(s) before any file access
3. Uses `label` fields as exact paths — no search needed
4. Follows `edges` to trace data flow
5. Reads full files only if map doesn't cover needed detail

### Slash Commands

**`/codemap-navigator:build-codemaps`**
- Detects project type (Rails, Django, Next.js, Express, generic)
- Identifies major feature areas
- Generates YAML codemaps in `codemaps/` directory
- Runs codemap-to-mermaid script if available (Rails projects)
- Outputs summary: list of maps created with node/edge counts

**`/codemap-navigator:codemap-status`**
- Coverage report: node count, edge count per map
- Percentage of source files covered
- Top unmapped directories ranked by recent activity
- Suggested next area to map

**`/codemap-navigator:update-codemaps`**
- Detects files changed since last codemap commit
- Updates only affected maps with new nodes/edges
- Regenerates Mermaid diagrams
- Creates git commit with change summary

### Staleness Hook

`codemap-staleness-check.sh` runs on `UserPromptSubmit` event (every prompt you send to Claude).

**Warns if:**
- Architecture-related files (models, controllers, services) have changed since last codemap update
- You're about to use QuickExplore with potentially stale maps

**Typical warning:**
```
⚠ Codemaps may be stale
   Last codemap update: 6h ago
   Recent changes: app/models/user.rb (3h ago), app/services/auth_service.rb (1h ago)
   Run /codemap-navigator:update-codemaps to sync
```

---

## Configuration

### Installation Requirements

- Claude Code installed and running
- Git repository with source code
- No external dependencies (pure bash + Claude native tools)

### Framework Support

| Framework | Detection | Conventions |
|-----------|-----------|------------|
| Rails | `Gemfile` + `app/` structure | `app/controllers/`, `app/models/`, `app/services/`, `app/frontend/` or `app/javascript/` |
| Django | `pyproject.toml` or `requirements.txt` + `manage.py` | `*/views.py`, `*/models.py`, `*/serializers.py` |
| Next.js | `package.json` + `next` dependency | `app/` or `pages/`, `components/`, `lib/` or `utils/` |
| Express/Node | `package.json` + `express` dependency | `src/routes/`, `src/controllers/`, `src/middleware/`, `src/services/` |
| Generic | `src/` or `lib/` structure | Python: `*.py`, Node: `*.js/*.ts`, Ruby: `*.rb` |

### Directory Structure

```
project-root/
├── codemaps/                    # Generated YAML maps
│   ├── feature-one.yaml
│   ├── feature-two.yaml
│   └── feature-one.mmd          # Mermaid diagram (if applicable)
├── scripts/
│   └── codemap_to_mermaid.rb    # Optional Rails helper
├── app/                         # or src/, lib/, etc.
└── ...
```

---

## API / Usage

### Real Example: Kadlekai Project

Kadlekai (time tracking SaaS with Rails + React + Inertia.js) runs these commands:

**Build initial maps:**
```
/codemap-navigator:build-codemaps
```

**Generated 4 maps in 5 minutes:**
- `calendar-worklogs.yaml` (11 nodes, 10 edges) — Calendar delete/lock parity across WeeklyView, DayView, serializers
- `command-k.yaml` (8 nodes, 7 edges) — Natural language command processing (CommandPalette → LlmService)
- `reports-dashboard.yaml` (7 nodes, 6 edges) — Reporting pipeline with time-lock safety
- `timer-auto-stop.yaml` (9 nodes, 8 edges) — Stale timer detection and cleanup

**Check coverage:**
```
/codemap-navigator:codemap-status
```

**Output:**
```
Codemaps coverage report:
  4 maps covering 25/201 source files (12%)

Maps:
  calendar-worklogs.yaml     — 11 nodes, 10 edges
  command-k.yaml             — 8 nodes, 7 edges
  reports-dashboard.yaml     — 7 nodes, 6 edges
  timer-auto-stop.yaml       — 9 nodes, 8 edges

Top unmapped (by recent activity):
  1. app/frontend/components/  (38 files, changed 6h ago)
  2. app/services/             (27 files, changed 2h ago)
  3. app/controllers/api/v1/   (12 files, changed 1d ago)

Next: Create a map for one of the top unmapped areas
```

**After architecture changes, sync maps:**
```
/codemap-navigator:update-codemaps
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Commands don't appear after install | Fully restart Claude (Cmd+Q, reopen). Plugin registration requires restart. |
| QuickExplore falls back to conventions | Run `/codemap-navigator:build-codemaps` to generate initial maps. Staleness hook will warn if maps are out of date. |
| "No codemaps directory found" | Run `/codemap-navigator:build-codemaps` to bootstrap. Creates `codemaps/` and generates initial YAML maps. |
| Maps feel incomplete | Run `/codemap-navigator:codemap-status` to see coverage and suggested next areas. Add maps for high-activity unmapped directories. |
| Mermaid diagrams don't regenerate | `codemap-to-mermaid.rb` script is Rails-specific. In non-Rails projects, YAML maps work standalone (diagrams are optional). |
| Staleness warnings are too frequent | Edit `.git/hooks/post-commit` or `codemap-staleness-check.sh` to adjust file patterns or time threshold. Defaults warn on changes within 6 hours. |

---

## Related

- **Codemaps in this repo**: `/codemaps/*.yaml` (examples in Kadlekai project)
- **Build command details**: `commands/build-codemaps.md`
- **Status command details**: `commands/codemap-status.md`
- **Update command details**: `commands/update-codemaps.md`
- **QuickExplore agent**: `agents/QuickExplore.md`
- **Staleness hook**: `hooks/codemap-staleness-check.sh`
- **Plugin config**: `plugin.json`
- **Beskar Marketplace**: https://gitlab.beskar.tech/beskar-marketplace/beskar-claude-marketplace
