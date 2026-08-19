# VPS Access and Deployment

Live hostnames, IPs, tailnet identities, service IDs, keys, and credentials
are private operational data. Retrieve them from approved inventory and do not
record them in this repository.

## Access Policy

- Use the approved private-network SSH route: `tailscale ssh ubuntu@<mail-host>`.
- Public TCP/22 is intentionally blocked. Use the provider recovery console
  only for break-glass recovery.
- The deployment root is `/opt/tlao-mail`.
- The service containers are `tlao-stalwart`, `tlao-caddy`, and
  `tlao-snappymail`.

## Deploying a Safe Update

1. Connect through the approved private SSH route.
1. Update the repository checkout and verify its staged diff contains no
   `.env`, `private/`, generated configuration, or operational-note files.
1. Ensure the VPS-only `/opt/tlao-mail/private/domains.local.json` remains
   present with mode `0600`.
1. Run the bootstrap script to update public templates and utilities:

   ```bash
   sudo ./packages/email/deployment/ovh/scripts/bootstrap-host.sh
   ```

1. Render private configuration and keys, then start the services:

   ```bash
   sudo /opt/tlao-mail/scripts/render-stalwart-config.sh
   sudo /opt/tlao-mail/scripts/generate-dkim.sh
   sudo /opt/tlao-mail/scripts/render-snappymail.sh
   sudo docker compose --env-file /opt/tlao-mail/.env \
     -f /opt/tlao-mail/docker-compose.yml up -d
   sudo /opt/tlao-mail/scripts/healthcheck.sh
   ```

Use `docker run --network container:tlao-stalwart` for Stalwart management
API calls when the host loopback path is unavailable. Keep the API credential
in the VPS `.env`; never paste it into terminal history, docs, or issue
comments.
