#!/usr/bin/env python3
"""Regenerate the Available Skills table in README.md from index.json + SKILL.md files."""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
INDEX_PATH = os.path.join(ROOT, "index.json")
README_PATH = os.path.join(ROOT, "README.md")


def extract_description(skill_path):
    skill_md = os.path.join(skill_path, "SKILL.md")
    if not os.path.exists(skill_md):
        return ""
    with open(skill_md) as f:
        content = f.read()
    m = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not m:
        return ""
    fm = m.group(1)
    # Block scalar: description: >\n  line1\n  line2
    block = re.search(r"^description:\s*>\n((?:[ \t]+.+\n?)+)", fm, re.MULTILINE)
    if block:
        lines = [l.strip() for l in block.group(1).splitlines() if l.strip()]
        return " ".join(lines)
    # Inline: description: some text
    inline = re.search(r"^description:\s*(.+)", fm, re.MULTILINE)
    if inline:
        return inline.group(1).strip()
    return ""


def first_sentence(text):
    """Return text up to and including the first sentence-ending period."""
    m = re.search(r"^.*?\.", text)
    return m.group(0) if m else text


def build_table(entries):
    rows = ["| Name | Description |", "|---|---|"]
    for entry in sorted(entries, key=lambda e: e["name"]):
        name = entry["name"]
        skill_path = os.path.join(ROOT, entry.get("path", name))
        desc = extract_description(skill_path) or entry.get("description", "")
        rows.append(f"| `{name}` | {first_sentence(desc)} |")
    return "\n".join(rows)


def update_readme(table):
    with open(README_PATH) as f:
        content = f.read()
    updated = re.sub(
        r"(## Available skills\n\n)[\s\S]*?(?=\n## )",
        rf"\g<1>{table}\n",
        content,
    )
    with open(README_PATH, "w") as f:
        f.write(updated)
    print("README updated.")


with open(INDEX_PATH) as f:
    entries = json.load(f)

table = build_table(entries)
update_readme(table)
