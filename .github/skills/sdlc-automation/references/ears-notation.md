# Notación EARS — Easy Approach to Requirements Syntax

## 1. Introducción a EARS

La notación **EARS (Easy Approach to Requirements Syntax)** es un estándar formal para la redacción de especificaciones de requisitos sin ambigüedad. Fue desarrollada por Alistair Mavin en Rolls-Royce para reducir errores de interpretación en sistemas críticos de ingeniería y software.

En el ciclo **SDLC Automation Agent**, todo criterio de aceptación proveniente de Broadcom Rally debe ser transformado a una o más cláusulas EARS dentro de `.docs/requerimientos.md`.

---

## 2. Los 5 Patrones Fundamentales de EARS

| Patrón | Estructura Sintáctica | Propósito / Cuándo Usarlo |
| :--- | :--- | :--- |
| **1. Ubicuo (Ubiquitous)** | `EL SISTEMA DEBERÁ <acción/respuesta>` | Requisitos continuos sin condición desencadenante. Siempre activos. |
| **2. Conducido por Eventos (Event-driven)** | `CUANDO <evento disparador>, EL SISTEMA DEBERÁ <acción/respuesta>` | Respuestas inmediatas a un evento o acción del usuario/sistema externo. |
| **3. Conducido por Estado (State-driven)** | `MIENTRAS <estado/condición activa>, EL SISTEMA DEBERÁ <acción/respuesta>` | Comportamientos que aplican únicamente mientras el sistema esté en un estado dado. |
| **4. Característica Opcional (Optional feature)** | `DONDE <característica habilitada>, EL SISTEMA DEBERÁ <acción/respuesta>` | Requisitos condicionados a configuraciones, feature flags o licencias. |
| **5. Comportamiento Indeseado / Negativo (Unwanted behavior)** | `SI <condición de error/anomalía>, EL SISTEMA DEBERÁ <acción/respuesta>` | Manejo de excepciones, fallos de red, validaciones erróneas y recuperación. |

---

## 3. Patrón Complejo / Compuesto

Cuando un requisito depende tanto de un evento como de un estado previo o condición:

```
MIENTRAS <estado activo>, CUANDO <evento disparador>, EL SISTEMA DEBERÁ <acción/respuesta>
```

O si incluye manejo de excepciones en un estado dado:

```
MIENTRAS <estado activo>, SI <condición de error>, EL SISTEMA DEBERÁ <acción de mitigación>
```

---

## 4. Ejemplos Concretos por Patrón

### Patrón 1: Ubicuo (Siempre Activo)
- **Correcto:** `EL SISTEMA DEBERÁ cifrar todos los tokens de sesión en reposo mediante AES-GCM-256.`
- **Correcto:** `EL SISTEMA DEBERÁ registrar todas las transacciones financieras en el log de auditoría con timestamp UTC.`
- **Incorrecto:** ❌ `El sistema debería ser seguro y rápido.` *(Vago, no medible, sin verbo rector).*

### Patrón 2: Conducido por Evento (CUANDO)
- **Correcto:** `CUANDO el usuario envíe el formulario de pago con fondos suficientes, EL SISTEMA DEBERÁ procesar la transacción y emitir un recibo en menos de 500 ms.`
- **Correcto:** `CUANDO expire el temporizador de inactividad de 15 minutos, EL SISTEMA DEBERÁ revocar el token JWT y redirigir a la pantalla de login.`
- **Incorrecto:** ❌ `Al pagar, se procesa la compra.` *(Omite SLA, omite actor pasivo, sintaxis informal).*

### Patrón 3: Conducido por Estado (MIENTRAS)
- **Correcto:** `MIENTRAS el nodo de base de datos primario esté en estado de conmutación por error (failover), EL SISTEMA DEBERÁ enrutar todas las consultas de lectura a las réplicas secundarias.`
- **Correcto:** `MIENTRAS la sesión de usuario permanezca autenticada, EL SISTEMA DEBERÁ renovar el heartbeat cada 5 minutos.`
- **Incorrecto:** ❌ `Durante el fallo se debe usar la réplica.` *(Falta verbo rector y sujeto formal).*

### Patrón 4: Opcional (DONDE)
- **Correcto:** `DONDE la autenticación multifactor (MFA) esté habilitada en el perfil de la cuenta, EL SISTEMA DEBERÁ solicitar un código TOTP de 6 dígitos tras validar la contraseña.`
- **Correcto:** `DONDE el flag "DARK_MODE" esté activo, EL SISTEMA DEBERÁ aplicar la paleta de colores de alto contraste conforme a WCAG 2.1 AA.`
- **Incorrecto:** ❌ `Si el usuario quiere 2FA, se lo pedimos.` *(Confunde "SI" condicional de error con opcionalidad).*

### Patrón 5: Comportamiento Indeseado / Negativo (SI)
- **Correcto:** `SI el servicio externo de pagos no responde en 3000 ms, EL SISTEMA DEBERÁ registrar el error E_GATEWAY_TIMEOUT y mostrar un mensaje de reintento al usuario.`
- **Correcto:** `SI la carga útil (payload) supera los 10 MB, EL SISTEMA DEBERÁ responder con código HTTP 413 Payload Too Large.`
- **Incorrecto:** ❌ `Si algo falla, mandar error.` *(Inútil para testing unitario y de integración).*

---

## 5. Tabla de Reglas de Transformación Rally → EARS

| Criterio Original en Rally | Clasificación | Transformación a Notación EARS |
| :--- | :--- | :--- |
| "El usuario debe poder cancelar un pedido si no ha sido enviado" | Estado + Evento | `MIENTRAS el pedido esté en estado 'Pendiente' o 'En Preparación', CUANDO el cliente solicite la cancelación, EL SISTEMA DEBERÁ anular la orden y revertir la reserva de stock.` |
| "Validar que el email sea válido" | Negativo | `SI el campo 'email' no cumple con el formato RFC 5322, EL SISTEMA DEBERÁ rechazar el registro con el mensaje 'Formato de correo inválido'.` |
| "Soportar modo offline" | Estado | `MIENTRAS no exista conexión de red disponible, EL SISTEMA DEBERÁ persistir las operaciones en IndexedDB local.` |
| "El login debe responder rápido" | Ubicuo / SLA | `EL SISTEMA DEBERÁ responder a las peticiones de autenticación válidas en un tiempo inferior a 250 ms (p95).` |

---

## 6. Lista de Verificación EARS para el Agente

Al generar `.docs/requerimientos.md`, validar:
- [ ] Cada criterio comienza con la palabra clave exacta (`CUANDO`, `MIENTRAS`, `DONDE`, `SI`, o `EL SISTEMA DEBERÁ`).
- [ ] Contiene obligatoriamente la frase rectora `EL SISTEMA DEBERÁ`.
- [ ] La acción resultante es determinista, binaria (pasa o falla) y comprobable mediante un test automatizado.
- [ ] No contiene términos ambiguos como: *fácil*, *rápido*, *amigable*, *adecuado*, *en la medida de lo posible*, *etc.*
- [ ] Tiempos de respuesta y umbrales numéricos tienen unidades explícitas (ms, MB, req/s, %).
