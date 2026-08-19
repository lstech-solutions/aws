# Critical Release Privacy Guard

The release workflow must never publish personal email addresses, tenant
domains, server IP addresses, private inventory, generated runtime
configuration, or credentials. This guard is a required companion to the
existing secret scanner; neither check replaces the other.

## Enforced Gates

- Commits made with Husky enabled run `privacy:check` after formatting and
  before the secret scans. It examines the Git index only. Never use
  `git commit --no-verify`.
- `version:patch` runs the same staged check before
  `@edcalderon/versioning` can create a release commit.
- `prerelease` and `push:release` fetch `origin/main`, then scan from
  the merge-base of `origin/main` and `HEAD` through `HEAD`, including
  the versioning-generated commit. This release-range gate is mandatory before
  a push.
- The guard's isolated Git-index tests run in both pre-commit and prerelease.
- `security:scan:staged` invokes the privacy guard before Gitleaks.

The guard rejects staged or release-range changes that contain:

- runtime/private paths such as `.env`, mail inventory, agent state, or
  Codex state;
- non-loopback IPv4 addresses;
- non-placeholder email addresses; and
- literal tenant domains in public OVH mail docs, Caddy/Stalwart templates,
  the mail-host fields in the environment example, and the private-inventory
  example schema.

It permits explicit placeholders, `example.invalid`, its subdomains,
`example.com`, `example.net`, `example.org`, `example.test`, their
subdomains, and `*.localhost`.

## Operator Commands

```bash
# Check exactly what will be committed
pnpm run privacy:check

# Check everything that would be released from the tracked upstream base
pnpm run privacy:release

# Run the isolated policy tests directly
pnpm run test:privacy
```

Do not bypass a failed check. Move operational values to ignored runtime files,
replace public examples with placeholders, and rerun the check.

## Exposure Response

If sensitive data reaches a branch or release candidate:

1. Stop the release and remove the data from the current change.
1. Revoke or rotate any exposed credential, key, or mailbox password.
1. If it was pushed, remove it from every reachable branch/tag and rewrite
   history where required by the incident owner; invalidate affected build
   artifacts and caches.
1. Notify the data owner and security contact with no additional sensitive
   values in the report.
1. Verify a clean release range with `pnpm run privacy:release` and the
   secret scanner before resuming.
