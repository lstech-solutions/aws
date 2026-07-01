#!/usr/bin/env bash
set -euo pipefail

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Create a Stalwart mailbox principal that uses the full email address as the login.

Usage:
  sudo /opt/tlao-mail/scripts/provision-mailbox.sh user@<domain>
EOF
  exit 0
fi

EMAIL_ADDRESS="${1:-}"
PASSWORD="${MAILBOX_PASSWORD:-}"
if [[ -z "${EMAIL_ADDRESS}" ]]; then
  printf 'Usage: %s <email-address>\n' "$0" >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  printf 'Missing %s\n' "${ENV_FILE}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

TLAO_MAIL_ROOT="${requested_root:-${TLAO_MAIL_ROOT:-/opt/tlao-mail}}"
STALWART_URL="${STALWART_URL:-http://127.0.0.1:8080}"
STALWART_ADMIN_USER="${STALWART_ADMIN_USER:?STALWART_ADMIN_USER is required in ${ENV_FILE}}"
STALWART_ADMIN_SECRET="${STALWART_ADMIN_SECRET:?STALWART_ADMIN_SECRET is required in ${ENV_FILE}}"

if [[ -z "${PASSWORD}" ]]; then
  PASSWORD="$(openssl rand -base64 36 | tr -d '\n' | tr '/+' 'Aa' | cut -c1-24)"
fi

AUTH_HEADER="Basic $(printf '%s:%s' "${STALWART_ADMIN_USER}" "${STALWART_ADMIN_SECRET}" | base64 -w0)"
PRINCIPAL_NAME="${EMAIL_ADDRESS,,}"
PAYLOAD="$(jq -n \
  --arg name "${PRINCIPAL_NAME}" \
  --arg email "${EMAIL_ADDRESS}" \
  --arg password "${PASSWORD}" \
  '{
    type: "individual",
    name: $name,
    description: ($email + " mailbox"),
    emails: [$email],
    secrets: [$password],
    roles: ["user"]
  }')"

response="$(
  curl -fsS \
    -X POST "${STALWART_URL}/api/principal" \
    -H "Authorization: ${AUTH_HEADER}" \
    -H 'Content-Type: application/json' \
    --data "${PAYLOAD}"
)"

principal_id="$(jq -r '.data' <<<"${response}")"

printf 'Created mailbox principal %s with id %s\n' "${EMAIL_ADDRESS}" "${principal_id}"
printf 'Username: %s\n' "${EMAIL_ADDRESS}"
printf 'Password: %s\n' "${PASSWORD}"
printf 'IMAP/SMTP host: %s\n' "${MAIL_FQDN:-mail.xn--tlo-fla.com}"
printf 'IMAP port: 993 (SSL/TLS)\n'
printf 'SMTP port: 587 (STARTTLS)\n'
