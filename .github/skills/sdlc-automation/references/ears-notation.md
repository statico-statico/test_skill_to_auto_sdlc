# Quick Reference: EARS Notation (Easy Approach to Requirements Syntax)

Mandatory syntax standard for translating Rally acceptance criteria into testable specifications in `.docs/requirements.md`.

---

## 1. The 5 Core EARS Patterns

| Pattern | Syntactic Structure | When to Use |
| :--- | :--- | :--- |
| **Ubiquitous** | `THE SYSTEM SHALL <action>` | Continuous, system-wide constraint without a trigger. Always active. |
| **Event-Driven** | `WHEN <trigger>, THE SYSTEM SHALL <action>` | Immediate response to a specific event or external stimulus. |
| **State-Driven** | `WHILE <active state>, THE SYSTEM SHALL <action>` | Behavior that applies only while the system is in a given state. |
| **Optional Feature** | `WHERE <feature is enabled>, THE SYSTEM SHALL <action>` | Behavior applicable only when a configuration or feature flag is enabled. |
| **Unwanted Behavior** | `IF <error condition/exception>, THE SYSTEM SHALL <action>` | Handling exceptions, invalid input, timeout, or external failure. |

---

## 2. Compound Patterns

For requirements triggered by an event while in a specific state or handling errors in a state:
- `WHILE <state>, WHEN <trigger>, THE SYSTEM SHALL <action>`
- `WHILE <state>, IF <error condition>, THE SYSTEM SHALL <recovery action>`

---

## 3. Concrete Examples

- **Ubiquitous:** `THE SYSTEM SHALL encrypt all session tokens at rest using AES-256-GCM.`
- **Event-Driven:** `WHEN the user submits a valid renewal request, THE SYSTEM SHALL extend session expiration by 15 minutes.`
- **State-Driven:** `WHILE the user session remains authenticated, THE SYSTEM SHALL respond to heartbeat requests within 200 ms.`
- **Optional Feature:** `WHERE the 'AUDIT_LOG_VERBOSE' flag is enabled, THE SYSTEM SHALL record HTTP headers in the audit trail.`
- **Unwanted Behavior:** `IF the provided token has expired, THE SYSTEM SHALL return HTTP 401 Unauthorized and invalidate the session in cache.`

---

## 4. Syntax Rules
- Every requirement MUST start with its uppercase keyword (`WHEN`, `WHILE`, `IF`, `WHERE`, `THE SYSTEM SHALL`).
- Avoid vague terms ("fast", "secure", "user-friendly"). Always state measurable thresholds (e.g., ms, HTTP status codes, specific algorithms).
