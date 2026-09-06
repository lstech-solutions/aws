---
sidebar_position: 1
---

# ¿Por qué «capa»?

TLÁO se denomina **capa** porque se sitúa entre dos mundos muy diferentes:
la realidad desordenada y no estructurada de la información que recibimos y
el mundo preciso y estructurado de los sistemas de ejecución.

## El problema: dos mundos incompatibles

### Información no estructurada

La información real llega en muchos formatos:

- **Correos**: solicitudes dentro de hilos de conversación.
- **PDF**: solicitudes de financiación, facturas y contratos.
- **Notas de reuniones**: tareas y decisiones dispersas.
- **Transcripciones**: conversaciones grabadas con tareas implícitas.
- **Páginas web**: oportunidades de financiación, requisitos y fechas límite.
- **Facturas**: solicitudes de pago con formatos distintos.
- **Mensajes de Slack o Teams**: peticiones breves y novedades.

Cada fuente tiene su propia estructura, o carece de ella, además de terminología
y contexto propios. No existe un formato estándar, campos uniformes ni un esquema común.

### Sistemas de ejecución

Los sistemas que ejecutan el trabajo requieren datos precisos y estructurados:

- **GitHub Issues**: título, descripción, etiquetas, responsables e hitos.
- **Calendarios**: nombre del evento, hora, ubicación y asistentes.
- **Notion o Jira**: tareas con campos, estados y relaciones.
- **Documentos de propuestas**: secciones con formato y requisitos concretos.
- **Hojas de presupuesto**: partidas, importes y categorías.
- **Sistemas de despliegue**: archivos de configuración, variables de entorno y comandos.

Estos sistemas no pueden consumir directamente información no estructurada.
Necesitan datos claros y organizados.

## La solución: una capa táctica

TLÁO actúa como una **capa de intermediación** que conecta ambos mundos:

```text
Información no estructurada
(correos, PDF, notas, transcripciones)
                │
                ▼
           CAPA TLÁO
  • Recepción unificada
  • Extracción estructurada
  • Razonamiento táctico
  • Interfaz de acciones
  • Orquestación
                │
                ▼
       Sistemas de ejecución
(GitHub, calendarios, Notion, etc.)
```

## ¿Qué la convierte en una capa?

Una capa de arquitectura de software tiene características concretas:

1. **Abstracción**: oculta la complejidad a ambos lados.
2. **Traducción**: convierte entre formatos y protocolos.
3. **Independencia**: puede añadirse o quitarse sin cambiar los sistemas superiores o inferiores.
4. **Estandarización**: ofrece una interfaz uniforme sin importar la variedad de entradas o salidas.

TLÁO cumple estas funciones:

- **Abstrae** el desorden de las entradas no estructuradas.
- **Traduce** entre lenguaje natural y datos estructurados.
- **Opera de forma independiente** de las fuentes y los sistemas de ejecución concretos.
- **Estandariza** el paso de la información a la acción.

## Las subcapas

TLÁO organiza la transformación en una capa base y cinco capas funcionales:

1. **Capa 0: identidad y espacio de trabajo**: quién y dónde.
2. **Capa 1: recepción**: entrada unificada de información heterogénea.
3. **Capa 2: comprensión**: extracción estructurada.
4. **Capa 3: razonamiento táctico**: planificación y decisiones.
5. **Capa 4: interfaz de acciones**: convierte las salidas en acciones reales.
6. **Capa 5: orquestación**: administra ejecuciones, registros e historial.

## Por qué importa

Sin una capa táctica, tienes que:

- **Convertir manualmente** cada correo en una tarea.
- **Copiar y pegar** información entre sistemas.
- **Recordar** qué debe ocurrir después.
- **Seguir el progreso** en herramientas desconectadas.
- **Perder contexto** al trasladar información entre sistemas.

Con TLÁO, la capa se encarga automáticamente de esa transformación para que
puedas concentrarte en el trabajo y no en traducir información entre sistemas.

## Próximos pasos

- Lee [¿Por qué «táctica»?](why-tactical) para entender el horizonte temporal.
- Explora [Acciones y resultados](action-outcomes) para conocer qué produce TLÁO.
