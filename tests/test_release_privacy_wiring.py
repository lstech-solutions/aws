import json
from pathlib import Path
import unittest


PACKAGE_JSON = Path(__file__).resolve().parents[1] / "package.json"


class ReleasePrivacyWiringTests(unittest.TestCase):
    def test_precommit_versioning_and_push_release_run_the_privacy_guard(self):
        scripts = json.loads(PACKAGE_JSON.read_text(encoding="utf-8"))["scripts"]

        self.assertEqual(
            scripts["privacy:check"],
            "bash scripts/privacy-guard.sh --staged",
        )
        self.assertEqual(
            scripts["test:privacy"],
            "python3 -m unittest tests/test_privacy_guard.py tests/test_release_privacy_wiring.py",
        )
        self.assertIn("pnpm run privacy:check", scripts["pre-commit"])
        self.assertIn("pnpm run test:privacy", scripts["pre-commit"])
        for version_script in (
            "version:patch",
            "version:minor",
            "version:major",
            "version:prerelease",
        ):
            self.assertTrue(
                scripts[version_script].startswith("pnpm run privacy:check"),
                version_script,
            )
        self.assertIn("pnpm run privacy:release", scripts["prerelease"])
        self.assertIn("pnpm run test:privacy", scripts["prerelease"])
        self.assertTrue(scripts["privacy:release"].startswith("git fetch --quiet origin main"))
        self.assertTrue(scripts["push:release"].startswith("pnpm run privacy:release"))


if __name__ == "__main__":
    unittest.main()
