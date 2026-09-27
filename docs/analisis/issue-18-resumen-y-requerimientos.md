# Issue #18 — resumen y requerimientos de la etapa actual

Actualizado: 2026-09-27. Entorno vigente: **pruebas**, tanto Agora como terceros.

## Corrección de la evidencia

La captura inicial se realizó sobre una base incorrecta para el alcance. El diagnóstico anterior queda sustituido: no deben utilizarse sus cifras, ausencia de tablas de negocio, restricciones de lectura ni conclusiones sobre logs para diseñar la migración.

Se repitió el análisis con las capturas locales `AgoraFinal` y `Terceros`, contrastándolas con [la issue #5](issue-5-roles-modulos-agora-v1.md). Los nombres de carpeta no son nombres SQL de bases. El esquema relevante es `agora` en una conexión y `terceros` en la otra. Los CSV y scripts permanecen excluidos del repositorio.

## Resultados

| Evidencia | Agora | Terceros |
|---|---:|---:|
| Tablas / columnas del esquema seleccionado | 46 / 340 | 13 / 112 |
| PK / FK | 45 / 70 | 13 / 16 |
| UNIQUE adicionales | 5 | 0 |
| Acceso SELECT | Todas las tablas del esquema | Todas las tablas del esquema |

Agora sí contiene entidades relacionales de personas, proveedores, representantes, actividades, solicitudes, ítems, ofertas, respuestas, validaciones y modificaciones. La inspección de JSON deja de ser el mecanismo principal para descubrir esas entidades; sigue siendo necesaria para el historial de cambios.

La correspondencia estructural más importante con #5 es: `objeto_cotizacion` como posible cabecera, `solicitud_cotizacion` como asociación por proveedor y entidades separadas para respuesta del solicitante y validación del ordenador. Debe validarse en el aplicativo; no se deduce autorización a partir de tablas.

Terceros separa persona, identificación, clasificación, complementos, vinculaciones y seguridad social. El mapeo requiere homologación de catálogos y conciliación con personas existentes. No hay una restricción UNIQUE de documento por tipo en el esquema capturado: hay que medir coincidencias ambiguas, no asumir que existen ni que no existen.

## Requerimientos de esta etapa

1. **Perfilamiento en pruebas:** ejecutar las consultas agregadas preparadas para cada esquema: conteos seleccionados, documentos vacíos, correspondencias natural/jurídica–proveedor, duplicidad normalizada, coherencia de ítems/ofertas y catálogos. Ya no se requiere solicitar SELECT como primer paso.
2. **Validación funcional:** confirmar la equivalencia de entidades con pantallas, estados, modificación de respuestas, decisión del solicitante y aprobación/rechazo del ordenador. Precisar el alcance de sociedades, evaluaciones, inhabilidades y certificados.
3. **Homologación con terceros:** revisar catálogos de identificación, contribuyente, tipo de tercero y complementos; definir representación legal, contactos, CIIU y seguridad social sin inventar códigos ni vigencias.
4. **Jobs de sincronización:** obtener código/configuración sin secretos, dirección, claves, frecuencia, manejo de cambios/bajas y evidencia de conciliación; confirmar compatibilidad temporal de ambas copias de pruebas.
5. **Almacenamiento:** explicar el tamaño de respuesta_cotizacion_solicitante mediante métricas de heap/índices/TOAST y estadísticas, antes de inspeccionar/exportar su texto o extrapolar tiempos.
6. **PoC aislada:** acordar muestra desidentificada y destino de ensayo, con verificaciones de transformación, integridad, reejecución y recuperación. No realizar escrituras en producción.

## Entregables y pendientes

- **Realizado:** inventario estructural de ambos esquemas; correspondencia con funciones de #5; riesgos sustentados por restricciones; propuesta de responsabilidades y mapeo preliminar; consultas locales de siguiente fase.
- **Pendiente de resultados:** calidad real de filas, conteos exactos, conciliación entre bases y verificación de los jobs. Las cifras del catálogo siguen siendo estimaciones.
- **Pendiente de definición:** matriz completa campo a campo, decisiones de destino y reglas de transformación aprobadas.
- **Pendiente de ejecución:** PoC medida y validada, estrategia de corte/rollback ajustada a resultados y aprobación técnica exigida por #18.

Ver [diagnóstico detallado](issue-18-hallazgos-csv.md) y [propuesta de mapeo y migración](issue-18-diagnostico-modelo-plan.md). No se han ejecutado las nuevas consultas contra las bases ni modificado datos o permisos.
