"""Build the SQLite gym database from versioned SQL files."""

from __future__ import annotations

import sqlite3
from pathlib import Path


def build_database(schema_path: Path, seed_path: Path) -> sqlite3.Connection:
    """Create and populate an in-memory SQLite database."""
    connection = sqlite3.connect(":memory:")
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    connection.executescript(schema_path.read_text(encoding="utf-8"))
    connection.executescript(seed_path.read_text(encoding="utf-8"))
    connection.commit()
    return connection

