#!/usr/bin/env bash
set -euo pipefail

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"
TEMPLATE_FILE="${TLAO_MAIL_ROOT}/stalwart/etc/config.base.toml"
OUTPUT_FILE="${TLAO_MAIL_ROOT}/stalwart/etc/config.toml"
INVENTORY_FILE="${DOMAIN_INVENTORY_FILE:-${TLAO_MAIL_ROOT}/private/domains.local.json}"

[[ -f "${ENV_FILE}" ]] || { printf 'Missing %s\n' "${ENV_FILE}" >&2; exit 1; }
[[ -f "${TEMPLATE_FILE}" ]] || { printf 'Missing %s\n' "${TEMPLATE_FILE}" >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required for private domain inventory.' >&2; exit 1; }

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a
TLAO_MAIL_ROOT="${requested_root:-${TLAO_MAIL_ROOT:-/opt/tlao-mail}}"
TEMPLATE_FILE="${TLAO_MAIL_ROOT}/stalwart/etc/config.base.toml"
OUTPUT_FILE="${TLAO_MAIL_ROOT}/stalwart/etc/config.toml"
INVENTORY_FILE="${DOMAIN_INVENTORY_FILE:-${TLAO_MAIL_ROOT}/private/domains.local.json}"

signature_lines=''
rule_lines=''
if [[ -f "${INVENTORY_FILE}" ]]; then
  while IFS=$'\t' read -r domain algorithm; do
    [[ "${domain}" == "${MAIL_PRIMARY_DOMAIN}" || "${domain}" == "${MAIL_ALT_DOMAIN:-}" ]] && continue
    [[ "${domain}" =~ ^[a-z0-9][a-z0-9.-]*[a-z0-9]$ ]] || { echo 'Invalid domain in private inventory.' >&2; exit 1; }
    [[ "${algorithm}" == "ed25519" || "${algorithm}" == "rsa" ]] || { echo 'Unsupported DKIM algorithm in private inventory.' >&2; exit 1; }
    slug="${domain//./_}"
    file_slug="${domain//./-}"
    toml_algorithm="${algorithm}-sha256"
    signature_lines+=$'\n'
    signature_lines+="[signature.\"dkim_${slug}\"]"$'\n'
    signature_lines+="private-key = \"%{file:/opt/stalwart/dkim/${file_slug}.${algorithm}.key}%\""$'\n'
    signature_lines+="domain = \"${domain}\""$'\n'
    signature_lines+='selector = "%{env:DKIM_SELECTOR}%"'$'\n'
    signature_lines+='headers = ["From", "To", "Cc", "Date", "Subject", "Message-ID", "Organization", "MIME-Version", "Content-Type", "In-Reply-To", "References", "List-Id", "User-Agent", "Thread-Topic", "Thread-Index"]'$'\n'
    signature_lines+="algorithm = \"${toml_algorithm}\""$'\ncanonicalization = "relaxed/relaxed"'$'\nexpire = "10d"'$'\nset-body-length = false'$'\nreport = false'$'\n'
    rule_lines+="  { if = \"listener != 'smtp' && sender_domain = '${domain}'\", then = \"['dkim_${slug}']\" },"$'\n'
  done < <(jq -r '.domains[] | [.domain, (.dkimAlgorithm // "ed25519")] | @tsv' "${INVENTORY_FILE}")
fi

tmp_file="$(mktemp "${OUTPUT_FILE}.XXXXXX")"
awk -v signatures="${signature_lines}" -v rules="${rule_lines}" '
  /^# <PRIVATE_DOMAIN_SIGNATURES>$/ { print signatures; next }
  /^  # <PRIVATE_DKIM_SIGN_RULES>$/ { printf "%s", rules; next }
  { print }
' "${TEMPLATE_FILE}" >"${tmp_file}"
chmod 0644 "${tmp_file}"
mv "${tmp_file}" "${OUTPUT_FILE}"
echo 'Rendered private domain DKIM configuration.'
