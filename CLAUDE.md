# Claude Repo Guide

Start here for mail work:

- [OVH mail bundle overview](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/README.md)
- [OVH mail docs index](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/README.md)
- [Domain onboarding runbook](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/DOMAIN-ONBOARDING.md)
- [Mailbox access guide](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/MAILBOX-ACCESS.md)
- [Private mailbox inventory template](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.example.json)

Keep the public docs generic and the live address list private.

Docs flow:

- Keep package-local operational docs in dedicated `docs/` folders.
- Treat package READMEs as short entry points that link into the docs folder rather than duplicating procedures.
- Prefer the docs index when a package has multiple supporting guides.

Operating order for a new domain:

1. Update the private inventory.
2. Create or confirm the Stalwart domain principal.
3. Generate or reuse DKIM material and publish the TXT record.
4. Publish MX, SPF, DMARC, TLSRPT, and autoconfig records.
5. Add the domain to SnappyMail allow-list settings.
6. Create mailbox principals with full email addresses.
7. Run the health checks.

Use the host network namespace when the direct management API call gets blocked:

```bash
docker run --rm --network container:tlao-stalwart curlimages/curl:8.10.1 ...
```
