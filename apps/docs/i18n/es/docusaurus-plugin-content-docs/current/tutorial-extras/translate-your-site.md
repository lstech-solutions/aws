---
sidebar_position: 2
---

# Traduce tu sitio

Este ejemplo muestra cómo traducir `docs/intro.md` al francés. La documentación
de TLÁO usa el mismo mecanismo para inglés (`en`) y español (`es`).

## Configura la internacionalización

Modifica `docusaurus.config.js` para añadir el idioma `fr`:

```js title="docusaurus.config.js"
export default {
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'fr'],
  },
}
```

## Traduce un documento

Copia `docs/intro.md` a la carpeta `i18n/fr`:

```bash
mkdir -p i18n/fr/docusaurus-plugin-content-docs/current/

cp docs/intro.md i18n/fr/docusaurus-plugin-content-docs/current/intro.md
```

Traduce al francés el contenido de `i18n/fr/docusaurus-plugin-content-docs/current/intro.md`.

## Inicia el sitio traducido

Inicia el servidor de desarrollo en francés:

```bash
npm run start -- --locale fr
```

Estará disponible en [http://localhost:3000/fr/](http://localhost:3000/fr/),
con la página de introducción traducida.

:::caution

Durante el desarrollo solo puedes usar un idioma a la vez.

:::

## Añade un selector de idioma

Añade un menú desplegable para navegar entre idiomas.

Modifica `docusaurus.config.js`:

```js title="docusaurus.config.js"
export default {
  themeConfig: {
    navbar: {
      items: [
        // highlight-start
        {
          type: 'localeDropdown',
        },
        // highlight-end
      ],
    },
  },
}
```

El selector aparece en la barra de navegación:

![Selector de idioma](./img/localeDropdown.png)

## Compila el sitio traducido

Para compilar un idioma concreto:

```bash
npm run build -- --locale fr
```

Para compilar todos los idiomas a la vez:

```bash
npm run build
```
