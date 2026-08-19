import importlib.util
from pathlib import Path
import unittest
from unittest.mock import Mock


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "verify-supabase-smtp.py"


def load_module():
    spec = importlib.util.spec_from_file_location("verify_supabase_smtp", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class FakeSMTP:
    def __init__(self, data_result=(250, b"queued"), quit_result=(221, b"bye")):
        self.ehlo = Mock(return_value=(250, b"hello"))
        self.starttls = Mock(return_value=(220, b"ready"))
        self.login = Mock(return_value=(235, b"authenticated"))
        self.mail = Mock(return_value=(250, b"sender accepted"))
        self.rcpt = Mock(return_value=(250, b"recipient accepted"))
        self.data = Mock(return_value=data_result)
        self.quit = Mock(return_value=quit_result)


class ProbeSmtpTests(unittest.TestCase):
    def setUp(self):
        self.module = load_module()
        self.connection_details = {
            "host": "smtp.example.test",
            "port": 587,
            "username": "smtp-user",
            "password": "<password>",
            "sender": "sender@example.test",
            "recipient": "recipient@example.test",
        }

    def test_probe_requires_successful_authenticated_submission_and_clean_quit(self):
        client = FakeSMTP()
        smtp_factory = Mock(return_value=client)

        result = self.module.probe_smtp(
            **self.connection_details,
            smtp_factory=smtp_factory,
        )

        smtp_factory.assert_called_once_with(
            self.connection_details["host"],
            self.connection_details["port"],
            timeout=10,
        )
        self.assertEqual(client.ehlo.call_count, 2)
        client.starttls.assert_called_once()
        client.login.assert_called_once_with(
            self.connection_details["username"],
            self.connection_details["password"],
        )
        client.mail.assert_called_once_with(self.connection_details["sender"])
        client.rcpt.assert_called_once_with(self.connection_details["recipient"])
        client.data.assert_called_once()
        client.quit.assert_called_once_with()

        self.assertEqual(
            result,
            {
                "host": "smtp.example.test",
                "port": 587,
                "authenticated": True,
                "submission_accepted": True,
                "quit_code": 221,
            },
        )
        self.assertNotIn(self.connection_details["password"], repr(result))
        self.assertNotIn(self.connection_details["username"], repr(result))

    def test_probe_rejects_a_non_250_data_response(self):
        client = FakeSMTP(data_result=(451, b"temporary failure"))

        with self.assertRaisesRegex(
            RuntimeError,
            r"SMTP DATA failed: expected 250, received 451",
        ):
            self.module.probe_smtp(
                **self.connection_details,
                smtp_factory=Mock(return_value=client),
            )

        client.quit.assert_called_once_with()

    def test_main_passes_named_probe_environment_to_probe_and_redacts_sensitive_output(self):
        environment = {
            "SUPABASE_SMTP_PROBE_HOST": "smtp.<probe-host>.invalid",
            "SUPABASE_SMTP_PROBE_PORT": "2525",
            "SUPABASE_SMTP_PROBE_USERNAME": "<probe-username>",
            "SUPABASE_SMTP_PROBE_PASSWORD": "<probe-password>",
            "SUPABASE_SMTP_PROBE_SENDER": "<probe-sender>@<probe-domain>",
            "SUPABASE_SMTP_PROBE_RECIPIENT": "<probe-recipient>@<probe-domain>",
        }
        received = {}
        message_body = "<probe-message-body>"

        def probe(**values):
            received.update(values)
            return {"accepted": True, "queued": True, "message_body": message_body}

        class Output:
            def __init__(self):
                self.chunks = []

            def write(self, value):
                self.chunks.append(value)

        output = Output()

        self.module.main(environment, probe, output)

        self.assertEqual(
            received,
            {
                "host": environment["SUPABASE_SMTP_PROBE_HOST"],
                "port": 2525,
                "username": environment["SUPABASE_SMTP_PROBE_USERNAME"],
                "password": environment["SUPABASE_SMTP_PROBE_PASSWORD"],
                "sender": environment["SUPABASE_SMTP_PROBE_SENDER"],
                "recipient": environment["SUPABASE_SMTP_PROBE_RECIPIENT"],
            },
        )
        rendered = "".join(output.chunks).lower()
        self.assertIn("accepted", rendered)
        self.assertIn("queued", rendered)
        self.assertNotIn(environment["SUPABASE_SMTP_PROBE_USERNAME"].lower(), rendered)
        self.assertNotIn(environment["SUPABASE_SMTP_PROBE_PASSWORD"].lower(), rendered)
        self.assertNotIn(message_body.lower(), rendered)

    def test_probe_reannounces_ehlo_after_starttls_with_verifying_context(self):
        client = FakeSMTP()
        smtp_factory = Mock(return_value=client)
        tls_context = object()
        tls_context_factory = Mock(return_value=tls_context)

        self.module.probe_smtp(
            **self.connection_details,
            smtp_factory=smtp_factory,
            tls_context_factory=tls_context_factory,
        )

        tls_context_factory.assert_called_once_with()
        client.starttls.assert_called_once_with(context=tls_context)
        self.assertEqual(client.ehlo.call_count, 2)


if __name__ == "__main__":
    unittest.main()
