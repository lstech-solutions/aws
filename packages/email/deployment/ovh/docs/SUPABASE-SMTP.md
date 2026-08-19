# Supabase Auth SMTP Profile

TLÁO Mail supports Supabase Auth custom SMTP through its normal authenticated
submission endpoint. Supabase owns the confirmation, recovery, magic-link, and
OTP templates; TLÁO accepts, queues, and delivers the resulting message
without rewriting it.

## Configuration

Use a dedicated app-only mailbox for one tenant or integration:

```text
SMTP host: <mail-host>
Port: 587
Security: STARTTLS
Username: transactional@<domain>
Password: <dedicated-mailbox-password>
Sender: transactional@<domain>
```

Never use a personal, shared, support, or administrator mailbox. Store the
credential in Supabase and the ignored repository-root `.env`; do not place
it in tracked files, issue comments, or the VPS environment.

The endpoint requires `EHLO`, `STARTTLS`, a second `EHLO`, SMTP
authentication, `MAIL FROM`, `RCPT TO`, `DATA`, and `QUIT`. Successful
submission returns `250` after `DATA` and `221` after `QUIT`.

## Scoped Policy

The VPS-only `SUPABASE_SMTP_ACCOUNT_LIST` may list dedicated mailbox logins
that receive the Supabase profile. Accounts on that list are limited to 25
recipients per message and 30 accepted submissions per minute; all other
mailboxes retain the normal service limits. Authentication and
authenticated-sender ownership remain required—there is no open-relay or
source-IP exception.

## Verification

Configure the six `SUPABASE_SMTP_PROBE_*` values only in the ignored root
`.env`, then run:

```bash
./packages/email/deployment/ovh/scripts/run-supabase-smtp-probe.sh
```

The probe emits only a safe accepted/queued result and does not print
credentials or message content. Before production rollout, run it against a
disposable Supabase Auth/GoTrue project and verify signup, recovery,
magic-link, and OTP email flows. Keep the resulting evidence sanitized.
