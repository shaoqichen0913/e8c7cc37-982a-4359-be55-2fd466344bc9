# Evidence Sources

Use this guide to collect workflow evidence without overreaching.

## Preferred Sources

- Current conversation: explicit requests, repeated clarifications, quality requirements, and user preferences.
- Existing skills: `.codex/skills/*/SKILL.md`, `agents/openai.yaml`, `references/`, `scripts/`, and `assets/`.
- Workspace docs: README files, task plans, ADRs, runbooks, checklists, prompt libraries, contribution docs, CI docs, release docs.
- Repository structure: package manifests, test directories, scripts, CI workflows, lint configs, security configs.
- Git metadata when available: recent commits, branch names, changed file clusters, repeated commit themes.
- GitHub/Notion/app connectors only when the user request or context makes them relevant and access is already available.

## Avoid Unless Explicitly Authorized

- Personal shell history.
- Browser history.
- Private home-directory documents outside the requested workspace.
- Secret stores, keychains, credential files, `.env` contents, tokens, customer data, or production logs.
- External systems that could mutate state.

## Useful Local Commands

Prefer read-only commands and `rg`/`rg --files`:

```bash
rg --files
find .codex/skills -maxdepth 3 -type f
rg -n "TODO|FIXME|runbook|checklist|manual|release|deploy|audit|security|reproduc|review|prompt|skill" .
git log --oneline --decorate -n 30
git status --short
```

If commands fail because the workspace is not a git repository or directories are absent, record that as scope information rather than a problem.

## Evidence Record Format

For each notable observation, capture:

- Source: file/path, conversation detail, command output, or connector object.
- Observation: what repeats, causes friction, or creates risk.
- Signal: frequency, recency, importance, or user emphasis.
- Quality dimension: readiness, transparency, auditability, security, reproducibility, maintainability, speed, or consistency.
- Candidate implication: skill, script, reference, asset, process note, or no action.
