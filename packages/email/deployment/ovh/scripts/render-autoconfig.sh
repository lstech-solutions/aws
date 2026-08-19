#!/usr/bin/env bash
set -euo pipefail

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"
TEMPLATE_FILE="${TLAO_MAIL_ROOT}/caddy/autoconfig/mail/config-v1.1.xml.template"
OUTPUT_FILE="${TLAO_MAIL_ROOT}/caddy/config/autoconfig/mail/config-v1.1.xml"

[[ -f "${ENV_FILE}" ]] || { printf 'Missing %s\n' "${ENV_FILE}" >&2; exit 1; }
[[ -f "${TEMPLATE_FILE}" ]] || { printf 'Missing %s\n' "${TEMPLATE_FILE}" >&2; exit 1; }

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a
[[ "${MAIL_FQDN:-}" =~ ^[a-z0-9][a-z0-9.-]*[a-z0-9]$ ]] || { echo 'MAIL_FQDN must be a hostname.' >&2; exit 1; }

install -d -m 0755 "$(dirname "${OUTPUT_FILE}")"
tmp_file="$(mktemp "${OUTPUT_FILE}.XXXXXX")"
sed "s/__MAIL_FQDN__/${MAIL_FQDN}/g" "${TEMPLATE_FILE}" >"${tmp_file}"
chmod 0644 "${tmp_file}"
mv "${tmp_file}" "${OUTPUT_FILE}"
