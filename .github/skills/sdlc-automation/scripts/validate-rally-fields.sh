#!/usr/bin/env bash
# ==============================================================================
# Script: validate-rally-fields.sh
# Propósito: Validar la integridad de los campos extraídos de Rally WSAPI y
#            comprobar las reglas de la máquina de estados antes de procesar.
# Códigos de salida:
#   0 - Validación exitosa (Listo para procesar)
#   1 - Error de campos requeridos faltantes o malformados
#   2 - Error crítico: Artefacto en estado 'Accepted' (Inmutable, abortar)
#   3 - Advertencia: Artefacto en estado 'Completed' (Requiere confirmación humana)
# ==============================================================================

set -euo pipefail

INPUT_FILE="${1:-}"

# Si se pasa un archivo, leerlo; de lo contrario, intentar leer de stdin
if [ -n "$INPUT_FILE" ] && [ -f "$INPUT_FILE" ]; then
    CONTENT=$(tr -d '\r' < "$INPUT_FILE")
elif [ ! -t 0 ]; then
    CONTENT=$(cat | tr -d '\r')
else
    echo "ERROR: Debe proporcionar un archivo JSON o pasar datos vía stdin." >&2
    echo "Uso: $0 <rally-payload.json> o cat payload.json | $0" >&2
    exit 1
fi

# Extraer campos clave (soporta python, node, jq o grep/sed como fallback seguro)
extract_json_val() {
    local key="$1"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import sys, json; print(json.loads(sys.argv[1]).get(sys.argv[2], ''))" "$CONTENT" "$key" 2>/dev/null || echo ""
    elif command -v python >/dev/null 2>&1; then
        python -c "import sys, json; print(json.loads(sys.argv[1]).get(sys.argv[2], ''))" "$CONTENT" "$key" 2>/dev/null || echo ""
    elif command -v node >/dev/null 2>&1; then
        node -e "try { const data = JSON.parse(process.argv[1]); console.log(data[process.argv[2]] || ''); } catch(e) {}" "$CONTENT" "$key" 2>/dev/null || echo ""
    elif command -v jq >/dev/null 2>&1; then
        echo "$CONTENT" | jq -r ".$key // empty" 2>/dev/null || echo ""
    else
        echo "$CONTENT" | grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/' || echo ""
    fi
}


FORMATTED_ID=$(extract_json_val "FormattedID")
NAME=$(extract_json_val "Name")
SCHEDULE_STATE=$(extract_json_val "ScheduleState")

echo "==> Validando artefacto Rally..."

# 1. Validar presencia de FormattedID y formato
if [ -z "$FORMATTED_ID" ]; then
    echo "❌ ERROR: El campo 'FormattedID' es obligatorio y no fue encontrado." >&2
    exit 1
fi

if ! echo "$FORMATTED_ID" | grep -Eq '^(US|DE)[0-9]+$'; then
    echo "⚠️ ADVERTENCIA: 'FormattedID' ($FORMATTED_ID) no coincide con el formato estándar (US12345 o DE12345)." >&2
fi

# 2. Validar presencia de Name / Título
if [ -z "$NAME" ]; then
    echo "❌ ERROR: El campo 'Name' (título de la historia) está vacío." >&2
    exit 1
fi

# 3. Validar ScheduleState
if [ -z "$SCHEDULE_STATE" ]; then
    echo "⚠️ ADVERTENCIA: 'ScheduleState' no definido. Se asume 'Defined'." >&2
    SCHEDULE_STATE="Defined"
fi

echo "    - FormattedID:    $FORMATTED_ID"
echo "    - Name:           $NAME"
echo "    - ScheduleState:  $SCHEDULE_STATE"

case "$SCHEDULE_STATE" in
    "Accepted")
        echo "🛑 ERROR CRÍTICO [Código 2]: El artefacto $FORMATTED_ID ya se encuentra en estado 'Accepted'." >&2
        echo "    Las historias aceptadas por el Product Owner son inmutables por política de auditoría." >&2
        echo "    ABORTANDO proceso." >&2
        exit 2
        ;;
    "Completed")
        echo "⚠️ ADVERTENCIA [Código 3]: El artefacto $FORMATTED_ID ya figura como 'Completed'." >&2
        echo "    Se requiere confirmación humana explícita para reprocesar o reabrir el desarrollo." >&2
        exit 3
        ;;
    "Defined")
        echo "✅ OK: Artefacto listo. Transicionará de 'Defined' ➔ 'In-Progress'."
        exit 0
        ;;
    "In-Progress")
        echo "✅ OK: Artefacto en curso ('In-Progress'). Continuando desarrollo."
        exit 0
        ;;
    *)
        echo "⚠️ Estado '$SCHEDULE_STATE' no estándar pero procesable."
        exit 0
        ;;
esac
