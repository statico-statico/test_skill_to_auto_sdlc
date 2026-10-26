# Rally WSAPI Field Mapping & State Machine

## 1. WSAPI Attribute Mapping

| Rally WSAPI Field | Data Type | SDLC Target | Usage | Required |
| :--- | :--- | :--- | :--- | :--- |
| `FormattedID` | String (e.g., `US10293`, `DE4512`) | All Artifacts | Primary identifier in branch, commit, MR, headers | Yes |
| `ObjectID` | Long (e.g., `718293849102`) | API / Payload | Numeric ID for WSAPI updates (`POST /hierarchicalrequirement/{ObjectID}`) | Yes |
| `Name` | String | `requirements.md`, Git, MR | Story title / commit header | Yes |
| `Description` | Rich Text (HTML) | `requirements.md` | Functional description & User Story (As a / I want / So that) | Yes |
| `AcceptanceCriteria` | Rich Text (HTML) | `requirements.md` | Input to synthesize formal EARS requirements | Yes |
| `Notes` | Rich Text (HTML) | `requirements.md` | Additional context, dependencies, or caveats | No |
| `ScheduleState` | Enum String | Flow Control | State machine & gate validation | Yes |
| `Owner._refObjectName` | String | `report.md` | Assigned developer/owner | No |
| `Iteration.Name` | String | `requirements.md`, Git | Sprint/Iteration label | No |
| `Project.Name` | String | `report.md` | Team / Project name | No |
| `Tags` | Collection | GitLab MR | MR labels (`--label "bot-generated,US10293,{tag}"`) | No |

---

## 2. State Machine Rules (`ScheduleState`)

```
[Defined] ──────► [In-Progress] ──────► [Completed] ──────► [Accepted]
   ▲                     ▲                     ▲                   ▲
   │                     │                     │                   │
   │ Phase 1: Ingest     │ Phase 3: Code/Test  │ Phase 5: MR Ready │ Human Only
   │ Agent promotes      │ Agent implements    │ Agent completes   │ (Product Owner)
```

| Current State in Rally | Agent Action | Policy & Security Rationale |
| :--- | :--- | :--- |
| **`Defined`** | Promote to `In-Progress` via WSAPI and continue. | Item is ready for development; updates `inProgressDate`. |
| **`In-Progress`** | Continue without state change. | Development already underway. |
| **`Completed`** | **Warn user** and request explicit confirmation. | Possible unintended re-processing or scope rework. |
| **`Accepted`** | 🛑 **ABORT IMMEDIATELY**. | Accepted items are immutable per audit and compliance policies. |

---

## 3. HTML Sanitization (Rally Rich Text → Markdown)
Strip HTML tags (`<div>`, `<p>`, `<span>`, `&nbsp;`, `<ul>`, `<li>`) into clean Markdown paragraphs and bullet lists before populating `.docs/requirements.md`.
