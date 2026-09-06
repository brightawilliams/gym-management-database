"""Command-line interface for the gym management database report."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Sequence

from .analytics import load_named_queries, run_analysis
from .database import build_database
from .reporting import build_report


def _root() -> Path:
    return Path(__file__).resolve().parents[2]


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate gym operational analytics.")
    parser.add_argument("--report-start", default="2026-08-01")
    parser.add_argument("--report-end", default="2026-08-31")
    parser.add_argument("--as-of", default="2026-08-31")
    parser.add_argument("--output", "-o", type=Path, default=Path("gym_report.md"))
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    root = _root()
    try:
        connection = build_database(root / "sql" / "schema.sql", root / "sql" / "seed.sql")
        queries = load_named_queries(root / "sql" / "business_queries.sql")
        results = run_analysis(
            connection,
            queries,
            report_start=args.report_start,
            report_end=args.report_end,
            as_of=args.as_of,
        )
        report = build_report(
            results,
            report_start=args.report_start,
            report_end=args.report_end,
            as_of=args.as_of,
        )
        args.output.write_text(report, encoding="utf-8")
    except (OSError, ValueError) as exc:
        print(f"Error: {exc}")
        return 1
    finally:
        if "connection" in locals():
            connection.close()

    print(f"Report written to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

