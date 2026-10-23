# Especificación de Requerimientos: US10293 — Advertencia de Expiración de Sesión y Renovación por Heartbeat

> **Identificador Rally:** `US10293`  
> **Título de la Historia:** Implementación de Advertencia de Expiración de Sesión y Renovación de Token por Heartbeat  
> **Iteración / Sprint:** Sprint 24.3 (Core Security)  
> **Fecha de Generación:** 2026-10-23  
> **Estado en Rally:** In-Progress (original: Defined)  
> **Generado por:** Copilot SDLC Automation Agent  

---

## 1. Descripción Funcional

Para garantizar la seguridad de la información corporativa y cumplir con las directrices regulatorias bancarias (PCI-DSS y SOC-2), el sistema debe gestionar de forma proactiva la inactividad del usuario en la plataforma web. 

Actualmente, las sesiones caducan de forma abrupta a los 15 minutos de inactividad, provocando la pérdida de datos no guardados en formularios y una experiencia de usuario deficiente. La nueva funcionalidad desplegará un modal emergente de advertencia a los 13 minutos de inactividad, otorgando una ventana de gracia de 2 minutos con cuenta regresiva. Si el usuario confirma que desea continuar activo, el sistema emitirá un ping de "heartbeat" seguro al backend para renovar el token JWT sin requerir recargar la página. Si la cuenta regresiva llega a cero sin interacción, la sesión será revocada de inmediato en el servidor y el usuario será redirigido a la pantalla de login con un mensaje explicativo.

---

## 2. Historia de Usuario

- **Como** usuario autenticado en la plataforma web,
- **quiero** recibir un aviso preventivo antes de que mi sesión expire por inactividad y tener la opción de extenderla con un solo clic,
- **para** evitar la pérdida de mi trabajo en progreso y mantener una experiencia fluida sin comprometer la seguridad de la cuenta.

---

## 3. Criterios de Aceptación (Notación EARS)

### 3.1 Requisitos Conducidos por Eventos (CUANDO)
- **REQ-EVT-01:** CUANDO el temporizador de inactividad alcance los 780 segundos (13 minutos) sin eventos de entrada del usuario (clic, pulsación de tecla o scroll), EL SISTEMA DEBERÁ mostrar en primer plano el modal de advertencia de expiración de sesión con un temporizador visual de 120 segundos.
- **REQ-EVT-02:** CUANDO el usuario presione el botón "Mantener sesión activa" dentro de la ventana de gracia, EL SISTEMA DEBERÁ emitir una solicitud de renovación (`POST /api/v1/auth/session/heartbeat`) y restablecer el temporizador de inactividad a cero en menos de 300 ms.
- **REQ-EVT-03:** CUANDO el contador regresivo de la ventana de gracia alcance 0 segundos sin interacción del usuario, EL SISTEMA DEBERÁ revocar el token de sesión en el backend, purgar los datos sensibles del almacenamiento local y redirigir al endpoint `/login?reason=inactivity_timeout`.

### 3.2 Requisitos Conducidos por Estado (MIENTRAS)
- **REQ-STA-01:** MIENTRAS el modal de advertencia de expiración esté visible en pantalla, EL SISTEMA DEBERÁ actualizar el segundero de la cuenta regresiva en intervalos exactos de 1000 ms.
- **REQ-STA-02:** MIENTRAS exista una petición de renovación de heartbeat en tránsito hacia el backend, EL SISTEMA DEBERÁ deshabilitar el botón "Mantener sesión activa" y mostrar un indicador visual de carga (spinner).

### 3.3 Requisitos Opcionales o Condicionales (DONDE)
- **REQ-OPT-01:** DONDE el usuario tenga habilitada la preferencia de accesibilidad "Reducción de movimiento", EL SISTEMA DEBERÁ presentar el modal de advertencia sin animaciones de transición CSS y emitir un aria-live alert para lectores de pantalla.

### 3.4 Requisitos de Manejo de Errores y Comportamiento Indeseado (SI)
- **REQ-NEG-01:** SI el endpoint de heartbeat retorna un código HTTP 401 Unauthorized o 403 Forbidden (ej. sesión revocada desde otro dispositivo), EL SISTEMA DEBERÁ forzar el cierre inmediato de la sesión local y redirigir al login mostrando el mensaje "Tu sesión ya no es válida".
- **REQ-NEG-02:** SI la llamada de red al endpoint de heartbeat falla por falta de conectividad (Network Error / Timeout > 5000 ms), EL SISTEMA DEBERÁ reintentar automáticamente una vez y, si persiste el fallo, presentar un botón "Reintentar conexión" sin cerrar la sesión prematuramente hasta que expire la ventana de gracia.

### 3.5 Requisitos Ubicuos (SIEMPRE)
- **REQ-UBI-01:** EL SISTEMA DEBERÁ invalidar el token de refresco y el access token en el servidor Redis al completarse el cierre de sesión por timeout.
- **REQ-UBI-02:** EL SISTEMA DEBERÁ registrar cada evento de expiración por inactividad y cada renovación por heartbeat en el log de auditoría de seguridad con timestamp UTC y correlation ID.

---

## 4. Requisitos No Funcionales (NFR)

| Categoría | Especificación del Requisito | Métrica / Umbral Verificable |
| :--- | :--- | :--- |
| **Rendimiento** | Latencia de respuesta en la renovación de sesión | < 200 ms (p95) en el endpoint `/heartbeat` |
| **Seguridad** | Protección de tokens y prevención de CSRF | Tokens transmitidos en cookies `HttpOnly; Secure; SameSite=Strict` |
| **Consumo de Recursos** | Impacto en CPU de los event listeners de inactividad | Utilización de *throttling* de 500 ms en eventos de mouse/teclado (< 1% CPU) |
| **Accesibilidad** | Compatibilidad con tecnologías de asistencia | Cumplimiento estricto WCAG 2.1 AA (foco retenido en modal accesible) |

---

## 5. Fuera de Alcance (Out of Scope)

- Sincronización de temporizador de inactividad entre múltiples pestañas vía `BroadcastChannel` (programada para la historia US10310).
- Modificación del tiempo global de expiración por rol o política de grupo (se mantiene fijo en 15 minutos).

---

## 6. Preguntas Abiertas y Supuestos

- [x] **Supuesto validado:** El backend ya cuenta con un servicio Redis para la lista negra de tokens revocados (`RevokedTokensSet`).
- [x] **Supuesto validado:** La expiración absoluta del token de refresco es de 8 horas, tras lo cual no se permite más renovación por heartbeat.

---

## 7. Matriz de Trazabilidad Rally

| Atributo Rally | Valor Ingerido |
| :--- | :--- |
| **FormattedID** | `US10293` |
| **Name** | Implementación de Advertencia de Expiración de Sesión y Renovación por Heartbeat |
| **ScheduleState** | `In-Progress` |
| **Owner** | Carlos Mendoza (Security Lead) |
| **Project** | Digital Banking Portal |
| **Iteration** | Sprint 24.3 |
