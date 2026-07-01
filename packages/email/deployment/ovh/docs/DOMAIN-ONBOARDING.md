# TLÁO Mail Domain Onboarding

This is the canonical runbook for adding a new hosted mail domain to the OVH/Stalwart bundle.

## Source Of Truth

- Private live inventory: [`packages/email/deployment/ovh/private/domains.local.json`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.json)
- Private inventory template: [`packages/email/deployment/ovh/private/domains.local.example.json`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.example.json)
- Mail host: `mail.xn--tlo-fla.com`
- Webmail host: `webmail.xn--tlo-fla.com`
- Live Stalwart management API: `http://127.0.0.1:8080/api/principal`
- On the VPS, prefer `docker run --network container:tlao-stalwart ...` for management calls. Direct host loopback requests can hit Stalwart auto-ban and return `Empty reply from server`.

## Quick Checklist

Use this sequence for every new domain:

1. Add the domain and its mailbox list to the private inventory.
1. Decide the DKIM signing strategy before touching DNS. Default to `ED25519-SHA256` for modern-only deployments; use `RSA-SHA256` or dual-signing when you need broader interoperability with Gmail or other conservative receivers.
1. Add the domain to `packages/email/deployment/ovh/stalwart/config.toml` and add the matching signing rule.
1. Update `packages/email/deployment/ovh/scripts/generate-dkim.sh` if the domain needs a new key type or a dedicated key file.
1. Generate the key on the VPS and publish the exact TXT value printed by `generate-dkim.sh`.
1. Publish DNS in the domain's authoritative DNS provider, not in the bundle. The provider may be Route 53, Cloud DNS, or something else, but the record set must match the live server exactly.
1. Update `SNAPPYMAIL_ALLOWED_DOMAINS`, rerender SnappyMail, and restart the container.
1. Create the domain principal, then create each mailbox principal with the built-in `user` role.
1. Run the health check, test IMAP and SMTP, and send one external delivery test before calling the rollout complete.
1. Delete any temporary test principals after verification.

## Order Of Operations

1. Update the private inventory with the new domain and the mailbox addresses that belong to it.
1. Add the domain to `packages/email/deployment/ovh/stalwart/config.toml`.
1. Add a DKIM signing block for the domain and a matching `auth.dkim` rule. Use the signing algorithm that best matches the domain's target receivers.
1. Generate or reuse the DKIM keys with `sudo /opt/tlao-mail/scripts/generate-dkim.sh`.
1. Publish the DNS records in the authoritative DNS provider for the domain.
1. Update `SNAPPYMAIL_ALLOWED_DOMAINS` and rerender SnappyMail.
1. Create the domain principal, then create each mailbox principal.
1. Run the host health check and verify the public endpoints.

## Stalwart Control Plane

The live server on this stack uses `POST /api/principal` for both domain and mailbox creation.

Use the host admin credential from `/opt/tlao-mail/.env`, but send the request through the Stalwart container network namespace:

```bash
sudo bash <<'EOF'
set -euo pipefail
set -a
source /opt/tlao-mail/.env
set +a
auth_header="Basic $(printf '%s:%s' "${STALWART_ADMIN_USER}" "${STALWART_ADMIN_SECRET}" | base64 -w0)"
payload="$(jq -n \
  --arg name '<domain>' \
  --arg description '<domain> domain' \
  '{type:"domain", name:$name, description:$description}')"
printf '%s' "${payload}" | docker run --rm -i --network container:tlao-stalwart curlimages/curl:8.10.1 -fsS \
  -H "Authorization: ${auth_header}" \
  -H 'Content-Type: application/json' \
  -X POST http://127.0.0.1:8080/api/principal \
  --data-binary @-
EOF
```

That request creates the domain principal and returns `{"data":<domain-id>}`.

Then create each mailbox principal:

```bash
sudo bash <<'EOF'
set -euo pipefail
set -a
source /opt/tlao-mail/.env
set +a
auth_header="Basic $(printf '%s:%s' "${STALWART_ADMIN_USER}" "${STALWART_ADMIN_SECRET}" | base64 -w0)"
payload="$(jq -n \
  --arg name '<mailbox>@<domain>' \
  --arg email '<mailbox>@<domain>' \
  --arg password '<mailbox-password>' \
  '{
    type: "individual",
    name: $name,
    description: ($email + " mailbox"),
    emails: [$email],
    secrets: [$password],
    roles: ["user"]
  }')"
printf '%s' "${payload}" | docker run --rm -i --network container:tlao-stalwart curlimages/curl:8.10.1 -fsS \
  -H "Authorization: ${auth_header}" \
  -H 'Content-Type: application/json' \
  -X POST http://127.0.0.1:8080/api/principal \
  --data-binary @-
EOF
```

If the domain principal is missing, mailbox creation fails with `{"error":"notFound","item":"<domain>"}`.

## DNS Records

For every new domain, publish the same record pattern the live stack already uses:

- `MX <domain> -> 10 mail.xn--tlo-fla.com.`
- `TXT <domain> -> "v=spf1 mx a:mail.xn--tlo-fla.com -all"` or the stricter SPF policy you need for that domain
- `TXT mail._domainkey.<domain> -> <value printed by generate-dkim.sh>`
- `TXT _dmarc.<domain> -> "v=DMARC1; p=quarantine; rua=mailto:postmaster@<domain>"`
- `TXT _smtp._tls.<domain> -> <domain-specific TLSRPT policy>`
- `CNAME autoconfig.<domain> -> mail.xn--tlo-fla.com.` when client autoconfig should work
- `CNAME autodiscover.<domain> -> mail.xn--tlo-fla.com.` when client autodiscover should work

Always publish the exact record type and algorithm printed by `generate-dkim.sh`; do not assume every domain uses the same DKIM key format.

Keep the actual live mailbox list in the private inventory file, not in public prose.

## SnappyMail

Add the new domain to `SNAPPYMAIL_ALLOWED_DOMAINS` in `/opt/tlao-mail/.env`, then rerender SnappyMail:

```bash
sudo /opt/tlao-mail/scripts/render-snappymail.sh
sudo docker compose --env-file /opt/tlao-mail/.env -f /opt/tlao-mail/docker-compose.yml restart snappymail
```

If you are maintaining the private inventory file, derive the SnappyMail domain list from it instead of typing the addresses by hand.

```bash
export SNAPPYMAIL_ALLOWED_DOMAINS="$(jq -r '.domains | map(.domain) | join(",")' /home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.json)"
```

## Validation

Run these checks after the domain is live:

```bash
sudo /opt/tlao-mail/scripts/healthcheck.sh
sudo docker compose --env-file /opt/tlao-mail/.env -f /opt/tlao-mail/docker-compose.yml ps
curl -I https://autoconfig.<domain>/mail/config-v1.1.xml
curl -I https://autodiscover.<domain>/mail/config-v1.1.xml
```

Then confirm the created mailbox principals:

```bash
sudo bash <<'EOF'
set -euo pipefail
set -a
source /opt/tlao-mail/.env
set +a
auth_header="Basic $(printf '%s:%s' "${STALWART_ADMIN_USER}" "${STALWART_ADMIN_SECRET}" | base64 -w0)"
docker run --rm --network container:tlao-stalwart curlimages/curl:8.10.1 -fsS \
  -H "Authorization: ${auth_header}" \
  http://127.0.0.1:8080/api/principal/<mailbox>@<domain> | jq .
EOF
```

If you used a temporary mailbox to validate a rollout, delete it immediately after the checks pass. Temporary principals are for testing only.

## Notes

- Keep mailbox usernames as full email addresses.
- Keep the private inventory gitignored.
- Update `stalwart/config.toml`, `generate-dkim.sh`, and `healthcheck.sh` together when you add a new domain so the live host stays consistent.
- Stalwart supports both `RSA-SHA256` and `ED25519-SHA256` DKIM signatures. Use RSA for domains that need maximum compatibility with Gmail and other receivers that do not verify Ed25519-only mail reliably.
- Never commit mailbox passwords, API secrets, DKIM private keys, or temporary test credentials.
- Prefer the exact mailbox names from the private inventory when creating principals so webmail, IMAP, and SMTP all share the same login contract.
