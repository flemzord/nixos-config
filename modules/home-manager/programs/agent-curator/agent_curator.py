#!/usr/bin/env python3
"""Local curator for Claude/Codex knowledge files.

This tool intentionally does not read raw session logs, JSON state, caches,
credentials, or model transcripts. It inventories a narrow allowlist of durable
knowledge files, writes sanitized metadata under XDG data state, and produces
reviewable proposals instead of mutating active agent configuration.
"""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import sys
from collections import defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


DEFAULT_CONFIG_PATH = "~/.config/agent-curator/config.json"
DEFAULT_DATA_DIR = "~/.local/share/agent-curator"
DEFAULT_AUTO_MANAGED_SKILL_PREFIXES = ["agent-"]
MAX_DESCRIPTION_CHARS = 500
MAX_HEADING_COUNT = 12

SECRET_NAME_RE = re.compile(
    r"(secret|credential|token|apikey|api[_-]?key|password|passwd|private[_-]?key|auth)",
    re.IGNORECASE,
)
SECRET_VALUE_RE = re.compile(
    r"(?i)("
    r"sk-[A-Za-z0-9_-]{20,}|"
    r"gh[pousr]_[A-Za-z0-9_]{20,}|"
    r"xox[baprs]-[A-Za-z0-9-]{20,}|"
    r"AKIA[0-9A-Z]{16}|"
    r"-----BEGIN [A-Z ]*PRIVATE KEY-----|"
    r"bearer\s+[A-Za-z0-9._~+/=-]{20,}|"
    r"[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|API_KEY)[A-Z0-9_]*\s*[:=]\s*['\"]?[^'\"\s]+"
    r")"
)

SKIP_DIR_PARTS = {
    ".cache",
    ".git",
    ".hub",
    ".tmp",
    "__pycache__",
    "archived_sessions",
    "backups",
    "cache",
    "file-history",
    "history",
    "logs",
    "node_modules",
    "projects",
    "sessions",
    "site-packages",
    "tmp",
    "worktrees",
}


@dataclass(frozen=True)
class Source:
    name: str
    root: str
    include: list[str]
    exclude: list[str]


@dataclass
class Document:
    source: str
    sources: list[str]
    kind: str
    name: str
    path: str
    aliases: list[dict[str, str]]
    management: str
    manager: str
    description: str
    headings: list[str]
    size: int
    mtime: str
    fingerprint: str
    managed_by_repo: bool = False


def expand_path(value: str) -> Path:
    return Path(os.path.expandvars(os.path.expanduser(value))).resolve()


def display_path(path: Path, *, resolve: bool = True) -> str:
    home = Path.home().resolve()
    actual = path.resolve() if resolve else path.absolute()
    try:
        rel = actual.relative_to(home)
        return f"~/{rel.as_posix()}"
    except ValueError:
        return actual.as_posix()


def utc_from_timestamp(ts: float) -> str:
    return datetime.fromtimestamp(ts, timezone.utc).isoformat()


def now_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")


def redact(text: str) -> str:
    if not text:
        return ""
    return SECRET_VALUE_RE.sub("[REDACTED]", text)


def normalize_name(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9._-]+", "-", value)
    value = re.sub(r"-+", "-", value).strip("-._")
    return value or "unnamed"


def path_is_sensitive(path: Path) -> bool:
    if any(part in SKIP_DIR_PARTS for part in path.parts):
        return True
    if any(part.endswith((".hm-backup", ".backup")) for part in path.parts):
        return True
    return any(SECRET_NAME_RE.search(part) for part in path.parts)


def path_is_within(path: Path, parent: Path) -> bool:
    try:
        path.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def ensure_output_outside_repo(data_dir: Path, repo_root: Path) -> None:
    if path_is_within(data_dir, repo_root):
        raise SystemExit(
            "refusing to write agent-curator output inside the nixos-config repo: "
            f"{display_path(data_dir)}"
        )


def matches_any(path: Path, root: Path, patterns: list[str]) -> bool:
    try:
        rel = path.relative_to(root).as_posix()
    except ValueError:
        return False
    return any(fnmatch.fnmatch(rel, pattern) for pattern in patterns)


def file_identity(path: Path) -> str:
    try:
        stat = path.stat()
        return f"inode:{stat.st_dev}:{stat.st_ino}"
    except OSError:
        return f"path:{path.resolve()}"


def path_contains(path: Path, marker: str, *, resolve: bool = True) -> bool:
    actual = path.resolve() if resolve else path.absolute()
    return marker in actual.as_posix()


def path_under(path: Path, root: Path, *, resolve: bool = True) -> bool:
    actual = path.resolve() if resolve else path.absolute()
    try:
        actual.relative_to(root)
        return True
    except ValueError:
        return False


def marketplace_name(path: Path) -> str:
    parts = path.absolute().parts
    try:
        index = parts.index("marketplaces")
    except ValueError:
        return "unknown"
    if index + 1 >= len(parts):
        return "unknown"
    return normalize_name(parts[index + 1])


def configured_auto_managed_prefixes(config: dict[str, Any]) -> list[str]:
    raw = config.get("auto_managed_skill_prefixes")
    if raw is None:
        return DEFAULT_AUTO_MANAGED_SKILL_PREFIXES.copy()
    if not isinstance(raw, list):
        return DEFAULT_AUTO_MANAGED_SKILL_PREFIXES.copy()
    prefixes = [str(item) for item in raw if str(item)]
    return prefixes or DEFAULT_AUTO_MANAGED_SKILL_PREFIXES.copy()


def classify_management(
    path: Path,
    kind: str,
    name: str,
    repo_root: Path,
    auto_managed_prefixes: list[str],
) -> tuple[str, str]:
    home = Path.home().resolve()
    raw = path.absolute()
    resolved = path.resolve()

    if path_under(resolved, repo_root):
        return "repo-managed", "nixos-config"

    if path_contains(path, "/skills/.system/", resolve=False) or path_contains(path, "/skills/.system/"):
        return "system-managed", "codex-system"

    if path_contains(path, "/.claude/plugins/marketplaces/", resolve=False):
        return "plugin-marketplace-managed", f"claude-marketplace:{marketplace_name(path)}"

    if path_contains(path, "/.codex/plugins/cache/", resolve=False) or path_contains(path, "/.codex/plugins/cache/"):
        return "plugin-marketplace-managed", "codex-plugin-cache"

    agent_skill_roots = [
        home / ".agents" / "skills",
        home / ".claude" / "skills",
        home / ".codex" / "skills",
    ]
    if (
        kind == "skill"
        and any(path_under(raw, root, resolve=False) for root in agent_skill_roots)
        and any(name.startswith(prefix) for prefix in auto_managed_prefixes)
    ):
        return "agent-curator-auto-managed", "agent-curator"

    if kind == "skill" and any(path_under(raw, root, resolve=False) for root in agent_skill_roots):
        return "agent-runtime-managed", "agent-cli-or-marketplace"

    if path_under(raw, home / ".claude", resolve=False) or path_under(raw, home / ".codex", resolve=False):
        return "local-agent-config", "home-directory"

    return "unknown", "unknown"


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---", 4)
    if end == -1:
        return {}
    raw = text[4:end]
    result: dict[str, str] = {}
    lines = raw.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        if ":" not in line or line.startswith((" ", "\t", "-")):
            index += 1
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip().strip("'\"")
        if key in {"name", "description", "version", "title"}:
            if value in {">", "|", ">-", "|-", ">+", "|+"}:
                block: list[str] = []
                index += 1
                while index < len(lines):
                    block_line = lines[index]
                    if block_line and not block_line.startswith((" ", "\t")):
                        break
                    if block_line.strip():
                        block.append(block_line.strip())
                    index += 1
                joined = "\n".join(block) if value.startswith("|") else " ".join(block)
                result[key] = redact(joined.strip())
                continue
            result[key] = redact(value)
        index += 1
    return result


def extract_headings(text: str) -> list[str]:
    headings: list[str] = []
    for line in text.splitlines():
        match = re.match(r"^(#{1,4})\s+(.+?)\s*$", line)
        if not match:
            continue
        heading = redact(match.group(2).strip())
        if heading and heading not in headings:
            headings.append(heading[:120])
        if len(headings) >= MAX_HEADING_COUNT:
            break
    return headings


def classify_document(path: Path) -> str:
    name = path.name
    parts = set(path.parts)
    if name == "SKILL.md":
        return "skill"
    if "commands" in parts and path.suffix == ".md":
        return "claude-command"
    if "agents" in parts and path.suffix == ".md":
        return "codex-agent"
    if name in {"AGENTS.md", "CLAUDE.md"}:
        return "agent-guidance"
    return "markdown"


def document_name(path: Path, frontmatter: dict[str, str]) -> str:
    if frontmatter.get("name"):
        return normalize_name(frontmatter["name"])
    if frontmatter.get("title"):
        return normalize_name(frontmatter["title"])
    if path.name == "SKILL.md":
        return normalize_name(path.parent.name)
    return normalize_name(path.stem)


def load_config(path: Path | None) -> dict[str, Any]:
    if path is None or not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"failed to read config {display_path(path)}: {exc}") from exc
    if not isinstance(data, dict):
        raise SystemExit(f"config {display_path(path)} must be a JSON object")
    return data


def default_sources(repo_root: Path) -> list[Source]:
    return [
        Source(
            name="claude-home",
            root="~/.claude",
            include=[
                "CLAUDE.md",
                "commands/**/*.md",
                "skills/**/SKILL.md",
                "plugins/**/AGENTS.md",
                "plugins/**/CLAUDE.md",
            ],
            exclude=[
                "skills/.system/**",
            ],
        ),
        Source(
            name="codex-home",
            root="~/.codex",
            include=[
                "AGENTS.md",
                "agents/*.md",
                "skills/**/SKILL.md",
            ],
            exclude=[
                "skills/.system/**",
                "worktrees/**",
                "archived_sessions/**",
                "history/**",
                "sessions/**",
            ],
        ),
        Source(
            name="codex-shared",
            root="~/.agents",
            include=["skills/**/SKILL.md"],
            exclude=[
                "skills/.system/**",
            ],
        ),
        Source(
            name="nixos-config",
            root=repo_root.as_posix(),
            include=[
                "AGENTS.md",
                "CLAUDE.md",
                ".agents/skills/**/SKILL.md",
                ".claude/skills/**/SKILL.md",
                "modules/home-manager/programs/skills/**/SKILL.md",
            ],
            exclude=[
                "secrets/**",
                ".direnv/**",
                ".git/**",
            ],
        ),
    ]


def configured_sources(config: dict[str, Any], repo_root: Path) -> list[Source]:
    raw_sources = config.get("sources")
    if not raw_sources:
        return default_sources(repo_root)
    sources: list[Source] = []
    for item in raw_sources:
        if not isinstance(item, dict):
            continue
        if not item.get("root") or not item.get("include"):
            continue
        sources.append(
            Source(
                name=str(item.get("name") or "source"),
                root=str(item.get("root") or ""),
                include=[str(v) for v in item.get("include", [])],
                exclude=[str(v) for v in item.get("exclude", [])],
            )
        )
    return sources


def iter_candidate_paths(source: Source) -> list[Path]:
    root = expand_path(source.root)
    if not root.exists():
        return []
    seen: set[Path] = set()
    paths: list[Path] = []
    for pattern in source.include:
        for path in root.glob(pattern):
            if not path.is_file() or path in seen:
                continue
            seen.add(path)
            if path_is_sensitive(path):
                continue
            if source.exclude and matches_any(path, root, source.exclude):
                continue
            paths.append(path)
    return sorted(paths)


def read_document(
    source: Source,
    path: Path,
    max_file_bytes: int,
    repo_root: Path,
    auto_managed_prefixes: list[str],
) -> Document | None:
    try:
        stat = path.stat()
    except OSError:
        return None
    if stat.st_size > max_file_bytes:
        return None

    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None
    if not text.strip():
        return None

    frontmatter = parse_frontmatter(text)
    kind = classify_document(path)
    name = document_name(path, frontmatter)
    management, manager = classify_management(path, kind, name, repo_root, auto_managed_prefixes)
    description = redact(frontmatter.get("description", "")).strip()[:MAX_DESCRIPTION_CHARS]
    headings = extract_headings(text)
    text_hash = hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]
    payload = json.dumps(
        {
            "kind": kind,
            "name": name,
            "description": description,
            "headings": headings,
            "text_hash": text_hash,
        },
        sort_keys=True,
    )
    return Document(
        source=source.name,
        sources=[source.name],
        kind=kind,
        name=name,
        path=display_path(path),
        aliases=[
            {
                "source": source.name,
                "path": display_path(path, resolve=False),
            }
        ],
        management=management,
        manager=manager,
        description=description,
        headings=headings,
        size=stat.st_size,
        mtime=utc_from_timestamp(stat.st_mtime),
        fingerprint=hashlib.sha256(payload.encode("utf-8")).hexdigest()[:16],
        managed_by_repo=repo_root in path.resolve().parents or path.resolve() == repo_root,
    )


def merge_document(existing: Document, incoming: Document) -> None:
    for source in incoming.sources:
        if source not in existing.sources:
            existing.sources.append(source)

    for alias in incoming.aliases:
        if alias not in existing.aliases:
            existing.aliases.append(alias)

    # Prefer the canonical shared source label when a file is seen through
    # ~/.claude/skills, ~/.codex/skills, and ~/.agents/skills compatibility paths.
    if incoming.source == "codex-shared":
        existing.source = incoming.source
        existing.path = incoming.path


def scan_documents(config: dict[str, Any]) -> tuple[list[Document], dict[str, Any]]:
    repo_root = expand_path(str(config.get("repo_root") or "~/nixos-config"))
    max_file_bytes = int(config.get("max_file_bytes") or 300_000)
    auto_managed_prefixes = configured_auto_managed_prefixes(config)
    docs_by_identity: dict[str, Document] = {}
    source_counts: dict[str, int] = {}
    raw_document_count = 0
    for source in configured_sources(config, repo_root):
        paths = iter_candidate_paths(source)
        source_counts[source.name] = len(paths)
        for path in paths:
            doc = read_document(
                source,
                path,
                max_file_bytes=max_file_bytes,
                repo_root=repo_root,
                auto_managed_prefixes=auto_managed_prefixes,
            )
            if doc is not None:
                raw_document_count += 1
                identity = file_identity(path)
                existing = docs_by_identity.get(identity)
                if existing is None:
                    docs_by_identity[identity] = doc
                else:
                    merge_document(existing, doc)
    docs = sorted(docs_by_identity.values(), key=lambda doc: (doc.kind, doc.name, doc.path))
    meta = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "repo_root": display_path(repo_root),
        "source_counts": source_counts,
        "raw_documents": raw_document_count,
        "deduplicated_documents": len(docs),
        "max_file_bytes": max_file_bytes,
        "auto_managed_skill_prefixes": auto_managed_prefixes,
        "policy": (
            "allowlist-only, no session logs, no JSON state, redacted metadata, "
            "realpath/inode deduplication, runtime/marketplace management classification, "
            "auto-managed skill prefix boundary"
        ),
    }
    return docs, meta


def data_dir_from(config: dict[str, Any], override: str | None) -> Path:
    if override:
        return expand_path(override)
    return expand_path(str(config.get("data_dir") or DEFAULT_DATA_DIR))


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


def repo_skill_names(docs: list[Document]) -> set[str]:
    return {doc.name for doc in docs if doc.kind == "skill" and doc.managed_by_repo}


def make_duplicate_proposals(docs: list[Document]) -> list[dict[str, Any]]:
    by_name: dict[str, list[Document]] = defaultdict(list)
    for doc in docs:
        if doc.kind != "skill":
            continue
        by_name[doc.name].append(doc)

    proposals: list[dict[str, Any]] = []
    for name, items in sorted(by_name.items()):
        if len(items) < 2:
            continue
        sources = {source for item in items for source in item.sources}
        fingerprints = {item.fingerprint for item in items}
        repo_managed = any(item.managed_by_repo for item in items)
        if repo_managed and len(fingerprints) == 1:
            continue
        proposals.append(
            {
                "type": "duplicate-skill",
                "name": name,
                "severity": "low" if len(fingerprints) == 1 else "medium",
                "summary": f"Skill '{name}' exists in {len(items)} real locations across {len(sources)} source view(s).",
                "recommendation": (
                    "Compare the runtime copy with the repo-managed copy and keep the repo version as source of truth."
                    if repo_managed
                    else "Review whether these locations should be consolidated or promoted into shared Nix-managed skills."
                ),
                "items": [asdict(item) for item in items],
            }
        )
    return proposals


def skill_inventory_entry(doc: Document) -> dict[str, Any]:
    return document_inventory_entry(doc)


def document_inventory_entry(doc: Document) -> dict[str, Any]:
    return {
        "name": doc.name,
        "path": doc.path,
        "description": doc.description,
        "mtime": doc.mtime,
        "management": doc.management,
        "manager": doc.manager,
    }


def make_runtime_managed_inventory_proposal(docs: list[Document]) -> list[dict[str, Any]]:
    managed_names = repo_skill_names(docs)
    runtime_managed = [
        doc
        for doc in docs
        if (
            doc.kind == "skill"
            and not doc.managed_by_repo
            and doc.name not in managed_names
            and doc.management in {"agent-runtime-managed", "plugin-marketplace-managed", "system-managed"}
        )
    ]
    if not runtime_managed:
        return []

    by_manager: dict[tuple[str, str], list[Document]] = defaultdict(list)
    for doc in runtime_managed:
        by_manager[(doc.management, doc.manager)].append(doc)

    items = []
    for (management, manager), manager_docs in sorted(by_manager.items()):
        items.append(
            {
                "management": management,
                "manager": manager,
                "count": len(manager_docs),
                "skills": [
                    skill_inventory_entry(doc)
                    for doc in sorted(manager_docs, key=lambda d: d.name)[:50]
                ],
                "truncated": len(manager_docs) > 50,
            }
        )

    return [
        {
            "type": "runtime-managed-skill-inventory",
            "name": "runtime-managed-skills",
            "severity": "info",
            "summary": f"{len(runtime_managed)} unique skills are managed outside nixos-config.",
            "recommendation": (
                "Keep CLI/marketplace-managed skills outside Nix by default. Pin a skill in "
                "nixos-config only when you intentionally want to freeze or override its content."
            ),
            "items": items,
        }
    ]


def make_auto_managed_skill_proposal(docs: list[Document]) -> list[dict[str, Any]]:
    auto_managed = [
        doc
        for doc in docs
        if doc.kind == "skill" and doc.management == "agent-curator-auto-managed"
    ]
    if not auto_managed:
        return []

    return [
        {
            "type": "auto-managed-skill-inventory",
            "name": "auto-managed-skills",
            "severity": "info",
            "summary": f"{len(auto_managed)} skill(s) are inside the agent-curator auto-managed boundary.",
            "recommendation": (
                "These skills may be changed automatically by future improve/apply flows. "
                "Keep this namespace for skills intentionally owned by agent-curator."
            ),
            "items": [
                {
                    "management": "agent-curator-auto-managed",
                    "manager": "agent-curator",
                    "count": len(auto_managed),
                    "skills": [
                        skill_inventory_entry(doc)
                        for doc in sorted(auto_managed, key=lambda d: d.name)[:50]
                    ],
                    "truncated": len(auto_managed) > 50,
                }
            ],
        }
    ]


def make_local_promotion_proposals(docs: list[Document]) -> list[dict[str, Any]]:
    managed_names = repo_skill_names(docs)
    candidates = [
        doc
        for doc in docs
        if (
            doc.kind == "skill"
            and not doc.managed_by_repo
            and doc.name not in managed_names
            and doc.management in {"local-agent-config", "unknown"}
        )
    ]
    if not candidates:
        return []

    return [
        {
            "type": "local-skill-promotion-candidates",
            "name": "local-skill-promotion-candidates",
            "severity": "info",
            "summary": f"{len(candidates)} local or unknown skills may be worth managing in nixos-config.",
            "recommendation": (
                "Review these manually. Promote only durable personal workflow policy, "
                "not marketplace/vendor content."
            ),
            "items": [
                {
                    "management": "local-or-unknown",
                    "manager": "manual-review",
                    "count": len(candidates),
                    "skills": [
                        skill_inventory_entry(doc)
                        for doc in sorted(candidates, key=lambda d: d.name)[:50]
                    ],
                    "truncated": len(candidates) > 50,
                }
            ],
        }
    ]


def make_local_agent_inventory_proposal(docs: list[Document]) -> list[dict[str, Any]]:
    local_agents = [
        doc
        for doc in docs
        if (
            doc.kind == "codex-agent"
            and not doc.managed_by_repo
            and doc.management in {"local-agent-config", "unknown"}
        )
    ]
    if not local_agents:
        return []

    return [
        {
            "type": "local-agent-inventory",
            "name": "local-codex-agents",
            "severity": "info",
            "summary": f"{len(local_agents)} local Codex agent(s) are managed outside nixos-config.",
            "recommendation": (
                "Keep generated or marketplace agent packs outside Nix by default. "
                "Promote only durable personal agents that should be reproducible across machines."
            ),
            "items": [
                {
                    "management": "local-or-unknown",
                    "manager": "manual-review",
                    "count": len(local_agents),
                    "noun": "agent(s)",
                    "entries": [
                        document_inventory_entry(doc)
                        for doc in sorted(local_agents, key=lambda d: d.name)[:50]
                    ],
                    "truncated": len(local_agents) > 50,
                }
            ],
        }
    ]


def make_guidance_proposals(docs: list[Document]) -> list[dict[str, Any]]:
    guidance = [
        doc
        for doc in docs
        if doc.kind == "agent-guidance" and doc.management != "plugin-marketplace-managed"
    ]
    if len(guidance) < 2:
        return []
    by_name: dict[str, list[Document]] = defaultdict(list)
    for doc in guidance:
        by_name[doc.name].append(doc)

    proposals: list[dict[str, Any]] = []
    for name, items in sorted(by_name.items()):
        sources = {source for item in items for source in item.sources}
        if len(sources) < 2:
            continue
        proposals.append(
            {
                "type": "guidance-alignment",
                "name": name,
                "severity": "info",
                "summary": f"Guidance file '{name}' appears in {len(sources)} sources.",
                "recommendation": (
                    "Review for durable preferences that should be centralized in the repo, "
                    "without copying private session-specific details."
                ),
                "items": [asdict(item) for item in items],
            }
        )
    return proposals


def build_proposals(docs: list[Document]) -> list[dict[str, Any]]:
    proposals: list[dict[str, Any]] = []
    proposals.extend(make_duplicate_proposals(docs))
    proposals.extend(make_auto_managed_skill_proposal(docs))
    proposals.extend(make_runtime_managed_inventory_proposal(docs))
    proposals.extend(make_local_promotion_proposals(docs))
    proposals.extend(make_local_agent_inventory_proposal(docs))
    proposals.extend(make_guidance_proposals(docs))
    return proposals


def proposal_markdown(proposal: dict[str, Any]) -> str:
    lines = [
        "---",
        f"type: {proposal['type']}",
        f"name: {proposal['name']}",
        f"severity: {proposal['severity']}",
        "status: proposed",
        "---",
        "",
        f"# {proposal['summary']}",
        "",
        "## Recommendation",
        "",
        proposal["recommendation"],
        "",
        "## Evidence",
        "",
        "Only sanitized metadata is included here. Review source files locally before promoting anything.",
        "",
    ]
    for item in proposal.get("items", []):
        if isinstance(item, dict) and "path" in item:
            sources = ", ".join(item.get("sources") or [item.get("source", "?")])
            lines.extend(
                [
                    f"- `{item.get('name', proposal['name'])}` from `{sources}`",
                    f"  - path: `{item.get('path', '')}`",
                    f"  - management: `{item.get('management', 'unknown')}` via `{item.get('manager', 'unknown')}`",
                    f"  - description: {item.get('description') or '(none)'}",
                ]
            )
            aliases = item.get("aliases") or []
            if len(aliases) > 1:
                lines.append("  - aliases:")
                for alias in aliases:
                    lines.append(f"    - `{alias.get('source', '?')}`: `{alias.get('path', '')}`")
        elif isinstance(item, dict) and ("skills" in item or "entries" in item):
            entries = item.get("entries") or item.get("skills") or []
            noun = item.get("noun") or "skill(s)"
            label = item.get("source") or item.get("manager") or item.get("management") or "unknown"
            lines.append(f"- `{label}`: {item.get('count')} {noun}")
            for entry in entries:
                desc = entry.get("description") or "(none)"
                lines.append(
                    f"  - `{entry.get('name')}` - `{entry.get('management', 'unknown')}` "
                    f"via `{entry.get('manager', 'unknown')}` - {desc} - `{entry.get('path')}`"
                )
            if item.get("truncated"):
                lines.append("  - ... truncated, see latest index.json")
    lines.append("")
    return "\n".join(lines)


def report_markdown(docs: list[Document], proposals: list[dict[str, Any]], meta: dict[str, Any]) -> str:
    by_source: dict[str, int] = defaultdict(int)
    by_kind: dict[str, int] = defaultdict(int)
    by_management: dict[str, int] = defaultdict(int)
    for doc in docs:
        by_source[doc.source] += 1
        by_kind[doc.kind] += 1
        by_management[doc.management] += 1

    lines = [
        "# Agent Curator Report",
        "",
        f"- generated_at: `{meta['generated_at']}`",
        f"- repo_root: `{meta['repo_root']}`",
        f"- raw_documents: `{meta.get('raw_documents', len(docs))}`",
        f"- documents_indexed: `{len(docs)}`",
        f"- proposals: `{len(proposals)}`",
        f"- auto_managed_skill_prefixes: `{', '.join(meta.get('auto_managed_skill_prefixes', [])) or '(none)'}`",
        f"- policy: {meta['policy']}",
        "",
        "## By Source",
        "",
    ]
    for source, count in sorted(by_source.items()):
        lines.append(f"- `{source}`: {count}")
    lines.extend(["", "## By Kind", ""])
    for kind, count in sorted(by_kind.items()):
        lines.append(f"- `{kind}`: {count}")
    lines.extend(["", "## By Management", ""])
    for management, count in sorted(by_management.items()):
        lines.append(f"- `{management}`: {count}")
    lines.extend(["", "## Proposals", ""])
    if not proposals:
        lines.append("- none")
    else:
        for proposal in proposals:
            lines.append(f"- `{proposal['type']}` `{proposal['name']}`: {proposal['summary']}")
    lines.append("")
    return "\n".join(lines)


def clear_proposal_dir(proposal_dir: Path) -> int:
    if not proposal_dir.exists():
        return 0

    removed = 0
    for path in proposal_dir.glob("*.md"):
        if not path.is_file():
            continue
        path.unlink()
        removed += 1
    return removed


def cmd_scan(args: argparse.Namespace) -> int:
    config = load_config(expand_path(args.config) if args.config else None)
    if args.repo_root:
        config["repo_root"] = args.repo_root
    data_dir = data_dir_from(config, args.data_dir)
    repo_root = expand_path(str(config.get("repo_root") or "~/nixos-config"))
    ensure_output_outside_repo(data_dir, repo_root)
    docs, meta = scan_documents(config)
    proposals = [] if args.no_proposals else build_proposals(docs)

    stamp = now_stamp()
    run_dir = data_dir / "runs" / stamp
    payload = {
        "meta": meta,
        "documents": [asdict(doc) for doc in docs],
        "proposals": proposals,
    }
    write_json(run_dir / "index.json", payload)
    write_text(run_dir / "REPORT.md", report_markdown(docs, proposals, meta))
    write_json(data_dir / "latest.json", payload)

    if not args.no_proposals:
        proposal_dir = data_dir / "proposals"
        removed = 0 if args.keep_proposal_history else clear_proposal_dir(proposal_dir)
        for index, proposal in enumerate(proposals, start=1):
            filename = f"{stamp}-{index:02d}-{proposal['type']}-{proposal['name']}.md"
            write_text(proposal_dir / filename, proposal_markdown(proposal))

    print(f"indexed {len(docs)} documents")
    print(f"wrote {display_path(run_dir / 'REPORT.md')}")
    if proposals:
        print(f"wrote {len(proposals)} proposal(s) under {display_path(data_dir / 'proposals')}")
        if removed:
            print(f"removed {removed} old proposal file(s)")
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    config = load_config(expand_path(args.config) if args.config else None)
    data_dir = data_dir_from(config, args.data_dir)
    latest = data_dir / "latest.json"
    if not latest.exists():
        print("agent-curator: no scan yet")
        print("run: agent-curator scan")
        return 1
    data = json.loads(latest.read_text(encoding="utf-8"))
    meta = data.get("meta", {})
    docs = data.get("documents", [])
    proposals = data.get("proposals", [])
    print(f"latest scan: {meta.get('generated_at', 'unknown')}")
    print(f"documents: {len(docs)}")
    print(f"proposals: {len(proposals)}")
    prefixes = meta.get("auto_managed_skill_prefixes") or []
    print(f"auto-managed prefixes: {', '.join(prefixes) if prefixes else '(none)'}")
    by_management: dict[str, int] = defaultdict(int)
    for doc in docs:
        by_management[str(doc.get("management", "unknown"))] += 1
    print(f"auto-managed skills: {by_management.get('agent-curator-auto-managed', 0)}")
    if by_management:
        print("management:")
        for management, count in sorted(by_management.items()):
            print(f"  {management}: {count}")
    by_type: dict[str, int] = defaultdict(int)
    for proposal in proposals:
        by_type[str(proposal.get("type", "unknown"))] += 1
    if by_type:
        print("proposal types:")
        for proposal_type, count in sorted(by_type.items()):
            print(f"  {proposal_type}: {count}")
    print(f"report data: {display_path(data_dir)}")
    return 0


def cmd_doctor(args: argparse.Namespace) -> int:
    config = load_config(expand_path(args.config) if args.config else None)
    if args.repo_root:
        config["repo_root"] = args.repo_root
    data_dir = data_dir_from(config, args.data_dir)
    repo_root = expand_path(str(config.get("repo_root") or "~/nixos-config"))
    auto_managed_prefixes = configured_auto_managed_prefixes(config)
    print(f"config: {display_path(expand_path(args.config)) if args.config else '(default/missing ok)'}")
    output_state = "refused-inside-repo" if path_is_within(data_dir, repo_root) else "ok-outside-repo"
    print(f"data_dir: {display_path(data_dir)} {output_state}")
    print(f"repo_root: {display_path(repo_root)} {'ok' if repo_root.exists() else 'missing'}")
    print(f"auto-managed prefixes: {', '.join(auto_managed_prefixes)}")
    for source in configured_sources(config, repo_root):
        root = expand_path(source.root)
        count = len(iter_candidate_paths(source))
        state = "ok" if root.exists() else "missing"
        print(f"source {source.name}: {display_path(root)} {state}, {count} candidate(s)")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="agent-curator",
        description="Read-only curator for Claude/Codex durable knowledge files.",
    )
    parser.add_argument(
        "--config",
        default=DEFAULT_CONFIG_PATH,
        help="JSON config path (default: ~/.config/agent-curator/config.json)",
    )
    parser.add_argument("--data-dir", help="Override output directory")
    parser.add_argument("--repo-root", help="Override nixos-config path")
    sub = parser.add_subparsers(dest="command", required=True)

    scan = sub.add_parser("scan", help="Index allowlisted knowledge files and write proposals")
    scan.add_argument("--no-proposals", action="store_true", help="Only write the inventory/report")
    scan.add_argument(
        "--keep-proposal-history",
        action="store_true",
        help="Do not clear old proposal markdown files before writing the latest scan proposals",
    )
    scan.set_defaults(func=cmd_scan)

    status = sub.add_parser("status", help="Show latest scan summary")
    status.set_defaults(func=cmd_status)

    doctor = sub.add_parser("doctor", help="Show source discovery and safety settings")
    doctor.set_defaults(func=cmd_doctor)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
