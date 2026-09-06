---
sidebar_position: 2
---

# Primeros pasos con agentes personalizados

Esta guía te acompaña en la creación de tu primer agente personalizado de Kiro.
Al terminar tendrás un agente funcional adaptado a tu flujo de trabajo.

## Requisitos previos

Antes de empezar, necesitas:

- **Kiro CLI instalado**: los agentes se configuran e invocan desde la línea de comandos.
- **Conocimientos básicos de JSON**: es el formato de las configuraciones.
- **Un editor de texto**: cualquiera que permita crear archivos de configuración.

## Crea tu primer agente

### Paso 1: crea el directorio de agentes

Las configuraciones se guardan en `~/.kiro/agents/`. Crea el directorio si no existe:

```bash
mkdir -p ~/.kiro/agents
```

### Paso 2: crea un archivo de configuración

Crea un archivo JSON cuyo nombre coincida con el del agente. Por ejemplo, para un redactor de documentación:

```bash
touch ~/.kiro/agents/docs-writer.json
```

### Paso 3: define la configuración básica

Abre el archivo en tu editor y añade esta estructura:

```json
{
  "name": "docs-writer",
  "description": "Agente especializado en redactar y mantener documentación",
  "prompt": "Eres especialista en crear documentación clara y completa.",
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

Los campos principales son:

- **name**: identificador para invocar el agente; debe coincidir con el nombre del archivo sin `.json`.
- **description**: explicación breve de su función.
- **prompt**: instrucciones del sistema que definen comportamiento y personalidad.
- **tools**: categorías de herramientas disponibles, como read, write, shell, grep, glob, thinking o report.
- **allowedTools**: herramientas aprobadas de antemano, sin confirmación; por ahora, vacío.
- **mcpServers**: servidores MCP externos; vacío para agentes básicos.
- **model**: modelo de IA concreto; `null` usa el predeterminado.

### Paso 4: personaliza las instrucciones del sistema

El campo `prompt` define la personalidad y el comportamiento del agente.
Adáptalo a tu caso de uso:

```json
{
  "prompt": "Eres especialista en documentación. Tu objetivo es crear documentación clara, completa y bien estructurada. Al redactar:\n\n- Usa lenguaje claro y conciso para el público destinatario\n- Organiza el contenido con títulos y estructura adecuados\n- Incluye ejemplos prácticos y fragmentos de código cuando corresponda\n- Sigue las buenas prácticas y guías de estilo\n- Mantén coherencia en terminología y formato\n\nDispones de herramientas de lectura y escritura para crear y actualizar documentación."
}
```

### Paso 5: configura el acceso a herramientas

Elige las categorías que necesita el agente:

- **read**: lectura de archivos, como readFile o readCode.
- **write**: escritura y edición, como fsWrite o editCode.
- **shell**: ejecución de comandos.
- **grep**: búsqueda de texto.
- **glob**: búsqueda de archivos por patrones y listado de directorios.
- **thinking**: razonamiento interno.
- **report**: informes de progreso.
- **delegate**: delegación a subagentes.

Para un redactor de documentación puedes usar:

```json
{
  "tools": ["read", "write", "grep", "glob", "thinking"]
}
```

### Paso 6: valida la configuración

Comprueba el formato JSON antes de usar el agente:

```bash
cat ~/.kiro/agents/docs-writer.json | jq .
```

Si el comando muestra la configuración sin errores, el JSON es válido.

## Ejecuta tu agente

### Uso básico

Usa `kiro chat` con la opción `--mode`:

```bash
kiro chat --mode docs-writer "Crea documentación del módulo de autenticación"
```

El agente iniciará una conversación con tu configuración personalizada.

### Añade archivos de contexto

Puedes añadir archivos concretos para ayudarle a comprender tu código:

```bash
kiro chat --mode docs-writer --add-file src/auth.ts "Documenta las funciones de autenticación"
```

### Opciones habituales de CLI

- `--mode <agent-name>`: indica qué agente usar.
- `--add-file <path>`: añade archivos como contexto.
- `--maximize`: maximiza la vista de la conversación.
- `--new-window`: abre la conversación en otra ventana.

## Comprueba que funciona

### Prueba 1: presentación

Pide al agente que se presente:

```bash
kiro chat --mode docs-writer "Hola, ¿puedes presentarte y explicar qué haces?"
```

Debería responder de acuerdo con las instrucciones del sistema que definiste.

### Prueba 2: acceso a herramientas

Pídele una tarea que requiera las herramientas configuradas:

```bash
kiro chat --mode docs-writer "Enumera los archivos Markdown del directorio docs"
```

Si puede leer archivos y buscar en directorios, la configuración de herramientas funciona.

### Prueba 3: comportamiento

Comprueba que sigue las pautas del sistema:

```bash
kiro chat --mode docs-writer "Explica cómo abordas la redacción de documentación"
```

La respuesta debería reflejar las instrucciones de tu `prompt`.

## Solución de problemas

### No se encuentra el agente

**Problema**: aparece «Agent not found» o «Unknown mode».

**Soluciones**:

- Comprueba que el archivo esté en `~/.kiro/agents/`.
- Revisa que el nombre del archivo coincida con el del agente y termine en `.json`.
- Verifica que el campo `name` coincida con el nombre del archivo sin la extensión.

```bash
# Comprueba si existe el archivo
ls -la ~/.kiro/agents/docs-writer.json

# Verifica que el campo name coincida
cat ~/.kiro/agents/docs-writer.json | jq .name
```

### Sintaxis JSON no válida

**Problema**: el agente no carga o muestra errores de análisis JSON.

**Soluciones**:

- Valida y formatea el JSON con `jq`:

  ```bash
  cat ~/.kiro/agents/docs-writer.json | jq .
  ```

- Revisa errores habituales: comas ausentes entre campos, comas al final del
  último campo, comillas sin escapar y corchetes o llaves sin pareja. Usa `\n`
  para representar saltos de línea dentro de cadenas.

### Errores de acceso a herramientas

**Problema**: el agente dice que no puede realizar ciertas acciones.

**Soluciones**:

- Verifica que la categoría necesaria esté en el arreglo `tools`.
- Comprueba la escritura exacta de los nombres.
- Las categorías habituales son `read`, `write`, `shell`, `grep`, `glob`, `thinking`, `report` y `delegate`.

### El comportamiento no es el esperado

**Problema**: el agente no sigue las instrucciones del sistema.

**Soluciones**:

- Haz el `prompt` más específico y detallado.
- Usa lenguaje claro y directo.
- Incluye ejemplos del comportamiento deseado.
- Prueba distintas solicitudes para afinar las respuestas.

## Próximos pasos

- **[Explora la configuración](./configuration.md)**: conoce las opciones avanzadas.
- **[Configura el acceso a herramientas](./tool-access.md)**: define aprobaciones previas y seguridad.
- **[Consulta más ejemplos](./examples.md)**: revisa configuraciones prácticas.

También puedes crear varios agentes para distintos flujos:

- Revisión de código con acceso de solo lectura.
- Asistencia de depuración con acceso completo.
- Infraestructura con herramientas de AWS o de nube.
- Pruebas, centrado en crearlas y ejecutarlas.

Optimiza cada agente para su propósito y mejora la eficiencia de tu trabajo.
