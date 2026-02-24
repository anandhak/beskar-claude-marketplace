#!/bin/bash

# Codemap Staleness Check Hook
# Generic hook for any project — warns when architecture files have been committed
# more recently than codemaps/, suggesting an /update-codemaps run.
#
# Installation: Add to .claude/settings.json UserPromptSubmit hooks:
# {
#   "type": "command",
#   "command": "bash .claude/hooks/codemap-staleness-check.sh"
# }

CODEMAP_DIR="codemaps"

# Silently exit if no codemaps directory — not all projects have one yet
if [ ! -d "$CODEMAP_DIR" ] || [ -z "$(ls "$CODEMAP_DIR"/*.yaml 2>/dev/null)" ]; then
  exit 0
fi

# Not a git repo — skip
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Detect architecture source directories (generic — works for Rails, Django, Next.js, Express)
ARCH_DIRS=""
for dir in \
  "app/frontend/components" "app/frontend/hooks" "app/frontend/pages" \
  "app/services" "app/controllers" "app/models" "app/jobs" \
  "src/components" "src/services" "src/models" "src/controllers" \
  "src/pages" "src/hooks" "src/routes" "src/middleware" \
  "components" "services" "models" "pages" "hooks" "lib" "backend" "frontend"
do
  if [ -d "$dir" ]; then
    ARCH_DIRS="$ARCH_DIRS $dir"
  fi
done

# No architecture directories detected — skip
if [ -z "$ARCH_DIRS" ]; then
  exit 0
fi

# Get unix timestamp of last commit touching codemaps/
LAST_CODEMAP_TS=$(git log -1 --format="%at" -- "$CODEMAP_DIR/" 2>/dev/null)

# No codemap commits yet — skip (fresh setup)
if [ -z "$LAST_CODEMAP_TS" ]; then
  exit 0
fi

# Get unix timestamp of last commit touching any architecture directory
LAST_ARCH_TS=$(git log -1 --format="%at" -- $ARCH_DIRS 2>/dev/null)

# No architecture commits yet — skip
if [ -z "$LAST_ARCH_TS" ]; then
  exit 0
fi

# Warn if architecture is newer than codemaps
if [ "$LAST_ARCH_TS" -gt "$LAST_CODEMAP_TS" ]; then
  ARCH_DATE=$(git log -1 --format="%ar" -- $ARCH_DIRS 2>/dev/null)
  CODEMAP_DATE=$(git log -1 --format="%ar" -- "$CODEMAP_DIR/" 2>/dev/null)
  echo "ℹ️  Codemaps may be stale"
  echo "   Architecture last changed: $ARCH_DATE"
  echo "   Codemaps last updated:     $CODEMAP_DATE"
  echo "   Consider running: /update-codemaps"
  echo ""
fi
