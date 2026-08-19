from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE_ROOT = Path(__file__).resolve().parents[1]
GUARD_SOURCE = SOURCE_ROOT / "scripts" / "privacy-guard.sh"


class PrivacyGuardStagedTests(unittest.TestCase):
    def make_repo(self):
        temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(temporary_directory.cleanup)
        repository = Path(temporary_directory.name)

        subprocess.run(["git", "init", "-q"], cwd=repository, check=True)
        subprocess.run(
            ["git", "config", "user.email", "test@example.invalid"],
            cwd=repository,
            check=True,
        )
        subprocess.run(
            ["git", "config", "user.name", "Privacy Guard Test"],
            cwd=repository,
            check=True,
        )

        target = repository / "scripts" / "privacy-guard.sh"
        target.parent.mkdir(parents=True)
        shutil.copy2(GUARD_SOURCE, target)
        return repository

    def stage(self, repository, relative_path, content):
        file_path = repository / relative_path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content, encoding="utf-8")
        subprocess.run(["git", "add", "--", str(relative_path)], cwd=repository, check=True)

    def run_guard(self, repository):
        return subprocess.run(
            ["bash", "scripts/privacy-guard.sh", "--staged"],
            cwd=repository,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_fails_for_real_email_added_in_staged_change(self):
        repository = self.make_repo()
        email = "person" + "@" + "company.test"
        self.stage(repository, "notes.txt", "contact=" + email + "\n")

        result = self.run_guard(repository)

        self.assertNotEqual(result.returncode, 0)

    def test_fails_for_non_loopback_ipv4_added_in_staged_change(self):
        repository = self.make_repo()
        address = ".".join(["8", "8", "8", "8"])
        self.stage(repository, "notes.txt", "server=" + address + "\n")

        result = self.run_guard(repository)

        self.assertNotEqual(result.returncode, 0)

    def test_fails_for_tenant_domain_in_public_mail_configuration(self):
        repository = self.make_repo()
        self.stage(
            repository,
            "packages/email/deployment/ovh/stalwart/config.toml",
            'domain = "tenant-private.com"\n',
        )

        result = self.run_guard(repository)

        self.assertNotEqual(result.returncode, 0)

    def test_allows_vendor_domain_outside_mail_host_fields_in_env_example(self):
        repository = self.make_repo()
        self.stage(
            repository,
            "packages/email/deployment/ovh/.env.example",
            "CADDY_CERT_ISSUER=acme-v02.api.letsencrypt.org-directory\n",
        )

        result = self.run_guard(repository)

        self.assertEqual(result.returncode, 0)

    def test_fails_for_each_runtime_or_private_path_when_staged(self):
        prohibited_paths = (
            ".env",
            "packages/email/deployment/ovh/private/domains.local.json",
            ".agents/state.json",
            ".codex/state.json",
            ".tdd-state.json",
        )

        for prohibited_path in prohibited_paths:
            with self.subTest(path=prohibited_path):
                repository = self.make_repo()
                self.stage(repository, prohibited_path, "safe-looking test content\n")

                result = self.run_guard(repository)

                self.assertNotEqual(result.returncode, 0)

    def test_allows_placeholders_and_example_invalid_values(self):
        repository = self.make_repo()
        self.stage(
            repository,
            "docs/setup.md",
            "mail=user@<domain>\nhost=<mail-host>\nexample=user@example.invalid\naddress=127.0.0.1\n",
        )

        result = self.run_guard(repository)

        self.assertEqual(result.returncode, 0)

    def test_ignores_unstaged_sensitive_content_and_checks_staged_snapshot_only(self):
        repository = self.make_repo()
        staged_path = repository / "docs" / "safe.md"
        self.stage(repository, "docs/safe.md", "placeholder=user@<domain>\n")

        email = "person" + "@" + "company.test"
        staged_path.write_text("contact=" + email + "\n", encoding="utf-8")

        result = self.run_guard(repository)

        self.assertEqual(result.returncode, 0)

    def test_passes_when_only_safe_files_are_staged(self):
        repository = self.make_repo()
        self.stage(repository, "README.md", "Use user@example.invalid in documentation.\n")
        self.stage(repository, "config/example.txt", "host=<webmail-host>\n")

        result = self.run_guard(repository)

        self.assertEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
