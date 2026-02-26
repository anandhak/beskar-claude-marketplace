---
description: Remove all codemap-navigator artifacts from this project. Run before removing the plugin, or to fully reset the codemap setup. Shows what exists, asks what to remove, then executes.
---

# Cleanup Codemap Navigator

Scan for all project artifacts created by codemap-navigator, show what was found, and remove what the user selects.

## Step 1: Scan for Artifacts

```bash
echo "=== Codemap Navigator — Project Artifacts ==="
echo ""

# Core codemap directory
if [ -d "codemaps/" ]; then
  MAP_COUNT=$(ls codemaps/*.yaml 2>/dev/null | wc -l | tr -d ' ')
  MMD_COUNT=$(ls codemaps/*.mmd 2>/dev/null | wc -l | tr -d ' ')
  echo "📁 codemaps/          — $MAP_COUNT YAML maps, $MMD_COUNT .mmd diagram files"
else
  echo "   codemaps/          — not found"
fi

# Gitignore entry
if grep -q "snapshot.txt" .gitignore 2>/dev/null; then
  echo "📄 .gitignore         — has codemaps/*.snapshot.txt entry"
fi

# Optional scripts
[ -f "scripts/codemap_to_mermaid.rb" ]      && echo "📄 scripts/codemap_to_mermaid.rb"
[ -f "scripts/codemap-pre-commit-check.sh" ] && echo "📄 scripts/codemap-pre-commit-check.sh"

# Pre-commit hook symlink (only if it points to a codemap script)
if [ -L ".git/hooks/pre-commit" ]; then
  TARGET=$(readlink ".git/hooks/pre-commit" 2>/dev/null)
  if echo "$TARGET" | grep -q "codemap"; then
    echo "🔗 .git/hooks/pre-commit  → $TARGET"
  fi
fi

# Codemapignore
[ -f ".codemapignore" ] && echo "📄 .codemapignore"

# CLAUDE.md references
if grep -q "codemaps\|codemap-navigator\|QuickExplore" CLAUDE.md 2>/dev/null; then
  REF_COUNT=$(grep -c "codemaps\|codemap-navigator\|QuickExplore" CLAUDE.md 2>/dev/null)
  echo "📝 CLAUDE.md          — $REF_COUNT lines reference codemaps (manual cleanup needed)"
fi
```

## Step 2: Present Options

Show the user what was found and ask which artifacts to remove. Present choices:

- **Full cleanup** — remove everything (codemaps/, scripts, hooks, gitignore entry)
- **Keep maps, remove tooling** — keep `codemaps/*.yaml` but remove scripts, hook symlink, .codemapignore
- **Only untracked/optional files** — remove scripts, hook symlink, .codemapignore; leave codemaps/ and .gitignore untouched
- **Nothing** — cancel and exit

Wait for user confirmation before proceeding.

## Step 3: Execute Removals

Based on user choice, run the appropriate removals:

### Remove codemaps/ directory

Check if files are git-tracked before choosing removal method:
```bash
if git ls-files --error-unmatch codemaps/ > /dev/null 2>&1; then
  # Git-tracked: use git rm to stage the removal
  git rm -r codemaps/
else
  # Untracked: plain delete
  rm -rf codemaps/
fi
```

### Remove .gitignore entry for snapshots

```bash
# Portable sed: works on both macOS and Linux
if grep -q "snapshot.txt" .gitignore 2>/dev/null; then
  # Remove the comment line and the pattern line
  grep -v "Codemap snapshot artifacts" .gitignore | grep -v "codemaps/\*\.snapshot\.txt" > .gitignore.tmp
  mv .gitignore.tmp .gitignore
  echo "Removed snapshot entry from .gitignore"
fi
```

### Remove optional scripts

```bash
rm -f scripts/codemap_to_mermaid.rb
rm -f scripts/codemap-pre-commit-check.sh
# Remove scripts/ directory only if now empty
rmdir scripts/ 2>/dev/null && echo "Removed empty scripts/ directory" || true
```

### Remove pre-commit hook symlink

```bash
if [ -L ".git/hooks/pre-commit" ]; then
  TARGET=$(readlink ".git/hooks/pre-commit" 2>/dev/null)
  if echo "$TARGET" | grep -q "codemap"; then
    rm .git/hooks/pre-commit
    echo "Removed pre-commit hook symlink"
  fi
fi
```

### Remove .codemapignore

```bash
rm -f .codemapignore
```

## Step 4: CLAUDE.md Hint

If CLAUDE.md has codemap references, do NOT auto-edit it. Instead, tell the user:

> CLAUDE.md has references to codemaps that you may want to remove manually.
> Lines to review:
> ```
> [show the matching lines with line numbers]
> ```
> You can remove the `@/codemaps/` entries in the codemap index section and any
> `Codemaps (\`codemaps/\`)` section from the file.

## Step 5: Offer to Commit

```bash
git status --short
```

If any tracked files were removed, offer to commit:
```
git add -A
git commit -m "Remove codemap-navigator artifacts"
```

## Step 6: Confirm Complete

Output a summary of what was removed and remind the user that the plugin itself
is removed via `/plugin remove codemap-navigator` in Claude Code.
