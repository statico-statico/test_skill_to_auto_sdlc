# Especificación de Requerimientos: {RALLY_FORMATTED_ID} — {TITLE}

> **Identificador Rally:** `{RALLY_FORMATTED_ID}`  
> **Título de la Historia:** {TITLE}  
> **Iteración / Sprint:** {ITERATION_NAME}  
> **Fecha de Generación:** {DATE}  
> **Estado en Rally:** {SCHEDULE_STATE}  
> **Generado por:** Copilot SDLC Automation Agent  

---

## 1. Descripción Funcional

{PROCESSED_DESCRIPTION}
*(Descripción depurada de la historia de usuario original de Rally, habiendo eliminado artefactos HTML y reformulado la intención técnica y de negocio de forma clara).*

---

## 2. Historia de Usuario

- **Como** {ROL_O_ACTOR},
- **quiero** {CAPACIDAD_O_ACCION_SOLICITADA},
- **para** {BENEFICIO_DE_NEGOCIO_O_VALOR_APORTADO}.

---

## 3. Criterios de Aceptación (Notación EARS)

### 3.1 Requisitos Conducidos por Eventos (CUANDO)
- **REQ-EVT-01:** CUANDO {evento_disparador_1}, EL SISTEMA DEBERÁ {accion_respuesta_1} EN MENOS DE {SLA_TIEMPO}.
- **REQ-EVT-02:** CUANDO {evento_disparador_2} Y {condicion_adicional}, EL SISTEMA DEBERÁ {accion_respuesta_2}.

### 3.2 Requisitos Conducidos por Estado (MIENTRAS)
- **REQ-STA-01:** MIENTRAS {estado_activo_o_condicion_permanente}, EL SISTEMA DEBERÁ {comportamiento_continuo}.

### 3.3 Requisitos Opcionales o Condicionales (DONDE)
- **REQ-OPT-01:** DONDE {caracteristica_o_flag_habilitado}, EL SISTEMA DEBERÁ {comportamiento_especifico}.

### 3.4 Requisitos de Manejo de Errores y Comportamiento Indeseado (SI)
- **REQ-NEG-01:** SI {condicion_de_fallo_o_dato_invalido}, EL SISTEMA DEBERÁ {accion_de_recuperacion_y_notificacion}.
- **REQ-NEG-02:** SI {recurso_o_servicio_externo_no_disponible}, EL SISTEMA DEBERÁ {mecanismo_fallback_o_reintento}.

### 3.5 Requisitos Ubicuos (SIEMPRE)
- **REQ-UBI-01:** EL SISTEMA DEBERÁ {restriccion_general_que_siempre_aplica}.

---

## 4. Requisitos No Funcionales (NFR)

| Categoría | Especificación del Requisito | Métrica / Umbral Verificable |
| :--- | :--- | :--- |
| **Rendimiento** | {descripcion_requisito_rendimiento} | Latencia < {TIEMPO_MS} ms (p95) |
| **Seguridad** | {descripcion_requisito_seguridad} | Cifrado {ALGORITMO}, validación de entrada OWASP |
| **Disponibilidad** | {descripcion_mecanismo_tolerancia_fallos} | Recuperación ante caída en < {SEGUNDOS} s |
| **Observabilidad** | {descripcion_trazabilidad_y_logs} | Logs estructurados JSON con correlation ID |

---

## 5. Fuera de Alcance (Out of Scope)

- {ELEMENTO_EXCLUIDO_1: lo que explícitamente no se implementará en este ticket}
- {ELEMENTO_EXCLUIDO_2: funcionalidades aplazadas para iteraciones futuras}

---

## 6. Preguntas Abiertas y Supuestos

- [ ] {PREGUNTA_1: ambigüedad detectada que requiere validación del PO/Arquitecto}
- [x] {SUPUESTO_1: premisa asumida para el desarrollo del diseño técnico}

---

## 7. Matriz de Trazabilidad Rally

| Atributo Rally | Valor Ingerido |
| :--- | :--- |
| **FormattedID** | `{RALLY_FORMATTED_ID}` |
| **Name** | `{TITLE}` |
| **ScheduleState Original** | `{SCHEDULE_STATE}` |
| **Owner** | `{OWNER_NAME}` |
| **Project** | `{PROJECT_NAME}` |
| **Iteration** | `{ITERATION_NAME}` |
