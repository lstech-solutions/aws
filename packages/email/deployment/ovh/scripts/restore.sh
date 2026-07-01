#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Restore a TLÁO Mail OVH backup archive into a VPS filesystem.

Usage:
  sudo ./packages/email/deployment/ovh/scripts/restore.sh --archive <path-or-s3-uri> [--target-root /opt/tlao-mail] [--force]

Options:
  --archive      Local path or s3:// URI to a backup archive.
  --target-root  Destination root to restore into. Defaults to /opt/tlao-mail.
  --force        Overwrite existing runtime directories under the target root.
  -h, --help     Show this help text.
EOF
}

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ARCHIVE_SOURCE=""
TARGET_ROOT="${TLAO_MAIL_ROOT}"
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive)
      ARCHIVE_SOURCE="${2:-}"
      shift 2
      ;;
    --target-root)
      TARGET_ROOT="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${ARCHIVE_SOURCE}" ]]; then
  printf 'Missing --archive argument\n' >&2
  usage >&2
  exit 1
fi

ENV_FILE="${TARGET_ROOT}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

BACKUP_S3_REGION="${BACKUP_S3_REGION:-${AWS_DEFAULT_REGION:-${AWS_REGION:-}}}"
if [[ -n "${BACKUP_AWS_ACCESS_KEY_ID:-}" ]]; then
  export AWS_ACCESS_KEY_ID="${BACKUP_AWS_ACCESS_KEY_ID}"
fi
if [[ -n "${BACKUP_AWS_SECRET_ACCESS_KEY:-}" ]]; then
  export AWS_SECRET_ACCESS_KEY="${BACKUP_AWS_SECRET_ACCESS_KEY}"
fi
if [[ -n "${BACKUP_AWS_SESSION_TOKEN:-}" ]]; then
  export AWS_SESSION_TOKEN="${BACKUP_AWS_SESSION_TOKEN}"
fi
if [[ -n "${BACKUP_AWS_PROFILE:-}" ]]; then
  export AWS_PROFILE="${BACKUP_AWS_PROFILE}"
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

archive_path="${ARCHIVE_SOURCE}"
checksum_path=""

if [[ "${ARCHIVE_SOURCE}" == s3://* ]]; then
  if ! command -v aws >/dev/null 2>&1; then
    printf 'aws CLI is required to restore from S3\n' >&2
    exit 1
  fi

  archive_name="$(basename "${ARCHIVE_SOURCE}")"
  archive_path="${tmpdir}/${archive_name}"
  checksum_path="${archive_path}.sha256"

  aws_args=()
  if [[ -n "${BACKUP_S3_REGION}" ]]; then
    aws_args+=(--region "${BACKUP_S3_REGION}")
  fi

  aws "${aws_args[@]}" s3 cp "${ARCHIVE_SOURCE}" "${archive_path}" --only-show-errors
  if aws "${aws_args[@]}" s3 cp "${ARCHIVE_SOURCE}.sha256" "${checksum_path}" --only-show-errors 2>/dev/null; then
    (cd "${tmpdir}" && sha256sum -c "${archive_name}.sha256")
  else
    printf 'Warning: checksum file not found next to %s\n' "${ARCHIVE_SOURCE}" >&2
  fi
else
  if [[ ! -f "${archive_path}" ]]; then
    printf 'Archive not found: %s\n' "${archive_path}" >&2
    exit 1
  fi

  if [[ -f "${archive_path}.sha256" ]]; then
    checksum_path="${archive_path}.sha256"
    (cd "$(dirname "${archive_path}")" && sha256sum -c "$(basename "${checksum_path}")")
  else
    printf 'Warning: checksum file not found for %s\n' "${archive_path}" >&2
  fi
fi

if [[ -d "${TARGET_ROOT}" ]]; then
  if find "${TARGET_ROOT}" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    if [[ "${FORCE}" != true ]]; then
      printf 'Target root %s is not empty. Re-run with --force to overwrite the runtime directories.\n' "${TARGET_ROOT}" >&2
      exit 1
    fi
  fi
else
  install -d -m 0755 "${TARGET_ROOT}"
fi

if [[ "${FORCE}" == true ]]; then
  rm -rf \
    "${TARGET_ROOT}/.env" \
    "${TARGET_ROOT}/docker-compose.yml" \
    "${TARGET_ROOT}/caddy" \
    "${TARGET_ROOT}/snappymail" \
    "${TARGET_ROOT}/stalwart"
fi

install -d -m 0755 \
  "${TARGET_ROOT}/caddy" \
  "${TARGET_ROOT}/snappymail" \
  "${TARGET_ROOT}/stalwart"

tar --use-compress-program="zstd -d" \
  -xpf "${archive_path}" \
  -C "${TARGET_ROOT}"

install -d -m 0755 \
  "${TARGET_ROOT}/caddy/logs" \
  "${TARGET_ROOT}/stalwart/logs"

printf 'Restored %s into %s\n' "${archive_path}" "${TARGET_ROOT}"
printf 'Next steps:\n'
printf '  sudo docker compose --env-file %s/.env -f %s/docker-compose.yml up -d stalwart snappymail caddy\n' "${TARGET_ROOT}" "${TARGET_ROOT}"
printf '  sudo %s/scripts/render-snappymail.sh\n' "${TARGET_ROOT}"
printf '  sudo %s/scripts/healthcheck.sh\n' "${TARGET_ROOT}"
