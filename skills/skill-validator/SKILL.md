---
name: skill-validator
description: >
  Security-scans a skill before installation. Detects injection patterns, credential
  theft, reverse shells, hardcoded secrets, and suspicious network access in skill
  scripts and SKILL.md. Use this skill when given a skill link, path, or name and
  asked whether it is safe to install. Activates for queries like "is this skill
  safe to install", "scan this skill", "check skill for security issues",
  "validate skill before installing", "audit this skill".
license: MIT
compatibility:
  agents:
    - codex
metadata:
  author: shaoqichen0913
  category: security
  version: "1.0.0"
scripts:
  - name: scan
    path: scripts/scan.sh
    description: >
      Static security scan of a skill folder. Pass a local path or a registry
      skill name. Prints a severity-graded report and exits non-zero if
      blockers are found.
    timeout_sec: 30
---

# Skill Validator

Security scanner for agent skills. Run this before installing any skill you did
not write yourself — especially skills referenced by URL or pulled from an
unfamiliar registry.

## When to use

Activate this skill when a user:
- Pastes a skill link, path, or name and asks whether it is safe to install
- Wants to audit a skill before running `skills install`
- Asks to "scan", "check", or "validate" a skill for security issues

## Workflow

### Step 1: Resolve the skill to a local path

If the user provides a **local path** (starts with `.` or `/`), use it directly.

If the user provides a **registry name** or **GitHub URL**, download the skill
folder first:

```
# Download from the default registry
skills install <name> --scope project --dry-run   # not yet implemented
# fallback: clone manually into a temp dir
```

For a GitHub URL pointing to a raw folder, use `gh` to clone the repo and
navigate to the skill folder, or download files individually with the GitHub
Contents API.

### Step 2: Run the scan

```
scripts/scan.sh <skill-path>
```

The script checks every `.sh` file and `SKILL.md` in the folder and prints a
severity-graded report:

| Severity | Meaning |
|---|---|
| CRITICAL | Hard block — do not install |
| HIGH | Strong warning — review manually before installing |
| MEDIUM | Informational — unusual but may be legitimate |
| OK | No issues found |

### Step 3: Report to the user

- If any **CRITICAL** findings exist: tell the user clearly **do not install**,
  explain what was found, and quote the offending lines.
- If only **HIGH** findings: show the findings, explain the risk, and ask the
  user whether they want to proceed.
- If only **MEDIUM** or none: tell the user the skill looks safe, but note any
  medium findings as "unusual but not necessarily malicious".

### Step 4: Let the user decide

Never install on behalf of the user. After presenting the report, wait for
their explicit instruction.

## What the scan checks

**CRITICAL — automatic block:**
- Reverse shell patterns (`bash -i`, `/dev/tcp/`, `nc -e`, `ncat -e`)
- Code execution from network (`curl | bash`, `wget | sh`, `eval $(curl`, `eval $(wget`)
- Credential theft (`~/.ssh/`, `~/.aws/credentials`, `~/.netrc`, `~/.gnupg/`)
- System destruction (`rm -rf /`, `mkfs`, `dd if=/dev/zero of=/dev/`)
- Privilege escalation (`chmod +s`, `chmod u+s`, `setuid`)
- Base64 decode-and-execute (`base64 -d | bash`, `base64 --decode | sh`)

**HIGH — strong warning:**
- `eval` with dynamic/variable input
- `sudo` or `su` calls
- Writing outside the skill directory (`> /etc/`, `>> /etc/`, `/usr/`, `/bin/`)
- Undeclared outbound network (`curl`, `wget`, `nc`, `ssh`) not covered by declared MCP servers
- Hardcoded credential patterns (tokens, passwords, private keys in plain text)

**MEDIUM — informational:**
- `exec` replacing the process
- Reading `$HOME`, `~`, or env vars that look like credential paths
- HTTP (not HTTPS) MCP server URLs
- Scripts missing `set -e` (errors may be silently swallowed)
