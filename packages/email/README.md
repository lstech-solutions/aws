# @tlao/email

TLÁO Email System - Standalone email package with Stalwart integration.

## Overview

Enterprise-grade email hosting with automated operational intelligence extraction. Integrates Stalwart mail server with TLÁO's execution engine.

## Features

- Stalwart mail server integration (IMAP, JMAP, SMTP, CalDAV, CardDAV)
- JMAP-first email ingestion
- Bedrock-powered email classification
- Automated agent execution (Plan/Grant)
- Standard email client support (Thunderbird, Outlook, Gmail, Apple Mail)
- Autodiscover/autoconfig for easy client setup

## Installation

```bash
pnpm install
```

## Development

```bash
pnpm dev      # Watch mode
pnpm build    # Build package
pnpm test     # Run tests
pnpm lint     # Lint code
```

## Deployment

- AWS-specific infrastructure remains under [`infrastructure/`](./infrastructure).
- The standalone OVH/VPS mail substrate bundle lives in [`deployment/ovh`](./deployment/ovh/README.md).
- The bundle's operational docs live in [`deployment/ovh/docs`](./deployment/ovh/docs/README.md).
- Start with [`deployment/ovh/docs/DOMAIN-ONBOARDING.md`](./deployment/ovh/docs/DOMAIN-ONBOARDING.md) for new domains and [`deployment/ovh/docs/MAILBOX-ACCESS.md`](./deployment/ovh/docs/MAILBOX-ACCESS.md) for client setup.
- The live domain and mailbox roster stays in the gitignored private inventory at [`deployment/ovh/private/domains.local.json`](./deployment/ovh/private/domains.local.json); use [`deployment/ovh/private/domains.local.example.json`](./deployment/ovh/private/domains.local.example.json) as the schema template.
- Use the OVH bundle when you need Stalwart + Caddy on a single Ubuntu 24.04 node while keeping TLÁO ingestion and provisioning logic in this package.

## Stalwart Management Auth

- Mailbox provisioning should use Stalwart management credentials, not mailbox IMAP credentials.
- For the OVH deployment, prefer `STALWART_API_USERNAME` plus `STALWART_API_SECRET`.
- `STALWART_API_KEY` remains as a backward-compatible single-string auth field and can contain `username:secret` for Basic auth.
- Stalwart API key principals are for the management REST API only. They cannot be used for JMAP, IMAP, or POP3 mailbox access.
- New TLÁO-managed mailbox principals should use the full email address as the login identifier. That keeps multi-domain client setup and SnappyMail-compatible webmail straightforward.
- Keep the live address list out of public prose; it belongs in the gitignored private inventory file in the OVH bundle.

## Architecture

Stalwart → JMAP Ingestion → Email Parser → Classification → Backend API → Artifacts
