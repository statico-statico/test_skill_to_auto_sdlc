# Referencia Rápida: Notación EARS (Easy Approach to Requirements Syntax)

Estándar sintáctico obligatorio para transformar criterios de aceptación de Rally a requisitos verificables en `.docs/requerimientos.md`.

---

## 1. Los 5 Patrones EARS

| Patrón | Estructura Sintáctica | Cuándo Usarlo |
| :--- | :--- | :--- |
| **Ubicuo** | `EL SISTEMA DEBERÁ <acción>` | Requisito continuo y transversal. Siempre activo. |
| **Evento** | `CUANDO <evento>, EL SISTEMA DEBERÁ <acción>` | Respuesta inmediata a un estímulo externo o de usuario. |
| **Estado** | `MIENTRAS <estado activo>, EL SISTEMA DEBERÁ <acción>` | Comportamiento vigente solo durante un estado específico. |
| **Opcional** | `DONDE <característica habilitada>, EL SISTEMA DEBERÁ <acción>` | Comportamiento condicionado a configuración o feature flag. |
| **No Deseado / Error** | `SI <condición de error/excepción>, EL SISTEMA DEBERÁ <acción>` | Manejo de excepciones, fallos de red o datos inválidos. |

---

## 2. Patrón Compuesto

Para requisitos que combinan evento con estado previo o manejo de error:
- `MIENTRAS <estado>, CUANDO <evento>, EL SISTEMA DEBERÁ <acción>`
- `MIENTRAS <estado>, SI <condición error>, EL SISTEMA DEBERÁ <acción de recuperación>`

---

## 3. Ejemplos de Referencia

- **Ubicuo:** `EL SISTEMA DEBERÁ cifrar los tokens de sesión en reposo con AES-256-GCM.`
- **Evento:** `CUANDO el usuario envíe una solicitud de renovación válida, EL SISTEMA DEBERÁ extender la expiración en 15 minutos.`
- **Estado:** `MIENTRAS la sesión permanezca activa, EL SISTEMA DEBERÁ responder al endpoint de heartbeat en menos de 200 ms.`
- **Opcional:** `DONDE el flag 'AUDIT_LOG_VERBOSE' esté activo, EL SISTEMA DEBERÁ incluir los encabezados HTTP en el registro de auditoría.`
- **Error:** `SI el token recibido ha expirado, EL SISTEMA DEBERÁ devolver HTTP 401 Unauthorized y revocar el identificador en caché.`

---

## 4. Reglas de Validación
- Todo requisito debe iniciar con su palabra clave en mayúsculas (`CUANDO`, `MIENTRAS`, `SI`, `DONDE`, `EL SISTEMA DEBERÁ`).
- Evitar adjetivos vagos ("rápido", "seguro", "amigable"). Incluir siempre umbrales medibles (ms, códigos HTTP, algoritmos).
