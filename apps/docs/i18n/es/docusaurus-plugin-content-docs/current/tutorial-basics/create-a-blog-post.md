---
sidebar_position: 3
---

# Crea una publicación de blog

Docusaurus crea una **página por publicación**, un **índice del blog**,
un **sistema de etiquetas** y un canal **RSS**, entre otras funciones.

## Crea tu primera publicación

Crea el archivo `blog/2021-02-28-greetings.md`:

```md title="blog/2021-02-28-greetings.md"
---
slug: greetings
title: ¡Saludos!
authors:
  - name: Joel Marcey
    title: Cocreador de Docusaurus 1
    url: https://github.com/JoelMarcey
    image_url: https://github.com/JoelMarcey.png
  - name: Sébastien Lorber
    title: Mantenedor de Docusaurus
    url: https://sebastienlorber.com
    image_url: https://github.com/slorber.png
tags: [greetings]
---

¡Felicidades! Has creado tu primera publicación.

Puedes experimentar y editarla todo lo que quieras.
```

La nueva publicación estará disponible en
[http://localhost:3000/blog/greetings](http://localhost:3000/blog/greetings).
