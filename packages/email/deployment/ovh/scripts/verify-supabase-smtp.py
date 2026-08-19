"""Probe an SMTP submission endpoint without exposing connection secrets."""

import os
import smtplib
import ssl
import sys


def _require_code(command, response, expected):
    """Return the response code or raise a concise error for an SMTP failure."""
    code, _message = response
    if code != expected:
        raise RuntimeError(
            f"SMTP {command} failed: expected {expected}, received {code}"
        )
    return code


def probe_smtp(
    *,
    host,
    port,
    username,
    password,
    sender,
    recipient,
    smtp_factory=smtplib.SMTP,
    tls_context_factory=ssl.create_default_context,
):
    """Authenticate and submit a small probe message through an SMTP server."""
    client = None
    primary_error = None
    quit_code = None

    try:
        client = smtp_factory(host, port, timeout=10)
        _require_code("EHLO", client.ehlo(), 250)
        _require_code("STARTTLS", client.starttls(context=tls_context_factory()), 220)
        _require_code("EHLO", client.ehlo(), 250)
        _require_code("AUTH", client.login(username, password), 235)
        _require_code("MAIL", client.mail(sender), 250)
        _require_code("RCPT", client.rcpt(recipient), 250)
        _require_code(
            "DATA",
            client.data("Subject: SMTP verification\r\n\r\nSMTP verification probe."),
            250,
        )
    except Exception as error:
        primary_error = error
        raise
    finally:
        if client is not None:
            try:
                quit_code = _require_code("QUIT", client.quit(), 221)
            except Exception:
                if primary_error is None:
                    raise

    return {
        "host": host,
        "port": port,
        "authenticated": True,
        "submission_accepted": True,
        "quit_code": quit_code,
    }


def main(environment, probe, output):
    """Run the SMTP probe and report a non-sensitive success status."""
    probe(
        host=environment["SUPABASE_SMTP_PROBE_HOST"],
        port=int(environment["SUPABASE_SMTP_PROBE_PORT"]),
        username=environment["SUPABASE_SMTP_PROBE_USERNAME"],
        password=environment["SUPABASE_SMTP_PROBE_PASSWORD"],
        sender=environment["SUPABASE_SMTP_PROBE_SENDER"],
        recipient=environment["SUPABASE_SMTP_PROBE_RECIPIENT"],
    )
    output.write("SMTP probe accepted and queued.\n")


if __name__ == "__main__":
    try:
        main(os.environ, probe_smtp, sys.stdout)
    except (KeyError, OSError, RuntimeError, ValueError, smtplib.SMTPException) as error:
        print(f"Supabase SMTP probe failed: {error}", file=sys.stderr)
        raise SystemExit(1) from error
