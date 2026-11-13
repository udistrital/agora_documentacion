# Issue #66 — Matriz de escenarios de integración

## Objetivo
Validar el registro, actualización y consulta de proveedores mediante agora_mid, comprobando respuestas HTTP, relaciones y persistencia real en PostgreSQL.

## A. Registro de proveedores

| ID | Escenario | Tipo | Validación esperada |
|---|---|---|---|
| REG-01 | Registro mínimo de proveedor natural | Natural | Creación correcta y persistencia |
| REG-02 | Registro completo de proveedor natural | Natural | Persistencia de tercero, identificación y datos naturales |
| REG-03 | Registro mínimo de proveedor jurídico | Jurídico | Creación correcta y persistencia |
| REG-04 | Registro completo de proveedor jurídico | Jurídico | Persistencia de tercero y datos jurídicos |
| REG-05 | Registro con contactos | Ambos | Creación y asociación de contactos |
| REG-06 | Registro con cuentas bancarias | Ambos | Creación y asociación de cuentas |

## B. Consulta

| ID | Escenario | Validación esperada |
|---|---|---|
| CON-01 | Consultar proveedor natural | Respuesta con información y relaciones |
| CON-02 | Consultar proveedor jurídico | Respuesta con información y relaciones |
| CON-03 | Consultar proveedor inexistente | Respuesta controlada |
| CON-04 | Consultar listado de proveedores | Resultados y paginación correctos |

## C. Actualización

| ID | Escenario | Validación esperada |
|---|---|---|
| ACT-01 | Actualización de proveedor natural | Cambios persistidos |
| ACT-02 | Actualización de proveedor jurídico | Cambios persistidos |
| ACT-03 | Actualización parcial | Conservación de campos no modificados |
| ACT-04 | Actualización de contactos | Relación actualizada sin duplicados |
| ACT-05 | Actualización de cuenta bancaria | Relación actualizada sin duplicados |
| ACT-06 | Intento de modificar campos protegidos | Operación rechazada según contrato |

## D. Validaciones y relaciones

| ID | Escenario | Validación esperada |
|---|---|---|
| VAL-01 | Payload sin campos obligatorios | Rechazo controlado |
| VAL-02 | Tipo de registro inconsistente | Rechazo controlado |
| VAL-03 | Identificación duplicada | No generar duplicados |
| VAL-04 | Relación con identificador inexistente | Error o advertencia según contrato |
| VAL-05 | Relación perteneciente a otro proveedor | No asociar indebidamente |
| VAL-06 | Envío de campos no permitidos | Rechazo controlado |

## E. Reintentos y recuperación

| ID | Escenario | Validación esperada |
|---|---|---|
| REC-01 | Repetir registro con misma clave natural | Comportamiento idempotente |
| REC-02 | Fallo temporal de terceros_crud | Error identificado y trazable |
| REC-03 | Fallo temporal de gestion_personas_crud | Error identificado y trazable |
| REC-04 | Recuperación después de fallo | Operación reintentada correctamente |
| REC-05 | Fallo durante creación de una relación | Resultado parcial identificado y verificable |
| REC-06 | Aislamiento entre ejecuciones | Sin contaminación de datos |

## F. Verificación de persistencia

| ID | Verificación | Evidencia |
|---|---|---|
| BD-01 | Registro principal del proveedor | Consulta SQL |
| BD-02 | Registro del tercero | Consulta SQL |
| BD-03 | Identificación asociada | Consulta SQL |
| BD-04 | Rama natural o jurídica | Consulta SQL |
| BD-05 | Contactos asociados | Consulta SQL |
| BD-06 | Cuentas bancarias asociadas | Consulta SQL |
| BD-07 | Ausencia de duplicados | Consulta SQL |
| BD-08 | Integridad de relaciones | Consultas SQL |

## Criterios de ejecución

- Utilizar datos sintéticos.
- Identificar cada ejecución mediante un identificador único.
- Ejecutar las operaciones a través del MID.
- Verificar la persistencia directamente en las bases de datos.
- Registrar solicitud, respuesta HTTP y resultado SQL.
- Clasificar cada escenario como APROBADO, FALLIDO o BLOQUEADO.
- No considerar aprobado un escenario cuya verificación obligatoria no se haya ejecutado.

## Estado

Matriz inicial elaborada. Los payloads y resultados esperados específicos deberán ajustarse a los contratos reales de los servicios CRUD.
