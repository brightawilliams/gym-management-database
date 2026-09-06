import sqlite3
import tempfile
import unittest
from pathlib import Path

from gym_database import build_database, load_named_queries, run_analysis
from gym_database.reporting import build_report


ROOT = Path(__file__).resolve().parents[1]
PARAMETERS = {
    "report_start": "2026-08-01",
    "report_end": "2026-08-31",
    "as_of": "2026-08-31",
}


class GymDatabaseTests(unittest.TestCase):
    def setUp(self):
        self.connection = build_database(ROOT / "sql" / "schema.sql", ROOT / "sql" / "seed.sql")
        self.queries = load_named_queries(ROOT / "sql" / "business_queries.sql")
        self.results = run_analysis(self.connection, self.queries, **PARAMETERS)

    def tearDown(self):
        self.connection.close()

    def test_table_counts_are_stable(self):
        counts = {
            table: self.connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            for table in ("members", "memberships", "payments", "fitness_classes", "class_enrollments")
        }
        self.assertEqual(counts, {
            "members": 10,
            "memberships": 10,
            "payments": 14,
            "fitness_classes": 8,
            "class_enrollments": 32,
        })

    def test_executive_summary_is_reproducible(self):
        summary = self.results["executive_summary"][0]
        self.assertEqual(summary["active_members"], 7)
        self.assertEqual(summary["frozen_members"], 1)
        self.assertEqual(summary["collected_revenue"], 225.0)
        self.assertEqual(summary["payment_success_pct"], 62.5)

    def test_membership_relationship_rejects_unknown_member(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                "INSERT INTO memberships VALUES ('BAD', 'UNKNOWN', 'PL-BASIC', '2026-08-01', NULL, 'Active', 2900)"
            )

    def test_duplicate_class_booking_is_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                "INSERT INTO class_enrollments VALUES ('CL001', 'M001', '2026-08-02', 'Booked')"
            )

    def test_payment_amount_must_be_positive(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.connection.execute(
                "INSERT INTO payments VALUES ('BAD', 'MS001', '2026-08-01', 0, 'Cash', 'Completed')"
            )

    def test_expected_business_queries_are_present(self):
        self.assertEqual(set(self.queries), {
            "executive_summary",
            "membership_mix",
            "payment_status",
            "class_performance",
            "trainer_workload",
            "members_for_follow_up",
        })

    def test_report_contains_management_sections(self):
        report = build_report(self.results, **PARAMETERS)
        self.assertIn("Active members: 7", report)
        self.assertIn("## Class performance", report)
        self.assertIn("## Members for follow-up", report)

    def test_unnamed_query_file_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "queries.sql"
            path.write_text("SELECT 1;", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "No named SQL queries"):
                load_named_queries(path)


if __name__ == "__main__":
    unittest.main()
