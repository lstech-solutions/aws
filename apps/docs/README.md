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

The owner-approved public mail and webmail hostnames appear in the user guides.
Keep mailbox addresses as placeholders. Operator inventory, credentials, and
account-owner details do not belong in public documentation. Screenshots must
show public screens with empty fields and no account or reset-token data.

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

## English and Spanish

English is served at `/documentation/`; Spanish at `/documentation/es/`.
Use the language menu in the navbar (or the main mobile menu) to switch the
current guide. Docusaurus provides localized HTML language metadata and
alternate-language links. The URL is the language preference; there is no
automatic redirect based on browser settings.

Maintain one Spanish counterpart for every `.md` and `.mdx` file in `docs/`,
including pages outside the main sidebar. Spanish content lives in
`i18n/es/docusaurus-plugin-content-docs/current/`. Preserve document filenames,
IDs, slugs, commands, server names, and referenced anchor IDs. Translate prose,
page metadata, image descriptions, and explanatory example strings. Screenshots
show the actual product UI; captions explain any English labels in Spanish.

Navbar and sidebar translations live in the plugin JSON catalogs under
`i18n/es/`. Wrap custom React interface labels with Docusaurus `Translate` or
`translate`, then update `i18n/es/code.json`:

```bash
pnpm --filter @tlao/docs exec docusaurus write-translations --locale es
pnpm --filter @tlao/docs dev --locale es
```

Development serves one locale at a time. `build:github` builds both locales;
preview the built artifact to test language switching. The documentation tests
reject missing or unchanged English copies in the Spanish content tree, and
Pages checks both locale outputs before deployment. Review the Spanish
counterpart whenever an English guide changes.
