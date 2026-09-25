# Issue #18 — resumen de avance y requerimientos

Fecha: 2026-09-25. Estado: diagnóstico estructural realizado; análisis del contenido y migración pendientes.

Issue: https://github.com/udistrital/agora_documentacion/issues/18

## Requerimientos de esta etapa

Para completar el diagnóstico del contenido se requiere:

1. **Acceso de lectura limitado o consultas ejecutadas por el DBA** sobre `prov_usuario`, excluyendo credenciales, y muestras desidentificadas de `prov_log_proveedor`, `prov_log_cotizacion` y `prov_log_cotizacion_historico`. Revisar la estructura de `data` y `query`, tipo de evento, módulo cuando aplique, fecha e identificadores sustitutos consistentes para conservar las relaciones. Las consultas sobre producción deben ser acotadas y coordinadas con el equipo responsable.
2. **Definición funcional de los registros:** determinar si `prov_usuario` representa cuentas, personas/proveedores o ambos; si los JSON contienen registros completos, cambios parciales o resultados de consultas; y cómo se obtiene el estado vigente. Incluir ejemplos desidentificados de creación y modificación de una misma entidad.
3. **Documentación de los jobs de sincronización con terceros:** responsable, código o configuración sin secretos, origen/destino, dirección, frecuencia, campos sincronizados, correspondencia de IDs, manejo de errores/reintentos y evidencia de ejecución y conciliación.
4. **Contrato vigente de terceros:** versión del API/modelo desplegado en producción, diccionario o DDL sin datos y catálogos para homologar identificación y tipos de persona. La documentación y una conciliación realizada por el equipo responsable pueden sustituir el acceso directo a su BD.
5. **Entorno aislado para la PoC:** destino de ensayo y muestra desidentificada. La prueba de concepto de migración no se ejecutará sobre producción ni generará escrituras en servicios productivos.

Estos insumos permitirán verificar si la información de Agora es suficiente, medir calidad y definir el mapeo. **No se ha concluido que los datos de negocio estén fuera de esta BD:** su representación puede estar en los JSON y requiere inspección.

## Qué se obtuvo

| Elemento | Resultado y alcance |
|---|---|
| Revisión funcional | Análisis del issue #5: registro/actualización de personas, actividades económicas, certificados y cotizaciones con roles y decisiones diferenciadas. Es evidencia documental, no prueba del comportamiento desplegado. |
| Inventario de producción | PostgreSQL; base `agora`, esquema de aplicación `public`; 28 tablas, 19 secuencias y 173 columnas. |
| Integridad declarada | 25 PK, 13 FK marcadas como validadas y 25 índices asociados a PK. No equivale a una auditoría del contenido. |
| Acceso | USAGE del esquema, sin SELECT en las 28 tablas ni en sus 173 columnas. |
| Almacenamiento | Aproximadamente 13,32 GiB sumados de tablas, índices y TOAST; `prov_log_cotizacion` y su histórico concentran el 92,61%. No es el tamaño de una futura exportación. |
| Volumen preliminar | Estimaciones: 27.829 filas en `prov_usuario`, 46.837 en `prov_log_proveedor`, 8.451 en `prov_log_cotizacion` y 9.776 en su histórico. No son conteos exactos ni cantidades confirmadas de personas/cotizaciones únicas. |
| Automatización visible en BD | Sin triggers no internos ni rutinas en esquemas de aplicación; sin tablas/servidores externos. Solo extensión plpgsql. Esto no descarta jobs externos. |
| Contexto de sincronización | El responsable informa que normalmente se realiza mediante jobs; falta evidencia del flujo específico Agora–terceros. |
| Referencia de terceros | Se revisaron modelos del repositorio: persona e identificación están separadas. Falta confirmar correspondencia con la versión desplegada. |

Se identificaron riesgos de diseño que requieren validación: documento sin unicidad declarada en cuentas, defaults vacíos o de relleno, una FK con SET NULL sobre una columna NOT NULL, borrado en cascada de auditoría y fechas guardadas como texto. **No se han demostrado duplicados, pérdida de datos ni registros inválidos.**

## Qué falta verificar en el contenido

- **Usuarios y proveedores:** distinguir cuenta de persona y proveedor; comprobar cobertura de naturales/jurídicas, representación legal y actividades económicas. Medir blancos, identificaciones de relleno, documentos repetidos y correspondencia con terceros sin fusionar personas automáticamente.
- **JSON de proveedores y cotizaciones:** identificar campos, versiones de estructura y relaciones. Incluir una muestra pequeña con diferentes eventos/módulos, varias fechas y eventos sucesivos de la misma entidad. Mantener identificadores sustitutos consistentes entre filas para reconstruir relaciones sin exponer información personal.
- **Estado vigente e histórico:** comprobar si los registros son snapshots completos, cambios parciales u otros resultados; verificar el significado de `query`, si refleja operaciones exitosas y cómo se resuelven modificaciones, cancelaciones y eventos repetidos. No ejecutar las consultas encontradas en logs.
- **Jobs:** establecer dirección de sincronización, clave de correspondencia, autoridad de cada campo, bajas, conflictos, reintentos e idempotencia. Una ejecución exitosa no demuestra por sí sola consistencia en ambos extremos.
- **Destino:** confirmar qué datos de personas mantiene terceros y qué entidades corresponden a Agora; mantener referencias a SICAPITAL para información financiera, Argo para contratos y Titán para nómina según el contexto informado, verificando las integraciones que realmente aplican al alcance.

## Pendientes del issue

| Entregable | Estado / dependencia |
|---|---|
| Inventario estructural | Realizado para la base capturada; falta documentar estructura interna de JSON y validar significado funcional. |
| Volumen y calidad | Solo tamaños y estimaciones; faltan conteos exactos y controles agregados con acceso de lectura o apoyo del DBA. |
| Matriz origen–destino | Pendiente del contenido, reglas de identidad y contrato desplegado de terceros. |
| Transformación y limpieza | Pendiente de hallazgos medidos y reglas acordadas; no hay cambios ejecutados sobre la BD. |
| Estrategia de migración | Existe plan preliminar; falta ajustarlo al comportamiento de los jobs, orden de carga, corte y recuperación. |
| PoC (prueba de concepto) | No ejecutada. Requiere muestra representativa desidentificada y destino aislado; medir tiempos, validar transformaciones/relaciones y probar reejecución y recuperación. El issue exige 100% de consistencia e integridad de la muestra evaluada. |
| Revisión y aprobación | Pendiente del líder técnico/arquitecto. |

## Evidencia revisada

- [Análisis funcional del issue #5](issue-5-roles-modulos-agora-v1.md).
- Capturas de metadatos conservadas localmente y excluidas de Git. Los resultados vacíos fueron confirmados por el responsable y mediante conteos explícitos.
- [Hallazgos detallados](issue-18-hallazgos-csv.md).
- [Plan inicial de diagnóstico y migración](issue-18-diagnostico-modelo-plan.md).

Este resumen no acredita cierre del issue. El análisis realizado se limita a metadatos; no se modificaron datos ni permisos de la BD.
