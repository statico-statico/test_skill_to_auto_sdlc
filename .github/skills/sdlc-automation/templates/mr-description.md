# 🤖 feat({RALLY_FORMATTED_ID}): {TITLE}

> **Tipo de MR:** Borrador Automatizado (`--draft`)  
> **Historia Rally:** [{RALLY_FORMATTED_ID}]({RALLY_ITEM_URL})  
> **Iteración:** {ITERATION_NAME}  
> **Generado por:** Copilot SDLC Automation Agent  
> **Etiquetas:** `bot-generated`, `{RALLY_FORMATTED_ID}`  

---

## 📌 1. Resumen de la Solución

{PROCESSED_DESCRIPTION_SUMMARY}

Esta propuesta de fusión implementa de forma end-to-end los requisitos formalizados en la especificación EARS de la historia `{RALLY_FORMATTED_ID}`, siguiendo el diseño técnico acordado.

---

## 📂 2. Archivos Modificados y Creados

| Archivo | Acción | Requisito Asociado |
| :--- | :--- | :--- |
| `{file_path_1}` | Modificado | `REQ-EVT-01` |
| `{file_path_2}` | Creado | `REQ-STA-01` |
| `{test_path_1}` | Creado | `REQ-NEG-01` |

---

## 🧪 3. Verificación de Calidad y Pruebas

- **Estado de Pruebas Automatizadas:** ✅ `{PASS_COUNT}/{TOTAL_COUNT}` pasando (100%).
- **Cobertura de Código:** `{COVERAGE}%` (Umbral mínimo: 80%).
- **Chequeo Estático / Lint:** 0 errores, 0 advertencias.
- **Seguridad OWASP:** Revisión conforme contra inyecciones y accesos no autorizados.

---

## 📖 4. Artefactos de Documentación Generados

Los documentos técnicos generados residen en el directorio `.docs/` de esta misma rama:
- 📄 [Requerimientos Formales (EARS)](.docs/requerimientos.md)
- 📐 [Diseño de Arquitectura y Contratos](.docs/diseño.md)
- 📊 [Reporte Completo de Calidad y Trazabilidad](.docs/report.md)

---

## 🔍 5. Checklist para el Revisor Humano

Antes de retirar el estado `--draft` y proceder a la fusión (*merge*):
- [ ] Validar que los criterios de aceptación EARS satisfacen la intención de negocio de Rally.
- [ ] Revisar la idoneidad de los contratos y firmas en `.docs/diseño.md`.
- [ ] Confirmar que no hay credenciales ni dependencias desactualizadas introducidas.
- [ ] Ejecutar el pipeline de CI/CD remoto y comprobar que finaliza en verde.
- [ ] Retirar la marca de Borrador (*Mark as ready*) y aprobar.
