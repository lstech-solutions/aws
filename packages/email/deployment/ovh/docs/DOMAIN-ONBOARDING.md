# Domain Onboarding

Use this runbook for every hosted domain. Domain names, mailbox addresses, and
DNS values are private operational data: never add them to tracked source,
issue comments, or public documentation.

## Private Inputs

Keep the source inventory in the ignored
`private/domains.local.json` file and securely copy it to the VPS at
`/opt/tlao-mail/private/domains.local.json` with mode `0600`. Use
[`domains.local.example.json`](../private/domains.local.example.json) as the
schema. Each domain specifies `dkimAlgorithm` as `ed25519` (default) or
`rsa`.

The VPS `.env` must also contain the private deployment hostnames and:

```dotenv
SNAPPYMAIL_ALLOWED_DOMAINS=<comma-separated-domains>
AUTOCONFIG_HOSTS=autoconfig.<domain>,autodiscover.<domain>
```

Append the matching autoconfig and autodiscover hosts for each domain. Do not
put SMTP credentials in this file.

## Repeatable Provisioning Path

1. Add the domain, DKIM algorithm, and mailbox list to the private inventory.
1. On the VPS, update `SNAPPYMAIL_ALLOWED_DOMAINS` and
   `AUTOCONFIG_HOSTS` in `/opt/tlao-mail/.env`.
1. Render the private Stalwart configuration and generate or reuse its DKIM
   key:

   ```bash
   sudo /opt/tlao-mail/scripts/render-stalwart-config.sh
   sudo /opt/tlao-mail/scripts/generate-dkim.sh
   ```

1. Publish the domain's MX, SPF, DKIM, DMARC, TLS reporting (if used),
   autoconfig, and autodiscover DNS records in its authoritative DNS provider.
   Point client discovery records to `<mail-host>`; publish exactly the DKIM
   TXT value emitted by the generator.
1. Create the Stalwart domain and mailbox principals through the management API
   from the container network. Use full mailbox addresses as login names and
   the `user` role.
1. Rerender SnappyMail and restart the affected services:

   ```bash
   sudo /opt/tlao-mail/scripts/render-snappymail.sh
   sudo docker compose --env-file /opt/tlao-mail/.env \
     -f /opt/tlao-mail/docker-compose.yml up -d stalwart snappymail caddy
   ```

1. Run the health check, test authenticated IMAP and STARTTLS SMTP, and send
   one external delivery test. Delete temporary test principals afterward.

## Supabase Auth

If the domain needs Supabase Auth custom SMTP, create one dedicated
`transactional@<domain>` mailbox. Never reuse a human, support, shared, or
administrator mailbox. Store its credential only in Supabase and the ignored
repository-root `.env`; add only the full mailbox login to the VPS
`SUPABASE_SMTP_ACCOUNT_LIST`. Complete the sanitized SMTP probe and
disposable-project verification in [Supabase SMTP](./SUPABASE-SMTP.md) before
production use.

## Validation

```bash
sudo /opt/tlao-mail/scripts/healthcheck.sh
curl -I https://autoconfig.<domain>/mail/config-v1.1.xml
curl -I https://autodiscover.<domain>/mail/config-v1.1.xml
```

The generated `/opt/tlao-mail/stalwart/etc/config.toml` is a private runtime
artifact. Do not copy it into this repository.
