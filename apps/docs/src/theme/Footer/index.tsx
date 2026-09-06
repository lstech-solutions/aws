import React, { type ReactNode } from 'react'
import Link from '@docusaurus/Link'
import useDocusaurusContext from '@docusaurus/useDocusaurusContext'
import styles from './styles.module.css'

export default function FooterWrapper(): ReactNode {
  const { siteConfig } = useDocusaurusContext()
  return (
    <footer className={styles.footer}>
      <div className={styles.inner}>
        <div>
          <p className={styles.brand}>
            TLÁO <span>/ DOCUMENTATION</span>
          </p>
          <p className={styles.description}>Clear instructions. Confident next steps.</p>
        </div>
        <nav className={styles.links} aria-label="Documentation footer">
          <Link to="/mail/">Mail guides</Link>
          <Link to="/mail/passwords">Password help</Link>
          <a href={siteConfig.url}>TLÁO home</a>
          <a href="https://github.com/lstech-solutions/aws-tlao">GitHub</a>
        </nav>
      </div>
      <div className={styles.meta}>
        <span>© {new Date().getFullYear()} TLÁO</span>
        <span>Documentation · v{String(siteConfig.customFields?.version)}</span>
      </div>
    </footer>
  )
}
