# Issue #18 — diagnóstico inicial y plan de verificación

Fecha: 2026-09-25. Estado: análisis preliminar; sin conexión directa a la BD, sin conteos reales y sin PoC ejecutada. No constituye el cierre del issue.

Actualización: ya se revisaron las dos capturas locales de metadatos. Ver [hallazgos del diagnóstico](issue-18-hallazgos-csv.md). Se confirmó ausencia de SELECT en tablas y columnas. La verificación de acceso está terminada; el siguiente paso es revisar el contenido de usuarios y JSON de proveedores/cotizaciones, junto con los jobs, mediante lectura mínima o resultados ejecutados por el DBA. El responsable confirmó que las credenciales y capturas corresponden a producción. La PoC debe realizarse en un entorno aislado con datos desidentificados.

## Evidencia y alcance

- [Issue #18](https://github.com/udistrital/agora_documentacion/issues/18): exige inventario y volumen, calidad, mapeo completo, transformaciones, estrategia, PoC con 100% de consistencia e integridad de la muestra y aprobación técnica.
- [Análisis del issue #5](issue-5-roles-modulos-agora-v1.md): inventario documental de registro, actualización, actividades económicas, certificados, acceso y cotizaciones. No acredita que la versión desplegada implemente todos esos flujos. Mantener su distinción entre respuesta del solicitante y validación del Ordenador del Gasto.
- Diagrama entregado y revisado localmente, excluido de esta publicación: no revela los campos internos de los JSON ni acredita por sí solo el alcance completo del sistema.
- Contexto informado por el responsable: acceso a Agora de producción; sin fuente del monolito ni acceso a BD de terceros; SICAPITAL administra información financiera/CDP/CRP, Titán calcula nómina, Argo crea/modifica contratos. El responsable informa que la sincronización normalmente se realiza mediante jobs; falta verificar el flujo específico Agora–terceros.
- Código consultado de `terceros_crud`, rama `develop`: [tercero](https://github.com/udistrital/terceros_crud/blob/develop/models/tercero.go), [datos_identificacion](https://github.com/udistrital/terceros_crud/blob/develop/models/datos_identificacion.go), [info_complementaria_tercero](https://github.com/udistrital/terceros_crud/blob/develop/models/info_complementaria_tercero.go), [vinculacion](https://github.com/udistrital/terceros_crud/blob/develop/models/vinculacion.go). Código disponible no equivale a DDL ni contrato desplegado.

## Lectura del modelo mostrado

| Grupo visible | Objetos de ejemplo | Interpretación y límite |
|---|---|---|
| Acceso y autorización | prov_usuario, prov_rol, prov_usuario_subsistema, prov_rol_subsistema | Cuentas y asignaciones; no asumir que una cuenta equivale a una persona/proveedor. |
| Navegación y framework | prov_menu, prov_grupo_menu, prov_servicio, prov_enlace, prov_pagina, prov_bloque | Configuración de interfaz; no confundir enlaces de menú con autorización efectiva del backend. |
| Infraestructura y sesión | prov_dbms, prov_configuracion, prov_valor_sesion, prov_tempformulario | Puede orientar la localización de otras fuentes. No migrar automáticamente sesiones ni configuración del monolito. |
| Auditoría | prov_log_usuario, prov_log_proveedor, prov_log_cotizacion y variantes | Hay columnas query/data/error; pueden ayudar a recuperar patrones históricos, su suficiencia como fuente y el significado de los eventos requieren inspección del contenido. |

No se ven entidades de solicitud, ítems, ofertas, decisiones, proveedor jurídico o representación legal que expliquen los manuales. Posibles explicaciones: otros esquemas/bases, acceso restringido, diagrama parcial, fuentes externas o almacenamiento en JSON. No elegir una explicación sin inventario.

`prov_usuario.clave`, `prov_dbms.password`, sesiones y cuerpos de logs pueden contener secretos o datos personales: para esta primera captura solo se necesitan metadatos. El objeto `result` no tiene semántica comprobada; verificar su naturaleza antes de incluirlo en el diseño.

## Límite propuesto de responsabilidades

| Información | Responsable propuesto | Tratamiento en Agora nuevo |
|---|---|---|
| Persona natural/jurídica e identificaciones | terceros, según requisito del responsable | Referencia estable a tercero; conciliación con registros existentes antes de crear personas. |
| Contacto, representación legal y actividades económicas | Confirmar contrato y catálogos de terceros | No asignar destinos por similitud de nombres; evitar un segundo maestro de personas. |
| Registro/habilitación del proveedor y cotizaciones | Agora, pendiente de validación funcional | Entidades de negocio y estados propios; referencias a personas y sistemas externos. |
| CDP/CRP e información financiera | SICAPITAL, según contexto informado | Claves externas completas; si se necesita copia histórica, indicar origen y fecha de captura. |
| Contratos y modificaciones | Argo, según contexto informado | Referencias al contrato; no recrear su gestión. |
| Liquidación de nómina | Titán, según contexto informado | Confirmar si existe integración relevante para este alcance; no inferirla del nombre del sistema. |
| Credenciales y roles | Servicio institucional de identidad/autorización por confirmar | Separar cuenta, persona, tipo de persona y permiso. |

El código de terceros separa `tercero.id` de `datos_identificacion.numero`, `tipo_documento_id` y `tercero_id`. `info_complementaria_tercero.dato` es JSONB y depende de un catálogo. `vinculacion` admite dos referencias a terceros y un tipo: podría servir para relaciones, pero representación legal, dirección y vigencias requieren confirmar semántica y catálogo.

No asumir igualdad de IDs Agora/terceros. Proponer una correspondencia auditable `(sistema_origen, entidad_origen, id_origen) → tercero_id`, con estado de conciliación, regla aplicada y lote. Una referencia entre servicios no implica una FK física entre bases distintas. Los documentos se tratan como texto y sus tipos necesitan homologación; nombres/correos no bastan para fusionar personas.

## Captura de evidencia realizada

Se revisaron metadatos de contexto, esquemas, tablas, columnas, restricciones, índices, extensiones y permisos mediante consultas de solo lectura. Los scripts, CSV y diagrama permanecen locales y no forman parte de esta publicación.

Las estimaciones de filas no son conteos exactos; pueden estar desactualizadas. La captura corresponde a producción; las estimaciones de catálogo no sustituyen conteos exactos ni mediciones de calidad. Para la siguiente fase se necesita lectura limitada o agregados y muestras desidentificadas preparados por el DBA.

## Cómo verificar la sincronización sin acceso a terceros

En Agora: revisar inventario de triggers/rutinas, tablas externas y extensiones; localizar columnas/tablas de ID externo, mapeo, lote, reintento o última sincronización. Inspeccionar localmente el código de funciones y definiciones de vistas relevantes. La presencia de dblink/FDW o de una conexión configurada solo prueba capacidad/configuración, no sincronización activa.

Solicitar al equipo dueño de la integración: componente/job responsable y repositorio, dirección del flujo, entidades/campos, criterio de identidad, frecuencia, último lote exitoso, tratamiento de bajas/errores/conflictos y versión desplegada. Pedir un diccionario/DDL sin datos de terceros y sus catálogos; acceso de lectura al API o una conciliación ejecutada por el equipo puede sustituir acceso directo a su BD.

Para probar consistencia se necesita una muestra conciliada en ambos extremos con IDs, fechas y resultados, manejada por un canal adecuado. Evidencia unilateral no demuestra igualdad ni completitud. La ausencia de triggers tampoco descarta integración: puede ejecutarse desde el monolito, un servicio, ETL o planificador externo.

Los logs con `query` pueden orientar tablas y consultas del legado si tienen retención útil. Revisarlos localmente, extraer nombres de objetos y patrones sin literales; no enviar SQL con datos personales. Complementar con recorridos funcionales en un entorno de validación aislado y contratos de API. No es necesario recuperar todas las consultas antiguas para diseñar el modelo; sí las reglas, estados, cardinalidades y consumidores que debe preservar.

## Calidad y mapeo después del inventario

Para cada entidad de negocio registrar: conteo exacto/estimado, nulos en campos funcionalmente obligatorios, valores vacíos, claves duplicadas, huérfanos (incluidas relaciones sin FK), distribución de estados y fechas, rangos monetarios y validez de códigos externos. Reportar agregados, sin filas personales. Usar reglas de negocio para definir obligatoriedad; no inferirla solo de NOT NULL.

Para personas, distinguir duplicidad de cuenta, de documento y de persona. Comparar tipo y número homologados sin perder ceros iniciales; separar dígito de verificación cuando lo requiera el contrato. No eliminar acentos, ñ ni caracteres válidos como una limpieza genérica. Detectar codificación dañada, espacios y caracteres de control; conservar el original y registrar transformaciones. No dividir automáticamente nombre completo en apellidos/nombres ni fusionar coincidencias ambiguas.

Para cotizaciones verificar relación solicitud–ítem–oferta–decisión, moneda/precisión, historial de modificaciones y correspondencia de estados con el flujo documental. Comprobar si responder al proveedor y validar cotizaciones vinculadas producen hechos diferentes. Determinar las claves completas de CDP/CRP/contrato con el sistema dueño; no usar únicamente un número sin validar vigencia u otros componentes.

La matriz completa debe tener una fila por campo con: sistema/base/esquema/tabla/columna origen, tipo y nulabilidad, significado, clave de negocio, dueño, entidad/campo destino, transformación, homologación, regla de conciliación, orden de carga, validación, política de rechazo, evidencia y estado. Todo campo debe quedar clasificado como migrar, derivar, referenciar, archivar o excluir, con justificación.

Ejemplos preliminares, NO mapeo aprobado:

| Origen visible | Destino candidato | Condición pendiente |
|---|---|---|
| prov_usuario.identificacion | datos_identificacion.numero | Primero demostrar que identifica a la persona y conciliar registros existentes. |
| prov_usuario.tipo_identificacion | datos_identificacion.tipo_documento_id | Homologar catálogo; no copiar ID o texto directamente. |
| prov_usuario.nombre/apellido | Atributos de tercero o cuenta | Confirmar semántica y autoridad; no sobrescribir el maestro desde una cuenta histórica. |
| prov_usuario.correo/telefono | Contacto institucional o complemento de tercero | Confirmar destino/catálogo y política de actualización. |
| prov_usuario.clave | Sin destino en maestro de personas | Resolver transición de autenticación con su dueño. |
| JSON de proveedores/cotizaciones, estructura pendiente de inspección | Modelo Agora de proveedores/solicitudes/ofertas | Confirmar cobertura, relaciones y reconstrucción del estado vigente antes del mapeo. |

## Estrategia y PoC propuestas

1. Acordar dueños, versión destino y reglas de identidad; registrar esquema/fecha del origen. Preservar copia recuperable antes de cualquier migración real.
2. Extraer a staging aislado con trazabilidad por lote; perfilar y poner ambigüedades en cuarentena. No corregir directamente el origen durante el diagnóstico.
3. Conciliar terceros existentes, resolver homologaciones y crear solo faltantes mediante el mecanismo acordado con el equipo dueño. Evitar escrituras que compitan con el sincronizador actual.
4. Cargar entidades Agora por dependencias, referencias externas e historial. Usar lotes reanudables e idempotentes, con correspondencia de IDs.
5. Para la PoC seleccionar una muestra representativa de personas naturales/jurídicas, representantes, duplicados, nulos, caracteres válidos, estados/historiales y referencias ausentes. Desidentificar manteniendo relaciones. Usar destino aislado, sin efectos en APIs compartidas.
6. Medir extracción, transformación y carga por separado, filas/segundo, errores y reintentos. Validar campos transformados, unicidad, relaciones, totales monetarios y conservación de estados. Cada fila extraída debe quedar contabilizada; los rechazos no cuentan como migración exitosa y deben resolverse para la muestra de aceptación. Reejecutar el lote para comprobar que no duplica datos.
7. Ensayar rollback/restauración. Un ROLLBACK SQL no revierte escrituras en otros servicios: registrar efectos externos por lote y acordar compensación sin borrar terceros compartidos. Medir recuperación.
8. Para corte real: carga inicial y delta si existe un mecanismo confiable; de lo contrario acordar congelación de escrituras y ventana. Drenar o suspender sincronización según su dirección, conciliar, cambiar consumidores y observar. Si se permiten escrituras nuevas tras el corte, rollback requiere reconciliarlas; no basta restaurar una copia anterior.

El 100% exigido por el issue debe expresarse como resultados verificables sobre toda la muestra acordada: sin pérdida no explicada, sin duplicados introducidos, sin referencias rotas y con reglas funcionales cumplidas. No afirmar cumplimiento con conteos solamente.

## Dependencias y siguiente entrega

El inventario estructural está realizado. Para cerrar #18 faltan perfilamiento del contenido, estructura interna y semántica de los JSON, contrato/versionado/catálogos de terceros, evidencia de los jobs de sincronización, mapeo completo, modelo destino validado, PoC medida y aprobación del líder/arquitecto.

El siguiente insumo es una muestra desidentificada de usuarios y eventos de proveedores/cotizaciones, junto con agregados de calidad y documentación de los jobs. No se ha demostrado que los datos de negocio estén fuera de Agora. Ver el [resumen y requerimientos](issue-18-resumen-y-requerimientos.md) para los requerimientos de esta etapa. No se modificaron datos ni permisos de la BD.
