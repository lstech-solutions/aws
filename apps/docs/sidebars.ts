import type { SidebarsConfig } from '@docusaurus/plugin-content-docs'

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    { type: 'doc', id: 'intro', label: 'Start here' },
    {
      type: 'category',
      label: 'TLÁO Mail',
      collapsed: false,
      link: { type: 'doc', id: 'mail/index' },
      items: ['mail/webmail', 'mail/smtp-imap', 'mail/passwords', 'mail/troubleshooting'],
    },
    {
      type: 'category',
      label: 'Platform concepts',
      items: ['concepts/why-layer', 'concepts/why-tactical', 'concepts/action-outcomes'],
    },
    {
      type: 'category',
      label: 'Custom agents',
      items: [
        'custom-agents/introduction',
        'custom-agents/getting-started',
        'custom-agents/configuration',
        'custom-agents/tool-access',
        'custom-agents/examples',
      ],
    },
  ],
}

export default sidebars
