# Scoring Rubric

Score each candidate from 0-3 in each dimension. Use the total to rank, but keep professional judgment: a security-critical candidate can outrank a higher-scoring convenience skill.

| Dimension | 0 | 1 | 2 | 3 |
| --- | --- | --- | --- | --- |
| Recurrence | One-off | Plausibly repeated | Repeated in evidence | Frequent or central workflow |
| Friction | Easy ad hoc task | Some setup | Repeated manual steps | Slow, error-prone, or often blocked |
| Risk reduction | Low consequence | Minor quality risk | Meaningful review or process risk | Security, compliance, production, or audit risk |
| Codifiability | Too vague | Checklist only | Clear workflow | Clear workflow plus reusable resources |
| Evidence strength | Speculative | One weak signal | Multiple signals | Direct repeated examples |
| Trigger clarity | Hard to trigger | Broad trigger | Usable trigger | Precise user phrases and artifact types |
| Reproducibility gain | None | Documents steps | Standardizes environment or commands | Makes outputs deterministic/verifiable |
| Auditability gain | None | Better notes | Source-linked report | Traceable evidence, logs, and validation |

## Priority Bands

- 19-24: Build now. Strong skill candidate.
- 14-18: Good candidate. Build after clarifying scope or collecting one more example.
- 8-13: Track as future skill or package as a reference/checklist.
- 0-7: Do not package yet.

## Resource Decision

- Use `SKILL.md` only for concise workflows and decision rules.
- Add `references/` for rubrics, templates, schemas, runbooks, examples, or policy details.
- Add `scripts/` for repeated deterministic commands, report generation, validation, extraction, or formatting.
- Add `assets/` for reusable templates, boilerplate, document layouts, starter projects, or static files.

## Quality Dimension Prompts

- Readiness: Does this help Codex start faster with less clarification?
- Transparency: Does this make assumptions, decisions, and tradeoffs visible?
- Auditability: Can another person trace sources, actions, and validation?
- Security: Does this reduce secret leakage, unsafe mutation, or permission ambiguity?
- Reproducibility: Can the same workflow be rerun with comparable output?
- Maintainability: Will the skill be easy to update as tools and projects change?
