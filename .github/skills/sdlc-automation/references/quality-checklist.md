# Checklist de Calidad y Seguridad (Python / Java)

Criterios de verificación obligatorios antes de aprobar el código y generar el Merge Request. Se refleja en `.docs/report.md`.

---

## 1. Principios de Diseño SOLID
- [ ] **SRP:** Clases, funciones y módulos con una sola responsabilidad (controladores sin lógica de negocio, entidades sin I/O directo).
- [ ] **OCP:** Extensible mediante composición, estrategias o inyección de dependencias sin modificar código base probado.
- [ ] **LSP:** Subtipos y derivados intercambiables sin alterar el comportamiento esperado ni lanzar excepciones anómalas.
- [ ] **ISP:** Interfaces y protocolos pequeños, específicos y segregados según las necesidades del cliente.
- [ ] **DIP:** Módulos de alto nivel dependen de abstracciones (interfaces/puertos), nunca de implementaciones concretas.

---

## 2. Seguridad OWASP Top 10 Esencial
- [ ] **Sin Secretos:** Cero claves API, contraseñas o tokens en código fuente. Usar variables de entorno o gestores de secretos.
- [ ] **Inyecciones (A03):** Consultas SQL estrictamente parametrizadas o mediante ORM seguro (SQLAlchemy, Spring Data JPA).
- [ ] **Control de Acceso (A01):** Validación de permisos y roles en la capa de negocio/servicio, nunca confiando únicamente en el cliente.
- [ ] **Validación de Entradas (A04):** Esquemas tipados estrictos (Pydantic en Python, Bean Validation / Hibernate Validator en Java).
- [ ] **Criptografía (A02):** Algoritmos robustos estándar (AES-256-GCM, bcrypt/Argon2 para hashes, SHA-256).
- [ ] **Logs Seguros (A09):** Trazas estructuradas en JSON con timestamps UTC, sin exponer PII (datos personales), tokens ni credenciales.

---

## 3. Higiene y Estándares de Código
- [ ] **Trazabilidad Rally Inline:** Cabecera obligatoria en cada archivo modificado o creado:
  - Python: `# Rally: {FormattedID} — Requisito EARS: {ID_REQUISITO}`
  - Java: `// Rally: {FormattedID} — Requisito EARS: {ID_REQUISITO}`
- [ ] **Sin Duplicación (DRY):** Lógica compartida extraída a servicios o funciones utilitarias.
- [ ] **Manejo de Errores:** Bloques de control con excepciones tipadas de negocio y códigos de estado HTTP semánticos.
- [ ] **Pruebas y Cobertura:** 100% de tests en verde (`pytest` o `mvn/gradle test`) con cobertura mínima del 80%.
