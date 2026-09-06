---
sidebar_position: 1
---

# Crea una página

Añade archivos **Markdown o React** a `src/pages` para crear una **página independiente**:

- `src/pages/index.js` → `localhost:3000/`
- `src/pages/foo.md` → `localhost:3000/foo`
- `src/pages/foo/bar.js` → `localhost:3000/foo/bar`

## Crea tu primera página React

Crea el archivo `src/pages/my-react-page.js`:

```jsx title="src/pages/my-react-page.js"
import React from 'react'
import Layout from '@theme/Layout'

export default function MyReactPage() {
  return (
    <Layout>
      <h1>Mi página React</h1>
      <p>Esta es una página React</p>
    </Layout>
  )
}
```

La página estará disponible en
[http://localhost:3000/my-react-page](http://localhost:3000/my-react-page).

## Crea tu primera página Markdown

Crea el archivo `src/pages/my-markdown-page.md`:

```mdx title="src/pages/my-markdown-page.md"
# Mi página Markdown

Esta es una página Markdown
```

La página estará disponible en
[http://localhost:3000/my-markdown-page](http://localhost:3000/my-markdown-page).
