---
sidebar_position: 4
---

# Control de acceso a herramientas

El control de acceso permite definir con precisión qué acciones puede realizar
un agente. Así puedes crear agentes especializados y capaces, adaptados a sus
flujos de trabajo y con los límites de seguridad adecuados.

## Descripción general

Cada agente dispone de herramientas para interactuar con tu código, ejecutar
comandos y realizar operaciones. El control de acceso permite:

- **Restringir capacidades** a lo necesario para su propósito.
- **Aprobar herramientas de confianza** para automatizar y reducir interrupciones.
- **Integrar herramientas externas** mediante servidores Model Context Protocol (MCP).
- **Mantener la seguridad** limitando las operaciones sensibles.

## Herramientas integradas de Kiro

Las herramientas se organizan por categorías. Puedes incluir categorías completas
o herramientas concretas en la configuración.

### Categorías de herramientas

**read**: lectura de archivos y análisis de código.

- Leer archivos con intervalos de líneas opcionales.
- Leer varios archivos a la vez.
- Analizar la estructura del código.
- Buscar en el contenido de archivos.

**write**: creación y modificación de archivos.

- Crear archivos.
- Añadir contenido a archivos existentes.
- Sustituir texto.
- Editar código mediante operaciones basadas en AST.
- Renombrar símbolos en el código.
- Mover y renombrar archivos actualizando las importaciones.

**shell**: ejecución de comandos.

- Ejecutar comandos bash.
- Iniciar y administrar procesos en segundo plano.
- Controlar servicios de larga duración.
- Leer la salida de procesos.

**grep**: búsqueda de texto.

- Búsqueda rápida con expresiones regulares.
- Búsqueda sensible o insensible a mayúsculas.
- Inclusión o exclusión por patrones de archivo.
- Contexto alrededor de las coincidencias.

**glob**: búsqueda de archivos.

- Búsqueda aproximada por ruta.
- Listado de directorios.
- Recorrido recursivo de directorios.
- Coincidencias mediante patrones.

**thinking**: razonamiento interno.

- Resolución estructurada de problemas.
- Planificación y desarrollo de estrategias.
- Reflexión sobre el enfoque.

**report**: comunicación del progreso.

- Informes de tareas largas.
- Actualizaciones de estado.
- Comentarios estructurados.

**introspect**: análisis propio.

- Análisis de capacidades.
- Reflexión sobre decisiones.
- Evaluación de la eficacia del enfoque.

**knowledge**: acceso a información.

- Consulta de documentación y bases de conocimiento.
- Recuperación de información contextual.
- Consulta de conocimiento almacenado.

**todo**: gestión de tareas.

- Crear y administrar listas de tareas.
- Seguir operaciones de varios pasos.
- Organizar trabajo pendiente.

**delegate**: coordinación de subagentes.

- Invocar subagentes especializados.
- Delegar subtareas complejas.
- Coordinar flujos con varios agentes.

**aws**: operaciones de AWS, si están configuradas.

- Interacción con servicios de AWS.
- Gestión de infraestructura.
- Operaciones sobre recursos de nube.

### Configura el acceso

Indica las categorías disponibles en la configuración:

```json
{
  "name": "my-agent",
  "tools": ["read", "write", "grep", "thinking"]
}
```

Este ejemplo permite leer, escribir, buscar y razonar, pero no ejecutar comandos
ni usar otras categorías.

## Integración con Model Context Protocol (MCP)

Los servidores MCP añaden herramientas externas: bases de datos, integraciones
con API, análisis especializado y otras capacidades.

### Añade servidores MCP

Configúralos en el campo `mcpServers`:

```json
{
  "name": "database-agent",
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb"
      }
    }
  },
  "tools": ["read", "@database"]
}
```

### Sintaxis de herramientas MCP

Usa estos formatos en `tools`:

- `@server_name`: todas las herramientas de un servidor.
- `@server_name/tool_name`: una herramienta concreta.

Ejemplo de herramientas concretas:

```json
{
  "tools": ["read", "write", "@database/query", "@database/schema"]
}
```

### Configuración MCP global

También puedes configurar servidores globales y reutilizarlos en varios agentes
con `includeMcpJson` en `true`:

```json
{
  "name": "my-agent",
  "includeMcpJson": true,
  "tools": ["read", "@global-server"]
}
```

Añade servidores globales desde la CLI:

```bash
kiro --add-mcp '{"name":"server-name","command":"path/to/server","args":["arg1"]}'
```

## Aprobación previa: automatizar operaciones de confianza

Permite ejecutar herramientas concretas sin confirmación del usuario. Reduce
interrupciones y automatiza operaciones de confianza.

### ¿Qué es la aprobación previa?

Por defecto, Kiro solicita confirmación cuando un agente quiere usar una
herramienta, especialmente para escribir o ejecutar comandos. La aprobación
previa elimina esa confirmación para las herramientas indicadas.

### Cuándo usarla

Resulta útil para:

- **Flujos repetitivos** en los que confías en el criterio del agente.
- **Operaciones de lectura** que no modifican el sistema.
- **Tareas bien definidas** con límites claros.
- **Procesos automáticos** que se ejecutan sin supervisión.
- **Operaciones urgentes** en las que las interrupciones tienen un coste.

### Cuándo no usarla

Evítala para:

- **Operaciones destructivas**, como eliminar archivos o modificar el sistema.
- **Agentes sin probar** que aún no han demostrado fiabilidad.
- **Permisos amplios** que pueden afectar muchos archivos.
- **Comandos** con impacto en todo el sistema.
- **Operaciones sobre archivos críticos** o sistemas de producción.

### Consideraciones de seguridad

1. **Mínimo privilegio**: aprueba solo las herramientas imprescindibles.
2. **Alcance limitado**: considera qué archivos y sistemas pueden afectar.
3. **Trazabilidad**: observa lo que hacen las herramientas aprobadas.
4. **Ampliación gradual**: empieza sin aprobaciones y añádelas al ganar confianza.
5. **Revisión periódica**: revisa y ajusta los permisos.

### Configura herramientas aprobadas

Usa el arreglo `allowedTools`:

```json
{
  "name": "docs-writer",
  "tools": ["read", "write", "grep"],
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch", "fsWrite"]
}
```

En este ejemplo, el agente puede leer y buscar sin confirmación y escribir
archivos nuevos. Otras operaciones de escritura, como `strReplace`, aún requieren confirmación.

### Ejemplos de aprobación previa

**Enfoque conservador**, solo lectura:

```json
{
  "name": "code-analyzer",
  "tools": ["read", "grep", "glob", "thinking"],
  "allowedTools": [
    "readFile",
    "readMultipleFiles",
    "readCode",
    "grepSearch",
    "fileSearch",
    "listDirectory"
  ]
}
```

**Enfoque moderado**, operaciones de escritura de confianza:

```json
{
  "name": "test-writer",
  "tools": ["read", "write", "grep"],
  "allowedTools": ["readFile", "readCode", "grepSearch", "fsWrite", "fsAppend"]
}
```

**Enfoque amplio**, automatización completa; úsalo con precaución:

```json
{
  "name": "automation-agent",
  "tools": ["read", "write", "shell", "grep"],
  "allowedTools": [
    "readFile",
    "readCode",
    "grepSearch",
    "fsWrite",
    "fsAppend",
    "strReplace",
    "editCode",
    "executeBash"
  ]
}
```

## Ejemplos de acceso a herramientas

### Ejemplo 1: redactor de documentación con permisos limitados

Agente de documentación con un conjunto limitado de herramientas aprobadas:

```json
{
  "name": "docs-writer",
  "description": "Agente especializado en redactar y mantener documentación",
  "tools": ["read", "write", "grep", "glob", "thinking"],
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch", "fileSearch"]
}
```

Puede leer y buscar sin interrupciones, pero la escritura requiere confirmación.

### Ejemplo 2: revisor de código de solo lectura

Agente que revisa sin modificar archivos:

```json
{
  "name": "code-reviewer",
  "description": "Especialista en revisión de código que analiza sin modificar",
  "tools": ["read", "grep", "glob", "thinking", "report"],
  "allowedTools": [
    "readFile",
    "readMultipleFiles",
    "readCode",
    "grepSearch",
    "fileSearch",
    "listDirectory",
    "getDiagnostics"
  ]
}
```

Las herramientas indicadas están aprobadas porque no modifican el código.

### Ejemplo 3: agente de automatización de pruebas

Creación de pruebas con aprobaciones selectivas:

```json
{
  "name": "test-automator",
  "description": "Generación y ejecución automática de pruebas",
  "tools": ["read", "write", "shell", "grep", "thinking"],
  "allowedTools": ["readFile", "readCode", "grepSearch", "fsWrite"]
}
```

Puede leer y crear archivos de prueba automáticamente; las modificaciones y
la ejecución de pruebas requieren confirmación.

### Ejemplo 4: agente de base de datos con MCP

Integración con una base de datos mediante MCP:

```json
{
  "name": "database-agent",
  "description": "Consultas y gestión de esquemas de base de datos",
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb"
      }
    }
  },
  "tools": ["read", "write", "@postgres/query", "@postgres/schema", "thinking"],
  "allowedTools": ["readFile", "@postgres/query"]
}
```

Puede leer archivos y ejecutar consultas automáticamente; los cambios de esquema
requieren confirmación.

## Buenas prácticas de seguridad

### 1. Empieza con restricciones y amplía gradualmente

Usa herramientas mínimas y ninguna aprobación previa al empezar. Añade permisos
según compruebes el comportamiento del agente.

```json
// Empieza aquí
{
  "tools": ["read", "thinking"],
  "allowedTools": []
}

// Después amplía
{
  "tools": ["read", "write", "thinking"],
  "allowedTools": ["readFile", "readCode"]
}

// Finalmente, si es necesario
{
  "tools": ["read", "write", "grep", "thinking"],
  "allowedTools": ["readFile", "readCode", "grepSearch", "fsWrite"]
}
```

### 2. Separa los agentes por nivel de riesgo

- **Riesgo alto**: sin aprobaciones previas y con confirmación completa.
- **Riesgo medio**: aprobaciones limitadas a lectura.
- **Riesgo bajo**: aprobaciones más amplias para flujos de confianza.

### 3. Usa agentes de solo lectura para analizar

Para revisión, análisis y exploración del código:

```json
{
  "tools": ["read", "grep", "glob", "thinking"],
  "allowedTools": ["readFile", "readCode", "grepSearch", "fileSearch"]
}
```

### 4. Limita el acceso a comandos

Los comandos pueden afectar todo el sistema. Inclúyelos solo cuando sean
necesarios y evita aprobarlos de antemano salvo casos justificados:

```json
{
  "tools": ["read", "write", "shell"],
  "allowedTools": [
    "readFile",
    "fsWrite"
    // Nota: no hay herramientas de comandos aprobadas de antemano
  ]
}
```

### 5. Limita el alcance de los servidores MCP

Considera con cuidado qué operaciones permite cada servidor:

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        // Usa credenciales de base de datos de solo lectura
        "DATABASE_URL": "postgresql://readonly_user@localhost/mydb"
      }
    }
  }
}
```

### 6. Realiza revisiones de seguridad periódicas

- ¿Siguen siendo necesarias todas las herramientas aprobadas?
- ¿Algún agente ha acumulado demasiados permisos?
- ¿Hay agentes que ya no se utilizan?
- ¿El uso de herramientas coincide con los casos previstos?

### 7. Guarda los agentes en control de versiones

Esto permite:

- Seguir los cambios a lo largo del tiempo.
- Revisar modificaciones antes del despliegue.
- Compartir configuraciones con el equipo.
- Revertir cambios problemáticos.

### 8. Prueba en entornos seguros

Antes de desplegar agentes con permisos amplios:

- Prueba en entornos de desarrollo aislados.
- Usa repositorios o ramas de prueba.
- Verifica el comportamiento con distintas solicitudes.
- Observa qué herramientas se utilizan realmente.

## Auditoría y registros

### Supervisa el uso de herramientas

Kiro registra las invocaciones. Revísalas para entender el comportamiento:

- ¿Qué herramientas se usan más?
- ¿Se usan correctamente las aprobadas?
- ¿Hay patrones de uso inesperados?
- ¿Qué operaciones solicitan más confirmaciones?

### Revisa la actividad del agente

Después de una sesión:

1. Verifica que las operaciones hayan sido adecuadas.
2. Identifica oportunidades de aprobación previa.
3. Detecta posibles problemas de seguridad.
4. Ajusta la configuración de acceso.

### Ajusta según el uso

Usa la auditoría para mejorar la configuración:

- Aprueba operaciones seguras que confirmas con frecuencia.
- Elimina herramientas que nunca se utilizan.
- Refuerza las restricciones si aparecen patrones preocupantes.
- Documenta la justificación de las decisiones.

## Próximos pasos

- **[Ejemplos](./examples.md)**: configuraciones completas con distintos permisos.
- **[Referencia de configuración](./configuration.md)**: todas las opciones.
- **[Primeros pasos](./getting-started.md)**: crea tu primer agente.

Busca un equilibrio entre automatización y seguridad. Empieza con permisos
limitados, prueba el comportamiento y amplía con criterio según ganes confianza.
