# TLÁO Mail OVH Deployment Bundle

This bundle deploys the mail substrate on an OVH VPS: Stalwart for mail
protocols and storage, Caddy for HTTPS, and SnappyMail as the fallback webmail
client. The application control plane remains in `@tlao/email`.

Start with the [operational docs](./docs/README.md). They cover VPS access,
mailbox clients, domain onboarding, and the optional Supabase Auth SMTP
profile.

## Privacy Boundary

The repository contains only reusable templates. Hosted domains, mailbox
addresses, server IPs, service IDs, API credentials, DKIM private keys, and
SMTP credentials belong only in ignored runtime files:

- `private/domains.local.json` in the repository checkout;
- `/opt/tlao-mail/private/domains.local.json` on the VPS; and
- `/opt/tlao-mail/.env` for host configuration and secrets.

The bootstrap copies `stalwart/config.toml` as a safe base template, then
`render-stalwart-config.sh` creates the VPS-only configuration from the
private inventory. `generate-dkim.sh` uses the same inventory, so new domains
do not need to be added to a tracked config or script.

Before starting or restarting Stalwart after changing the inventory, run:

```bash
sudo /opt/tlao-mail/scripts/render-stalwart-config.sh
sudo /opt/tlao-mail/scripts/generate-dkim.sh
```

Never commit or print the private inventory, mailbox passwords, API secrets,
or generated keys.
