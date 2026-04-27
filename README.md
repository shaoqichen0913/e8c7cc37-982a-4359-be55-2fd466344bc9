# Skill Registry

A public registry of agent skills compatible with the skill framework.

## Available skills

| Name | Description |
|---|---|
| `code-reviewer` | Static analysis: linting, security scan, complexity |
| `knowledge-retriever` | Web search (Brave) + internal docs (Notion) |

## Usage

```bash
# Search available skills
skills search "code review"

# Install a skill by name
skills install code-reviewer --scope project

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

## Adding a skill

Open a pull request with a new skill folder. The `SKILL.md` frontmatter must include `name` (kebab-case) and `description`.
