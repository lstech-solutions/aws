# TLÁO Repo Agent Guide

Use these docs first for email work:

- [OVH mail bundle overview](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/README.md)
- [OVH mail docs index](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/README.md)
- [Domain onboarding runbook](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/DOMAIN-ONBOARDING.md)
- [Mailbox access guide](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/MAILBOX-ACCESS.md)
- [VPS access and deployment runbook](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/VPS-ACCESS.md)
- [SnappyMail package notes](/home/ed/Documents/LSTS/aws/packages/email-ui/README.md)
- [Email package overview](/home/ed/Documents/LSTS/aws/packages/email/README.md)

Docs flow:

- Keep package-local operational docs in dedicated `docs/` folders.
- Treat each package README as a short entry point that links into the docs folder instead of duplicating long procedures.
- Prefer the docs index first when a package has more than one supporting guide.

Operational policy:

- Resolve live mail and webmail hosts from the private inventory; public docs
  use `<mail-host>` and `<webmail-host>` placeholders.
- Use the approved private-network SSH route; provider recovery access is
  break-glass only and public TCP/22 is intentionally blocked.
- Stalwart container: `tlao-stalwart`
- Caddy container: `tlao-caddy`
- SnappyMail container: `tlao-snappymail`

Private live inventory:

- [packages/email/deployment/ovh/private/domains.local.json](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.json) is gitignored and stores the actual hosted domains and mailbox addresses.
- [packages/email/deployment/ovh/private/domains.local.example.json](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.example.json) shows the schema with placeholders.

Rules:

- Do not commit mailbox passwords, API secrets, or the private inventory.
- Use placeholders such as `user@<domain>` in all public prose.
- When adding a new domain, update the private inventory, render the private
  Stalwart configuration, generate DKIM, and update DNS and SnappyMail together.
- Use `docker run --network container:tlao-stalwart` for live Stalwart API calls from the host when the loopback path is blocked.
