---
sidebar_position: 3
---

# Referencia de configuración

Esta página reúne las opciones de configuración de agentes personalizados de
Kiro: formato del archivo, campos disponibles y formas de adaptar el comportamiento.

## Formato del archivo de configuración

Cada agente se define en un archivo JSON independiente dentro de `~/.kiro/agents/`.

### Ubicación del archivo

```
~/.kiro/agents/<agent-name>.json
```

Por ejemplo:

- `~/.kiro/agents/docs-writer.json`
- `~/.kiro/agents/code-reviewer.json`
- `~/.kiro/agents/debugger-assistant.json`

### Estructura básica

Las configuraciones siguen esta estructura JSON:

```json
{
  "name": "agent-name",
  "description": "Breve descripción del propósito del agente",
  "prompt": "Instrucciones del sistema que definen el comportamiento del agente",
  "tools": ["read", "write", "shell"],
  "allowedTools": [],
  "mcpServers": {},
  "toolAliases": {},
  "resources": [],
  "hooks": {},
  "toolsSettings": {},
  "includeMcpJson": true,
  "model": null
}
```

## Opciones principales

### name (obligatorio)

Identificador único del agente. Es el nombre que usarás para invocarlo desde la CLI.

```json
{
  "name": "docs-writer"
}
```

**Uso**: `kiro chat --mode docs-writer "Crea documentación de la API"`

**Reglas**:

- Debe ser único entre tus agentes.
- Usa minúsculas separadas por guiones, formato kebab-case.
- Elige un nombre que describa su propósito.

### description (obligatorio)

Descripción breve de lo que hace el agente para que el equipo entienda su función rápidamente.

```json
{
  "description": "Agente especializado en redactar y mantener documentación"
}
```

**Buenas prácticas**:

- Una frase concisa.
- Describe la función principal.
- Menciona capacidades especiales o áreas de enfoque.

### prompt

Instrucciones del sistema que definen comportamiento y personalidad. Es el campo
principal para personalizar cómo trabaja el agente.

```json
{
  "prompt": "Eres especialista en documentación. Crea documentación clara y completa con ejemplos prácticos. Prioriza la precisión y la integridad."
}
```

**Buenas prácticas**:

- Define funciones y responsabilidades concretas.
- Incluye pautas para abordar las tareas.
- Indica restricciones y preferencias.
- Usa lenguaje claro y directo.
- Puedes incluir varias líneas para instrucciones detalladas.

**Ejemplo de instrucciones detalladas**:

```json
{
  "prompt": "Eres especialista en revisión de código. Tu función es:\n\n- Analizar posibles errores y problemas de seguridad\n- Comprobar los estándares de código\n- Proponer mejoras de legibilidad\n- Dar comentarios constructivos con ejemplos\n\nPuedes leer archivos, pero no modificarlos: tu función es revisar y comentar."
}
```

## Configuración de herramientas

### tools

Arreglo de categorías o herramientas concretas que el agente puede utilizar.
Controla qué acciones puede realizar.

```json
{
  "tools": ["read", "write", "shell", "grep", "glob", "thinking"]
}
```

**Categorías disponibles**:

- **read**: lectura de archivos, como readFile, readMultipleFiles y readCode.
- **write**: escritura y edición, como fsWrite, fsAppend, strReplace y editCode.
- **shell**: comandos, como executeBash y controlBashProcess.
- **grep**: búsqueda de texto con grepSearch.
- **glob**: patrones de archivos con fileSearch y listDirectory.
- **thinking**: razonamiento interno y planificación.
- **report**: informes de progreso.
- **introspect**: reflexión sobre el propio enfoque.
- **knowledge**: acceso a bases de conocimiento.
- **todo**: gestión de tareas.
- **delegate**: delegación a subagentes.
- **aws**: operaciones específicas de AWS.

**Buenas prácticas**:

- Incluye únicamente las herramientas necesarias.
- Usa conjuntos mínimos para agentes especializados.
- Considera las implicaciones de permitir escritura y comandos.
- Empieza con lectura y amplía según las necesidades.

**Ejemplo de agente de solo lectura**:

```json
{
  "tools": ["read", "grep", "glob", "thinking", "report"]
}
```

**Ejemplo de agente con acceso completo**:

```json
{
  "tools": ["read", "write", "shell", "grep", "glob", "thinking", "report"]
}
```

### allowedTools

Nombres de herramientas aprobadas de antemano para usarlas sin confirmación.
Permite automatizar y reducir interrupciones.

```json
{
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch", "fsWrite"]
}
```

**Cuándo usar la aprobación previa**:

- Automatización de trabajo repetitivo.
- Operaciones de confianza que no necesitan confirmación.
- Reducción de interrupciones en operaciones seguras.
- Agentes especializados con permisos concretos.

**Consideraciones de seguridad**:

- Aprueba únicamente herramientas en las que confíes.
- Ten cuidado con escritura y comandos.
- Considera el alcance de las operaciones.
- Revisa el comportamiento antes de aprobar herramientas.
- Empieza con un arreglo vacío y amplía gradualmente.

**Ejemplo de aprobaciones de bajo riesgo**:

```json
{
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch", "listDirectory"]
}
```

### toolAliases

Nombres personalizados de herramientas. Esta opción avanzada permite crear
alias o renombrar herramientas para el agente.

```json
{
  "toolAliases": {}
}
```

La mayoría de los usuarios puede dejar este objeto vacío.

### toolsSettings

Opciones específicas de cada herramienta para personalizar su comportamiento.
Es una función avanzada.

```json
{
  "toolsSettings": {}
}
```

La mayoría de los usuarios puede dejar este objeto vacío.

## Integración con MCP

### mcpServers

Configura servidores Model Context Protocol (MCP) que amplían las capacidades
mediante herramientas externas.

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb"
      }
    }
  }
}
```

**Estructura de un servidor MCP**:

- **command**: comando para iniciar el servidor.
- **args**: arreglo de argumentos de línea de comandos.
- **env**: variables de entorno del servidor.

**Uso de herramientas MCP**:

Después de configurar el servidor, referencia sus herramientas en `tools`:

```json
{
  "tools": ["read", "write", "@database/query", "@database/schema"]
}
```

**Formatos**:

- `@server_name/tool_name`: una herramienta concreta del servidor.
- `@server_name`: todas las herramientas del servidor.

**Ejemplo de agente de base de datos con MCP**:

```json
{
  "name": "database-admin",
  "description": "Agente de administración de bases de datos con capacidades SQL",
  "prompt": "Eres administrador de bases de datos. Ayuda con consultas, diseño de esquemas y optimización.",
  "tools": ["read", "thinking", "@database"],
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/mydb"
      }
    }
  }
}
```

### includeMcpJson

Indica si se incluyen los servidores de la configuración MCP global.

```json
{
  "includeMcpJson": true
}
```

**Valores**:

- `true`: incluye los servidores globales; es el valor predeterminado.
- `false`: usa únicamente los definidos en este agente.

## Configuración avanzada

### resources

Recursos adicionales a los que puede acceder el agente.

```json
{
  "resources": []
}
```

La mayoría de los usuarios puede dejar este arreglo vacío.

### hooks

Acciones asociadas a eventos para automatización. Permiten iniciar operaciones
cuando ocurren determinados eventos.

```json
{
  "hooks": {}
}
```

La mayoría de los usuarios puede dejar este objeto vacío.

### model

Modelo de IA concreto para el agente. Usa `null` para utilizar el predeterminado.

```json
{
  "model": null
}
```

**Cuándo indicar un modelo**:

- Probar modelos diferentes para tareas concretas.
- Usar uno más rápido en operaciones sencillas.
- Usar uno más capaz para razonamiento complejo.

**Ejemplo**:

```json
{
  "model": "claude-3-5-sonnet-20241022"
}
```

## Ejemplos de configuración

### Ejemplo 1: redactor de documentación

Agente especializado en crear y mantener documentación.

```json
{
  "name": "docs-writer",
  "description": "Agente especializado en redactar y mantener documentación clara y completa",
  "prompt": "Eres especialista en documentación. Tu objetivo es crear documentación clara, completa y bien estructurada. Al redactar:\n\n- Usa lenguaje claro y conciso para el público destinatario\n- Organiza el contenido con títulos y estructura adecuados\n- Incluye ejemplos prácticos y fragmentos de código cuando corresponda\n- Sigue las buenas prácticas y guías de estilo\n- Mantén coherencia en terminología y formato\n- Enlaza secciones relacionadas\n- Prioriza la precisión y la integridad\n\nDispones de herramientas de lectura y escritura para crear y actualizar documentación.",
  "mcpServers": {},
  "tools": ["read", "write", "grep", "glob", "thinking"],
  "toolAliases": {},
  "allowedTools": [],
  "resources": [],
  "hooks": {},
  "toolsSettings": {},
  "includeMcpJson": true,
  "model": null
}
```

**Características principales**:

- Herramientas limitadas al trabajo de documentación.
- Instrucciones que enfatizan las buenas prácticas.
- Sin herramientas aprobadas de antemano; requiere confirmación.

**Uso**:

```bash
kiro chat --mode docs-writer "Añade documentación de los puntos de acceso de autenticación de usuarios"
```

### Ejemplo 2: revisor de código

Agente especializado en revisar código sin modificarlo.

```json
{
  "name": "code-reviewer",
  "description": "Agente especializado en revisar calidad de código, buenas prácticas y posibles problemas",
  "prompt": "Eres especialista en revisión de código. Tu función es:\n\n- Analizar errores y problemas de seguridad y rendimiento\n- Comprobar los estándares y buenas prácticas\n- Proponer mejoras de legibilidad y mantenimiento\n- Identificar indicios de problemas y antipatrones\n- Dar comentarios constructivos con ejemplos concretos\n- Verificar el manejo de errores y los casos límite\n\nPuedes leer archivos, pero no modificarlos directamente: tu función es revisar y comentar.",
  "mcpServers": {},
  "tools": ["read", "grep", "glob", "thinking", "report"],
  "toolAliases": {},
  "allowedTools": [],
  "resources": [],
  "hooks": {},
  "toolsSettings": {},
  "includeMcpJson": true,
  "model": null
}
```

**Características principales**:

- Acceso de solo lectura para revisar con seguridad.
- Instrucciones centradas en calidad de código.
- Herramienta report para comentarios estructurados.

**Uso**:

```bash
kiro chat --mode code-reviewer "Revisa el módulo de autenticación para detectar problemas de seguridad"
```

### Ejemplo 3: configuración mínima

Una configuración sencilla de agente personalizado.

```json
{
  "name": "simple-assistant",
  "description": "Asistente sencillo de uso general",
  "prompt": "Eres un asistente que ayuda al usuario.",
  "tools": ["read", "write", "thinking"],
  "allowedTools": [],
  "mcpServers": {},
  "toolAliases": {},
  "resources": [],
  "hooks": {},
  "toolsSettings": {},
  "includeMcpJson": true,
  "model": null
}
```

### Ejemplo 4: agente con herramientas aprobadas

Agente con operaciones de lectura automatizadas.

```json
{
  "name": "auto-reader",
  "description": "Agente con operaciones de lectura aprobadas de antemano",
  "prompt": "Eres un asistente de análisis de código. Lee y analiza archivos para aportar información útil.",
  "tools": ["read", "grep", "glob", "thinking"],
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch", "listDirectory"],
  "mcpServers": {},
  "toolAliases": {},
  "resources": [],
  "hooks": {},
  "toolsSettings": {},
  "includeMcpJson": true,
  "model": null
}
```

## Validación de la configuración

### Cómo validar el archivo

Antes de usar un agente, comprueba su configuración.

**1. Revisa la sintaxis JSON**:

```bash
cat ~/.kiro/agents/your-agent.json | jq .
```

Si es válida, aparecerá el JSON con formato. Si hay errores, `jq` los indicará.

**2. Verifica la ubicación**:

```bash
ls -la ~/.kiro/agents/
```

Comprueba que el archivo `.json` esté en el directorio correcto.

**3. Prueba el agente**:

```bash
kiro chat --mode your-agent "Hola, ¿puedes presentarte?"
```

### Errores habituales

**Sintaxis JSON no válida**:

```json
{
  "name": "my-agent",
  "tools": ["read", "write"] // ❌ Los comentarios no son válidos en JSON
}
```

**Campos obligatorios ausentes**:

```json
{
  "description": "Mi agente" // ❌ Falta el campo "name"
}
```

**Nombres de herramientas no válidos**:

```json
{
  "tools": ["read", "invalid-tool"] // ❌ "invalid-tool" no existe
}
```

**Formato MCP incorrecto**:

```json
{
  "mcpServers": {
    "database": "npx @modelcontextprotocol/server-postgres" // ❌ Debe ser un objeto
  }
}
```

### Solución de problemas

**No se encuentra el agente**:

- Verifica la ubicación `~/.kiro/agents/`.
- Comprueba la extensión `.json`.
- Confirma que el nombre del archivo coincida con el del agente.

**Errores de herramientas**:

- Revisa los nombres del arreglo `tools`.
- Comprueba la escritura de las categorías.
- Usa el formato `@server_name` en referencias MCP.

**Errores del servidor MCP**:

- Revisa el comando del servidor.
- Comprueba que estén instaladas sus dependencias.
- Verifica las variables de entorno.

## Próximos pasos

- Aprende a gestionar permisos en [Control de acceso a herramientas](./tool-access.md).
- Consulta [Ejemplos prácticos](./examples.md).
- Crea agentes propios para tus flujos de trabajo.
