# TLÁO documentation

The public documentation lives at `https://xn--tlo-fla.com/documentation/`.
The landing page and docs are published together by
[the GitHub Pages workflow](../../.github/workflows/deploy-github-pages.yml).
Do not deploy a docs-only artifact to this repository's Pages site: it would
replace the landing page.

## Content

- `docs/intro.md`: documentation home.
- `docs/mail/`: browser access, SMTP/IMAP settings, password recovery, and troubleshooting.
- `docs/concepts/` and `docs/custom-agents/`: platform and agent guides.
- `sidebars.ts`: supported navigation. Docusaurus starter examples are not part of the guide navigation.

Keep mail hostnames and mailbox addresses as placeholders. Operator inventory,
credentials, and account-owner details do not belong in public documentation.

## Preview and validate

```bash
pnpm --filter @tlao/docs dev
pnpm --filter @tlao/docs run lint
pnpm --filter @tlao/docs run type-check
pnpm --filter @tlao/docs exec jest --runInBand
pnpm --filter @tlao/docs run build:github
```

The default base path is `/documentation/`, matching production. The footer
reads its version from the package metadata, synchronized with the root and
landing packages by the repository's versioning tool.

## Publish

Prepare a reviewed patch, update the synchronized versions and changelog, run
the release privacy checks and both site builds, then push the release commit
to `main`. The Pages workflow validates the docs and publishes one artifact
containing the landing page at `/` and docs at `/documentation/`.
Tag that same commit and create the GitHub release. Confirm that the Pages run
succeeds and both public routes work; the tag does not trigger another competing
Pages deployment.
