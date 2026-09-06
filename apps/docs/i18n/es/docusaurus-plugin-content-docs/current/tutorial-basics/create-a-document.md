---
sidebar_position: 2
---

# Crea un documento

Los documentos son **grupos de páginas** conectadas mediante:

- Una **barra lateral**.
- La **navegación anterior y siguiente**.
- El **control de versiones**.

## Crea tu primer documento

Crea un archivo Markdown en `docs/hello.md`:

```md title="docs/hello.md"
# Hola

¡Este es mi **primer documento de Docusaurus**!
```

El documento estará disponible en
[http://localhost:3000/docs/hello](http://localhost:3000/docs/hello).

## Configura la barra lateral

Docusaurus puede **crear automáticamente una barra lateral** a partir de `docs`.

Añade metadatos para personalizar la etiqueta y la posición:

```md title="docs/hello.md" {1-4}
---
sidebar_label: '¡Hola!'
sidebar_position: 3
---

# Hola

¡Este es mi **primer documento de Docusaurus**!
```

También puedes definir la barra lateral explícitamente en `sidebars.js`:

```js title="sidebars.js"
export default {
  tutorialSidebar: [
    'intro',
    // highlight-next-line
    'hello',
    {
      type: 'category',
      label: 'Tutorial',
      items: ['tutorial-basics/create-a-document'],
    },
  ],
}
```
