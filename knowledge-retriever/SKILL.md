---
name: knowledge-retriever
description: >
  Retrieves relevant information from internal documentation and the web to answer
  engineering questions. Use this skill when asked to look up, find, research, or
  summarize information — including internal docs, runbooks, architecture decisions,
  API references, or current best practices. Activates for queries like "find docs on",
  "look up", "search for", "what does X do", "how does Y work", "get context on".
license: MIT
compatibility:
  agents:
    - codex
metadata:
  author: osapiens engineering
  category: retrieval
  version: "1.0.0"
mcp_servers:
  - name: brave_search
    transport: http
    url: https://api.search.brave.com/mcp/v1
    auth:
      type: bearer
      token_env_var: BRAVE_API_KEY
    enabled_tools:
      - web_search
      - summarize
    description: Web search via Brave Search API — used for current information and external docs
    required: false

  - name: notion
    transport: http
    url: https://mcp.notion.com/mcp
    auth:
      type: oauth
    enabled_tools:
      - search
      - retrieve_page
      - retrieve_block_children
    description: Internal Notion workspace — engineering docs, ADRs, runbooks, onboarding guides
    required: false
---

# Knowledge Retriever

Retrieve and synthesize information from internal documentation and web search.

## When to use

Activate this skill when the user needs to:

- Find specific information in internal docs, runbooks, or ADRs
- Research current best practices, library versions, or external APIs
- Get context on a system, service, or concept before making a change
- Summarize or compare multiple sources on a topic

## How to use this skill

### Searching internal documentation (Notion)

Use the `notion` MCP tools to search the internal workspace:

```
notion.search({ query: "<topic>" })
notion.retrieve_page({ page_id: "<id>" })
notion.retrieve_block_children({ block_id: "<id>" })
```

**Source selection rule:** Prefer Notion results for anything that is:
- Team-specific (processes, architecture decisions, on-call runbooks)
- Versioned internally (internal API contracts, environment configs)
- More recent than the web result (Notion updates outpace docs sites)

### Searching the web (Brave Search)

Use the `brave_search` MCP tools for external queries:

```
brave_search.web_search({ query: "<topic>", count: 5 })
brave_search.summarize({ url: "<result_url>" })
```

**Source selection rule:** Prefer web search for:
- Open-source library documentation and changelogs
- Industry best practices and standards (RFCs, OWASP, etc.)
- Recent news or announcements (releases, deprecations, CVEs)

## Synthesis guidelines

1. **Check Notion first** for internal context — the org's decisions override generic advice
2. **Cross-reference with web** when the internal docs are silent or outdated
3. **Cite sources** in your response: Notion page title + URL, or web result URL
4. **Resolve conflicts** by preferring the more recent source, noting the discrepancy

## Required environment variables

| Variable | MCP Server | Purpose |
|---|---|---|
| `BRAVE_API_KEY` | `brave_search` | Brave Search API authentication |

The `notion` MCP uses OAuth — run `codex mcp login notion` once to authenticate.

## References

- [Source selection heuristics](./references/source-selection.md)
