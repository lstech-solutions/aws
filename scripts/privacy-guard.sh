#!/usr/bin/env bash
set -euo pipefail

mode="${1:---staged}"

case "${mode}" in
  --staged)
    diff_args=(--cached)
    source_ref=":"
    ;;
  --range)
    range="${2:-}"
    [[ -n "${range}" ]] || { echo "--range requires a revision range" >&2; exit 2; }
    diff_args=("${range}")
    source_ref="HEAD:"
    ;;
  *)
    echo "Usage: $(basename "$0") --staged | --range <revision-range>" >&2
    exit 2
    ;;
esac

is_sensitive_path() {
  case "$1" in
    .env|*/.env|.env.*|*/.env.*)
      [[ "$1" != ".env.example" && "$1" != */.env.example ]]
      ;;
    .agents/*|*/.agents/*|.tdd-state.json|*/.tdd-state.json|.codex|.codex/*|*/.codex|*/.codex/*)
      return 0
      ;;
    packages/email/deployment/ovh/private/*)
      [[ "$1" != "packages/email/deployment/ovh/private/domains.local.example.json" ]]
      ;;
    *)
      return 1
      ;;
  esac
}

has_non_loopback_ipv4() {
  local address octet

  while IFS= read -r address; do
    IFS=. read -r -a octet <<<"${address}"
    (( ${#octet[@]} == 4 )) || continue
    for value in "${octet[@]}"; do
      [[ "${value}" =~ ^[0-9]{1,3}$ ]] || continue 2
      (( 10#${value} <= 255 )) || continue 2
    done
    (( 10#${octet[0]} == 127 )) || return 0
  done < <(grep -Eao '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)

  return 1
}

is_placeholder_email() {
  local domain="${1##*@}"
  domain="${domain,,}"

  case "${domain}" in
    example.com|example.net|example.org|example.test|example.invalid|*.example.com|*.example.net|*.example.org|*.example.test|*.invalid|*.localhost)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_real_email() {
  local address

  while IFS= read -r address; do
    is_placeholder_email "${address}" || return 0
  done < <(grep -Eao "[[:alnum:].!#\$%&'*+/=?^_\`{|}~-]+@[[:alnum:]-]+(\.[[:alnum:]-]+)*\.[[:alpha:]]{2,}" || true)

  return 1
}

has_tenant_domain_in_public_mail_file() {
  local path="$1" domain content

  case "${path}" in
    packages/email/deployment/ovh/docs/*|packages/email/deployment/ovh/stalwart/*|packages/email/deployment/ovh/caddy/*|packages/email/deployment/ovh/.env.example|packages/email/deployment/ovh/private/domains.local.example.json)
      ;;
    *)
      return 1
      ;;
  esac

  content="$(cat)"
  case "${path}" in
    packages/email/deployment/ovh/.env.example)
      content="$(printf '%s\n' "${content}" | grep -E '^(MAIL_FQDN|MAIL_PRIMARY_DOMAIN|MAIL_ALT_DOMAIN|SNAPPYMAIL_HOSTS|SNAPPYMAIL_ALLOWED_DOMAINS|AUTOCONFIG_HOSTS|SNAPPYMAIL_(IMAP|SMTP)_HOST)=' || true)"
      ;;
  esac

  while IFS= read -r domain; do
    case "${domain,,}" in
      example.com|example.net|example.org|example.invalid|*.example.com|*.example.net|*.example.org|*.invalid)
        ;;
      *)
        return 0
        ;;
    esac
  done < <(printf '%s\n' "${content}" | grep -Eaio '\b([[:alnum:]-]+\.)+(com|net|org|io|co|app|dev|ai|xyz|ca|club|info|lat|tech|site|online|me|us|uk|de|es|fr|br|mx)\b' || true)

  return 1
}

failed=0
while IFS= read -r -d '' path; do
  if is_sensitive_path "${path}"; then
    echo "privacy guard: staged sensitive path: ${path}" >&2
    failed=1
    continue
  fi

  if ! blob="$(git show "${source_ref}${path}" 2>/dev/null)"; then
    echo "privacy guard: unable to read staged content: ${path}" >&2
    failed=1
    continue
  fi

  if has_non_loopback_ipv4 <<<"${blob}"; then
    echo "privacy guard: non-loopback IPv4 address in: ${path}" >&2
    failed=1
  fi
  if has_real_email <<<"${blob}"; then
    echo "privacy guard: non-placeholder email address in: ${path}" >&2
    failed=1
  fi
  if has_tenant_domain_in_public_mail_file "${path}" <<<"${blob}"; then
    echo "privacy guard: tenant domain in public mail file: ${path}" >&2
    failed=1
  fi
done < <(git diff "${diff_args[@]}" --name-only --diff-filter=ACMR -z)

exit "${failed}"

# This hook deliberately reads blobs from the index.  Reading the files from the
# working tree would make an un-staged local secret prevent an unrelated commit.
is_sensitive_path() {
  case "$1" in
    .env|*/.env|.env.*|*/.env.*|packages/email/deployment/ovh/private/domains.local.json|.agents/state.json|*/.agents/state.json|.tdd-state.json|*/.tdd-state.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_non_loopback_ipv4() {
  local address octet first

  while IFS= read -r address; do
    IFS=. read -r -a octet <<<"$address"
    (( ${#octet[@]} == 4 )) || continue

    for first in "${octet[@]}"; do
      [[ "$first" =~ ^[0-9]{1,3}$ ]] || continue 2
      (( 10#$first <= 255 )) || continue 2
    done

    # 127.0.0.0/8 is the IPv4 loopback range.
    (( 10#${octet[0]} == 127 )) || return 0
  done < <(grep -Eao '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)

  return 1
}

is_placeholder_email() {
  local domain=${1##*@}
  domain=${domain,,}

  case "$domain" in
    example.com|example.net|example.org|*.example.com|*.example.net|*.example.org|*.invalid|*.test|*.localhost)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_real_email() {
  local address

  while IFS= read -r address; do
    is_placeholder_email "$address" || return 0
  done < <(grep -Eao "[[:alnum:].!#\$%&'*+/=?^_\`{|}~-]+@[[:alnum:]][[:alnum:].-]*[[:alnum:]]" || true)

  return 1
}

failed=0
while IFS= read -r -d '' path; do
  if is_sensitive_path "$path"; then
    echo "privacy guard: staged sensitive path: $path" >&2
    failed=1
    continue
  fi

  # A file can have a non-text blob.  grep -a below treats it as bytes and only
  # reports an actual matching byte sequence.
  if git show ":$path" | has_non_loopback_ipv4; then
    echo "privacy guard: staged non-loopback IPv4 address in: $path" >&2
    failed=1
  fi

  if git show ":$path" | has_real_email; then
    echo "privacy guard: staged email address in: $path" >&2
    failed=1
  fi
done < <(git diff --cached --name-only --diff-filter=ACMR -z)

exit "$failed"
