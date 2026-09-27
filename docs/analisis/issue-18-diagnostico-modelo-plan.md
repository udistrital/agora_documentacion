# Issue #18 — evolución y migración: propuesta corregida

Fecha: 2026-09-27. Fuentes vigentes: metadatos locales de `AgoraFinal` y `Terceros`, ambos de **pruebas**, y [análisis funcional #5](issue-5-roles-modulos-agora-v1.md). Sustituye el plan basado en la conexión incorrecta. Ver [diagnóstico](issue-18-hallazgos-csv.md).

## Decisiones propuestas

- Terceros será el maestro de personas e identificaciones, conforme al requisito del proyecto. Antes de crear personas, conciliar contra los terceros existentes y verificar la versión del API que administra el esquema observado.
- Agora conservará su registro de proveedor, solicitudes, invitaciones/asignaciones, ofertas, decisiones e historial; referenciará el tercero canónico. Separar identidad de persona, condición de proveedor y autorización.
- Preservar la distinción de #5 entre respuesta del solicitante y validación del ordenador. No modelar ambas como un único booleano de aprobación.
- Homologar catálogos territoriales, identificación, clasificación y entidades. IDs iguales entre conexiones no significan entidades iguales.
- Mantener referencias al dominio financiero y de contratación según SICAPITAL/Argo; determinar qué evaluación/inhabilidad es propia de Agora. Titán solo interviene donde exista una integración confirmada.
- Diseñar bajas e historial con conservación de trazabilidad, revisando los CASCADE existentes. Una FK validada no establece la política de retención adecuada para el nuevo modelo.

## Mapeo preliminar de atributos y relaciones

Los destinos de terceros que se nombran existen en la captura. Su equivalencia funcional y las extensiones de Agora son **propuestas**, no un modelo aprobado. No es todavía la matriz completa de los 340 campos de origen.

| Origen Agora | Destino candidato / tratamiento | Regla o validación |
|---|---|---|
| informacion_persona_natural.num_documento_persona | datos_identificacion.numero | Conservar texto/ceros; homologar tipo antes de conciliar. |
| informacion_persona_natural.tipo_documento | datos_identificacion.tipo_documento_id | Traducir parametro_estandar a tipo_documento por significado/código validado, no copiar ID. |
| informacion_persona_natural.digito_verificacion | datos_identificacion.digito_verificacion | Aplicar solo al tipo correspondiente; no confundir con parte del número. |
| primer_nombre, segundo_nombre, primer_apellido, segundo_apellido | tercero, campos homónimos | Preservar acentos y nulos; resolver diferencias con persona ya existente mediante autoridad de campo. |
| Nombres de persona natural | tercero.nombre_completo | Derivación acordada; no sustituir el nombre existente sin conciliación. |
| fecha_nacimiento | tercero.fecha_nacimiento | Fecha a timestamp sin inventar hora/zona con significado de evento. |
| fecha_expedicion_documento | datos_identificacion.fecha_expedicion | Preservar precisión de fecha. |
| id_ciudad_expedicion_documento | datos_identificacion.ciudad_expedicion | Homologar territorio; validar catálogo origen, sin FK declarada para esta columna. |
| id_pais_nacimiento | tercero.lugar_origen, condicionado | País y lugar no son equivalentes por defecto; validar nivel territorial. |
| informacion_persona_juridica.num_nit_empresa / digito_verificacion | datos_identificacion.numero / digito_verificacion | Tipo NIT obtenido de catálogo vigente; conciliar antes de alta. |
| informacion_persona_juridica.nom_proveedor | tercero.nombre_completo | Confirmar nombre legal y divergencias con informacion_proveedor.nom_proveedor. |
| informacion_proveedor.id_proveedor | ID legado + referencia tercero_id en registro de proveedor | Mantener tabla de correspondencia; no reutilizar ID numérico de otra base. |
| informacion_proveedor.tipopersona | Clasificación jurídica/persona homologada | No equiparar directamente con tipo_contribuyente_id o tipo_tercero_id. Tratar consorcios, uniones y extranjeros. |
| informacion_proveedor.num_documento | Clave de conciliación con persona | Verificar enlace lógico según tipo; no existe FK declarada. |
| informacion_proveedor.estado | Estado de registro de proveedor | No convertir automáticamente en tercero.activo. |
| direccion, correo, correo_pago, telefono/proveedor_telefono | Complementos de tercero o contacto propio del proveedor | Confirmar catálogo, propósito, formato JSON y vigencia. No asumir que todos los correos tienen igual finalidad. |
| Datos bancarios y régimen | Destino a acordar por atributo | Confirmar autoridad, catálogo de banco y necesidad de conservación; no publicar muestras. |
| proveedor_representante_legal | vinculacion u otra relación aprobada | Conciliar ambos terceros; confirmar tipo y dirección principal/relacionado; no inventar vigencias. |
| proveedor_actividad_ciiu | Actividad del tercero/proveedor según contrato | Preservar código de cuatro caracteres y catálogo. No inventar ID de complemento. |
| id_arl, id_eps, id_fondo_pension, id_caja_compensacion | seguridad_social_tercero, condicionado | Resolver entidad como tercero y fechas requeridas. Falta fecha_inicio_vinculacion en estos campos de origen: requiere regla, no un valor ficticio. |
| Datos familiares | tercero_familiar, condicionado | Los booleanos de dependientes no identifican personas relacionadas. No crear familiares sin evidencia. |
| Fechas textuales del proveedor | Auditoría tipada del proveedor | Perfilar y convertir formatos inequívocos; cuarentena del resto, conservar valor original. |
| Anexos y soportes | Referencias documentales | Verificar existencia, acceso y repositorio; una ruta no acredita archivo migrado. |
| objeto_cotizacion | Cabecera del proceso de cotización | Preservar ID legado, vigencia, responsables, fechas, necesidad y condiciones. |
| solicitud_cotizacion | Asociación/invitación objeto–proveedor | Preservar unicidad del par e informado; confirmar semántica en aplicativo. |
| item_cotizacion_padre | Ítem solicitado | Conservar precisión de cantidad y unidad homologada. |
| respuesta_cotizacion_proveedor / item_cotizacion | Oferta e ítems ofertados | Mantener una respuesta por solicitud y coherencia de objeto; aclarar IVA y descuentos antes de calcular totales. |
| respuesta_cotizacion_solicitante | Decisión/respuesta por solicitud | Determinar multiplicidad, significado de resultado y política para texto voluminoso. |
| validacion_ordenador | Validación separada | Confirmar dónde residen decisión, fecha y actor; no inventar auditoría faltante. |
| Tablas modificacion_* / relacion_estado_* | Historial y solicitudes de cambio | Preservar anterior/nuevo, orden y relaciones; no sobrescribir IDs contenidos en JSON sin inventario. |
| codigo_validacion | Evidencia de certificación, condicionado | Confirmar tipo_certificacion e id_tabla; diseñar preservación de verificabilidad de certificados históricos. |
| Evaluación, inhabilidad y sociedades | Entidades sujetas a definición de alcance | No excluir por ausencia en manuales; definir conservación/migración con dueño funcional. |

La matriz final deberá cubrir cada campo con tipo, nulabilidad, dueño, destino, decisión (migrar/referenciar/derivar/archivar/excluir), transformación, validación, rechazo y evidencia. Cada campo sin destino permanece pendiente, no completado.

## Conciliación e integración entre bases

1. Identificar el job y su versión/configuración sin secretos. Registrar dirección, frecuencia, watermark, claves y tratamiento de bajas/conflictos/reintentos. Confirmar si las copias de pruebas corresponden al mismo corte.
2. Homologar catálogos de identificación y persona antes de comparar. Normalizar solo lo acordado, conservando originales y ceros iniciales.
3. Resolver coincidencias por tipo de documento homologado + número, considerando activos e historial. Cero coincidencias no implica alta inmediata; múltiples coincidencias exigen resolución. No hacer matching automático por nombre o correo.
4. Registrar correspondencias `(sistema, entidad, id_legado) → tercero_id`, regla, evidencia, estado y lote. El tercero existente no se sobrescribe solo por aparecer en Agora.
5. Ejecutar conciliación en entorno autorizado mediante APIs/extractos controlados. No existe JOIN SQL directo entre las dos conexiones por el hecho de que ambas sean PostgreSQL. Evitar exportar identidades al repositorio o usar hashes simples de documentos como anonimización.
6. Medir por categoría: conciliados únicos, no encontrados, ambiguos, diferencias de atributos y desfases temporales. Los totales globales de personas de terceros no deben igualar proveedores de Agora.

## Siguiente ronda en DBeaver

Se prepararon localmente `issue-18-calidad-agora-pruebas.sql` e `issue-18-calidad-terceros-pruebas.sql`, excluidos de Git. Ejecutar cada uno en su conexión correcta y exportar cada resultado por separado, conservando fecha/contexto en el registro local. Son consultas de lectura con límites de tiempo; ante error ejecutar ROLLBACK y conservar el mensaje. No repetir el inventario de permisos sobre public.

Los scripts devuelven agregados y catálogos; revisar estos últimos antes de compartir. No consultan nombres/documentos individuales, cuentas bancarias ni contenido de ofertas. Un timeout es una consulta pendiente, no un cero. No ejecutar conteos exactos o inspecciones masivas del texto de respuesta_cotizacion_solicitante en esta primera ronda.

## Estrategia y PoC

1. Congelar la definición del alcance y el contrato destino. Conservar evidencia de la captura correcta y marcar la anterior como sustituida.
2. Extraer a staging aislado una muestra desidentificada estratificada: personas naturales/jurídicas, consorcios/uniones/extranjeros si hay datos, representantes, registros ya conciliados y ambiguos, solicitudes con/sin respuestas, estados y modificaciones, soportes y relaciones externas.
3. Cargar/homologar catálogos y correspondencias; resolver terceros existentes mediante el mecanismo acordado. Evitar doble escritura con los jobs y registrar efectos externos por lote.
4. Cargar registro de proveedor, cabeceras, ítems solicitados, asignaciones, ofertas, ítems ofertados, decisiones/validaciones e historial en orden de dependencias.
5. Medir extracción, transformación y carga por separado. Comprobar integridad referencial y de negocio, conciliación de cantidades/importes según fórmulas validadas, cobertura de atributos y documentos. El 100% exigido por #18 se evalúa sobre toda la muestra acordada; rechazos sin resolver no cuentan como éxito.
6. Reejecutar para probar idempotencia y ensayar recuperación. ROLLBACK SQL no revierte escrituras a APIs externas; el plan debe contemplar compensación sin borrar terceros compartidos.
7. Dimensionar la ejecución real solo después de explicar el almacenamiento de respuestas y medir una muestra representativa. Elegir carga inicial+delta si el origen/job permite capturar cambios; en caso contrario, acordar ventana y congelación. Definir el manejo de escrituras posteriores al corte antes de prometer rollback.

No se ha ejecutado la PoC ni se propone alterar producción durante el diagnóstico. La revisión y aprobación del modelo por el líder técnico/arquitecto siguen pendientes.
