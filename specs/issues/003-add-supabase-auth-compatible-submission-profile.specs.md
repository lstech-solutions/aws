# Technical Specification for Issue #3

## Issue Summary

- Title: `feat(smtp): add Supabase Auth-compatible submission profile`
- Labels: enhancement
- Priority: High — it gates Supabase Auth email flows for customers.

## Problem Statement

The TLAO Stalwart deployment already has authenticated submission listeners on
ports 587 (STARTTLS) and 465 (implicit TLS), but that supported behavior is not
defined as an interoperable Supabase Auth profile or verified by a repeatable
protocol-level check. Supabase must receive the final SMTP `250` response after
`DATA` and a `221` response after `QUIT`; accepting a message internally is not
enough if the client sees EOF instead.

Live diagnostics on 2026-08-18 showed authenticated Supabase connections
successfully queued and delivered messages through both existing listeners.
This feature therefore formalizes and continuously verifies the existing safe
submission path rather than adding an unauthenticated relay or a message
rewriting bridge.

## Technical Approach

Use the existing canonical mail host as the explicit Supabase-compatible
profile. Preserve Stalwart's `session.rcpt.relay` predicate requiring SMTP
authentication. Add a credential-driven protocol probe that performs the exact
Supabase-relevant lifecycle: EHLO, STARTTLS or implicit TLS, EHLO, AUTH, MAIL
FROM, RCPT TO, DATA, final `250`, QUIT, and `221`.

The probe must print only status/queue correlation metadata, never credentials
or message content. It will be callable on the VPS with a short-lived,
dedicated mailbox credential and will fail on incomplete responses, premature
EOF, failed TLS validation, or rejected authentication. The existing health
check will optionally invoke it only when its explicitly named test variables
are present. Public operational documentation will describe supported ports,
TLS/auth settings, per-tenant credential lifecycle, limits/error behavior, and
log-based correlation.

## Implementation Plan

1. Add a small protocol-probe module/CLI with an injectable SMTP transport so
   unit tests can assert final `250` and `221` handling without a live mailbox.
2. Add a VPS wrapper and optional health-check integration that source only
   dedicated Supabase probe environment variables, keeps secrets out of output,
   and produces a submission correlation identifier.
3. Document the supported Supabase Auth profile on the existing hostname,
   including 587 STARTTLS as the primary path and 465 implicit TLS as an
   alternative, credentials, limits, observability, and troubleshooting.
4. Add a live-only GoTrue/Supabase interoperability command or CI-gated test
   profile, enabled only when test credentials and a disposable Supabase Auth
   environment are supplied.

## Test Plan

1. Unit tests
   - A successful STARTTLS transaction requires final `250` after DATA and
     `221` after QUIT.
   - EOF before either response fails with a clear protocol error.
   - Authentication and relay rejections retain the server's explicit SMTP
     response; credentials and message bodies never appear in output.
2. Deployment tests
   - The wrapper validates required configuration and does not run when probe
     credentials are absent.
   - The health check keeps its existing behavior when optional probe variables
     are not configured.
3. Interoperability tests
   - A disposable GoTrue environment configured with the profile completes
     signup, recovery, magic-link, and OTP sends using Supabase templates.
   - The captured transcript contains `250` after DATA and `221` after QUIT.

## Files to Modify

- `packages/email/deployment/ovh/scripts/healthcheck.sh`: optional non-secret
  probe invocation and result reporting.
- `packages/email/deployment/ovh/.env.example`: documented optional probe
  variable names with placeholders only.
- `packages/email/deployment/ovh/docs/README.md`: index the new runbook.
- `packages/email/deployment/ovh/docs/MAILBOX-ACCESS.md`: link general SMTP
  settings to the Supabase-specific profile.

## Files to Create

- `packages/email/deployment/ovh/scripts/verify-supabase-smtp.*`: protocol
  lifecycle probe and VPS entry point.
- `packages/email/deployment/ovh/docs/SUPABASE-SMTP.md`: versioned customer and
  operator runbook.
- Corresponding focused unit/integration test files following repository test
  conventions.

## Existing Utilities to Leverage

- `packages/email/deployment/ovh/stalwart/config.toml`: listeners, TLS, relay
  safety, DKIM, and tracer configuration.
- `packages/email/deployment/ovh/scripts/healthcheck.sh`: established host
  environment and Compose access pattern.
- `packages/email/tests/unit/stalwart-client.test.ts`: Jest/TypeScript testing
  conventions for Stalwart-facing code.

## Success Criteria

- [ ] The documented profile uses authenticated SMTP submission only.
- [ ] Port 587 STARTTLS completes `250` after DATA and `221` after QUIT.
- [ ] Port 465 implicit TLS is verified when enabled.
- [ ] Probe failures expose safe, standards-compliant diagnostic context.
- [ ] Secrets and message bodies are neither logged nor committed.
- [ ] A gated GoTrue interoperability check is available for a disposable
      Supabase Auth environment.
- [ ] Existing mail health checks and test suite remain green.

## Out of Scope

- Replacing, rendering, or modifying Supabase Auth templates.
- Adding an unauthenticated relay, broad source-IP trust, or a separate SMTP
  bridge.
- Changing live customer credentials or generating a dedicated hostname without
  a tenant/domain onboarding request.
