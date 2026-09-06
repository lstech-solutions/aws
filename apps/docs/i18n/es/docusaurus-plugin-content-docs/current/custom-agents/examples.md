---
sidebar_position: 5
---

# Ejemplos de agentes personalizados

Estas configuraciones completas sirven como punto de partida para tus agentes.
Cada ejemplo incluye la configuración, sus opciones principales y las ventajas del enfoque.

## Ejemplo 1: agente de infraestructura AWS

Agente especializado en administrar infraestructura AWS con herramientas
aprobadas y restricciones para operaciones destructivas.

### Caso de uso

Pensado para profesionales de DevOps que administran recursos AWS habitualmente.
Accede a herramientas de AWS y limita operaciones destructivas para evitar
eliminar recursos por accidente.

### Configuración

```json
{
  "name": "aws-infrastructure-agent",
  "description": "Agente especializado en infraestructura AWS con acceso a herramientas centrado en la seguridad",
  "prompt": "Eres especialista en infraestructura AWS. Tu función es:\n\n- Ayudar a diseñar e implementar arquitecturas de nube en AWS\n- Ayudar con infraestructura como código: Terraform y CloudFormation\n- Optimizar el uso y coste de recursos AWS\n- Aplicar buenas prácticas de seguridad\n- Investigar problemas de infraestructura y proponer soluciones\n\nDispones de herramientas AWS para leer, analizar y administrar infraestructura. Puedes ejecutar comandos de AWS CLI. Verifica siempre las operaciones destructivas antes de continuar y explica el impacto de los cambios.",
  "mcpServers": {
    "aws": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-aws"],
      "env": {}
    }
  },
  "tools": ["read", "write", "shell", "grep", "glob", "thinking", "report", "aws"],
  "toolAliases": {},
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch", "listDirectory", "executeBash"],
  "resources": [],
  "hooks": {},
  "toolsSettings": {
    "shell": {
      "confirmBeforeExecution": true
    }
  },
  "includeMcpJson": true,
  "model": null
}
```

### Opciones principales

- **Lectura aprobada**: permite leer archivos y realizar consultas mediante comandos sin confirmación.
- **Servidor MCP de AWS**: amplía las capacidades de gestión de nube.
- **Confirmación de comandos**: solicita confirmación para comandos destructivos.
- **Herramientas AWS**: acceso a operaciones específicas de infraestructura.

### Ventajas para el flujo de trabajo

- **Menos interrupciones**: automatiza la lectura y acelera el análisis.
- **Seguridad**: requiere confirmación explícita para operaciones destructivas.
- **Integración AWS**: el servidor MCP añade capacidades específicas.
- **Pautas claras**: las instrucciones definen el papel de especialista en infraestructura.

### Uso

```bash
kiro chat --mode aws-infrastructure-agent "Enumera las instancias EC2 de la VPC predeterminada y su estado"
kiro chat --mode aws-infrastructure-agent "Revisa esta configuración de Terraform para detectar problemas de seguridad"
kiro chat --mode aws-infrastructure-agent "Propón formas de optimizar el coste de nuestras instancias RDS"
```

## Ejemplo 2: revisor de código

Agente de solo lectura centrado en analizar la calidad del código sin modificarlo.

### Caso de uso

Para desarrolladores que necesitan revisiones automáticas sin modificaciones
accidentales. Sirve para revisar PR, auditar seguridad y evaluar calidad.

### Configuración

```json
{
  "name": "code-reviewer",
  "description": "Agente especializado en revisar calidad de código, buenas prácticas y posibles problemas",
  "prompt": "Eres especialista en revisión de código. Tu función es:\n\n- Analizar errores y problemas de seguridad y rendimiento\n- Comprobar los estándares y buenas prácticas\n- Proponer mejoras de legibilidad y mantenimiento\n- Identificar indicios de problemas y antipatrones\n- Dar comentarios constructivos con ejemplos concretos\n- Verificar el manejo de errores y los casos límite\n- Evaluar la complejidad y proponer simplificaciones\n\nPuedes leer archivos, pero no modificarlos directamente: tu función es revisar y comentar. Explica siempre tu razonamiento y ofrece sugerencias que puedan aplicarse.",
  "mcpServers": {},
  "tools": ["read", "grep", "glob", "thinking", "report"],
  "toolAliases": {},
  "allowedTools": [
    "readFile",
    "readMultipleFiles",
    "readCode",
    "grepSearch",
    "fileSearch",
    "listDirectory"
  ],
  "resources": [],
  "hooks": {},
  "toolsSettings": {},
  "includeMcpJson": true,
  "model": null
}
```

### Opciones principales

- **Solo lectura**: sin herramientas de escritura ni comandos.
- **Lectura aprobada**: automatiza la consulta de archivos para revisar con eficiencia.
- **Herramienta report**: genera comentarios estructurados.
- **Herramientas específicas**: incluye solo lo necesario para analizar código.

### Ventajas para el flujo de trabajo

- **Sin modificaciones accidentales**: no dispone de herramientas para editar código.
- **Revisiones eficientes**: automatiza lectura y búsqueda.
- **Análisis completo**: consulta varios archivos y busca en todo el código.
- **Comentarios organizados**: report facilita una salida estructurada.

### Uso

```bash
kiro chat --mode code-reviewer "Revisa el módulo de autenticación para detectar vulnerabilidades"
kiro chat --mode code-reviewer "Revisa este PR para detectar problemas de calidad y de buenas prácticas"
kiro chat --mode code-reviewer "Analiza el manejo de errores en el código de procesamiento de pagos"
```

## Ejemplo 3: agente de depuración

Agente con acceso completo para encontrar y corregir problemas del código.

### Caso de uso

Para desarrolladores que necesitan ayuda para depurar. Puede leer, escribir y
ejecutar comandos para reproducir errores y corregirlos.

### Configuración

```json
{
  "name": "debugger-assistant",
  "description": "Agente especializado en identificar y corregir problemas del código",
  "prompt": "Eres especialista en depuración. Tu función es:\n\n- Analizar mensajes de error y trazas para identificar causas\n- Ayudar a reproducir problemas con casos mínimos\n- Proponer estrategias de depuración\n- Identificar correcciones y alternativas\n- Explicar con claridad los escenarios complejos\n- Usar registros y herramientas de diagnóstico eficazmente\n- Verificar las correcciones mediante pruebas y comprobaciones\n\nTienes acceso completo para leer y escribir código, ejecutar comandos de prueba y usar herramientas de depuración. Explica tu enfoque y verifica las correcciones antes de considerarlas terminadas.",
  "mcpServers": {},
  "tools": ["read", "write", "shell", "grep", "glob", "thinking", "report", "introspect"],
  "toolAliases": {},
  "allowedTools": [],
  "resources": [],
  "hooks": {},
  "toolsSettings": {
    "write": {
      "confirmBeforeExecution": true
    },
    "shell": {
      "confirmBeforeExecution": true
    }
  },
  "includeMcpJson": true,
  "model": null
}
```

### Opciones principales

- **Acceso completo**: lectura, escritura, comandos e introspección.
- **Confirmación de operaciones destructivas**: escritura y comandos requieren confirmación.
- **Herramienta introspect**: permite reflexionar durante depuraciones complejas.
- **Sin aprobaciones previas**: las operaciones requieren confirmación por seguridad.

### Ventajas para el flujo de trabajo

- **Depuración completa**: acceso a las herramientas necesarias.
- **Controles de seguridad**: confirmación para operaciones destructivas.
- **Reflexión**: introspect ayuda en escenarios complejos.
- **Comunicación clara**: las instrucciones establecen cómo explicar la depuración.

### Uso

```bash
kiro chat --mode debugger-assistant "La función de acceso falla con un error de puntero nulo"
kiro chat --mode debugger-assistant "Ayúdame a investigar por qué la API devuelve errores 500 de forma intermitente"
kiro chat --mode debugger-assistant "Encuentra y corrige la fuga de memoria de este servicio"
```

## Más ideas de agentes

### Redactor de documentación

Agente centrado en crear y mantener documentación con lectura y escritura.

```json
{
  "name": "docs-writer",
  "description": "Agente especializado en redactar y mantener documentación",
  "prompt": "Eres especialista en documentación. Crea documentación clara y completa.",
  "tools": ["read", "write", "grep", "glob", "thinking"],
  "allowedTools": ["readFile", "fsWrite", "grepSearch"]
}
```

### Agente de pruebas de API

Especializado en probar API, con comandos para usar curl.

```json
{
  "name": "api-tester",
  "description": "Agente especializado en pruebas y validación de API",
  "prompt": "Eres especialista en pruebas de API. Prueba los puntos de acceso y valida sus respuestas.",
  "tools": ["read", "shell", "grep", "thinking"],
  "allowedTools": ["readFile", "executeBash"]
}
```

### Agente de base de datos

Integración MCP para operaciones de base de datos.

```json
{
  "name": "database-admin",
  "description": "Agente especializado en administración de bases de datos",
  "prompt": "Eres administrador de bases de datos. Ayuda con consultas y diseño de esquemas.",
  "tools": ["read", "shell", "thinking", "@database"],
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"]
    }
  }
}
```

## Adapta los ejemplos

Puedes ajustar estas configuraciones a tus necesidades.

### Ajusta el acceso a herramientas

Modifica `tools` para incluir o excluir categorías:

```json
{
  "tools": ["read", "write", "shell"]  // Acceso completo
  "tools": ["read", "grep"]             // Solo lectura con búsqueda
  "tools": ["read", "write"]            // Sin acceso a comandos
}
```

### Añade aprobaciones previas

Incluye herramientas concretas en `allowedTools` para automatizar operaciones de confianza:

```json
{
  "allowedTools": ["readFile", "readMultipleFiles", "grepSearch"]
}
```

### Configura servidores MCP

Añade servidores para ampliar las capacidades:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    }
  }
}
```

## Próximos pasos

- [Crea tu agente](./getting-started.md) a partir de estos patrones.
- [Explora la configuración](./configuration.md) en detalle.
- [Aprende a controlar el acceso a herramientas](./tool-access.md).

Cada ejemplo muestra un enfoque distinto. Elige el más cercano a tus necesidades
y adáptalo a tu caso de uso.
