---
description: First-run guided demo. Picks one feature area from your codebase, builds a single example codemap, and shows how QuickExplore uses it — so you see the plugin working before committing to a full build.
---

# Codemap Navigator — Quickstart

Welcome! Let's prove this works in your codebase before you commit to anything.

We'll build **one codemap** for one feature area, then show exactly how QuickExplore would use it instead of grep. Takes about 60 seconds.

---

## Step 1: Check for Existing Maps

```bash
ls codemaps/*.yaml 2>/dev/null && echo "MAPS_EXIST" || echo "NO_MAPS"
```

If `MAPS_EXIST`: skip to Step 4 — you already have maps, just show QuickExplore using them.

If `NO_MAPS`: continue to Step 2.

---

## Step 2: Detect Your Project and Pick One Feature

Detect the framework:
```bash
ls Gemfile package.json pyproject.toml go.mod 2>/dev/null | head -3
```

Then find the most interesting entry point — the single busiest file that connects frontend to backend:

**Rails**: look for the most-referenced service or controller
```bash
ls app/services/*.rb 2>/dev/null | head -8
ls app/controllers/api/v1/*.rb 2>/dev/null | head -8
```

**Next.js / React**:
```bash
ls src/pages/*.tsx src/app/**/*.tsx pages/*.tsx 2>/dev/null | head -8
```

**Django**:
```bash
find . -name "views.py" | grep -v migrations | head -6
```

**Generic**:
```bash
ls src/routes/*.js src/controllers/*.js lib/*.rb 2>/dev/null | head -8
```

Pick the **one file** that looks like the core of a user-facing feature (not auth/boilerplate). Read its first 30 lines to understand what it does:
```bash
head -30 <chosen-file>
```

Announce your choice: *"I'll map the [feature name] feature around [chosen-file]."*

---

## Step 3: Build One Example Codemap

Create `codemaps/` if needed:
```bash
mkdir -p codemaps
```

Read the chosen file and any 2–4 files it directly calls or imports. Then write a single YAML codemap at `codemaps/<feature-slug>.yaml`:

```yaml
codemap:
  id: <feature-slug>
  title: <Feature Name>
  description: |
    <One sentence: what does this feature do end-to-end?>
    <Any non-obvious gotcha worth documenting here.>
  nodes:
    - id: <node-id>
      label: <exact/path/from/project/root.rb>
      type: entry|component|service|controller|model|hook|utility
      description: <one-line role>
    # ... 3-6 more nodes
  edges:
    - from: <node-id>
      to: <other-node-id>
      relationship: calls|renders|imports|delegates_to|uses
    # ... 3-5 more edges
```

Keep it to **5–8 nodes and 4–6 edges** — just enough to trace one user action from UI to database and back.

After writing the file, confirm:
```bash
cat codemaps/<feature-slug>.yaml
```

---

## Step 4: Show QuickExplore in Action

Now demonstrate what QuickExplore does with this map vs what raw grep would do.

**Without the map** (what Claude normally does):
```bash
# Grep for the feature — scans every file
grep -r "WorklogService\|create_worklog\|worklog" app/ --include="*.rb" --include="*.jsx" -l 2>/dev/null | wc -l
```
Print: *"Without a codemap, Claude would open N files to answer 'how does [feature] work?'"*

**With the map** (what QuickExplore does):
Read the YAML file you just created. Then say:

> "With this codemap, QuickExplore reads 1 file (~400 tokens) and immediately knows:
> - Entry point: `<label of entry node>`
> - Core logic: `<label of service/controller node>`
> - Data layer: `<label of model node>`
> - Key relationship: `<one edge description>`
>
> It then reads only the 1–2 files needed for the specific question — skipping the other N."

---

## Step 5: Wrap Up

Show a mini-summary:

```
✅ Quickstart complete!

Created: codemaps/<feature-slug>.yaml
  Nodes: X  |  Edges: Y

How QuickExplore uses it:
  → Reads 1 YAML file first (~400 tokens)
  → Jumps directly to relevant files
  → Skips broad grep across your codebase

Next steps:
  Run /codemap-navigator:build-codemaps   → Generate maps for all feature areas
  Run /codemap-navigator:codemap-status   → See full coverage report
  Use @QuickExplore                       → Token-efficient exploration from now on

Tip: Fall back to the default Explore agent when you've just made big
     architecture changes and maps may not be up to date yet.
```

Offer to commit the new codemap:
```bash
git add codemaps/
git status
```

Ask: *"Want me to commit this map, or run `/build-codemaps` to generate maps for all feature areas now?"*
