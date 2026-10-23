# Checklist de Calidad y Seguridad — SDLC Automation Agent

Este checklist define los criterios obligatorios que el agente y los revisores humanos deben verificar antes de aprobar la transición hacia Git y Merge Request. Se refleja directamente en la sección 3 del archivo `.docs/report.md`.

---

## 1. Principios SOLID de Diseño de Software

- [ ] **S — Single Responsibility Principle (SRP):** Cada clase, función o módulo tiene una única responsabilidad y una única razón para cambiar. Los controladores no contienen lógica de negocio; las entidades no ejecutan persistencia directa.
- [ ] **O — Open/Closed Principle (OCP):** El código está abierto a la extensión pero cerrado a la modificación directa. Se emplean patrones como Strategy o decoradores para añadir nuevos comportamientos sin alterar código probado.
- [ ] **L — Liskov Substitution Principle (LSP):** Cualquier clase derivada puede sustituir a su clase base sin alterar la correctitud del programa. No se lanzan excepciones inesperadas en subtipos.
- [ ] **I — Interface Segregation Principle (ISP):** Las interfaces son pequeñas, cohesivas y orientadas al cliente. Ningún componente está obligado a implementar métodos que no utiliza.
- [ ] **D — Dependency Inversion Principle (DIP):** Los módulos de alto nivel dependen de abstracciones (interfaces o protocolos), nunca de implementaciones concretas. Se utiliza inyección de dependencias.

---

## 2. Evaluación de Seguridad — OWASP Top 10

| ID OWASP | Categoría de Vulnerabilidad | Criterio de Verificación del Agente |
| :--- | :--- | :--- |
| **A01:2021** | **Broken Access Control** | Todas las operaciones verifican permisos de usuario/rol en el backend. No se confía en la protección del frontend ni en parámetros manipulables por el cliente. |
| **A02:2021** | **Cryptographic Failures** | No hay secretos en texto claro. Se emplean algoritmos criptográficos robustos (AES-256-GCM, SHA-256/SHA-512, bcrypt/Argon2 para contraseñas). TLS 1.3 activo. |
| **A03:2021** | **Injection** | Consultas SQL/ORM parametrizadas. Ninguna entrada de usuario se concatena directamente en sentencias SQL, comandos de sistema operativo o plantillas HTML. |
| **A04:2021** | **Insecure Design** | Se implementan límites de tasa (rate limiting), validación de esquemas y controles de flujo de negocio seguros antes de la codificación. |
| **A05:2021** | **Security Misconfiguration** | Modo debug desactivado en producción. Encabezados de seguridad HTTP configurados (CSP, HSTS, X-Content-Type-Options). Sin credenciales por defecto. |
| **A06:2021** | **Vulnerable & Outdated Components** | Todas las nuevas librerías añadidas al gestor de paquetes (`package.json`, `pyproject.toml`, etc.) provienen de fuentes oficiales y están en versiones estables. |
| **A07:2021** | **Identification & Authentication Failures** | Tokens JWT con expiración corta y firma criptográfica verificada. Protección contra ataques de fuerza bruta. |
| **A08:2021** | **Software & Data Integrity Failures** | Deserialización segura. Verificación de integridad en descargas de artefactos y scripts externos. |
| **A09:2021** | **Security Logging & Monitoring Failures** | Se registran eventos clave de seguridad (fallos de login, accesos denegados, cambios de privilegios) con timestamps UTC, sin registrar datos sensibles (PII/contraseñas). |
| **A10:2021** | **Server-Side Request Forgery (SSRF)** | Peticiones HTTP salientes validadas contra una lista blanca de dominios permitidos. Prohibido acceso a rangos IP locales o metadata de nube (`169.254.169.254`). |

---

## 3. Estándares de Código y Buenas Prácticas

### 3.1 Higiene del Código y Trazabilidad
- [ ] **Sin Secretos Hardcodeados:** Ninguna clave API, contraseña, token o URI de infraestructura privada está inscrita en el código fuente. Se leen desde variables de entorno.
- [ ] **Trazabilidad Rally Inline:** Cada archivo creado o sustancialmente modificado incluye un comentario inicial vinculante:
  ```javascript
  // Rally: US10293 — Requisito EARS: REQ-001 (Validación de tokens de sesión)
  ```
- [ ] **DRY (Don't Repeat Yourself):** No existe duplicación innecesaria de lógica. Los cálculos y transformaciones comunes residen en módulos utilitarios compartidos.
- [ ] **Imports Limpios:** Sin imports no utilizados, circulares o con comodines (`from module import *`).
- [ ] **Manejo Defensivo de Errores:** Todas las llamadas a I/O, base de datos, APIs de red o parsing de datos están envueltas en bloques de control con propagación o logging controlado.

### 3.2 Logging y Diagnóstico
- [ ] Niveles de log respetados:
  - `ERROR`: Fallos no recuperables que requieren atención inmediata.
  - `WARN`: Condiciones anómalas recuperables o advertencias de rendimiento.
  - `INFO`: Hitos significativos del flujo de negocio.
  - `DEBUG`: Información de diagnóstico detallada (desactivada en producción).
- [ ] Logs estructurados (formato JSON o clave-valor estándar).

---

## 4. Estándares de Pruebas Automatizadas

| Métrica / Tipo de Prueba | Umbral Mínimo Requerido | Objetivo |
| :--- | :--- | :--- |
| **Tasa de Aprobación** | **100%** de los tests deben pasar en verde | Cero regresiones introducidas |
| **Cobertura de Código (Coverage)** | **≥ 80%** en líneas y ramas del nuevo código | Asegurar robustez en ramas condicionales |
| **Happy Path Tests** | Al menos 1 por cada criterio de aceptación EARS de evento | Validar caso nominal de éxito |
| **Negative Tests (Edge Cases)** | Al menos 2 por cada criterio negativo EARS | Validar respuestas ante entradas erróneas o timeout |
| **Pruebas de Integración** | Mínimo 1 test de extremo a extremo del flujo | Validar contratos entre capas o servicios |
