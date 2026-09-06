---
sidebar_position: 1
---

# Administra versiones de la documentación

Docusaurus permite mantener varias versiones de tus documentos.

## Crea una versión

Publica la versión 1.0 de tu proyecto:

```bash
npm run docusaurus docs:version 1.0
```

La carpeta `docs` se copia en `versioned_docs/version-1.0` y se crea `versions.json`.

Ahora tienes dos versiones:

- `1.0` en `http://localhost:3000/docs/`, con la documentación de la versión 1.0.
- `current` en `http://localhost:3000/docs/next/`, con la **próxima documentación aún no publicada**.

## Añade un selector de versión

Para navegar entre versiones, añade un menú desplegable.

Modifica `docusaurus.config.js`:

```js title="docusaurus.config.js"
export default {
  themeConfig: {
    navbar: {
      items: [
        // highlight-start
        {
          type: 'docsVersionDropdown',
        },
        // highlight-end
      ],
    },
  },
}
```

El selector aparece en la barra de navegación:

![Selector de versión de la documentación](./img/docsVersionDropdown.png)

## Actualiza una versión existente

Edita los documentos en la carpeta correspondiente:

- `versioned_docs/version-1.0/hello.md` actualiza `http://localhost:3000/docs/hello`.
- `docs/hello.md` actualiza `http://localhost:3000/docs/next/hello`.
