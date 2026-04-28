---
name: workflow-skill-miner
description: Analyze prior work and history to recommend repeatable workflows that should become Codex skills, with evidence, scoring, and governance criteria.
version: "1.0.0"
---

# Workflow Skill Miner

## Purpose

Use this skill to turn observed work history into a prioritized backlog of high-value Codex skills. The output must be evidence-based: cite the sources inspected, separate facts from inference, and make clear which recommendations are ready to implement versus which need more examples.

## When to use

Use this skill when the user asks to analyze history, work artifacts, prior conversations, repository patterns, task reports, or documented workflows to identify what should be packaged as Codex skills. Also use it when the user wants workflow recommendations that improve readiness, transparency, auditability, security, reproducibility, governance, maintainability, or repeated task execution.

## Operating Principles

- Work from accessible evidence first: current conversation, files the user provides, project-local docs, existing `.codex/skills`, git history when present, issue/PR metadata when explicitly available, and approved connectors.
- Preserve privacy and security: do not read personal shell history, browser history, secrets, private home-directory files, or external systems unless the user explicitly asks and access is appropriate.
- Minimize sensitive copying: summarize sensitive artifacts, avoid quoting credentials, tokens, customer data, or private identifiers, and flag suspected secrets without reproducing them.
- Keep provenance: for each recommendation, record the evidence source, observed pattern, frequency or recurrence signal, risk/impact, and confidence.
- Prefer skills for repeatable judgment or process, not one-off commands. Recommend scripts/assets only when deterministic execution or templates would reduce repeated work.

## Workflow

1. Define the analysis boundary.
   - State which sources are available and which are out of scope.
   - If the user requested broad "history", inspect only accessible workspace and conversation history unless they explicitly authorize more.
   - If the workspace is large, sample first and explain the sampling strategy.

2. Build an evidence inventory.
   - Inspect existing skills and `.codex` configuration.
   - Inspect repository structure, docs, task files, prompts, scripts, tests, CI files, and recent git history if present.
   - Note recurring domains, repeated commands, common failure modes, review comments, manual checklists, and artifacts the user repeatedly asks Codex to create or validate.
   - Use [references/evidence-sources.md](references/evidence-sources.md) for source selection and command patterns.

3. Extract workflow patterns.
   - Group observations by user intent, artifact type, toolchain, decision process, and quality objective.
   - Mark whether each pattern is repetitive, fragile, high-stakes, slow, security-sensitive, or hard to audit.
   - Distinguish "candidate skill", "candidate script inside a skill", "candidate reference/checklist", and "not worth packaging".

4. Score and rank candidates.
   - Apply the rubric in [references/scoring-rubric.md](references/scoring-rubric.md).
   - Favor candidates with concrete evidence, recurring use, clear triggers, high risk reduction, and obvious reusable resources.
   - Penalize vague ideas, tasks that depend on unavailable private context, and one-off project-specific fixes.

5. Produce the recommendation report.
   - Use [references/report-template.md](references/report-template.md).
   - Include a ranked list, triggering examples, proposed skill names, resources to include, implementation effort, risks, and validation plan.
   - Include a "Do not package yet" section for ideas with weak evidence or unresolved security concerns.

## Recommendation Quality Bar

A strong recommendation has:

- Clear trigger language that would fit SKILL.md frontmatter.
- At least two evidence points or one high-impact evidence point.
- A concrete repeatable workflow.
- A scoped artifact plan: SKILL.md only, references, scripts, assets, or connectors.
- A validation plan that can be run without leaking secrets or mutating production systems.
- Explicit benefits for readiness, transparency, auditability, security, and reproducibility where relevant.

Do not recommend creating a skill just because a topic appears once. Suggest a checklist, note, or future observation instead.

## Output Constraints

- Be direct and auditable. Prefer tables or compact bullets over narrative.
- Cite local files with paths and line numbers when practical.
- Label inference clearly when evidence is indirect.
- Use confidence levels: High, Medium, Low.
- End with the next 1-3 concrete skill-building steps, not a generic invitation.
