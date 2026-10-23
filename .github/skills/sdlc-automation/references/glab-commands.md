# Referencia de Comandos glab CLI para Automatización SDLC

La herramienta de línea de comandos de GitLab (`glab`) es el puente operativo utilizado por el agente para interactuar con repositorios remotos y gestionar Merge Requests sin necesidad de navegación por interfaz gráfica.

---

## 1. Comandos Principales para el Agente

### 1.1 Creación de Merge Request (No interactivo)

```bash
glab mr create \
  --title "feat({FormattedID}): {concise_title}" \
  --description-file .docs/report.md \
  --target-branch main \
  --source-branch "{BRANCH_NAME}" \
  --draft \
  --assignee @me \
  --label "bot-generated,{FormattedID}" \
  --yes
```

> **Salida estándar esperada:**  
> Retorna la URL del Merge Request generado (ej. `https://gitlab.example.com/org/repo/-/merge_requests/42`). El agente debe capturar esta URL y el identificador numérico (`IID`, en este caso `42`).

### 1.2 Añadir Notas / Comentarios en el Merge Request

```bash
glab mr note create {MR_IID} -m "## 🤖 Reporte de Validación Automatizada
- **Rally Story:** {FormattedID}
- **Tests ejecutados:** {PASS_COUNT}/{TOTAL_COUNT} en verde
- **Documentos generados:** \`.docs/requerimientos.md\`, \`.docs/diseño.md\`, \`.docs/report.md\`

MR generado en modo Borrador (Draft) a la espera de revisión humana."
```

### 1.3 Verificación del Estado del MR

```bash
# Inspeccionar detalles y estado de aprobación del MR
glab mr view {MR_IID}

# Listar MRs abiertas vinculadas al ticket de Rally
glab mr list --search "{FormattedID}" --state opened
```

### 1.4 Verificación de Autenticación de GitLab

```bash
glab auth status
```

---

## 2. Banderas (Flags) de Seguridad Obligatorias

| Flag | Tipo | Justificación de Seguridad y Automatización |
| :--- | :--- | :--- |
| `--yes` | **Crítico / Obligatorio** | Suprime los avisos interactivos de confirmación por consola. Sin esta bandera, la CLI se bloquea esperando un `[y/n]` en `stdin`, pausando indefinidamente el agente. |
| `--draft` | **Crítico / Obligatorio** | Marca el Merge Request como borrador (*Work In Progress*). Impide que pipelines de producción o fusiones accidentales se ejecuten antes de la inspección humana. |
| `--description-file` | **Recomendado** | Carga el cuerpo del MR directamente desde `.docs/report.md`. Evita problemas de truncamiento de strings o caracteres de escape en consolas PowerShell/Bash. |
| `--assignee @me` | **Recomendado** | Asigna automáticamente la autoría al usuario cuya sesión o token ejecuta el comando, manteniendo la responsabilidad técnica clara. |
| `--label` | **Recomendado** | Etiqueta el MR con `bot-generated` y el identificador de Rally para auditoría y filtrado ágil en los tableros de GitLab. |

---

## 3. Banderas y Comandos Prohibidos

| Flag / Comando | Estado | Razón Técnica |
| :--- | :--- | :--- |
| `--attach` | ❌ **PROHIBIDO** | Marcado como experimental e inestable en versiones recientes de `glab`. Puede fallar silenciosamente o corromper el payload. |
| Invocaciones sin `--yes` | ❌ **PROHIBIDO** | Congela la sesión del agente al requerir entrada interactiva del teclado. |
| `glab mr merge` | ❌ **PROHIBIDO** | El agente **NUNCA** fusiona código a ramas protegidas de manera autónoma. La fusión es potestad exclusiva del revisor humano. |
| `glab mr close` / `delete` | ❌ **PROHIBIDO** | Acciones destructivas no autorizadas sobre el ciclo de vida del código. |

---

## 4. Resolución de Errores Comunes (Troubleshooting)

### Error: `glab: command not found`
- **Diagnóstico:** El binario no está en el `PATH` del sistema.
- **Acción:** Notificar al usuario con instrucciones de instalación (`winget install GitLab.glab` o `brew install glab`).

### Error: `401 Unauthorized / Token expired`
- **Diagnóstico:** El token personal de GitLab expiró o no tiene alcances `api` / `write_repository`.
- **Acción:** Solicitar al usuario ejecutar `glab auth login` en su terminal interactivo.

### Error: `Branch already has an open MR`
- **Diagnóstico:** Ya existe un MR abierto para la rama especificada.
- **Acción:** Ejecutar `glab mr view` para recuperar el enlace existente en lugar de intentar duplicarlo.
