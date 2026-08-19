#!/usr/bin/env bash
set -euo pipefail

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"
INVENTORY_FILE="${DOMAIN_INVENTORY_FILE:-${TLAO_MAIL_ROOT}/private/domains.local.json}"
FORCE=0

if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
elif [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Generate or reuse DKIM keys from the private domain inventory.

Usage:
  sudo /opt/tlao-mail/scripts/generate-dkim.sh [--force]
EOF
  exit 0
fi

[[ -f "${ENV_FILE}" ]] || { printf 'Missing %s\n' "${ENV_FILE}" >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required for private domain inventory.' >&2; exit 1; }

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a
TLAO_MAIL_ROOT="${requested_root:-${TLAO_MAIL_ROOT:-/opt/tlao-mail}}"
INVENTORY_FILE="${DOMAIN_INVENTORY_FILE:-${TLAO_MAIL_ROOT}/private/domains.local.json}"

DKIM_DIR="${TLAO_MAIL_ROOT}/stalwart/dkim"
DKIM_SELECTOR="${DKIM_SELECTOR:-mail}"
PRIMARY_DOMAIN="${MAIL_PRIMARY_DOMAIN:?MAIL_PRIMARY_DOMAIN is required}"
ALT_DOMAIN="${MAIL_ALT_DOMAIN:-}"

install -d -m 0750 "${DKIM_DIR}"

ensure_keypair() {
  local algorithm="$1" private_key="$2" public_key="$3"
  if [[ "${FORCE}" -eq 1 || ! -f "${private_key}" ]]; then
    if [[ "${algorithm}" == "rsa" ]]; then
      openssl genrsa -out "${private_key}" 2048
    else
      openssl genpkey -algorithm ed25519 -out "${private_key}"
    fi
    chmod 600 "${private_key}"
  fi
  if [[ "${FORCE}" -eq 1 || ! -f "${public_key}" ]]; then
    openssl pkey -in "${private_key}" -pubout -out "${public_key}"
    chmod 644 "${public_key}"
  fi
}

print_record() {
  local domain="$1" algorithm="$2" private_key="$3" public_key="$4" public_value
  if [[ "${algorithm}" == "rsa" ]]; then
    public_value="$(openssl rsa -in "${private_key}" -pubout -outform der 2>/dev/null | openssl base64 -A)"
  else
    public_value="$(openssl asn1parse -in "${public_key}" -offset 12 -noout -out /dev/stdout | base64 -w0)"
  fi
  printf 'Publish this DNS TXT record:\n  Name: %s._domainkey.%s\n  Type: TXT\n  Value: "v=DKIM1; k=%s; p=%s"\n' \
    "${DKIM_SELECTOR}" "${domain}" "${algorithm}" "${public_value}"
}

generate_domain_key() {
  local domain="$1" algorithm="$2" slug private_key public_key
  [[ "${domain}" =~ ^[a-z0-9][a-z0-9.-]*[a-z0-9]$ ]] || { echo 'Invalid domain in private inventory.' >&2; exit 1; }
  [[ "${algorithm}" == "ed25519" || "${algorithm}" == "rsa" ]] || { echo 'Unsupported DKIM algorithm in private inventory.' >&2; exit 1; }
  slug="${domain//./-}"
  private_key="${DKIM_DIR}/${slug}.${algorithm}.key"
  public_key="${DKIM_DIR}/${slug}.${algorithm}.pub"
  ensure_keypair "${algorithm}" "${private_key}" "${public_key}"
  print_record "${domain}" "${algorithm}" "${private_key}" "${public_key}"
}

ensure_keypair ed25519 "${DKIM_DIR}/primary.ed25519.key" "${DKIM_DIR}/primary.ed25519.pub"
print_record "${PRIMARY_DOMAIN}" ed25519 "${DKIM_DIR}/primary.ed25519.key" "${DKIM_DIR}/primary.ed25519.pub"

if [[ -n "${ALT_DOMAIN}" ]]; then
  ensure_keypair ed25519 "${DKIM_DIR}/secondary.ed25519.key" "${DKIM_DIR}/secondary.ed25519.pub"
  print_record "${ALT_DOMAIN}" ed25519 "${DKIM_DIR}/secondary.ed25519.key" "${DKIM_DIR}/secondary.ed25519.pub"
fi

if [[ -f "${INVENTORY_FILE}" ]]; then
  while IFS=$'\t' read -r domain algorithm; do
    [[ "${domain}" == "${PRIMARY_DOMAIN}" || "${domain}" == "${ALT_DOMAIN}" ]] && continue
    generate_domain_key "${domain}" "${algorithm:-ed25519}"
  done < <(jq -r '.domains[] | [.domain, (.dkimAlgorithm // "ed25519")] | @tsv' "${INVENTORY_FILE}")
fi

if docker ps --format '{{.Names}}' | grep -qx 'tlao-stalwart'; then
  docker compose --env-file "${ENV_FILE}" -f "${TLAO_MAIL_ROOT}/docker-compose.yml" up -d --force-recreate stalwart >/dev/null
  echo 'Recreated Stalwart so DKIM signing picks up the rendered configuration.'
fi
