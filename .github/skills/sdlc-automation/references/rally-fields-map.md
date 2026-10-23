# Mapeo de Campos Rally WSAPI → Documentos SDLC

## 1. Mapeo General de Atributos WSAPI

| Campo Rally WSAPI | Tipo de Dato | Destino en SDLC | Sección / Uso | Obligatorio |
| :--- | :--- | :--- | :--- | :--- |
| `FormattedID` | String (ej. `US10293`, `DE4512`) | Todos los artefactos | Identificador principal en Headers, Branches, Commits, MRs | Sí |
| `ObjectID` | Long (ej. `718293849102`) | API / Payload | Identificador numérico para mutaciones WSAPI (`POST /hierarchicalrequirement/{ObjectID}`) | Sí |
| `Name` | String | `requerimientos.md`, Git, MR | Título de la historia / commit / MR | Sí |
| `Description` | Rich Text (HTML) | `requerimientos.md` | Descripción funcional e Historia de Usuario (Como/Quiero/Para) | Sí |
| `AcceptanceCriteria` | Rich Text (HTML) | `requerimientos.md` | Base para sintetizar criterios en Notación EARS | Sí |
| `Notes` | Rich Text (HTML) | `requerimientos.md` | Contexto adicional, dependencias o advertencias de negocio | No |
| `ScheduleState` | Enum String | Control de Flujo | Máquina de estados ágil y validación de compuertas | Sí |
| `Owner._refObjectName` | String | `report.md` | Trazabilidad del responsable asignado | No |
| `Iteration.Name` | String | `requerimientos.md`, Git | Nombre del Sprint/Iteración | No |
| `Project.Name` | String | `report.md` | Nombre del equipo / proyecto Rally | No |
| `Tags` | Collection | GitLab MR | Etiquetas para el MR (`--label "bot-generated,US10293,{tag}"`) | No |

---

## 2. Máquina de Estados: `ScheduleState`

Rally clasifica el progreso de los artefactos (`HierarchicalRequirement` y `Defect`) mediante el campo `ScheduleState`. El agente debe evaluar rigurosamente este campo antes de cualquier alteración en el workspace:

```
[Defined] ──────► [In-Progress] ──────► [Completed] ──────► [Accepted]
   ▲                     ▲                     ▲                   ▲
   │                     │                     │                   │
   │ Fase 1: Inicio      │ Fase 3: Codificación│ Fase 5: MR creado │ Solo Humano
   │ Agente promueve     │ Agente trabaja      │ Agente finaliza   │ (Product Owner)
```

### Tabla de Reglas de Transición para el Agente

| Estado Actual en Rally | Acción del Agente | Justificación Técnica / Seguridad |
| :--- | :--- | :--- |
| **`Defined`** | Promover a `In-Progress` vía WSAPI y continuar. | El ítem está listo para desarrollo. Actualiza métricas de inicio (`inProgressDate`). |
| **`In-Progress`** | Continuar sin cambiar el estado. | El trabajo ya está en curso (puede ser reanudación de sesión). |
| **`Completed`** | **Advertir al usuario** y solicitar confirmación explícita antes de proceder. | Podría ser un re-trabajo o reproceso no planificado. |
| **`Accepted`** | 🛑 **ABORTAR INMEDIATAMENTE**. | Los ítems aceptados por el Product Owner son inmutables para el agente por motivos de auditoría y SOX compliance. |

---

## 3. Limpieza y Normalización de HTML (Rally Rich Text → Markdown)

Rally almacena campos de texto enriquecido con marcado HTML. El agente debe normalizar el contenido antes de inyectarlo en `.docs/requerimientos.md`:

```
Entrada HTML de Rally:
<div><strong>Como</strong> operador bancario</div><div><strong>Quiero</strong> transferir fondos</div><div>&nbsp;</div><ul><li>Validar saldo > 0</li></ul>

Salida Markdown limpia:
**Como** operador bancario
**Quiero** transferir fondos

- Validar saldo > 0
```

### Reglas de Conversión
1. `<div>`, `<p>` → Convertir en saltos de línea dobles (`\n\n`).
2. `<strong>`, `<b>` → Convertir en negritas Markdown (`**texto**`).
3. `<em>`, `<i>` → Convertir en cursivas Markdown (`*texto*`).
4. `<ul><li>` / `<ol><li>` → Convertir en listas Markdown (`- item` o `1. item`).
5. `&nbsp;` → Convertir a espacio estándar o eliminar si está en línea vacía.
6. `&amp;`, `&lt;`, `&gt;`, `&quot;` → Decodificar a `&`, `<`, `>`, `"`.
7. `<span ...>`, `<font ...>` → Eliminar etiquetas conservando únicamente el texto interior.

---

## 4. Mejores Prácticas de Consulta WSAPI (MCP Shallow Fetch)

Para minimizar el consumo de tokens y evitar cuotas de peticiones o retardos en la respuesta de la WSAPI:

- ❌ **PROHIBIDO**: `fetch=true` (devuelve el grafo completo de colecciones anidadas, consumiendo decenas de miles de tokens innecesarios).
- ✅ **OBLIGATORIO**: `fetch=FormattedID,ObjectID,Name,Description,AcceptanceCriteria,Notes,ScheduleState,Owner,Iteration,Project,Tags`.
- ✅ **Filtro exacto**: `query=(FormattedID = "{ID}")`.
