#!/usr/bin/env bash
# ==============================================================================
# Script: git-workflow.sh
# Propósito: Automatizar el flujo completo de Git y GitLab CLI:
#            Creación de rama, commit semántico, push remoto y generación de MR Draft.
# Parámetros:
#   $1 - Rally FormattedID (ej. US10293)
#   $2 - Título del requerimiento (ej. "Implement Session Timeout Warning")
#   $3 - Rama destino (opcional, por defecto: main)
#   $4 - Archivo de descripción del MR (opcional, por defecto: .docs/report.md)
# ==============================================================================

set -euo pipefail

FORMATTED_ID="${1:-}"
TITLE="${2:-}"
TARGET_BRANCH="${3:-main}"
DESC_FILE="${4:-.docs/report.md}"

if [ -z "$FORMATTED_ID" ] || [ -z "$TITLE" ]; then
    echo "ERROR: Parámetros obligatorios faltantes." >&2
    echo "Uso: $0 <FormattedID> <Title> [TargetBranch] [DescriptionFile]" >&2
    exit 1
fi

# Validar que git está inicializado
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: El directorio actual no es un repositorio Git válido." >&2
    exit 1
fi

# Validar archivo de descripción
if [ ! -f "$DESC_FILE" ]; then
    if [ -f ".docs/mr-description.md" ]; then
        DESC_FILE=".docs/mr-description.md"
    else
        echo "ADVERTENCIA: Archivo de reporte $DESC_FILE no encontrado. Se creará descripción mínima." >&2
        mkdir -p .docs
        cat <<EOF > .docs/temp-mr-desc.md
# feat($FORMATTED_ID): $TITLE

Automatización SDLC completada por Copilot Agent.
Rally ID: $FORMATTED_ID
EOF
        DESC_FILE=".docs/temp-mr-desc.md"
    fi
fi

# 1. Generar nombre de rama normalizado
CLEAN_TITLE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | cut -c 1-40)
BRANCH_NAME="feature/${FORMATTED_ID}-${CLEAN_TITLE}"

echo "==> Creando rama de trabajo: $BRANCH_NAME"
git checkout -B "$BRANCH_NAME"

# 2. Preparar y crear commit semántico
echo "==> Registrando cambios locales..."
git add .

# Verificar si hay cambios reales para commitear
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "AVISO: No se detectaron modificaciones nuevas en el árbol de trabajo para commitear."
else
    COMMIT_MSG="feat(${FORMATTED_ID}): ${TITLE}

- Implementa requerimientos aprobados de Rally ${FORMATTED_ID}
- Especificaciones: .docs/requerimientos.md
- Diseno tecnico: .docs/diseno.md
- Trazabilidad cruzada bidireccional

Rally-Issue: ${FORMATTED_ID}"

    git commit -m "$COMMIT_MSG"
    echo "==> Commit generado con éxito."
fi

# 3. Publicar rama en remoto
echo "==> Publicando rama en origen..."
if git remote | grep -q "origin"; then
    git push -u origin HEAD
else
    echo "AVISO: No se detectó un remote 'origin'. Omitiendo 'git push'." >&2
fi

# 4. Crear Merge Request en GitLab vía glab CLI
echo "==> Creando Merge Request en GitLab con glab CLI..."
if command -v glab >/dev/null 2>&1; then
    MR_OUTPUT=$(glab mr create \
        --title "feat(${FORMATTED_ID}): ${TITLE}" \
        --description-file "$DESC_FILE" \
        --target-branch "$TARGET_BRANCH" \
        --source-branch "$BRANCH_NAME" \
        --draft \
        --assignee @me \
        --label "bot-generated,${FORMATTED_ID}" \
        --yes 2>&1 || true)

    echo "$MR_OUTPUT"

    # Extraer URL del MR si está en la salida
    MR_URL=$(echo "$MR_OUTPUT" | grep -Eo 'https?://[^ ]+/merge_requests/[0-9]+' | head -n 1 || echo "")
    MR_IID=$(echo "$MR_URL" | grep -Eo '[0-9]+$' || echo "")

    if [ -n "$MR_IID" ] && [ -n "$MR_URL" ]; then
        echo "==> Añadiendo nota técnica automatizada al MR #$MR_IID..."
        glab mr note create "$MR_IID" -m "## 🤖 Reporte de Validación Automatizada
- **Rally Story:** $FORMATTED_ID
- **Documentación de Especificación:** \`.docs/requerimientos.md\` y \`.docs/diseno.md\`
- **Reporte Post-Tarea:** \`.docs/report.md\`

Merge Request generado en modo borrador (**Draft**) a la espera de aprobación humana." >/dev/null 2>&1 || true
    fi

    cat <<EOF

================================================================================
RESULTADO DEL FLUJO GIT:
BRANCH_NAME=$BRANCH_NAME
MR_URL=${MR_URL:-"No disponible / Pendiente de verificación"}
MR_IID=${MR_IID:-"N/A"}
================================================================================
EOF
else
    echo "ADVERTENCIA: El binario 'glab' no está disponible en el entorno." >&2
    echo "La rama '$BRANCH_NAME' fue creada localmente." >&2
fi
