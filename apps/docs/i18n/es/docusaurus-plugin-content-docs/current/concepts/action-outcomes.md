---
sidebar_position: 3
---

# Acciones y resultados

La «A» y la «O» de TLÁO representan **Action & Outcomes**, acciones y resultados:
los efectos concretos y medibles que produce TLÁO. Conocer sus salidas ayuda a entender su valor.

## ¿Qué es una acción?

Una **acción** es una tarea específica y ejecutable con parámetros claros.

### Propiedades principales de una acción

Toda acción incluye:

1. **Descripción de la tarea**: qué debe hacerse.
2. **Responsable**: quién se encarga.
3. **Fecha límite**: cuándo debe completarse.
4. **Prioridad**: qué urgencia o importancia tiene.
5. **Dependencias**: qué debe ocurrir primero.
6. **Contexto**: por qué importa y cuáles son sus antecedentes.

### Ejemplo de acción

```json
{
  "task": "Redactar la descripción de la propuesta de financiación",
  "owner": "Sarah Chen",
  "deadline": "2024-03-15",
  "priority": "high",
  "dependencies": ["Aprobación del presupuesto", "Cronograma finalizado"],
  "context": "La convocatoria NSF cierra el 20 de marzo. La descripción debe coincidir con el presupuesto aprobado.",
  "estimatedHours": 8,
  "tags": ["grant", "writing", "deadline-critical"]
}
```

## ¿Qué es un resultado?

Un **resultado** es el efecto de completar una acción: un cambio de estado medible.

### Tipos de resultados

1. **Entregable creado**: documento, código, diseño, etc.
2. **Decisión tomada**: aprobación, opción seleccionada o dirección elegida.
3. **Información recopilada**: investigación, datos o requisitos aclarados.
4. **Comunicación realizada**: correo enviado, reunión celebrada o novedad publicada.
5. **Sistema actualizado**: incidencia creada, evento añadido o estado modificado.

### Ejemplo de resultado

```json
{
  "action_id": "draft-grant-narrative",
  "status": "completed",
  "completedDate": "2024-03-14",
  "completedBy": "Sarah Chen",
  "deliverable": {
    "type": "document",
    "location": "docs/grants/nsf-2024-narrative.pdf",
    "wordCount": 3500
  },
  "notes": "Descripción completada y revisada por el investigador principal. Lista para presentar.",
  "nextActions": ["Presentar la solicitud", "Avisar al equipo de finanzas"]
}
```

## El ciclo de acciones y resultados

TLÁO administra todo el ciclo:

```text
Entrada no estructurada
         │
         ▼
Procesamiento de TLÁO
         │
         ▼
Acciones estructuradas
         │
         ├─→ Tarea 1 → Resultado 1 → Nuevas acciones
         ├─→ Tarea 2 → Resultado 2 → Nuevas acciones
         └─→ Tarea 3 → Resultado 3 → Nuevas acciones
```

Cada resultado puede iniciar nuevas acciones y mantener un flujo continuo de información a ejecución.

## Ejemplos prácticos

### Ejemplo 1: de un correo a acciones

**Entrada**: correo sobre una próxima conferencia.

**Acciones generadas**:

- Presentar una propuesta de ponencia: en dos semanas.
- Reservar transporte y alojamiento: en una semana.
- Preparar las diapositivas: un día antes.
- Informar al equipo de las fechas de ausencia: esta semana.

**Resultados registrados**:

- ✅ Propuesta presentada: 1 de marzo.
- ✅ Vuelos reservados: 3 de marzo.
- ⏳ Diapositivas en preparación: vencen el 14 de marzo.
- ✅ Equipo informado: 2 de marzo.

### Ejemplo 2: de un PDF de financiación a acciones

**Entrada**: PDF de 50 páginas de una convocatoria.

**Acciones generadas**:

- Verificar elegibilidad: investigador principal, hoy.
- Recopilar documentos: administración, en tres días.
- Preparar presupuesto: finanzas, en una semana.
- Redactar la descripción del proyecto: responsable de investigación, en diez días.
- Obtener aprobación institucional: investigador principal, en doce días.
- Presentar la solicitud: administración, en catorce días.

**Resultados registrados**:

- ✅ Elegibilidad confirmada para 500 000 dólares.
- ✅ Documentos recopilados: currículos, cartas y certificaciones.
- ✅ Presupuesto preparado: 487 000 dólares en total.
- ⏳ Descripción al 60 %.
- ⏳ Aprobación pendiente del comité de revisión.
- ⏳ Presentación pendiente de aprobación.

### Ejemplo 3: de notas de reunión a acciones

**Entrada**: transcripción de una reunión de planificación.

**Acciones generadas**:

- Actualizar el cronograma en Notion: responsable de proyecto, hoy.
- Crear tareas de diseño: responsable de diseño, mañana.
- Programar revisión de arquitectura: responsable técnico, esta semana.
- Documentar decisiones técnicas: responsable técnico, en dos días.
- Enviar el resumen a las partes interesadas: responsable de proyecto, hoy.

**Resultados registrados**:

- ✅ Cronograma actualizado con tres hitos nuevos.
- ✅ Ocho tareas de diseño creadas y asignadas.
- ✅ Revisión programada para el 10 de marzo a las 14:00.
- ✅ Decisiones documentadas en la wiki.
- ✅ Resumen enviado a doce personas.

## Propiedades de las acciones en detalle

### Descripción de la tarea

Debe ser clara, específica y ejecutable:

- ❌ «Trabajar en la financiación»: vago.
- ✅ «Redactar el resumen de dos páginas del proyecto para la convocatoria NSF»: específico.

### Responsable

Indica quién se encarga:

- Una persona: «Sarah Chen».
- Un rol: «Responsable de proyecto».
- Un equipo: «Equipo de diseño».
- Sin asignar: «Por determinar», aunque conviene asignarlo pronto.

### Fecha límite

Indica cuándo debe estar listo:

- Absoluta: «2024-03-15».
- Relativa: «Dentro de tres días».
- Contextual: «Antes del cierre de la convocatoria».
- Flexible: «Al final de la semana; no es crítico».

### Prioridad

Expresa urgencia e importancia:

- **Crítica**: bloquea otro trabajo o tiene un vencimiento inminente.
- **Alta**: importante, con un plazo cercano.
- **Media**: debe hacerse pronto.
- **Baja**: deseable, con un plazo flexible.

### Dependencias

Indican qué debe ocurrir primero:

- Otras acciones: «Requiere aprobación del presupuesto».
- Eventos externos: «Después de la reunión con el cliente».
- Información: «Cuando se aclaren los requisitos».
- Recursos: «Cuando esté disponible la persona de diseño».

### Contexto

Explica por qué importa:

- Antecedentes.
- Documentos o enlaces relacionados.
- Conversaciones relevantes.
- Importancia estratégica.
- Riesgos o restricciones.

## Propiedades de los resultados en detalle

### Estado

Situación actual:

- **Sin iniciar**: la acción existe, pero no ha comenzado.
- **En curso**: el trabajo ha empezado.
- **Bloqueada**: espera una dependencia.
- **Completada**: terminó correctamente.
- **Cancelada**: ya no es necesaria.

### Entregable

Indica qué se produjo:

- Documento con su ubicación.
- Código con enlace al repositorio.
- Decisión con su justificación.
- Comunicación con sus destinatarios.
- Actualización de un sistema con sus detalles.

### Próximas acciones

Indican qué sigue:

- Tareas de seguimiento.
- Acciones dependientes que ya pueden empezar.
- Información nueva que da lugar a más acciones.

## Integración con sistemas de ejecución

Las acciones de TLÁO se corresponden directamente con los sistemas de ejecución.

### GitHub Issues

```text
Acción → Incidencia de GitHub
- Tarea → Título
- Contexto → Descripción
- Responsable → Persona asignada
- Fecha límite → Hito
- Prioridad → Etiquetas
- Dependencias → Incidencias vinculadas
```

### Eventos de calendario

```text
Acción → Evento de calendario
- Tarea → Título del evento
- Fecha límite → Fecha y hora
- Responsable → Asistentes
- Contexto → Descripción
- Dependencias → Requisitos previos en las notas
```

### Tareas de Notion o Jira

```text
Acción → Tarea de Notion o Jira
- Tarea → Nombre
- Responsable → Persona asignada
- Fecha límite → Vencimiento
- Prioridad → Campo de prioridad
- Dependencias → Relaciones
- Contexto → Descripción
- Etiquetas → Etiquetas
```

## Por qué importan las acciones y los resultados

### Para las personas

- **Claridad**: saber qué hacer a continuación.
- **Contexto**: entender por qué importa.
- **Seguimiento**: ver el progreso y lo completado.
- **Priorización**: centrarse en lo importante.

### Para los equipos

- **Coordinación**: todos saben quién hace qué.
- **Dependencias**: queda claro qué bloquea cada tarea.
- **Responsabilidad**: la asignación es explícita.
- **Visibilidad**: el progreso es transparente.

### Para las organizaciones

- **Ejecución**: la estrategia se convierte en acciones.
- **Trazabilidad**: historial completo de decisiones y trabajo.
- **Aprendizaje**: los resultados revelan patrones.
- **Optimización**: identificar cuellos de botella e ineficiencias.

## Próximos pasos

- Vuelve a [Conceptos básicos](/) para explorar otras ideas fundamentales.
- Lee [¿Por qué «capa»?](why-layer) para entender la posición de TLÁO en tu flujo de trabajo.
- Explora [¿Por qué «táctica»?](why-tactical) para entender el horizonte temporal.
