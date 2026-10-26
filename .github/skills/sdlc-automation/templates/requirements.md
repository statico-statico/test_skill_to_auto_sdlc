# Requirements Specification: {RALLY_FORMATTED_ID} — {TITLE}

> **Rally FormattedID:** `{RALLY_FORMATTED_ID}`  
> **Title:** {TITLE}  
> **Iteration:** {ITERATION_NAME}  
> **Generation Date:** {DATE}  
> **Rally State:** {SCHEDULE_STATE}  
> **Author / Agent:** SDLC Orchestrator Agent  

---

## 1. Functional Overview

{PROCESSED_DESCRIPTION}
*(Normalized business and technical intent extracted from Rally, free of HTML artifacts).*

---

## 2. User Story

- **As a** {ROLE_OR_PERSONA},
- **I want to** {CAPABILITY_OR_ACTION},
- **So that** {BUSINESS_VALUE_OR_BENEFIT}.

---

## 3. Acceptance Criteria (EARS Notation)

### 3.1 Event-Driven Requirements (WHEN)
- **REQ-EVT-01:** WHEN {trigger_event_1}, THE SYSTEM SHALL {system_response_1} IN LESS THAN {SLA_TIME}.
- **REQ-EVT-02:** WHEN {trigger_event_2} AND {precondition}, THE SYSTEM SHALL {system_response_2}.

### 3.2 State-Driven Requirements (WHILE)
- **REQ-STA-01:** WHILE {active_state_or_condition}, THE SYSTEM SHALL {continuous_behavior}.

### 3.3 Optional / Conditional Requirements (WHERE)
- **REQ-OPT-01:** WHERE {feature_flag_or_option_enabled}, THE SYSTEM SHALL {specific_behavior}.

### 3.4 Unwanted Behavior / Error Handling (IF)
- **REQ-ERR-01:** IF {error_condition_or_invalid_input}, THE SYSTEM SHALL {recovery_and_notification_action}.
- **REQ-ERR-02:** IF {external_service_unavailable}, THE SYSTEM SHALL {fallback_or_retry_action}.

### 3.5 Ubiquitous Requirements (ALWAYS)
- **REQ-UBI-01:** THE SYSTEM SHALL {continuous_system_wide_constraint}.

---

## 4. Non-Functional Requirements (NFR)

| Category | Specification | Measurable Threshold / SLA |
| :--- | :--- | :--- |
| **Performance** | {latency_throughput_spec} | Latency < {TIME_MS} ms (p95) |
| **Security** | {auth_encryption_spec} | {CIPHER_SPEC}, OWASP input validation |
| **Availability** | {fault_tolerance_spec} | Recovery in < {SECONDS} s |
| **Observability** | {logging_metrics_spec} | Structured JSON logs with correlation ID |

---

## 5. Out of Scope

- {Explicitly list boundaries, features, and edge cases not covered by this user story}
