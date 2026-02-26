---
name: codemap-status
description: Show a coverage report for all codemaps — node/edge counts, last updated date, unmapped files, and the next best area to map. Use to understand codemap health and prioritize new maps.
disable-model-invocation: false
---

# Codemap Status Report

Generate a coverage report showing what's mapped, what's not, and what to map next.

## Step 1: List All Codemaps

```bash
ls -la codemaps/*.yaml 2>/dev/null | grep -v "INDEX.yaml" || echo "No codemaps found — run /codemap-navigator:build-codemaps"
```

For each `.yaml` file (excluding `INDEX.yaml`), extract stats:
```bash
for yaml in codemaps/*.yaml; do
  [ "$(basename "$yaml")" = "INDEX.yaml" ] && continue
  name=$(basename "$yaml" .yaml)
  nodes=$(grep -c "^    - id:" "$yaml" 2>/dev/null || echo 0)
  edges=$(grep -c "^    - from:" "$yaml" 2>/dev/null || echo 0)
  last_updated=$(git log -1 --format="%ar" -- "$yaml" 2>/dev/null || echo "uncommitted")
  echo "$name: $nodes nodes, $edges edges, last updated: $last_updated"
done
```

## Step 2: List All Mapped File Paths

Extract all `label:` values from all codemaps to build a list of covered files:
```bash
grep -h "      label:" codemaps/*.yaml 2>/dev/null | sed 's/.*label: //' | sort -u
```

## Step 3: Find All Architecture Source Files

Detect source directories and list all architecture files:
```bash
# Detect what source directories exist
for dir in app/frontend/components app/frontend/hooks app/frontend/pages \
           app/services app/controllers app/models app/jobs \
           src/components src/services src/models src/controllers src/pages src/hooks \
           lib components services models pages hooks; do
  if [ -d "$dir" ]; then
    find "$dir" -name "*.rb" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.js" -o -name "*.ts" \
      -o -name "*.py" -o -name "*.go" 2>/dev/null | grep -v "__pycache__\|node_modules\|\.test\.\|\.spec\." | sort
  fi
done
```

## Step 4: Calculate Coverage

- **Covered files**: files whose path appears in any codemap's `label` fields
- **Uncovered files**: architecture files with NO codemap coverage
- **Coverage %**: covered / total × 100

## Step 5: Suggest Next Area to Map

Rank uncovered file clusters by:
1. **Most files in a directory** → highest value to map
2. **Most recently modified** (`git log --format="%ar" -- <path>`) → most active area
3. **Most referenced** (files imported/required by many others) → highest leverage
4. **Highest commit churn** → files that change most often have highest ROI to document

```bash
# Build mapped file list and compute churn for uncovered files in one pass
MAPPED=$(grep -h "      label:" codemaps/*.yaml 2>/dev/null | \
  grep -v "INDEX.yaml" | sed 's/.*label: //' | sort -u)

for dir in app/frontend/components app/frontend/hooks app/services \
           app/controllers app/models app/jobs; do
  [ -d "$dir" ] || continue
  find "$dir" \( -name "*.rb" -o -name "*.jsx" -o -name "*.js" -o -name "*.ts" \) \
    2>/dev/null | grep -v "node_modules\|\.test\.\|\.spec\."
done | while read f; do
  echo "$MAPPED" | grep -qx "$f" || echo "$f"
done | while read f; do
  count=$(git log --oneline -- "$f" 2>/dev/null | wc -l | tr -d ' ')
  echo "$count $f"
done | sort -rn | head -10
```

Include churn counts in the output:
```
Top unmapped files by commit frequency:
  42 commits  app/services/worklog_service.rb
  31 commits  app/controllers/api/v1/worklogs_controller.rb
```

## Step 6: Output Report

```
📊 Codemap Coverage Report
══════════════════════════

Maps (4 total):
  command-k.yaml          8 nodes   7 edges   last: 3 days ago
  reports-dashboard.yaml  9 nodes   8 edges   last: 3 days ago
  timer-auto-stop.yaml    5 nodes   4 edges   last: 3 days ago
  calendar-worklogs.yaml  11 nodes  10 edges  last: 2 hours ago

Coverage:
  Mapped files:    33 / 147  (22%)
  Unmapped files:  114

Top unmapped areas (by file count):
  1. app/frontend/components/modals/   — 12 files  (most recently changed: 2 days ago)
  2. app/services/google_calendar/     — 4 files
  3. app/controllers/api/v1/           — 8 files (only projects_controller partially mapped)

💡 Suggested next map: app/frontend/components/modals/
   → Many modal components, recently active, no coverage
   → Run: /codemap-navigator:build-codemaps (it will focus on this area)
```
