# Issue #18 — jobs operativos y responsabilidad de terceros

Fecha: 2026-09-30. Se pudo abrir el paquete Talend local `argo.zip` y leer sus XML sin ejecutar jobs ni conectarse a las BD. El paquete y sus metadatos de conexión no se publican. Este documento omite credenciales, usuarios y servidores.

## Alcance vigente y evidencia productiva

El trabajo actual y el próximo sprint se limitan al registro de personas: contrato con terceros y estructura/API propia de Agora para las vistas revisadas. Toda identidad nueva se crea en terceros, incluso sin contrato; se reutiliza la existente cuando corresponda y Agora conserva su ID. Los jobs confirmados son de producción; su selección contractual histórica no condiciona las altas nuevas. Argo mantiene las vinculaciones de contratistas en terceros. La estructura de pruebas se considera una base aplicable a producción bajo la equivalencia habitual informada, con verificación puntual antes del despliegue; las cifras de datos no se extrapolan. Cotizaciones, respuestas, validaciones y otros módulos se abordarán después.


## Alcance y evidencia

Se identificaron 12 definiciones de jobs en el paquete. Para el flujo de personas se revisaron `terceros_juridicos_0.1.item` y los tramos de altas de persona/identificación y vinculación de `vinculacion_0.1.item`, bajo process/OAS/oas/core. Hay además jobs de funcionarios, contratos, perfiles y otras integraciones: no se presume que todos pertenezcan al alcance de Agora ni se hizo su auditoría completa.

**El responsable confirma que los jobs recibidos son los desplegados en producción y están funcionando.** La premisa funcional comunicada es que el trabajador mantiene sus datos más actualizados en Agora y por eso el flujo alimenta terceros desde Agora. Se distingue el origen de captura (Agora legado) del dueño de persistencia para el nuevo registro (terceros). Los atributos transferidos que se detallan abajo quedan establecidos como responsabilidad de terceros, tanto en consulta como en alta/actualización.

La versión 0.1 es la del archivo revisado. Ya no está pendiente confirmar el despliegue; sí recoger métricas/rechazos y conciliar resultados, precisar frecuencia y completar la revisión de actualizaciones/bajas. La confirmación operativa no cambia los INSERT observados en estas altas ni demuestra que estos tramos actualicen registros existentes. La estructura de pruebas se toma como base para producción según la equivalencia habitual informada; las métricas productivas se verificarán cuando se aborde la conciliación/migración y no bloquean el registro del sprint.

## Transferencias observadas

| Flujo | Origen / selección | Escrituras observadas |
|---|---|---|
| terceros_juridicos | informacion_persona_juridica de Agora: NIT, dígito y nombre | INSERT a terceros.tercero y terceros.datos_identificacion. |
| vinculacion, tramo de persona natural | informacion_proveedor e informacion_persona_natural de Agora combinadas con contratos, actas y novedades de Argo; selección con vigencia 2026 y condiciones de fechas | INSERT a terceros.tercero y terceros.datos_identificacion. También INSERT a terceros.vinculacion; su mapeo y alcance se detallan abajo. |

El segundo flujo no es evidencia de sincronización de **todas** las personas naturales registradas en Agora: selecciona una población contractual. Que el nuevo registro de persona requiera contrato no está establecido por este job.

## Atributos responsabilidad de terceros y tabla de destino

| Tabla y atributo en el esquema terceros | Persona natural (vinculacion, tMap_5/6) | Persona jurídica (terceros_juridicos, tMap_5/6) |
|---|---|---|
| tercero.nombre_completo | nom_proveedor del origen | nom_proveedor jurídico |
| tercero.primer_nombre, segundo_nombre, primer_apellido, segundo_apellido | Campos homónimos de persona natural | Sin expresión de origen en el mapa |
| tercero.fecha_nacimiento | fecha_nacimiento del origen | Sin expresión de origen |
| tercero.lugar_origen | Constante 0 | Constante 0 |
| tercero.tipo_contribuyente_id | Constante 1 | Constante 2 |
| tercero.usuario_wso2 | Documento leído como cedula | NIT |
| tercero.activo | true | true |
| tercero.fecha_creacion / fecha_modificacion | Fecha de ejecución | Fecha de ejecución |
| datos_identificacion.tipo_documento_id | Constante 3 (CC en catálogo de pruebas) | Constante 7 (NIT en catálogo de pruebas) |
| datos_identificacion.numero | cedula procedente de num_documento del proveedor | num_nit_empresa |
| datos_identificacion.digito_verificacion | Dígito de persona natural en la segunda lectura | Dígito jurídico |
| datos_identificacion.fecha_expedicion | fecha_expedicion_documento | Sin expresión de origen |
| datos_identificacion.ciudad_expedicion / documento_soporte | Sin valor de origen asignado en los mapas revisados | Sin valor de origen asignado |
| datos_identificacion.tercero_id | Lookup del tercero por usuario_wso2 = documento | Lookup del tercero por usuario_wso2 = NIT |
| datos_identificacion.activo y fechas | true y fecha de ejecución | true y fecha de ejecución |

Estas constantes describen el job, **no son reglas recomendadas para el formulario**. No fijar CC para toda persona natural, no usar 0 como lugar real ni equiparar documento y usuario de identidad sin confirmar contrato. La auditoría creada por el job no conserva necesariamente la fecha histórica de alta de Agora.

Los campos sin expresión de origen se muestran para delimitar el job: no se presentan como datos transferidos. `id` es generado en destino; `datos_identificacion.tercero_id` relaciona la identificación con `terceros.tercero.id`. Los campos de auditoría/clasificación generados por el job también pertenecen a terceros, pero no son datos que deba pedir el formulario.

No se observan en estas altas escrituras de dirección, correo, teléfonos, datos bancarios, régimen, actividad económica, representante legal o anexos hacia complementos de terceros. Para el registro nuevo se propone su distribución explícita en el [modelo inicial de Agora CRUD](issue-18-responsabilidades-y-modelo-inicial-crud.md). La ausencia en el job fundamenta el alcance de esa propuesta, no una afirmación de que terceros carezca de soporte genérico.

## Vinculación: escritura confirmada y corrección de cobertura

La revisión anterior detalló solo persona e identificación y dejó sin desarrollar la etapa de vinculaciones. Al revisar nuevamente las 12 definiciones y seguir las conexiones de los componentes se confirma una salida a **`terceros.vinculacion`** en `vinculacion_0.1.item`: `tMap_3` → flujo `vinculacion` → `tDBOutput_1`, configurado con esquema `terceros`, tabla `vinculacion` y acción **INSERT**. Estos datos también quedan bajo responsabilidad de terceros.

### Persona natural: origen y destino por campo

| Columna de terceros.vinculacion | Expresión del mapa / origen | Interpretación para el nuevo diseño |
|---|---|---|
| `tercero_principal_id` | `row2.tercero_id`, obtenido de `terceros.datos_identificacion` mediante número = `user.cedula` | Referencia a la persona natural; no es el ID del proveedor ni el número documental. |
| `tercero_relacionado_id` | Sin expresión, nullable | Este flujo no relaciona dos personas. No acredita una relación representante–empresa o miembro–consorcio. |
| `tipo_vinculacion_id` | Constante `290` | ID usado por este flujo; confirmar catálogo y significado antes de reutilizarlo en el MID. |
| `cargo_id` | Constante `313` | Clasificación del flujo; no es el cargo declarado del representante legal. |
| `dependencia_id` | `row6.id_master`, lookup de `transaccional.mapeo_dependencias` por `id_argo = user.cod_dependencia` | Homologación de dependencia procedente del contexto contractual; no copiar sin traducción el código legado. |
| `soporte` | Sin expresión, nullable | No se transfiere un soporte en este mapa. |
| `periodo_id` | Constante `47` | Período del flujo; no inferir etiqueta/vigencia del catálogo solo a partir de este número. |
| `fecha_inicio_vinculacion` | `user.fecha_inicio` | Fecha seleccionada/derivada de actas y novedades contractuales de Argo. |
| `fecha_fin_vinculacion` | `user.fecha_fin` | Fecha seleccionada/derivada de actas y novedades contractuales de Argo. |
| `activo` | `true` | Estado de la vinculación, distinto de persona activa y de proveedor registrado. |
| `fecha_creacion` | `TalendDate.getCurrentDate()` | Auditoría del INSERT. |
| `fecha_modificacion` | `TalendDate.getCurrentDate()` | Auditoría del INSERT; no demuestra actualización posterior. |

El tramo fuente `tDBInput_10` combina personas/proveedores de Agora con contratos, actas de inicio, novedades y dependencia del supervisor de Argo. Filtra vigencia **2026**, inicio posterior al **2026-07-01**, fechas no nulas y distintas. Por tanto, no produce una vinculación para cada persona que diligencia el registro. Las fechas corresponden al contexto contractual; no deben reemplazarse por fecha de registro de proveedor.

Antes del INSERT, `tMap_4` excluye coincidencias de número documental con vinculaciones de `periodo_id = 47` y `tipo_vinculacion_id = 290`. El lookup no discrimina número de contrato y usa número documental sin tipo. `tMap_3` requiere coincidencias para persona y dependencia mediante inner joins. Revisar cobertura de múltiples contratos, documentos ambiguos y dependencias sin homologación; el `DISTINCT` del origen incluye atributos contractuales y no garantiza una fila por persona. La salida tiene `DIE_ON_ERROR = false`, por lo que debe conciliarse el resultado y los rechazos.

El mismo archivo contiene una rama con período 40 y salida de mapa `copyOfvinculacion`, pero esta no tiene conexión a un componente de escritura: no se contabiliza como otra carga a la tabla.

### Otros jobs del paquete

- **`terceros_juridicos_0.1`:** no se encontró salida hacia `terceros.vinculacion`. Para jurídicas se mantienen las transferencias comprobadas a `tercero` y `datos_identificacion`; no se extiende el mapeo contractual natural a jurídicas ni consorcios.
- **`vinculacion_funcionarios_0.1`:** también contiene un INSERT a `terceros.vinculacion` (`tMap_3` → `tDBOutput_1`). Mapea persona por identificación, `tipo_vinculacion_id = user.CAR_COD`, `cargo_id = user.CAR_TC_COD`, dependencia homologada con sustitución 0 → 2, período 40, inicio `user.EMP_DESDE` y fin fijo 2026-12-31; relacionado/soporte sin expresión, activo true y fechas técnicas de ejecución. Se registra como flujo adicional de funcionarios, sin convertirlo en contrato de registro de proveedores.
- Ese job incluye además un componente UPDATE de `dependencia_id` por `vinculacion.id` (`tDBOutput_4`), pero está **desactivado** (`ACTIVATE = false`) en el paquete revisado. Su presencia no acredita una actualización operativa. No se generaliza la observación de INSERT de las altas a todos los componentes del paquete.

### Consecuencia para MID y Agora CRUD

**Argo debe crear, actualizar y mantener las vinculaciones de contratistas mediante terceros**, donde residen en `terceros.vinculacion`. Agora MID no administra esas vinculaciones en el sprint de registro; una eventual consulta futura no transfiere su mantenimiento a Agora. La propuesta de Agora CRUD no debe duplicar este vínculo contractual, cargo, período, dependencia y fechas como un maestro propio. **Dar de alta un proveedor no implica crear automáticamente una vinculación tipo 290.** El disparador observado es contractual y depende de Argo, fuera del registro actual.

La representación legal y la pertenencia a consorcios siguen siendo relaciones propuestas para el registro de Agora, distintas del vínculo observado. Antes de cerrarlas se debe evaluar si `terceros.vinculacion` y sus catálogos soportan esas relaciones genéricas; el job no lo demuestra porque no asigna `tercero_relacionado_id`. Si se acuerda esa reutilización, se ajustará el propietario sin duplicar relaciones en ambos servicios.

## Conciliación y riesgos a validar

- Antes de insertar tercero, el lookup lee número e ID de tercero desde datos_identificacion y compara únicamente el número; no filtra por tipo de documento ni activo. El mapa usa UNIQUE_MATCH y salida de rechazo de inner join para las altas sin coincidencia. Revisar el comportamiento frente a documentos ambiguos ya encontrados en pruebas.
- Para insertar identificación se vuelve a leer el origen y se busca tercero mediante usuario_wso2, restringiendo la lectura de terceros a creados en el último día (jurídicas) o la última hora (naturales). Es una ventana de lectura, no evidencia de frecuencia del job.
- Los outputs inspeccionados usan INSERT, no UPDATE ni UPSERT. En la segunda fase no se observa un lookup de exclusión contra datos_identificacion antes de insertar. Reejecución, fallos parciales y multiplicidad de contratos pueden requerir controles de idempotencia. No se atribuyen a estos jobs los duplicados de pruebas sin traza que lo demuestre.
- DIE_ON_ERROR está deshabilitado en las salidas inspeccionadas. Se necesitan registros de rechazos, conteos por etapa y resultado final para acreditar éxito; terminar el componente no implica que todas sus filas se hayan escrito.
- La selección natural incluye columnas de contrato en DISTINCT: esto no garantiza una fila por persona. Además hay filtros de vigencia y fechas que requieren confirmación de mantenimiento/alcance.

## Uso para el CRUD del sprint

**Los atributos transferidos de identidad, nombres e identificación pertenecen a terceros.** El MID debe dirigir esas operaciones a la API de terceros y usar la tabla/recurso de destino indicada en la matriz; Agora CRUD conserva `tercero_id` y el registro del proveedor. Las rutas HTTP y DTO deberán contrastarse con el contrato API vigente: esta matriz no inventa endpoints a partir de nombres de tablas. El esquema soporta además campos que el job deja sin valor; no confundir soporte, transferencia y obligatoriedad.

Se incorporó el contraste con las issues #12–#17 y una [propuesta de entidades y atributos](issue-18-responsabilidades-y-modelo-inicial-crud.md) para naturales, jurídicas y consorcios/uniones temporales. Está fijada la responsabilidad de terceros sobre los datos transferidos; la estructura nueva de Agora es una propuesta inicial que requiere validar reglas, cardinalidades y cobertura del formulario.

Ver [dependencias y alcance](issue-18-dependencias-y-alcance.md) para OIKOS, Administrativa/JBPM, SICAPITAL, Kronos, Core y exclusión de Arka. La prioridad de esta fase sigue siendo Agora–terceros.

## Formularios del sprint y contratos pendientes

Se revisaron las issues #12–#17 y los ocho mockups de registro natural/jurídico. La [matriz de formularios](issue-18-formularios-gestion-persona.md) relaciona los campos con terceros, Agora y las decisiones aún pendientes; no establece una migración definitiva. Los endpoints de Administrativa/JBPM, OIKOS, KRONOS y Core siguen por definir. Para Core se debe evaluar servicio existente (incluida otra BD), nuevo endpoint sobre el esquema o exposición mediante WSO2, como se detalla en [dependencias y alcance](issue-18-dependencias-y-alcance.md).

## Soporte adicional verificado en terceros

La [revisión de repositorios y GET de catálogos](issue-18-soporte-api-terceros.md) confirma soporte para caracterización y contacto genérico en `info_complementaria_tercero`, además de seguridad social y familiares. Estos datos no deben duplicarse en Agora. La propuesta elimina `caracterizacion_natural` y la dirección general propia; mantiene los bloques de negocio y `tercero_id`. Algunas funciones del MID requieren homologar IDs/DTO antes de reutilizarse. Planificar jobs legado → terceros y migración legado → Agora nuevo corresponde a la transición futura, fuera del sprint actual.
