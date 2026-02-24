---
name: update-codemaps
description: Check git log for architecture files changed since last codemap update. Update only affected codemaps, regenerate Mermaid diagrams, and commit. Run after significant feature changes.
disable-model-invocation: false
---

# Update Codemaps

Incrementally update codemaps for feature areas that have changed since the last codemap commit.

## Step 1: Find Changed Architecture Files

```bash
# Get timestamp of last codemap commit
LAST_CODEMAP=$(git log -1 --format="%H" -- codemaps/ 2>/dev/null)

if [ -z "$LAST_CODEMAP" ]; then
  echo "No previous codemap commits found — run /build-codemaps first"
  exit 0
fi

# List all architecture files changed since last codemap commit
git diff --name-only "$LAST_CODEMAP" HEAD -- \
  app/frontend/components/ \
  app/frontend/hooks/ \
  app/frontend/pages/ \
  app/services/ \
  app/controllers/ \
  app/models/ \
  app/jobs/ \
  src/ \
  lib/ \
  components/ \
  services/ \
  models/ \
  pages/ \
  2>/dev/null
```

## Step 2: Map Changed Files to Feature Areas

For each changed file, identify which codemap(s) it belongs to by checking existing codemaps:

```bash
# Show all node labels in existing codemaps to find matches
grep -h "label:" codemaps/*.yaml 2>/dev/null | sed 's/.*label: //' | sort
```

If a changed file appears in a codemap's `label` field → that codemap needs updating.
If a changed file has NO codemap coverage → suggest creating a new codemap for it.

## Step 3: Update Affected Codemaps

For each affected codemap:

1. **Read the current YAML file**
2. **Read the changed source files** to understand what changed
3. **Update nodes**: add new files, remove deleted ones, update descriptions
4. **Update edges**: add new relationships, remove obsolete ones
5. **Update the description** if the feature's behaviour changed
6. **Keep under 1,000 tokens**: if the map is growing too large, split it

**What warrants an update:**
- New files added to a feature area (add node)
- File deleted or renamed (update/remove node)
- New relationship between existing components (add edge)
- Critical gotcha discovered (add to description)
- Field names or API contracts changed (update description)

**What does NOT warrant an update:**
- Bug fixes that don't change architecture
- Style/formatting changes
- Test additions (unless testing patterns are being mapped)
- Documentation-only changes

## Step 4: Regenerate Mermaid Diagrams

```bash
if [ -f "scripts/codemap_to_mermaid.rb" ]; then
  ruby scripts/codemap_to_mermaid.rb
else
  echo "No codemap_to_mermaid.rb — update .mmd files manually or install the script"
fi
```

## Step 5: Commit Updated Codemaps

```bash
git add codemaps/
git status codemaps/
```

Commit with a message like:
```
chore: Update codemaps for <feature-area> after <brief description of change>
```

## Step 6: Output Summary

```
✅ Updated 2 codemaps:
   calendar-worklogs.yaml  — added node: confirmation-modal, updated edge: calendar → weekly-view
   auth.yaml               — updated description: token expiry gotcha documented

⚠️  3 changed files have no codemap coverage:
   app/services/new_feature_service.rb
   app/frontend/components/NewFeature.jsx
   app/controllers/api/v1/new_feature_controller.rb
   → Consider running /build-codemaps to add a new feature map
```
