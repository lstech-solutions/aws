# Mailbox Access

Use the values issued for your domain; do not copy live values from another
tenant or add them to this guide.

## Standard Client Settings

- IMAP server: `<mail-host>`
- IMAP port/security: `993` / `SSL/TLS`
- SMTP server: `<mail-host>`
- SMTP port/security: `587` / `STARTTLS`
- Username: the full `<mailbox>@<domain>` address
- Authentication: normal password

SMTP port `465` with implicit TLS is also supported where a client requires
it. Complete [domain onboarding](./DOMAIN-ONBOARDING.md) before creating a
mailbox on a new domain.

## Webmail and Clients

Use `https://<webmail-host>` for the fallback SnappyMail client. Its
administrator password is a VPS-only secret; do not use it as a mailbox
credential.

Thunderbird, Apple Mail, Outlook, and the Gmail mobile app can use the IMAP
and SMTP settings above. Configure both incoming and outgoing usernames as the
full mailbox address, then send a test message to a permitted address.

## Mailbox Purpose

Human, shared, and administrator mailboxes use normal IMAP and SMTP access.
A Supabase integration uses its own app-only transactional mailbox in the same
domain. This permits rotation or revocation without affecting people. See
[Supabase SMTP](./SUPABASE-SMTP.md) for the scoped limits and validation
procedure.

## Troubleshooting

- `Relay not allowed`: confirm SMTP authentication completed; never enable
  unauthenticated relay access.
- Login failure: use the full mailbox address and verify the Stalwart
  principal has the built-in `user` role.
- Certificate warning: confirm the configured host exactly matches the issued
  certificate.
- Delivery failure: verify port `587`, STARTTLS, and authenticated SMTP.
