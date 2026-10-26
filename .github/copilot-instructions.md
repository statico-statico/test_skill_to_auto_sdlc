# GitHub Copilot Instructions — SDLC Automation Workspace

Directrices de alto nivel y enrutamiento para GitHub Copilot y Modo Agente en este repositorio (Python / Java).

---

## 1. Enrutamiento y Activación

Cuando el usuario mencione un ticket de Rally (`US\d+`, `DE\d+`) o solicite *"automatiza este issue"*, *"de issue a PR"*, *"crea el MR para..."*:
- Delegar la ejecución completa en el agente orquestador `@sdlc-orchestrator` (`.github/agents/sdlc-orchestrator.agent.md`).
- El agente opera bajo el skill `sdlc-automation` (`.github/skills/sdlc-automation/SKILL.md`).

---

## 2. Reglas Maestras Inviolables

1. **Spec-Driven Development:** NUNCA modificar ni crear código funcional sin especificaciones aprobadas en `.docs/requerimientos.md` (EARS) y `.docs/diseño.md`.
2. **Human-in-the-Loop (4 Gates):** Pausar obligatoriamente y requerir confirmación humana en:
   - **Gate 1:** Ingesta y validación de Rally.
   - **Gate 2:** Aprobación de especificaciones técnicas.
   - **Gate 3:** Implementación y pruebas en verde (100%).
   - **Gate 4:** Verificación del Draft MR en GitLab.
3. **Trazabilidad:** Cabecera obligatoria en todo archivo nuevo o modificado:
   - Python: `# Rally: {FormattedID} — Requisito EARS: {ID_REQUISITO}`
   - Java: `// Rally: {FormattedID} — Requisito EARS: {ID_REQUISITO}`
4. **Seguridad Operativa:** Todos los MRs se crean con `--draft`. Prohibido `git push --force` y comandos interactivos sin banderas automáticas (`--yes`).
