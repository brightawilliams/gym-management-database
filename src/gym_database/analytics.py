"""Load and execute named gym-management SQL queries."""

from __future__ import annotations

import re
import sqlite3
from pathlib import Path
from typing import Any


QUERY_MARKER = re.compile(r"^-- name: ([a-z][a-z0-9_]*)\s*$", re.MULTILINE)


def load_named_queries(path: Path) -> dict[str, str]:
    source = path.read_text(encoding="utf-8")
    matches = list(QUERY_MARKER.finditer(source))
    if not matches:
        raise ValueError("No named SQL queries were found")

    queries: dict[str, str] = {}
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        statement = source[match.end():end].strip()
        if not statement:
            raise ValueError(f"Query '{match.group(1)}' is empty")
        queries[match.group(1)] = statement
    return queries


def run_analysis(
    connection: sqlite3.Connection,
    queries: dict[str, str],
    *,
    report_start: str,
    report_end: str,
    as_of: str,
) -> dict[str, list[dict[str, Any]]]:
    parameters = {
        "report_start": report_start,
        "report_end": report_end,
        "as_of": as_of,
    }
    return {
        name: [dict(row) for row in connection.execute(statement, parameters).fetchall()]
        for name, statement in queries.items()
    }

