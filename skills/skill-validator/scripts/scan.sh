#!/usr/bin/env bash
set -euo pipefail

# Usage: scan.sh <skill-path>
# Exits 0 if no blockers, 1 if CRITICAL or HIGH findings exist.

SKILL_PATH="${1:-}"
if [[ -z "$SKILL_PATH" ]]; then
  echo "Usage: scan.sh <skill-path>" >&2
  exit 2
fi

if [[ ! -d "$SKILL_PATH" ]]; then
  echo "ERROR: '$SKILL_PATH' is not a directory." >&2
  exit 2
fi

SKILL_PATH="$(cd "$SKILL_PATH" && pwd)"

CRITICAL=0
HIGH=0
MEDIUM=0
FINDINGS=""

add_finding() {
  local severity="$1"
  local file="$2"
  local line_no="$3"
  local description="$4"
  local snippet="$5"
  local preview
  preview="$(printf '%s' "$snippet" | head -c 120 | tr '\n' ' ')"
  case "$severity" in
    CRITICAL) CRITICAL=$((CRITICAL + 1)) ;;
    HIGH)     HIGH=$((HIGH + 1)) ;;
    MEDIUM)   MEDIUM=$((MEDIUM + 1)) ;;
  esac
  if [[ -n "$line_no" ]]; then
    FINDINGS="${FINDINGS}[$severity] ${file}:${line_no}
  ${description}
  -> ${preview}
"
  else
    FINDINGS="${FINDINGS}[$severity] ${file}
  ${description}
"
  fi
}

# Run a grep check and pipe findings into add_finding.
# Args: severity file rel description pattern
check_pattern() {
  local severity="$1"
  local file="$2"
  local rel="$3"
  local description="$4"
  local pattern="$5"
  local tmp_matches
  tmp_matches="$(grep -nE "$pattern" "$file" 2>/dev/null)" || true
  if [[ -z "$tmp_matches" ]]; then return; fi
  while IFS= read -r match; do
    [[ -z "$match" ]] && continue
    local line_no="${match%%:*}"
    local snippet="${match#*:}"
    # Skip comment lines
    [[ "$snippet" =~ ^[[:space:]]*# ]] && continue
    add_finding "$severity" "$rel" "$line_no" "$description" "$snippet"
  done <<< "$tmp_matches"
}

scan_file() {
  local file="$1"
  local rel="${file#"$SKILL_PATH/"}"

  # ── CRITICAL ────────────────────────────────────────────────────────────────
  check_pattern "CRITICAL" "$file" "$rel" \
    "Reverse shell pattern" \
    '(bash[[:space:]]+-i|/dev/tcp/|nc[[:space:]]+-e[[:space:]]|ncat[[:space:]]+-e[[:space:]]|mkfifo.+bash)'

  check_pattern "CRITICAL" "$file" "$rel" \
    "Network code execution (curl/wget piped to shell)" \
    '(curl|wget)[^|]*\|[[:space:]]*(bash|sh|python[23]?|perl|ruby)'

  check_pattern "CRITICAL" "$file" "$rel" \
    "eval of network-fetched content" \
    'eval[[:space:]]*\$\([[:space:]]*(curl|wget)'

  check_pattern "CRITICAL" "$file" "$rel" \
    "Base64 decode piped to shell" \
    'base64[[:space:]]+(--decode|-d)[^|]*\|[[:space:]]*(bash|sh|python[23]?|perl)'

  check_pattern "CRITICAL" "$file" "$rel" \
    "Reading sensitive credential paths (~/.ssh, ~/.aws, ~/.gnupg)" \
    '~/\.(ssh|aws|gnupg|netrc|config/gcloud)|HOME/\.(ssh|aws|gnupg|netrc)'

  check_pattern "CRITICAL" "$file" "$rel" \
    "Destructive system operation (rm -rf /, mkfs, dd /dev/)" \
    '(rm[[:space:]]+-rf[[:space:]]*/[^/]|mkfs\.|dd[[:space:]]+if=/dev/zero[[:space:]]+of=/dev/)'

  check_pattern "CRITICAL" "$file" "$rel" \
    "Setting setuid bit (privilege escalation)" \
    'chmod[[:space:]]+(\+s|u\+s)'

  # ── HIGH ─────────────────────────────────────────────────────────────────────
  check_pattern "HIGH" "$file" "$rel" \
    "Privilege escalation via sudo/su" \
    '^[[:space:]]*(sudo|su)[[:space:]]'

  check_pattern "HIGH" "$file" "$rel" \
    "eval with dynamic/variable input (potential injection)" \
    'eval[[:space:]]+\$[^(]'

  check_pattern "HIGH" "$file" "$rel" \
    "Writing to system directory (/etc, /usr, /bin, /sbin)" \
    '(>>?|tee)[[:space:]]+/(etc|usr|bin|sbin|lib|boot|sys|proc)/'

  check_pattern "HIGH" "$file" "$rel" \
    "Possible hardcoded credential/token" \
    '(password|passwd|secret|api_key|apikey|access_token|auth_token|private_key)[[:space:]]*=[[:space:]]*["'"'"'][^"'"'"'$][^"'"'"']{4,}'

  check_pattern "HIGH" "$file" "$rel" \
    "Outbound network call (curl/wget/nc/ssh) — verify this is intentional" \
    '^[[:space:]]*(curl|wget|nc|ssh|sftp)[[:space:]]'

  # ── MEDIUM ───────────────────────────────────────────────────────────────────
  check_pattern "MEDIUM" "$file" "$rel" \
    "exec replaces the current process (may escape cleanup)" \
    '^[[:space:]]*exec[[:space:]]'

  check_pattern "MEDIUM" "$file" "$rel" \
    "Reading HOME or credential-adjacent env var" \
    '\$(HOME|XDG_CONFIG_HOME|USERPROFILE|APPDATA)'

  # Missing set -e check (only for .sh files)
  if [[ "$file" == *.sh ]]; then
    if ! grep -qE '^[[:space:]]*set[[:space:]]+-[a-z]*e' "$file" 2>/dev/null; then
      add_finding "MEDIUM" "$rel" "" "Script missing 'set -e' — errors may be silently ignored" ""
    fi
  fi
}

scan_skill_md() {
  local file="$SKILL_PATH/SKILL.md"
  [[ -f "$file" ]] || return 0
  local rel="SKILL.md"

  check_pattern "MEDIUM" "$file" "$rel" \
    "MCP server uses plain HTTP (not HTTPS)" \
    'url:[[:space:]]*http://'

  check_pattern "HIGH" "$file" "$rel" \
    "Script path is absolute or uses path traversal (../)" \
    'path:[[:space:]]*(/|\.\.)'
}

# ── Main ─────────────────────────────────────────────────────────────────────

echo "==========================================================="
echo " Skill Security Scan"
echo " Path: $SKILL_PATH"
echo "==========================================================="
echo ""

scan_skill_md

# Collect all .sh files into an array first (avoids subshell scoping issues)
SCRIPT_FILES=()
while IFS= read -r -d '' f; do
  SCRIPT_FILES+=("$f")
done < <(find "$SKILL_PATH" -name "*.sh" -print0 2>/dev/null)

for script in "${SCRIPT_FILES[@]+"${SCRIPT_FILES[@]}"}"; do
  scan_file "$script"
done

# ── Report ────────────────────────────────────────────────────────────────────

if [[ $CRITICAL -eq 0 && $HIGH -eq 0 && $MEDIUM -eq 0 ]]; then
  echo "OK  RESULT: SAFE"
  echo ""
  echo "No security issues found. This skill looks safe to install."
  exit 0
fi

if [[ -n "$FINDINGS" ]]; then
  echo "Findings:"
  echo "-----------------------------------------------------------"
  echo "$FINDINGS"
fi

echo "-----------------------------------------------------------"
printf " CRITICAL: %d   HIGH: %d   MEDIUM: %d\n" "$CRITICAL" "$HIGH" "$MEDIUM"
echo "-----------------------------------------------------------"
echo ""

if [[ $CRITICAL -gt 0 ]]; then
  echo "BLOCKED  RESULT: DO NOT INSTALL"
  echo ""
  echo "This skill contains patterns characteristic of malicious code. Do not install it."
  exit 1
elif [[ $HIGH -gt 0 ]]; then
  echo "WARNING  RESULT: HIGH RISK — review manually before installing"
  echo ""
  echo "Review the findings above carefully before deciding whether to install."
  exit 1
else
  echo "CAUTION  RESULT: MEDIUM FINDINGS ONLY"
  echo ""
  echo "No critical or high-risk patterns found. Medium findings above may be legitimate."
  exit 0
fi
