#!/usr/bin/env bash
set -euo pipefail

mode="${1:---repo}"
repo_root="$(git rev-parse --show-toplevel)"
config_path="${repo_root}/.gitleaks.toml"

run_gitleaks() {
  if command -v gitleaks >/dev/null 2>&1; then
    GITLEAKS_CONFIG="${config_path}" gitleaks "$@"
    return
  fi

  if command -v docker >/dev/null 2>&1; then
    docker run --rm \
      -e GITLEAKS_CONFIG=/repo/.gitleaks.toml \
      -v "${repo_root}:/repo" \
      -w /repo \
      ghcr.io/gitleaks/gitleaks:v8.30.0 \
      "$@"
    return
  fi

  echo "gitleaks or docker is required for secret scanning" >&2
  exit 1
}

case "${mode}" in
  --staged)
    run_gitleaks git --staged --redact --no-banner --verbose
    ;;
  --repo|--all|"")
    run_gitleaks detect --no-git --source "${repo_root}" --redact --no-banner --verbose
    ;;
  *)
    echo "Usage: $(basename "$0") [--staged|--repo]" >&2
    exit 2
    ;;
esac
