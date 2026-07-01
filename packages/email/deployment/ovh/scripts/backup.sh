#!/usr/bin/env bash
set -euo pipefail

requested_root="${TLAO_MAIL_ROOT:-}"
TLAO_MAIL_ROOT="${requested_root:-/opt/tlao-mail}"
ENV_FILE="${TLAO_MAIL_ROOT}/.env"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

TLAO_MAIL_ROOT="${requested_root:-${TLAO_MAIL_ROOT:-/opt/tlao-mail}}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
BACKUP_S3_BUCKET="${BACKUP_S3_BUCKET:-}"
BACKUP_S3_PREFIX="${BACKUP_S3_PREFIX:-tlao-mail/backups}"
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
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_DIR="${TLAO_MAIL_ROOT}/backups"
ARCHIVE_NAME="tlao-mail-${STAMP}.tar.zst"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"
CHECKSUM_PATH="${ARCHIVE_PATH}.sha256"

install -d -m 0755 "${BACKUP_DIR}"

tar --use-compress-program="zstd -T0 -19" \
  -cpf "${ARCHIVE_PATH}" \
  -C "${TLAO_MAIL_ROOT}" \
  .env \
  docker-compose.yml \
  caddy/Caddyfile \
  caddy/config \
  caddy/data \
  snappymail/_data_ \
  stalwart/certs \
  stalwart/data \
  stalwart/dkim \
  stalwart/etc

(
  cd "${BACKUP_DIR}"
  sha256sum "${ARCHIVE_NAME}" > "${ARCHIVE_NAME}.sha256"
)
printf 'Created backup archive: %s\n' "${ARCHIVE_PATH}"
printf 'Created checksum: %s\n' "${CHECKSUM_PATH}"

if [[ -n "${BACKUP_S3_BUCKET}" ]]; then
  if ! command -v aws >/dev/null 2>&1; then
    printf 'BACKUP_S3_BUCKET is set but aws CLI is not installed\n' >&2
    exit 1
  fi

  aws_args=()
  if [[ -n "${BACKUP_S3_REGION}" ]]; then
    aws_args+=(--region "${BACKUP_S3_REGION}")
  fi

  s3_prefix="${BACKUP_S3_PREFIX%/}"
  s3_destination="s3://${BACKUP_S3_BUCKET}/${s3_prefix}/"
  aws "${aws_args[@]}" s3 sync "${BACKUP_DIR}" "${s3_destination}" --only-show-errors
  printf 'Mirrored backups to %s\n' "${s3_destination}"
fi

find "${BACKUP_DIR}" -type f \( -name 'tlao-mail-*.tar.zst' -o -name 'tlao-mail-*.tar.zst.sha256' \) -mtime "+${BACKUP_RETENTION_DAYS}" -delete
