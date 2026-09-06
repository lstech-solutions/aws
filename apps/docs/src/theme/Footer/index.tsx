import React, { type ReactNode } from 'react'
import Link from '@docusaurus/Link'
import Translate, { translate } from '@docusaurus/Translate'
import useDocusaurusContext from '@docusaurus/useDocusaurusContext'
import styles from './styles.module.css'

export default function FooterWrapper(): ReactNode {
  const { siteConfig } = useDocusaurusContext()
  return (
    <footer className={styles.footer}>
      <div className={styles.inner}>
        <div>
          <p className={styles.brand}>
            TLÁO{' '}
            <span>
              / <Translate id="docs.footer.brand">DOCUMENTATION</Translate>
            </span>
          </p>
          <p className={styles.description}>
            <Translate id="docs.footer.description">
              Clear instructions. Confident next steps.
            </Translate>
          </p>
        </div>
        <nav
          className={styles.links}
          aria-label={translate({ id: 'docs.footer.navigation', message: 'Documentation footer' })}
        >
          <Link to="/mail/">
            <Translate id="docs.footer.mail">Mail guides</Translate>
          </Link>
          <Link to="/mail/passwords">
            <Translate id="docs.footer.passwords">Password help</Translate>
          </Link>
          <a href={siteConfig.url}>
            <Translate id="docs.footer.home">TLÁO home</Translate>
          </a>
          <a href="https://github.com/lstech-solutions/aws-tlao">GitHub</a>
        </nav>
      </div>
      <div className={styles.meta}>
        <span>© {new Date().getFullYear()} TLÁO</span>
        <span>
          <Translate id="docs.footer.version">Documentation</Translate> · v
          {String(siteConfig.customFields?.version)}
        </span>
      </div>
    </footer>
  )
}
