# TLÁO Repo Agent Guide

Use these docs first for email work:

- [OVH mail bundle overview](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/README.md)
- [OVH mail docs index](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/README.md)
- [Domain onboarding runbook](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/DOMAIN-ONBOARDING.md)
- [Mailbox access guide](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/MAILBOX-ACCESS.md)
- [SnappyMail package notes](/home/ed/Documents/LSTS/aws/packages/email-ui/README.md)
- [Email package overview](/home/ed/Documents/LSTS/aws/packages/email/README.md)

Docs flow:

- Keep package-local operational docs in dedicated `docs/` folders.
- Treat each package README as a short entry point that links into the docs folder instead of duplicating long procedures.
- Prefer the docs index first when a package has more than one supporting guide.

Critical operational constants:

- Mail host: `mail.xn--tlo-fla.com`
- Webmail host: `webmail.xn--tlo-fla.com`
- Stalwart container: `tlao-stalwart`
- Caddy container: `tlao-caddy`
- SnappyMail container: `tlao-snappymail`

Private live inventory:

- [packages/email/deployment/ovh/private/domains.local.json](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.json) is gitignored and stores the actual hosted domains and mailbox addresses.
- [packages/email/deployment/ovh/private/domains.local.example.json](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.example.json) shows the schema with placeholders.

Rules:

- Do not commit mailbox passwords, API secrets, or the private inventory.
- Use placeholders such as `user@<domain>` in public prose unless the canonical TLÁO punycode mailbox is required.
- When adding a new domain, keep DNS, DKIM, SnappyMail, and mailbox creation in sync.
- Use `docker run --network container:tlao-stalwart` for live Stalwart API calls from the host when the loopback path is blocked.
