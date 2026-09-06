"""Markdown reporting for gym operational analytics."""

from __future__ import annotations

from typing import Any, Iterable


SECTIONS = {
    "membership_mix": "Current membership mix",
    "payment_status": "Payments by status",
    "class_performance": "Class performance",
    "trainer_workload": "Trainer workload",
    "members_for_follow_up": "Members for follow-up",
}


def _label(value: str) -> str:
    return value.replace("_", " ").title()


def _table(rows: Iterable[dict[str, Any]]) -> list[str]:
    items = list(rows)
    if not items:
        return ["No records."]
    columns = list(items[0])
    lines = [
        "| " + " | ".join(_label(column) for column in columns) + " |",
        "| " + " | ".join("---" for _ in columns) + " |",
    ]
    for row in items:
        lines.append(
            "| " + " | ".join("—" if row[column] is None else str(row[column]) for column in columns) + " |"
        )
    return lines


def build_report(
    results: dict[str, list[dict[str, Any]]],
    *,
    report_start: str,
    report_end: str,
    as_of: str,
) -> str:
    summary_rows = results.get("executive_summary", [])
    if len(summary_rows) != 1:
        raise ValueError("Executive summary must return exactly one row")
    summary = summary_rows[0]

    lines = [
        "# Gym Management Database Report",
        "",
        f"**Reporting window:** {report_start} through {report_end}  ",
        f"**Membership snapshot:** {as_of}",
        "",
        "## Executive summary",
        "",
        f"- Active members: {summary['active_members']}",
        f"- Frozen members: {summary['frozen_members']}",
        f"- Successful payment revenue: ${summary['collected_revenue']:.2f}",
        f"- Payment success rate: {summary['payment_success_pct']}%",
        f"- Class attendance rate: {summary['attendance_pct']}%",
    ]

    for key, title in SECTIONS.items():
        if key not in results:
            raise ValueError(f"Missing analysis result: {key}")
        lines.extend(["", f"## {title}", "", *_table(results[key])])

    lines.extend(
        [
            "",
            "## Interpretation notes",
            "",
            "- Revenue includes completed payments only; failed, pending, and refunded payments are separated.",
            "- Attendance rate excludes cancelled bookings.",
            "- Follow-up identifies current members with a payment issue or no recorded attendance.",
            "- All records are fictional and created for portfolio demonstration.",
            "",
        ]
    )
    return "\n".join(lines)

