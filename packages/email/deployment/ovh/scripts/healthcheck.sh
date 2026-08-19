#!/usr/bin/env bash
set -euo pipefail

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"
INVENTORY_FILE="${DOMAIN_INVENTORY_FILE:-${TLAO_MAIL_ROOT}/private/domains.local.json}"

[[ -f "${ENV_FILE}" ]] || { printf 'Missing %s\n' "${ENV_FILE}" >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required for private domain inventory.' >&2; exit 1; }

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a
TLAO_MAIL_ROOT="${requested_root:-${TLAO_MAIL_ROOT:-/opt/tlao-mail}}"

compose() {
  docker compose --env-file "${ENV_FILE}" -f "${TLAO_MAIL_ROOT}/docker-compose.yml" "$@"
}

require_key() {
  [[ -f "$1" ]] || { echo 'A configured DKIM private key is missing.' >&2; exit 1; }
}

printf '== Compose services ==\n'
compose ps

printf '\n== Open ports ==\n'
ss -tulpn | egrep ':22|:25|:80|:443|:465|:587|:993|:8080' || true

printf '\n== Local HTTP/JMAP ==\n'
curl -fsSI http://127.0.0.1:8080/ >/dev/null && echo 'Loopback HTTP reachable'
curl -fsS http://127.0.0.1:8080/.well-known/jmap -o /dev/null && echo 'Local JMAP discovery reachable'

printf '\n== DKIM ==\n'
require_key "${TLAO_MAIL_ROOT}/stalwart/dkim/primary.ed25519.key"
if [[ -n "${MAIL_ALT_DOMAIN:-}" ]]; then
  require_key "${TLAO_MAIL_ROOT}/stalwart/dkim/secondary.ed25519.key"
fi
if [[ -f "${INVENTORY_FILE}" ]]; then
  while IFS=$'\t' read -r domain algorithm; do
    [[ "${domain}" == "${MAIL_PRIMARY_DOMAIN}" || "${domain}" == "${MAIL_ALT_DOMAIN:-}" ]] && continue
    [[ "${algorithm}" == "ed25519" || "${algorithm}" == "rsa" ]] || { echo 'Invalid DKIM algorithm in private inventory.' >&2; exit 1; }
    require_key "${TLAO_MAIL_ROOT}/stalwart/dkim/${domain//./-}.${algorithm}.key"
  done < <(jq -r '.domains[] | [.domain, (.dkimAlgorithm // "ed25519")] | @tsv' "${INVENTORY_FILE}")
fi
echo 'Configured DKIM keys present'

printf '\n== SnappyMail ==\n'
if compose ps snappymail 2>/dev/null | grep -q 'Up'; then
  echo 'SnappyMail container is running'
  if [[ -n "${SNAPPYMAIL_HOSTS:-}" ]] && compose ps caddy 2>/dev/null | grep -q 'Up'; then
    snappymail_host="${SNAPPYMAIL_HOSTS%%,*}"
    snappymail_host="${snappymail_host// /}"
    curl -fsSI "https://${snappymail_host}" >/dev/null && echo 'Webmail reachable'
  fi
else
  echo 'SnappyMail container is not running'
fi

if compose ps caddy 2>/dev/null | grep -q 'Up'; then
  printf '\n== Public HTTPS/JMAP ==\n'
  curl -fsSI "https://${MAIL_FQDN}" >/dev/null && echo 'Public mail host reachable'
  curl -fsS "https://${MAIL_FQDN}/.well-known/jmap" -o /dev/null && echo 'Public JMAP discovery reachable'
fi

printf '\n== Supabase SMTP profile ==\n'
echo 'Run the repository-local Supabase SMTP probe; credentials are intentionally not stored on this VPS.'
