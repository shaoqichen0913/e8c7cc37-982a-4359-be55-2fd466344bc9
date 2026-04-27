# Skill Registry

A registry of agent skills compatible with the skill framework.

## Available skills

| Name | Description |
|---|---|
| `code-reviewer` | Static analysis: linting, security scan, complexity |
| `knowledge-retriever` | Internal docs (Notion) + Codex native web search |
| `skill-publish` | Validate, test, and publish a skill to this registry |
| `testcase-skill` | Generate and run test cases for functions and modules |

## Usage

```bash
# Search available skills
skills search
skills search "code review"

# Install a skill by name
skills install code-reviewer --scope project

# Check runtime readiness
skills doctor code-reviewer
skills doctor knowledge-retriever --ping

# List installed skills
skills list
```

## Registry structure

Each skill is a folder containing a `SKILL.md` file:

```
<skill-name>/
├── SKILL.md          # frontmatter + agent instructions
├── scripts/          # optional executable scripts
└── references/       # optional context files
```

## Publishing a skill

Install the `skill-publish` skill and use it inside Codex:

```bash
skills install skill-publish --scope project
```

Then in Codex:
```
publish my skill at ./path/to/my-skill
```

The agent will validate, test, and open a PR to this registry for review.

### Requirements

- `gh` CLI authenticated (`gh auth login`)
- `SKILL_REGISTRY_REPO=shaoqichen0913/e8c7cc37-982a-4359-be55-2fd466344bc9`
