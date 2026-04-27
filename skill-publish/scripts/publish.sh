#!/usr/bin/env bash
# publish.sh — push a skill to the registry and update index.json
set -euo pipefail

SKILL_PATH="${1:-}"
REGISTRY_REPO="${2:-${SKILL_REGISTRY_REPO:-}}"

if [[ -z "$SKILL_PATH" ]]; then
  echo "Usage: publish.sh <skill-path> [<owner/repo>]" >&2
  echo "  or set SKILL_REGISTRY_REPO=<owner/repo>" >&2
  exit 1
fi

if [[ -z "$REGISTRY_REPO" ]]; then
  echo "Error: registry repo not specified." >&2
  echo "  Pass as second argument or set SKILL_REGISTRY_REPO=<owner/repo>" >&2
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI not found. Install from https://cli.github.com" >&2
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "Error: not authenticated. Run: gh auth login" >&2
  exit 1
fi

SKILL_MD="$SKILL_PATH/SKILL.md"
SKILL_NAME=$(grep -m1 '^name:' "$SKILL_MD" | sed 's/name:[[:space:]]*//')
SKILL_DESC=$(grep -m1 '^description:' "$SKILL_MD" | sed 's/description:[[:space:]]*//' | tr -d '>')
SKILL_DESC="${SKILL_DESC## }"

if [[ -z "$SKILL_NAME" ]]; then
  echo "Error: could not read skill name from SKILL.md" >&2
  exit 1
fi

echo ""
echo "Publishing '$SKILL_NAME' to $REGISTRY_REPO"
echo ""

# ── Clone registry to temp dir ───────────────────────────────────────────────
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "  Cloning registry..."
gh repo clone "$REGISTRY_REPO" "$TMP_DIR/registry" -- --depth=1 --quiet

# ── Copy skill folder ────────────────────────────────────────────────────────
DEST="$TMP_DIR/registry/$SKILL_NAME"
if [[ -d "$DEST" ]]; then
  echo "  Updating existing skill '$SKILL_NAME'..."
  rm -rf "$DEST"
else
  echo "  Adding new skill '$SKILL_NAME'..."
fi
cp -r "$SKILL_PATH" "$DEST"

# ── Update index.json ────────────────────────────────────────────────────────
INDEX="$TMP_DIR/registry/index.json"
if [[ ! -f "$INDEX" ]]; then
  echo "[]" > "$INDEX"
fi

# Remove existing entry for this skill and add updated one
python3 - "$INDEX" "$SKILL_NAME" "$SKILL_DESC" <<'EOF'
import json, sys

index_path, name, desc = sys.argv[1], sys.argv[2], sys.argv[3]
with open(index_path) as f:
    entries = json.load(f)

entries = [e for e in entries if e.get("name") != name]
entries.append({"name": name, "description": desc.strip(), "path": name})
entries.sort(key=lambda e: e["name"])

with open(index_path, "w") as f:
    json.dump(entries, f, indent=2)
    f.write("\n")
EOF

echo "  Updated index.json"

# ── Commit and push ──────────────────────────────────────────────────────────
cd "$TMP_DIR/registry"
git add .
git diff --cached --stat

ACTION="add"
git log --oneline origin/main.."$SKILL_NAME" 2>/dev/null && ACTION="update" || true

git commit -m "$ACTION: $SKILL_NAME skill" --quiet
git push --quiet

echo ""
echo "✓ Published '$SKILL_NAME' to $REGISTRY_REPO"
echo "  Install with: skills install $SKILL_NAME"
