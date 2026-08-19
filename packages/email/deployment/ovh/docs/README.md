# TLÁO Mail OVH Docs

This folder is the canonical home for the OVH/Stalwart bundle's operational docs.

- [Bundle overview](../README.md)
- [Domain onboarding runbook](./DOMAIN-ONBOARDING.md)
- [Mailbox access guide](./MAILBOX-ACCESS.md)
- [Supabase SMTP profile](./SUPABASE-SMTP.md)
- [VPS access and deployment runbook](./VPS-ACCESS.md)

Use these docs as the source of truth for mail deployment and mailbox operations.
Keep the live inventory in the gitignored `private/` files. Keep Supabase
integration and probe credentials in the gitignored repository-root `.env`;
never put those SMTP passwords on the VPS. For Supabase specifically, the VPS
`.env` contains only the non-secret `SUPABASE_SMTP_ACCOUNT_LIST` scope; it does
not contain Supabase SMTP credentials.
