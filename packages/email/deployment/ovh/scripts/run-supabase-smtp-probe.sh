#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../../../.." && pwd)"
env_file="${repo_root}/.env"

if [[ ! -f "${env_file}" ]]; then
  printf 'Missing private environment file: %s\n' "${env_file}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${env_file}"
set +a

required_vars=(
  SUPABASE_SMTP_PROBE_HOST
  SUPABASE_SMTP_PROBE_PORT
  SUPABASE_SMTP_PROBE_USERNAME
  SUPABASE_SMTP_PROBE_PASSWORD
  SUPABASE_SMTP_PROBE_SENDER
  SUPABASE_SMTP_PROBE_RECIPIENT
)

for required_var in "${required_vars[@]}"; do
  if [[ -z "${!required_var:-}" ]]; then
    printf 'Missing %s in %s\n' "${required_var}" "${env_file}" >&2
    exit 1
  fi
done

exec python3 "${script_dir}/verify-supabase-smtp.py"
