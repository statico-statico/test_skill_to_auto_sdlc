# Quality & Security Checklist (Python / Java)

Mandatory criteria to verify before approving code changes and issuing a Merge Request. Corresponds to section 4 in `.docs/report.md`.

---

## 1. SOLID Design Principles
- [ ] **SRP:** Each class, function, or module has a single responsibility (controllers handle no business logic; entities perform no direct I/O).
- [ ] **OCP:** Open for extension via composition, strategies, or dependency injection; closed for modification of tested core logic.
- [ ] **LSP:** Derived types and sub-implementations are substitutable without altering expected behavior or throwing unexpected exceptions.
- [ ] **ISP:** Small, focused interfaces/protocols tailored to consumer needs.
- [ ] **DIP:** High-level modules depend on abstractions (interfaces/ports), never on concrete infrastructure details.

---

## 2. Essential OWASP Top 10 Security
- [ ] **No Secrets (A02):** Zero API keys, passwords, or tokens hardcoded in source. Use environment variables or secret vaults.
- [ ] **Injection Prevention (A03):** Parameterized SQL queries and secure ORM usage (SQLAlchemy, Spring Data JPA).
- [ ] **Broken Access Control (A01):** Authorization checks enforced in business/service layers, never relying on client validation alone.
- [ ] **Input Validation (A04):** Strictly typed schemas (Pydantic in Python, Bean Validation / Hibernate Validator in Java).
- [ ] **Cryptographic Hygiene (A02):** Industry-standard algorithms (AES-256-GCM, bcrypt/Argon2 for passwords, SHA-256).
- [ ] **Security Logging (A09):** Structured JSON logs with UTC timestamps, omitting PII, tokens, or credentials.

---

## 3. Code Hygiene & Standards
- [ ] **Inline Traceability:** Header comment at the top of each created or modified file:
  - Python: `# Rally: {FormattedID} — EARS Requirement: {REQ_ID}`
  - Java: `// Rally: {FormattedID} — EARS Requirement: {REQ_ID}`
- [ ] **DRY (Don't Repeat Yourself):** Shared logic extracted to reusable services or utility modules.
- [ ] **Defensive Error Handling:** Handled with typed domain exceptions and semantic HTTP status codes.
- [ ] **Test Coverage:** 100% test pass rate (`pytest` or `mvn/gradle test`) with ≥ 80% coverage.
