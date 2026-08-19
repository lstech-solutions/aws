from pathlib import Path
import tomllib
import unittest


CONFIG_PATH = Path(__file__).resolve().parents[2] / "stalwart" / "config.toml"
ACCOUNT_LIST_CONDITION = (
    "!is_empty(authenticated_as) & "
    "contains(split('%{env:SUPABASE_SMTP_ACCOUNT_LIST}%', ','), authenticated_as)"
)


class SupabaseSubmissionPolicyTests(unittest.TestCase):
    def test_limits_are_account_scoped_and_preserve_standard_submission_defaults(self):
        config = tomllib.loads(CONFIG_PATH.read_text(encoding="utf-8"))
        session = config["session"]

        self.assertNotIn("auth", session)
        self.assertEqual(
            session["rcpt"]["max-recipients"],
            [
                {"if": ACCOUNT_LIST_CONDITION, "then": 25},
                {"else": 100},
            ],
        )
        self.assertEqual(
            config["queue"]["limiter"]["inbound"]["supabase-submission"],
            {
                "match": ACCOUNT_LIST_CONDITION,
                "key": "authenticated_as",
                "rate": "30/1m",
            },
        )


if __name__ == "__main__":
    unittest.main()
