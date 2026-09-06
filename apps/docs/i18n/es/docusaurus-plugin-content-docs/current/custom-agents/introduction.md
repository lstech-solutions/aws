---
sidebar_position: 1
---

# Agentes personalizados

## ¿Qué son los agentes personalizados?

Los agentes personalizados son configuraciones especializadas de Kiro que
permiten adaptar su comportamiento a tareas y flujos de trabajo concretos.
Funcionan como distintos «modos» de Kiro, cada uno preparado para escribir
documentación, revisar código, depurar problemas o administrar infraestructura.

Cada agente tiene sus propias instrucciones del sistema, permisos de
herramientas y opciones de configuración. Puedes crear un agente de
documentación con solo las herramientas necesarias o uno de depuración con
acceso para ejecutar comandos y modificar código.

## ¿Por qué usar agentes personalizados?

Permiten adaptar el asistente a tus necesidades específicas. Sus ventajas principales son:

### Optimización del flujo de trabajo

Los agentes especializados comprenden el contexto y las restricciones de una
tarea. Un agente de documentación prioriza la claridad y la estructura; uno de
revisión se centra en la calidad y las buenas prácticas. Así ofrecen ayuda más pertinente.

### Menos interrupciones

Los permisos y las aprobaciones previas reducen las solicitudes de confirmación
para operaciones de confianza. Si un flujo lee y escribe Markdown con frecuencia,
puedes aprobar esas herramientas de antemano para que trabaje con mayor fluidez.

### Más contexto

Las instrucciones del sistema pueden incluir conocimientos y pautas del área
correspondiente. El agente empieza cada conversación con el contexto adecuado:
estándares de código del equipo, guía de estilo o metodología de depuración.

### Colaboración en equipo

Las configuraciones son archivos JSON que puedes compartir mediante control de
versiones. Todos pueden usar los mismos agentes especializados y mantener flujos
y criterios coherentes.

### Control de seguridad

Los permisos detallados permiten asignar a cada agente únicamente el acceso que
necesita. Un revisor puede tener acceso de solo lectura, mientras que un depurador
puede leer, escribir y ejecutar comandos. El principio de mínimo privilegio ayuda
a conservar la seguridad al automatizar.

## Relación con Kiro CLI

Crea las configuraciones como archivos JSON en `~/.kiro/agents/` e invócalas con
la opción `--mode` de Kiro CLI:

```bash
kiro chat --mode docs-writer "Crea documentación de la API"
kiro chat --mode code-reviewer "Revisa el módulo de autenticación"
kiro chat --mode debugger-assistant "Investiga el fallo al iniciar sesión"
```

Cada agente puede acceder a las herramientas integradas de Kiro, como operaciones
de archivos, comandos y análisis de código, y a los servidores Model Context
Protocol (MCP) configurados. Tú decides cuáles puede usar y qué operaciones
requieren confirmación.

## Cuándo usar agentes personalizados

Son especialmente útiles si:

- **Repites flujos de trabajo**: redactas documentación o revisas PR con frecuencia.
- **Necesitas un comportamiento especializado**: quieres seguir pautas concretas.
- **Quieres reducir interrupciones**: puedes aprobar herramientas de confianza para tareas definidas.
- **Trabajas en equipo**: compartes configuraciones y procedimientos uniformes.
- **Necesitas límites de seguridad**: quieres restringir las operaciones de un agente.

No hacen falta para todas las tareas: el agente predeterminado de Kiro sirve
para trabajo general. Si repites un tipo de trabajo o necesitas un comportamiento
distinto, considera crear uno personalizado.

## Próximos pasos

- **[Primeros pasos](./getting-started.md)**: crea tu primer agente paso a paso.
- **[Referencia de configuración](./configuration.md)**: consulta todas las opciones.
- **[Control de acceso a herramientas](./tool-access.md)**: conoce los permisos y las aprobaciones previas.
- **[Ejemplos](./examples.md)**: adapta configuraciones prácticas.

Empieza con un agente sencillo y explora después las funciones avanzadas.
