---
sidebar_position: 5
---

# Despliega tu sitio

Docusaurus es un **generador de sitios estáticos**, también conocido como
**[Jamstack](https://jamstack.org/)**.

Genera el sitio como **archivos estáticos de HTML, JavaScript y CSS**.

## Compila el sitio

Genera la versión **de producción**:

```bash
npm run build
```

Los archivos estáticos se crean en la carpeta `build`.

## Publica el sitio

Prueba localmente la versión de producción:

```bash
npm run serve
```

La carpeta `build` se sirve en [http://localhost:3000/](http://localhost:3000/).

Puedes publicar esa carpeta **en casi cualquier alojamiento**, gratis o a bajo
coste. Consulta la **[guía de despliegue](https://docusaurus.io/docs/deployment)**.
