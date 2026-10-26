---
name: sdlc-automation
description: >
  End-to-end SDLC automation skill transforming Rally issues into GitLab Merge Requests
  for Python and Java projects. Governs spec-driven development (EARS), hexagonal/layered architecture,
  self-healing test loops, glab CLI workflows, and 4 mandatory human gates.
license: proprietary
compatibility: >
  Requires glab CLI, Rally MCP server, Git, Python 3.10+ or Java 17+.
allowed-tools: terminal codebase editFiles fetch mcp:rally-mcp
metadata:
  version: "2.0.0"
  methodology: spec-driven-development
  supported-stacks: "Python, Java"
---

# SDLC Automation Skill — Procedimiento Operativo Estándar (SOP)

Este skill define la secuencia estandarizada para transformar un requerimiento de Rally en un Merge Request en GitLab con compuertas humanas obligatorias.

---

## 0. Triggers de Activación
- Identificador Rally en el prompt: `US\d+` (User Story) o `DE\d+` (Defect).
- Petición del usuario: *"automatiza este issue"*, *"de issue a PR"*, *"crea el MR para US..."*.

---

## Matriz de Fases y Compuertas Humanas

| Fase | Acción Principal | Entradas / Herramientas | Salida / Artefacto | 🚪 Compuerta Humana |
| :--- | :--- | :--- | :--- | :--- |
| **0. Stack** | Detectar lenguaje y runner | `detect-stack.bat` / `.sh` | Variables de stack | Automática |
| **1. Ingesta** | Extraer y validar ticket Rally | `mcp:rally-mcp` | Datos limpios de ticket | **Gate 1:** Validar alcance |
| **2. Specs** | Formular EARS y Arquitectura | `templates/requerimientos.md`, `diseño.md` | `.docs/requerimientos.md`, `.docs/diseño.md` | **Gate 2:** Aprobar diseño |
| **3. Build** | Implementar código y tests | `#editFiles`, runner tests (max 3 reintentos) | Código fuente + tests 100% verde | **Gate 3:** Aprobar código |
| **4. GitLab** | Branch, commit, report y MR | `git`, `glab mr create --draft` | Rama remota + Draft MR + `.docs/report.md` | **Gate 4:** Validar MR |
| **5. Cierre** | Sincronizar Rally | `mcp:rally-mcp` | Rally `Completed` + comentario cruzado | Cierre final |

---

## Protocolo Detallado por Fase

### Fase 0: Detección de Stack Tecnológico
1. Ejecutar `.github/skills/sdlc-automation/scripts/detect-stack.bat` (Windows) o `detect-stack.sh` (Unix).
2. **Python:** Gestor (`poetry`/`pipenv`/`pip`), Test runner (`pytest`/`unittest`), Linter (`ruff`/`flake8`).
3. **Java:** Maven (`pom.xml` ➔ `mvn test`) o Gradle (`build.gradle` ➔ `gradle test`).

### Fase 1: Ingesta Rally y Máquina de Estados
1. Consultar Rally con campos mínimos: `FormattedID,ObjectID,Name,Description,AcceptanceCriteria,ScheduleState,Owner,Iteration,Project`.
2. **Reglas de Estado (`ScheduleState`):**
   - `Accepted`: **ABORTAR inmediatamente** (inmutable).
   - `Completed`: Advertir y solicitar confirmación para reprocesar.
   - `Defined`: Promover a `In-Progress`.
   - `In-Progress`: Continuar.
3. Normalizar HTML a Markdown plano.
4. 🚪 **Gate 1:** Presentar ID, título, criterios detectados y cambio de estado. Esperar confirmación.

### Fase 2: Especificaciones Técnicas (Spec-Driven)
1. **`.docs/requerimientos.md`:** Aplicar `templates/requerimientos.md`. Transformar cada criterio a **EARS** (`references/ears-notation.md`):
   - `CUANDO` (Evento), `MIENTRAS` (Estado), `SI` (Excepción/Error), `DONDE` (Opcional), `EL SISTEMA DEBERÁ` (Ubicuo).
2. **`.docs/diseño.md`:** Aplicar `templates/diseño.md`.
   - **Java:** **Arquitectura Hexagonal Estricta** (`domain/` puro sin dependencias, `application/port/`, `infrastructure/adapter/`).
   - **Python:** **Arquitectura por Capas** (`routers/` ➔ `services/` ➔ `models/` ➔ `repositories/`), salvo dominio de alta complejidad.
   - Diagrama Mermaid, inventario de archivos, contratos y estrategia de pruebas.
3. 🚪 **Gate 2:** Presentar ambos documentos. **Prohibido escribir código sin aprobación explícita.**

### Fase 3: Implementación y Bucle de Auto-Sanación
1. Implementar código según `.docs/diseño.md`.
2. Añadir cabecera de trazabilidad en cada archivo afectado:
   - Python: `# Rally: {FormattedID} — Requisito EARS: {ID_REQUISITO}`
   - Java: `// Rally: {FormattedID} — Requisito EARS: {ID_REQUISITO}`
3. **Bucle de Auto-Sanación (Self-Healing Loop):**
   - Ejecutar suite de pruebas (`pytest` o `mvn/gradle test`).
   - Si fallan: analizar stack trace, aplicar corrección quirúrgica y reejecutar (máx. 3 intentos).
   - Si persiste tras 3 intentos: detenerse y solicitar intervención humana.
4. Validar `references/quality-checklist.md` (sin secretos, SQL parametrizado, validación de tipos).
5. 🚪 **Gate 3:** Presentar resumen de cambios, cobertura y tests en verde (100%). Esperar confirmación.

### Fase 4: Git Workflow y GitLab Draft MR
1. Ejecutar `.github/skills/sdlc-automation/scripts/git-workflow.bat` / `.sh` o comandos equivalentes:
   - Rama: `feature/{FormattedID}-{slug-titulo}`
   - Commit: `feat({FormattedID}): {Title}`
   - Push: `git push -u origin HEAD`
2. Generar `.docs/report.md` con matriz de trazabilidad y métricas.
3. Crear Draft MR:
   ```bash
   glab mr create --title "feat({FormattedID}): {Title}" \
     --description-file .docs/report.md \
     --target-branch main \
     --source-branch "$BRANCH_NAME" \
     --draft --assignee @me \
     --label "bot-generated,{FormattedID}" --yes
   ```
4. 🚪 **Gate 4:** Compartir enlace del MR creado y solicitar confirmación para cerrar ticket en Rally.

### Fase 5: Cierre en Rally
1. Actualizar Rally `ScheduleState` a `"Completed"`.
2. Publicar comentario en la discusión de Rally con URL del MR, rama y referencias de especificación.

---

## Reglas de Seguridad Inviolables
1. **PROHIBIDO** comandos destructivos (`git push --force`, `git reset --hard` remoto).
2. **OBLIGATORIO** flag `--draft` en la creación de Merge Requests.
3. **OBLIGATORIO** detenerse en cada una de las 4 compuertas humanas.
4. **OBLIGATORIO** abortar si el ticket en Rally está en estado `Accepted`.
