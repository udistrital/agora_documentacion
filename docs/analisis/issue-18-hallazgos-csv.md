# Issue #18 — hallazgos de la primera captura

Fuentes: dos capturas locales de metadatos de pruebas, revisadas el 2026-09-25. Los CSV, scripts y diagrama no se publican. Análisis sin conexión directa a la BD ni inspección de filas. Complementa [el plan](issue-18-diagnostico-modelo-plan.md).

Se confirmó ausencia de SELECT en las 173 columnas y 28 tablas. Ver la interpretación acordada al final: aún debe verificarse la estructura de negocio contenida en los JSON.

## Resultado principal

La base `agora` capturada contiene un único esquema de aplicación, `public`, con 28 tablas ordinarias y 19 secuencias. No aparecen vistas, vistas materializadas, tablas externas ni tablas particionadas en `3.csv`. La configuración, cuentas, permisos y logs explican la estructura visible; aún no se localizan tablas maestras reconocibles de proveedores, solicitudes, ítems u ofertas que permitan mapear el flujo de los manuales.

Esto reduce la hipótesis de «otro esquema oculto por search_path» dentro de esta base: el inventario consultó los catálogos, no solo el esquema activo. Otras bases/servidores y contenido JSON siguen siendo posibilidades. No demuestra dónde se guarda el negocio, ni que el monolito o terceros estén sincronizando datos actualmente.

## Inventario cuantificado

| Dato | Resultado | Evidencia |
|---|---|---|
| Motor / codificación | PostgreSQL / UTF8 | Captura local de contexto |
| Esquemas de aplicación | public, con USAGE | 2.csv |
| Tablas / secuencias / columnas de tablas | 28 / 19 / 173 | 3.csv, 4.csv |
| Claves primarias / foráneas | 25 / 13 | 5.csv |
| UNIQUE adicionales / CHECK declarados | 0 / 0; NOT NULL se captura por columna | 4.csv, 5.csv |
| Índices | 25, todos asociados a las PK inventariadas | 6.csv |
| FK validadas | 13 de 13 con convalidated=true | 5.csv |
| Tablas sin PK | prov_logger, prov_tempformulario, result | 3.csv, 5.csv |
| RLS habilitado | No, en las 28 tablas | 3.csv |
| SELECT a nivel tabla para el rol efectivo | false en las 28 tablas | 3.csv |
| Extensiones instaladas | Solo plpgsql 1.0 | 10.csv |
| Tamaño sumado de las 28 tablas | 14.306.697.216 bytes ≈ 13,324 GiB | 3.csv |

El tamaño es suma de `pg_total_relation_size`, incluye índices y TOAST; no es tamaño de exportación, cantidad de datos útiles ni tamaño total de la base. Las filas son estimaciones de `reltuples`, no conteos exactos.

| Tabla | Filas estimadas | Tamaño GiB |
|---|---:|---:|
| prov_log_cotizacion_historico | 9.776 | 8,525 |
| prov_log_cotizacion | 8.451 | 3,814 |
| prov_log_usuario | 805.081 | 0,547 |
| prov_log_proveedor | 46.837 | 0,376 |
| prov_usuario | 27.829 | 0,014 |
| prov_usuario_subsistema | 28.141 | 0,005 |

Los dos primeros logs concentran el 92,61% del almacenamiento medido. La diferencia entre estimaciones de filas y tamaños amerita revisar vigencia de estadísticas, tamaño de payloads e índices/TOAST antes de estimar tiempos de migración. No prueba por sí sola bloat ni corrupción. No exportar todos los JSON para averiguarlo; comenzar por metadatos y después una muestra limitada/revisada por el DBA.

## Acceso y resultados sin filas

El rol usado no tiene SELECT a nivel de tabla ni de columna, según las dos capturas. Eso no impide leer estos metadatos, pero limita el perfilamiento del contenido. [PostgreSQL distingue permisos de tabla y columna](https://www.postgresql.org/docs/14/functions-info.html#FUNCTIONS-INFO-ACCESS-TABLE).

El responsable confirmó que 7, 8, 9, 11 y 12 finalizaron con cero filas. Significan respectivamente: sin herencia/particiones, sin triggers no internos dentro del filtro, sin rutinas en esquemas de aplicación, sin servidores externos y sin tablas externas. Las FK pueden tener triggers internos excluidos por la consulta 8. No es necesario repetir esas consultas.

Solo `plpgsql` instalado no demuestra una integración ausente: no aparecen las extensiones dblink/postgres_fdw/pg_cron, pero el monolito o un job externo puede conectarse directamente a otros sistemas. Tampoco puede deducirse la dirección de la sincronización.

## Riesgos estructurales verificables

1. **Identidad sin unicidad de documento declarada.** `prov_usuario` tiene PK `id_usuario`, pero no hay UNIQUE de `(tipo_identificacion, identificacion)`. Esto permite varias cuentas con el mismo documento; no demuestra duplicados ni que eso sea inválido para cuentas. Para terceros se necesita resolver identidad de persona de forma independiente.
2. **NOT NULL no garantiza datos completos.** Nombre, apellido, correo, teléfono y tipo tienen defaults vacíos. Identificación tiene default `0` y tipo de identificación `CC`. Verificar blancos y valores de relleno antes de homologar; todavía no se observó su presencia real.
3. **Acción referencial incompatible con nulabilidad.** `prov_rol.estado_registro_id` es NOT NULL, pero su FK usa ON DELETE SET NULL. Borrar un estado que esté referenciado intentaría asignar NULL y fallaría. Definir la política de baja; no reproducir esta contradicción en el destino.
4. **Borrado en cascada de auditoría.** `prov_log_usuario.id_usuario` referencia a usuario con ON DELETE CASCADE; borrar una cuenta puede borrar sus logs. Revisar conservación de historial antes de trasladar esa política. `prov_usuario_subsistema` también tiene cascade desde usuario.
5. **IDs referenciados generados por secuencias.** `prov_rol_subsistema`, `prov_servicio` y `prov_usuario_subsistema` contienen defaults `nextval` en campos de referencia a rol/subsistema. Generar un valor no selecciona una entidad existente: podría fallar la FK o coincidir con una entidad no deseada. Además `prov_rol.rol_id` usa una secuencia diferente (`...seq1`) de varias referencias (`...seq`). Verificar comportamiento del legado; cargar referencias explícitas al migrar.
6. **Relaciones lógicas sin FK.** No están declaradas las relaciones aparentes `prov_bloque_pagina.id_pagina → prov_pagina`, `id_bloque → prov_bloque`, `prov_grupo_menu.id_grupo_padre → prov_grupo_menu` ni `prov_subsistema.id_pagina → prov_pagina`. Son candidatas por nombre; validar valores centinela y semántica antes de contar huérfanos o agregar restricciones.
7. **Combinaciones de autorización sin restricción compuesta.** `prov_usuario_subsistema` y `prov_servicio` referencian rol y subsistema por separado, sin FK compuesta a `prov_rol_subsistema`. La BD no impone que cada par exista allí; verificar si el negocio lo requiere.
8. **Fechas de auditoría como texto.** `prov_log_usuario.fecha_log`, `prov_logger.fecha` y `prov_tempformulario.fecha` son cadenas. Otros logs usan timestamp sin zona. Perfilamiento debe establecer formatos y zona de origen antes de convertirlos; la zona de sesión no demuestra la semántica histórica.
9. **Artefactos sin semántica validada.** `result` es una tabla ordinaria, con una columna booleana `?column?`, sin PK y una fila estimada. No se debe asignarle propósito ni eliminarla sin confirmar dueño/uso.

Las FK están marcadas como validadas; ello acredita su definición/estado, no una auditoría actual de todos los datos ni las relaciones que faltan. No se han probado duplicados, huérfanos, formatos inválidos ni porcentajes de completitud.

## Verificación complementaria de acceso

- `13.csv`: confirma conexión a `agora`; el usuario de conexión y rol efectivo coinciden. Se omite el nombre en este informe porque no hace falta para el diagnóstico público.
- `14.csv`: las 173 columnas de las 28 tablas tienen `select_tabla=false` y `select_columna=false`; USAGE del esquema es true. El responsable también confirma que no puede consultar filas. El acceso actual permite inspeccionar estructura, pero no medir calidad ni extraer una muestra de negocio.
- `15.csv`: los cinco conteos son cero. Quedan confirmados los resultados vacíos anteriores; no hace falta repetirlos.
- El inventario también mostró otras bases del servidor. Se omiten sus nombres, cantidades y permisos de conexión por no ser necesarios para este diagnóstico. No hace falta explorarlas para el siguiente paso: primero se revisará el contenido disponible en Agora.

## Interpretación acordada y siguiente paso

**No se ha demostrado que los datos de negocio estén fuera de esta base.** `prov_usuario` contiene identificación y contacto; `prov_log_proveedor`, `prov_log_cotizacion` y su histórico contienen JSON que podrían representar entidades completas, cambios parciales o resultados de consultas. El inventario relacional no revela esa estructura interna. El nombre «log» no basta para determinar suficiencia ni autoridad como fuente de migración.

El responsable informa que la sincronización normalmente se realiza mediante jobs. Falta identificar los jobs específicos de Agora–terceros y su configuración. Los resultados vacíos de triggers/rutinas no descartan jobs externos.

La prioridad es obtener lectura limitada o resultados ejecutados por el DBA para perfilar `prov_usuario` e inspeccionar muestras desidentificadas de los JSON de proveedores y cotizaciones. Se debe establecer cobertura, relaciones, significado de eventos y regla para reconstruir el estado vigente, sin asumir que el último registro por fecha sea la verdad del negocio. La configuración `prov_dbms` es un insumo complementario si hace falta explicar referencias externas, no prueba de que se deban buscar los datos fuera.

Ver [resumen actualizado y solicitud para el líder](issue-18-resumen-y-requerimientos.md). No se necesita otra ronda de consultas de permisos. Siguen pendientes calidad medida, mapeo completo, estrategia validada, PoC y aprobación técnica.
