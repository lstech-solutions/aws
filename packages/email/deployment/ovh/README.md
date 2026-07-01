# TLÁO Mail Core OVH Deployment Bundle

This bundle adds a standalone OVH/VPS deployment path for TLÁO Mail Core without forcing OVH into [`packages/infra`](../../../../packages/infra), which is still AWS/SST-specific. The VPS is the mail substrate only; [`packages/email/src/services/stalwart-client.ts`](../../../../packages/email/src/services/stalwart-client.ts) and the rest of `@tlao/email` remain the future TLÁO control plane above it.

Detailed mail-ops docs now live under [`docs/`](./docs/README.md). Treat this README as the bundle overview and entry point.

## Architecture

- Ubuntu `24.04 LTS` on the OVH VPS.
- Docker Engine + Docker Compose plugin.
- `stalwartlabs/stalwart:v0.14` for SMTP, submission, IMAPS, JMAP, and admin APIs.
- `caddy:2.11.2-alpine` for HTTPS termination on `443` with automatic Let's Encrypt issuance.
- A TLÁO-branded wrapper image built on top of `djmaze/snappymail:v2.38.2` as the fallback webmail UI, reverse-proxied through Caddy.
- Mail protocols bind directly on the host: `25`, `465`, `587`, `993`.
- Stalwart HTTP binds to loopback-only `127.0.0.1:8080` through Docker port mapping; Caddy proxies web/JMAP/admin traffic to it.
- SnappyMail stays internal to Docker and is published only through Caddy on dedicated webmail hostnames.
- Persistent bind mounts live under `/opt/tlao-mail`.
- `ufw`, `fail2ban`, and Stalwart auto-ban cover the baseline security posture.

## Bundle Contents

- [`docker-compose.yml`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docker-compose.yml): production compose stack for Stalwart + SnappyMail + Caddy.
- [`.env.example`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/.env.example): server-side environment template.
- [`stalwart/config.toml`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/stalwart/config.toml): pinned Stalwart configuration with RocksDB, internal directory, HTTP forwarding, auto-ban, and DKIM signing for the hosted domains in the private inventory.
- [`caddy/Caddyfile`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/caddy/Caddyfile): HTTPS proxy for admin/JMAP plus webmail hostnames.
- [`docs/README.md`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/README.md): docs index for the bundle's operational runbooks.
- [`docs/MAILBOX-ACCESS.md`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/MAILBOX-ACCESS.md): IMAP/SMTP client access guide for Thunderbird and Gmail.
- [`docs/DOMAIN-ONBOARDING.md`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/DOMAIN-ONBOARDING.md): domain-level provisioning contract for DNS, DKIM, DMARC, SnappyMail, and future automation.
- [`private/domains.local.example.json`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.example.json): schema template for the private live domain and mailbox inventory.
- [`private/domains.local.json`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.json): gitignored private inventory with the actual hosted domains and mailbox addresses.
- [`scripts/bootstrap-host.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/bootstrap-host.sh): Ubuntu 24.04 host prep, Docker install, UFW, fail2ban, directory creation, bootstrap certificate generation, and cron setup.
- [`scripts/generate-dkim.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/generate-dkim.sh): creates the DKIM keys for the hosted domains in the private inventory, prints the DNS TXT records to publish, and restarts Stalwart when needed.
- [`scripts/provision-mailbox.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/provision-mailbox.sh): creates a Stalwart mailbox principal from a full email address and assigns the built-in `user` role.
- [`scripts/render-snappymail.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/render-snappymail.sh): renders SnappyMail domain config files for each hosted mail domain.
- [`scripts/apply-snappymail-branding.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/apply-snappymail-branding.sh): rebuilds and restarts the TLÁO-branded SnappyMail wrapper image.
- [`scripts/sync-certs.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/sync-certs.sh): copies Caddy-issued certificates into Stalwart and restarts the mail container when they rotate.
- [`scripts/backup.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/backup.sh): local compressed backups under `/opt/tlao-mail/backups`, with optional S3 mirroring when offsite credentials are configured.
- [`scripts/restore.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/restore.sh): restores a local archive or `s3://` backup into a fresh VPS filesystem.
- [`scripts/healthcheck.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/healthcheck.sh): quick operational validation on the VPS.

## Target Layout On The VPS

The repo bundle is copied into this runtime layout:

```text
/opt/tlao-mail
├── .env
├── docker-compose.yml
├── backups
├── caddy
│   ├── Caddyfile
│   ├── config
│   ├── data
│   └── logs
├── email-ui
│   └── snappymail-image
├── snappymail
│   └── _data_/_default_
│       ├── admin_password.txt
│       └── domains
├── scripts
│   ├── backup.sh
│   ├── healthcheck.sh
│   ├── render-snappymail.sh
│   ├── restore.sh
│   └── sync-certs.sh
└── stalwart
    ├── certs
    ├── data
    ├── dkim
    ├── etc
    │   └── config.toml
    └── logs
```

## Exact Deployment Commands

Assumption: you are connected to the OVH VPS as `ubuntu` and the repo is present on the server.

```bash
ssh ubuntu@15.204.116.157
cd /path/to/aws-tlao
sudo ./packages/email/deployment/ovh/scripts/bootstrap-host.sh
sudoedit /opt/tlao-mail/.env
sudo /opt/tlao-mail/scripts/render-snappymail.sh
sudo docker compose --env-file /opt/tlao-mail/.env -f /opt/tlao-mail/docker-compose.yml up -d stalwart snappymail
sudo /opt/tlao-mail/scripts/apply-snappymail-branding.sh
```

`bootstrap-host.sh` disables root login and tightens SSH limits immediately. It disables password authentication only when the target admin user already has a non-empty `authorized_keys`; otherwise it keeps password auth enabled to avoid locking out the first operator session.

`bootstrap-host.sh` also generates the live DKIM keys under `/opt/tlao-mail/stalwart/dkim/primary.ed25519.key`, `/opt/tlao-mail/stalwart/dkim/secondary.ed25519.key`, and one key per hosted domain in the private inventory using the configured signing algorithm for that domain, then prints the TXT record values you must publish.

Local admin access before DNS is live:

```bash
ssh -L 8080:127.0.0.1:8080 ubuntu@15.204.116.157
curl -I http://127.0.0.1:8080
curl -i http://127.0.0.1:8080/.well-known/jmap
```

After DNS `A`/`AAAA` records point to the VPS and OVH rDNS is set to `mail.xn--tlo-fla.com`:

```bash
sudo docker compose --env-file /opt/tlao-mail/.env -f /opt/tlao-mail/docker-compose.yml up -d caddy
sudo /opt/tlao-mail/scripts/sync-certs.sh
sudo /opt/tlao-mail/scripts/render-snappymail.sh
sudo /opt/tlao-mail/scripts/healthcheck.sh
```

## Backups And Restore

`backup.sh` now creates a restore-focused archive that includes:

- `/opt/tlao-mail/.env`
- `/opt/tlao-mail/docker-compose.yml`
- `/opt/tlao-mail/caddy/Caddyfile`
- `/opt/tlao-mail/caddy/config`
- `/opt/tlao-mail/caddy/data`
- `/opt/tlao-mail/snappymail/_data_`
- `/opt/tlao-mail/stalwart/certs`
- `/opt/tlao-mail/stalwart/data`
- `/opt/tlao-mail/stalwart/dkim`
- `/opt/tlao-mail/stalwart/etc`

If `BACKUP_S3_BUCKET` is set in `/opt/tlao-mail/.env`, the script also mirrors the `backups/` directory to `s3://<bucket>/<prefix>/` using AWS CLI credentials from the same environment file or the active AWS CLI profile.

Use either `BACKUP_AWS_PROFILE` or the explicit `BACKUP_AWS_ACCESS_KEY_ID` / `BACKUP_AWS_SECRET_ACCESS_KEY` pair in `/opt/tlao-mail/.env` if the host does not already have a usable AWS CLI profile.

`restore.sh` reads `/opt/tlao-mail/.env` before it talks to S3, so a freshly bootstrapped host can fetch an offsite archive as long as that file contains the backup AWS credentials or profile settings.

Recommended restore flow for a new VPS:

```bash
sudo ./packages/email/deployment/ovh/scripts/bootstrap-host.sh
sudoedit /opt/tlao-mail/.env   # add BACKUP_AWS_* or AWS_PROFILE if you are restoring from S3
sudo ./packages/email/deployment/ovh/scripts/restore.sh --archive s3://your-bucket/tlao-mail/backups/tlao-mail-YYYYMMDDTHHMMSSZ.tar.zst --force
sudo /opt/tlao-mail/scripts/render-snappymail.sh
sudo docker compose --env-file /opt/tlao-mail/.env -f /opt/tlao-mail/docker-compose.yml up -d stalwart snappymail caddy
sudo /opt/tlao-mail/scripts/healthcheck.sh
```

If you keep the backup locally instead of on S3, pass the local archive path to `restore.sh` instead of the `s3://` URI.

## SnappyMail Fallback UI

This bundle now runs SnappyMail as a fallback webmail surface while the custom TLÁO mail UI is still being built.

- Use a dedicated webmail hostname such as `webmail.xn--tlo-fla.com`.
- Keep the live domain roster in the private inventory and mirror it into `SNAPPYMAIL_ALLOWED_DOMAINS`.
- SnappyMail domain files are rendered under `/opt/tlao-mail/snappymail/_data_/_default_/domains`.
- SnappyMail admin is available at `https://<webmail-host>/?admin`.
- On first start, SnappyMail writes the bootstrap admin password to `/opt/tlao-mail/snappymail/_data_/_default_/admin_password.txt`.
- The TLÁO brand theme is built from `/opt/tlao-mail/email-ui/snappymail-image` and reapplied on container start, so restarts do not drift back to stock SnappyMail visuals.

For example:

```dotenv
SNAPPYMAIL_HOSTS=webmail.xn--tlo-fla.com
SNAPPYMAIL_ALLOWED_DOMAINS=xn--tlo-fla.com
SNAPPYMAIL_IMAP_HOST=mail.xn--tlo-fla.com
SNAPPYMAIL_IMAP_PORT=993
SNAPPYMAIL_IMAP_SECURITY=ssl
SNAPPYMAIL_SMTP_HOST=mail.xn--tlo-fla.com
SNAPPYMAIL_SMTP_PORT=587
SNAPPYMAIL_SMTP_SECURITY=starttls
SNAPPYMAIL_LOGIN_MODE=email
SNAPPYMAIL_BRAND_THEME=Default
SNAPPYMAIL_BRAND_TITLE=TLÁO Mail
SNAPPYMAIL_BRAND_LOADING_DESCRIPTION=TLÁO Mail
SNAPPYMAIL_BRAND_FAVICON_URL=/snappymail/v/2.38.2/themes/Default/images/tlao-mark.svg
SNAPPYMAIL_BRAND_ALLOW_THEME_SWITCH=false
```

Append the rest of the hosted domains from the private inventory before rendering SnappyMail for a live host.

`SNAPPYMAIL_LOGIN_MODE=email` is the correct long-term setting for multi-domain hosting because it keeps the login identifier globally unique. That is also why the TLÁO provisioning package now defaults new mailbox principals to the full email address.

The first branded theme intentionally reuses the TLÁO landing palette: deep slate backgrounds, TLÁO blue (`#3B82F6`), aqua accent lighting, and an animated login-only footer. The source of truth for that overlay lives in [`packages/email-ui/snappymail/image`](../../../../packages/email-ui/snappymail/image).

## Firewall Policy

`bootstrap-host.sh` opens only:

- `22/tcp` for SSH.
- `25/tcp` for server-to-server SMTP inbound.
- `80/tcp` for Caddy and Let's Encrypt HTTP-01.
- `443/tcp` for admin UI, JMAP, and management API over HTTPS.
- `465/tcp` for implicit-TLS submission.
- `587/tcp` for STARTTLS submission.
- `993/tcp` for IMAPS.

It does not open `143`, `110`, `995`, `4190`, or `8080`.

## DNS Preparation

Use the TLÁO domain in its DNS-safe punycode form: `xn--tlo-fla.com`. Publish the base host records after the VPS is running:

- `A mail.xn--tlo-fla.com -> 15.204.116.157`
- `AAAA mail.xn--tlo-fla.com -> 2604:2dc0:202:300::31cb`
- `A webmail.xn--tlo-fla.com -> 15.204.116.157`
- `AAAA webmail.xn--tlo-fla.com -> 2604:2dc0:202:300::31cb`
- `MX xn--tlo-fla.com -> 10 mail.xn--tlo-fla.com.`
- `TXT xn--tlo-fla.com -> "v=spf1 mx a:mail.xn--tlo-fla.com -all"`
- `TXT _dmarc.xn--tlo-fla.com -> "v=DMARC1; p=quarantine; rua=mailto:postmaster@<domain>"`
- `TXT mail._domainkey.xn--tlo-fla.com -> <value printed by /opt/tlao-mail/scripts/generate-dkim.sh>`

For every additional hosted domain, follow [`docs/DOMAIN-ONBOARDING.md`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/DOMAIN-ONBOARDING.md). That runbook is the authoritative checklist for DNS, DKIM, mailbox provisioning, validation, and cleanup, and it intentionally stays provider-agnostic so Route 53, Cloud DNS, and future DNS backends can all use the same operating steps.

OVH-specific requirement:

- Set reverse DNS/PTR for `15.204.116.157` to `mail.xn--tlo-fla.com`.
- Set reverse DNS/PTR for `2604:2dc0:202:300::31cb` to `mail.xn--tlo-fla.com` if OVH exposes IPv6 reverse DNS controls for this VPS.

If you later enable an external relay, update SPF to include that provider and re-evaluate DMARC policy.

## Validation

Run these commands on the server:

```bash
sudo docker compose --env-file /opt/tlao-mail/.env -f /opt/tlao-mail/docker-compose.yml ps
sudo docker logs --tail=100 tlao-stalwart
sudo docker logs --tail=100 tlao-snappymail
sudo docker logs --tail=100 tlao-caddy
sudo /opt/tlao-mail/scripts/healthcheck.sh
sudo /opt/tlao-mail/scripts/apply-snappymail-branding.sh
sudo /opt/tlao-mail/scripts/generate-dkim.sh
sudo /opt/tlao-mail/scripts/render-snappymail.sh
curl -i http://127.0.0.1:8080/.well-known/jmap
curl -I https://webmail.xn--tlo-fla.com
openssl s_client -connect mail.xn--tlo-fla.com:465 -servername mail.xn--tlo-fla.com </dev/null
openssl s_client -starttls smtp -connect mail.xn--tlo-fla.com:587 -servername mail.xn--tlo-fla.com </dev/null
openssl s_client -connect mail.xn--tlo-fla.com:993 -servername mail.xn--tlo-fla.com </dev/null
swaks --server mail.xn--tlo-fla.com --port 587 --tls \
  --auth LOGIN --auth-user <mailbox>@<domain> --auth-password 'REPLACE_ME' \
  --from <mailbox>@<domain> --to <mailbox>@<domain>
```

The new TLÁO provisioning default is to make the Stalwart principal `name` equal the full mailbox address. That is the cleanest contract for SnappyMail and for future custom webmail. Some older bootstrap mailboxes on the live server still use legacy principal names such as `admin`, so migrate those individually before assuming webmail-style email logins for every existing account.

## First-Login Hardening

- Replace the bootstrap certificate with the Caddy-issued certificate by running [`sync-certs.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/sync-certs.sh) after Caddy obtains it.
- Add an SSH public key for `ubuntu`, then disable password authentication once key-based access is verified if the bootstrap left it enabled.
- Rotate `/opt/tlao-mail/.env` secrets if the host was provisioned in a shared context.
- Publish the exact TXT record printed by [`generate-dkim.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/generate-dkim.sh), and rerun it with `--force` only when you intentionally rotate the DKIM key.
- Keep the fallback web administration username distinct from mailbox usernames. Use `webadmin` or another control-plane-only identifier instead of `admin`.
- Create the initial domain principal for `xn--tlo-fla.com` (`tláo.com` in DNS punycode).
- Create the domain principals and mailbox principals listed in the private inventory, with each mailbox using the built-in `user` role so IMAP and SMTP login is authorized.
- Create operational mailboxes such as `postmaster@`, `support@`, `ops@`, and `grants@` when the business need exists.
- Create a dedicated Stalwart API key principal for future automation instead of reusing the fallback admin credential.
  - For mailbox provisioning, the minimal tested permission set also needed the type-specific permissions `individual-create`, `individual-delete`, `individual-get`, `individual-list`, `individual-update`, `domain-get`, and `domain-list`, in addition to `authenticate`.
- Use [`provision-mailbox.sh`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/scripts/provision-mailbox.sh) for new mailbox principals once the Stalwart management API is live.
- Copy `/opt/tlao-mail/backups` off-host once a secondary storage location exists.

## TLÁO Integration Path

- Keep this VPS as the standalone mail substrate.
- Use JMAP first for ingestion and IMAP only as a compatibility fallback.
- Reuse the existing Stalwart client concept in [`src/services/stalwart-client.ts`](../../../../packages/email/src/services/stalwart-client.ts), but revalidate its endpoint usage against the current Stalwart management API before automating provisioning.
- Keep mailbox provisioning, signal ingestion, and relay policy in the TLÁO application layer; the VPS should stay focused on durable mail transport and storage.
- Do not add an OVH tenant to `packages/infra` until there is a genuine runtime abstraction that is not AWS-specific.
- Before onboarding any new email domain, follow [`docs/DOMAIN-ONBOARDING.md`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/docs/DOMAIN-ONBOARDING.md) so DNS, DKIM, DMARC, webmail, and mailbox provisioning move together.

## Official References

- <https://stalw.art/docs/install/platform/docker>
- <https://stalw.art/docs/server/reverse-proxy/caddy>
- <https://stalw.art/docs/server/listener/>
- <https://stalw.art/docs/http/settings/>
- <https://stalw.art/docs/server/auto-ban/>
- <https://stalw.art/docs/install/upgrade>
- <https://hub.docker.com/_/caddy>
