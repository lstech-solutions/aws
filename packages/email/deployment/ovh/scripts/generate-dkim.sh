#!/usr/bin/env bash
set -euo pipefail

TLAO_MAIL_ROOT="${TLAO_MAIL_ROOT:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"
FORCE=0

if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
elif [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Generate or reuse the TLÁO Mail DKIM keys.

Usage:
  sudo /opt/tlao-mail/scripts/generate-dkim.sh
  sudo /opt/tlao-mail/scripts/generate-dkim.sh --force
EOF
  exit 0
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  printf 'Missing %s\n' "${ENV_FILE}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

DOMAIN="${MAIL_PRIMARY_DOMAIN:?MAIL_PRIMARY_DOMAIN is required in ${ENV_FILE}}"
ALT_DOMAIN="${MAIL_ALT_DOMAIN:-}"
DKIM_SELECTOR="${DKIM_SELECTOR:-mail}"
DKIM_DIR="${TLAO_MAIL_ROOT}/stalwart/dkim"
PRIVATE_KEY_PATH="${DKIM_DIR}/primary.ed25519.key"
PUBLIC_KEY_PATH="${DKIM_DIR}/primary.ed25519.pub"
SECONDARY_PRIVATE_KEY_PATH="${DKIM_DIR}/secondary.ed25519.key"
SECONDARY_PUBLIC_KEY_PATH="${DKIM_DIR}/secondary.ed25519.pub"
CIG_LAT_DOMAIN="cig.lat"
CIG_LAT_PRIVATE_KEY_PATH="${DKIM_DIR}/cig-lat.rsa.key"
CIG_LAT_PUBLIC_KEY_PATH="${DKIM_DIR}/cig-lat.rsa.pub"
A_QUANT_DOMAIN="a-quant.xyz"
A_QUANT_PRIVATE_KEY_PATH="${DKIM_DIR}/a-quant.ed25519.key"
A_QUANT_PUBLIC_KEY_PATH="${DKIM_DIR}/a-quant.ed25519.pub"
TIRANICIDA_DOMAIN="tiranicida.ca"
TIRANICIDA_PRIVATE_KEY_PATH="${DKIM_DIR}/tiranicida.ed25519.key"
TIRANICIDA_PUBLIC_KEY_PATH="${DKIM_DIR}/tiranicida.ed25519.pub"
ALTERNUN_DOMAIN="alternun.org"
ALTERNUN_PRIVATE_KEY_PATH="${DKIM_DIR}/alternun.ed25519.key"
ALTERNUN_PUBLIC_KEY_PATH="${DKIM_DIR}/alternun.ed25519.pub"
HASHPASS_DOMAIN="hashpass.club"
HASHPASS_PRIVATE_KEY_PATH="${DKIM_DIR}/hashpass-club.ed25519.key"
HASHPASS_PUBLIC_KEY_PATH="${DKIM_DIR}/hashpass-club.ed25519.pub"
COMPOSE_FILE="${TLAO_MAIL_ROOT}/docker-compose.yml"

install -d -m 0750 "${DKIM_DIR}"

ensure_ed25519_keypair() {
  local private_key_path="$1"
  local public_key_path="$2"

  if [[ "${FORCE}" -eq 1 || ! -f "${private_key_path}" ]]; then
    openssl genpkey -algorithm ed25519 -out "${private_key_path}"
    chmod 600 "${private_key_path}"
  fi

  if [[ "${FORCE}" -eq 1 || ! -f "${public_key_path}" ]]; then
    openssl pkey -in "${private_key_path}" -pubout -out "${public_key_path}"
    chmod 644 "${public_key_path}"
  fi
}

ensure_rsa_keypair() {
  local private_key_path="$1"
  local public_key_path="$2"

  if [[ "${FORCE}" -eq 1 || ! -f "${private_key_path}" ]]; then
    openssl genrsa -out "${private_key_path}" 2048
    chmod 600 "${private_key_path}"
  fi

  if [[ "${FORCE}" -eq 1 || ! -f "${public_key_path}" ]]; then
    openssl rsa -in "${private_key_path}" -pubout -out "${public_key_path}"
    chmod 644 "${public_key_path}"
  fi
}

print_record() {
  local domain_name="$1"
  local key_path="$2"
  local key_type="$3"
  local dkim_public_key

  if [[ "${key_type}" == "rsa" ]]; then
    dkim_public_key="$(
      openssl rsa -in "${key_path}" -pubout -outform der 2>/dev/null | openssl base64 -A
    )"
  else
    dkim_public_key="$(
      openssl asn1parse -in "${key_path}" -offset 12 -noout -out /dev/stdout | base64 -w0
    )"
  fi

  printf 'Publish this DNS TXT record:\n'
  printf '  Name: %s._domainkey.%s\n' "${DKIM_SELECTOR}" "${domain_name}"
  printf '  Type: TXT\n'
  printf '  Value: "v=DKIM1; k=%s; p=%s"\n' "${key_type}" "${dkim_public_key}"
}

ensure_ed25519_keypair "${PRIVATE_KEY_PATH}" "${PUBLIC_KEY_PATH}"
print_record "${DOMAIN}" "${PUBLIC_KEY_PATH}" "ed25519"

if [[ -n "${ALT_DOMAIN}" ]]; then
  ensure_ed25519_keypair "${SECONDARY_PRIVATE_KEY_PATH}" "${SECONDARY_PUBLIC_KEY_PATH}"
  if [[ "${ALT_DOMAIN}" != "${CIG_LAT_DOMAIN}" && "${ALT_DOMAIN}" != "${ALTERNUN_DOMAIN}" ]]; then
    print_record "${ALT_DOMAIN}" "${SECONDARY_PUBLIC_KEY_PATH}" "ed25519"
  fi
fi

ensure_rsa_keypair "${CIG_LAT_PRIVATE_KEY_PATH}" "${CIG_LAT_PUBLIC_KEY_PATH}"
print_record "${CIG_LAT_DOMAIN}" "${CIG_LAT_PRIVATE_KEY_PATH}" "rsa"

ensure_ed25519_keypair "${A_QUANT_PRIVATE_KEY_PATH}" "${A_QUANT_PUBLIC_KEY_PATH}"
print_record "${A_QUANT_DOMAIN}" "${A_QUANT_PUBLIC_KEY_PATH}" "ed25519"

ensure_ed25519_keypair "${TIRANICIDA_PRIVATE_KEY_PATH}" "${TIRANICIDA_PUBLIC_KEY_PATH}"
print_record "${TIRANICIDA_DOMAIN}" "${TIRANICIDA_PUBLIC_KEY_PATH}" "ed25519"

ensure_ed25519_keypair "${ALTERNUN_PRIVATE_KEY_PATH}" "${ALTERNUN_PUBLIC_KEY_PATH}"
print_record "${ALTERNUN_DOMAIN}" "${ALTERNUN_PUBLIC_KEY_PATH}" "ed25519"

ensure_ed25519_keypair "${HASHPASS_PRIVATE_KEY_PATH}" "${HASHPASS_PUBLIC_KEY_PATH}"
print_record "${HASHPASS_DOMAIN}" "${HASHPASS_PUBLIC_KEY_PATH}" "ed25519"

if [[ -f "${COMPOSE_FILE}" ]] && docker ps --format '{{.Names}}' | grep -qx 'tlao-stalwart'; then
  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d --force-recreate stalwart >/dev/null
  printf 'Recreated Stalwart so DKIM signing picks up the current key and current env.\n'
fi
