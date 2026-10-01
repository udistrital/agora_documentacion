# Issue #18 — responsabilidades y modelo inicial para el registro de proveedores

Actualizado: 2026-09-30. Alcance: vistas actuales de registro de personas, con base en [#5](../issue-5/issue-5-roles-modulos-agora-v1.md), los [formularios #12–#17](issue-18-formularios-gestion-persona.md) y los [jobs Agora–terceros](issue-18-jobs-agora-terceros.md). No se diseñan ni crean las futuras issues MID/CRUD ni se ejecutan cambios de BD.

## Alcance vigente y evidencia productiva

El trabajo actual y el próximo sprint se limitan al registro de personas: contrato con terceros y estructura/API propia de Agora para las vistas revisadas. Toda identidad nueva se crea en terceros, incluso sin contrato; se reutiliza la existente cuando corresponda y Agora conserva su ID. Los jobs confirmados son de producción; su selección contractual histórica no condiciona las altas nuevas. Argo mantiene las vinculaciones de contratistas en terceros. La estructura de pruebas se considera una base aplicable a producción bajo la equivalencia habitual informada, con verificación puntual antes del despliegue; las cifras de datos no se extrapolan. Cotizaciones, respuestas, validaciones y otros módulos se abordarán después.


## Decisión de responsabilidad

El responsable confirma que los jobs analizados están desplegados en producción y funcionan. Su premisa es que el trabajador dispone de información más actualizada en Agora, desde donde se nutre terceros. **Los datos transferidos por estos jobs son responsabilidad de terceros en el nuevo diseño.** El origen histórico de captura en Agora no justifica duplicar su maestro de identidad en Agora CRUD.

- **Terceros:** identidad de la persona natural/jurídica, identificaciones, caracterización y contacto genérico soportados, seguridad social, familiares y vinculaciones contractuales, con tablas y campos documentados. Argo mantiene las vinculaciones contractuales. El registro del proveedor no debe volver a almacenar como maestro sus nombres, razón social, documento ni nacimiento.
- **Agora CRUD:** condición y estado de proveedor, información específica del registro, bancaria/fiscal, actividades, documentación y relaciones propias de ese registro, según la propuesta inicial de este documento. Guarda el `tercero_id` que identifica a la persona en terceros.
- **MID:** compone y distribuye las operaciones entre terceros y Agora CRUD; devuelve a las vistas el registro integrado. No constituye un tercer maestro de datos.

La asignación a terceros de lo transferido es una decisión de esta etapa. Las tablas nuevas de Agora son una propuesta de diseño, no tablas existentes ni una migración aprobada. Para datos adicionales potencialmente genéricos se propone un destino inicial explícito; se podrá cambiar mediante una decisión de reutilización/extensión de terceros, evitando dos dueños del mismo atributo.

## Matriz de destino en terceros

Las tablas siguientes son del esquema **`terceros`**. El MID utiliza su API; no escribe directamente en la BD. Los nombres permiten identificar el recurso al que dirigir la petición, pero las rutas y los DTO aún deben verificarse en el contrato del servicio.

| Atributo | Persona natural: origen en el job | Persona jurídica: origen en el job | Tabla.columna destino |
|---|---|---|---|
| Nombre completo / razón social | `nom_proveedor` | `nom_proveedor` jurídico | `terceros.tercero.nombre_completo` |
| Primer nombre | `primer_nombre` | No transferido | `terceros.tercero.primer_nombre` |
| Segundo nombre | `segundo_nombre` | No transferido | `terceros.tercero.segundo_nombre` |
| Primer apellido | `primer_apellido` | No transferido | `terceros.tercero.primer_apellido` |
| Segundo apellido | `segundo_apellido` | No transferido | `terceros.tercero.segundo_apellido` |
| Fecha de nacimiento | `fecha_nacimiento` | No transferida; no sustituir por constitución | `terceros.tercero.fecha_nacimiento` |
| Número de identificación | `num_documento` del proveedor, leído como `cedula` | `num_nit_empresa` | `terceros.datos_identificacion.numero` |
| Dígito de verificación | Dígito de la persona natural | Dígito de la jurídica | `terceros.datos_identificacion.digito_verificacion` |
| Fecha de expedición del documento | `fecha_expedicion_documento` | No transferida | `terceros.datos_identificacion.fecha_expedicion` |
| Tipo de documento | Constante 3 (CC en la captura) | Constante 7 (NIT en la captura) | `terceros.datos_identificacion.tipo_documento_id` |
| Tipo de contribuyente | Constante 1 | Constante 2 | `terceros.tercero.tipo_contribuyente_id` |
| Usuario de identidad | Documento leído como `cedula` | NIT | `terceros.tercero.usuario_wso2` |
| Lugar de origen | Constante 0; no transfiere ubicación real | Constante 0 | `terceros.tercero.lugar_origen` |
| Persona identificada | Lookup del tercero por documento/usuario | Lookup del tercero por NIT/usuario | `terceros.datos_identificacion.tercero_id` → `terceros.tercero.id` |
| Estado activo | `true` en las dos tablas | `true` en las dos tablas | `terceros.tercero.activo`, `terceros.datos_identificacion.activo` |
| Fechas técnicas de creación/modificación | Fecha de ejecución en las dos tablas | Fecha de ejecución en las dos tablas | `fecha_creacion`, `fecha_modificacion` de ambas tablas |

`terceros.tercero.id` y el ID de la identificación son generados por terceros; no son el ID del proveedor legado. Para el registro nuevo, el tipo documental se resuelve según la persona y el catálogo vigente: no se fija CC para todos. Las constantes del job tampoco justifican enviar un lugar ficticio ni fabricar un usuario WSO2. El régimen fiscal/bancario de Agora **no es** `tipo_contribuyente_id`.

Para campos que el formulario solicita y el job no llena, se propone reutilizar `terceros.datos_identificacion.ciudad_expedicion` y `documento_soporte` cuando corresponda a la identificación, y `terceros.tercero.lugar_origen` solo tras homologar su significado territorial. País/departamento de expedición pueden ser selectores para resolver la ciudad; no se inventan columnas en terceros. Esta ampliación de captura no se presenta como una transferencia existente del job.

No se identificó un flujo específico de consorcios/uniones temporales en las altas inspeccionadas. Se propone que su identidad registral, si el catálogo/contrato de terceros la admite, también resida en `tercero` y `datos_identificacion`; no se los fuerza a persona jurídica ni se les asigna automáticamente el valor 2. La clasificación y documentación exigida quedan por validar.

## Vinculaciones existentes en terceros

La segunda revisión confirma que `vinculacion_0.1` también inserta en **`terceros.vinculacion`** para personas naturales seleccionadas por contratos de Argo. Son responsabilidad de terceros `tercero_principal_id`, `tipo_vinculacion_id`, `cargo_id`, `dependencia_id`, `periodo_id`, fechas de inicio/fin, estado y auditoría. `tercero_relacionado_id` y `soporte` quedan sin expresión de origen. Ver el [mapeo completo y filtros del job](issue-18-jobs-agora-terceros.md#vinculación-escritura-confirmada-y-corrección-de-cobertura).

**Argo dirige a terceros las operaciones de creación, actualización y mantenimiento de la vinculación contractual.** Agora MID no incorpora esas operaciones en el sprint de registro. No se crea automáticamente por registrar al proveedor ni se duplica en Agora CRUD: el job exige contexto contractual, y la fecha de vinculación no es la fecha de inscripción. No se encontró esa escritura en el job de jurídicas.

La propuesta de representación y miembros de asociación de abajo no describe este vínculo contractual. Antes de cerrar su implementación se debe evaluar si el recurso/catálogos de vinculación de terceros admiten esas relaciones genéricas; el job natural no acredita ese uso, pues no asigna tercero relacionado. Si se acuerda reutilizarlo, esas relaciones se dirigirán a terceros y se retirará su duplicación del modelo de Agora.

## Caracterización y contacto: responsabilidad de terceros

La [revisión del código y APIs](issue-18-soporte-api-terceros.md) acredita soporte en `terceros.info_complementaria_tercero` para género, etnia, discapacidad, estado civil, orientación sexual, identidad de género, hijos, cabeza de familia, personas a cargo, teléfonos, correo y dirección/lugar de residencia. Se retiran `caracterizacion_natural` y `direccion_proveedor` de la propuesta de Agora para no duplicarlos. La matriz de esa revisión indica grupos/códigos y las diferencias entre dato soportado, DTO compatible y extensión pendiente.

Migrante, víctima, PEP y pensionado requieren una definición puntual de catálogo/semántica; no se asignan automáticamente a Agora. Los datos societarios/experiencia con conceptos similares en terceros requieren validar contexto antes de retirar sus atributos propuestos. La existencia de complementos no convierte cualquier JSON en un contrato aprobado.

## Estructura propuesta para Agora CRUD

Nombre lógico del esquema: **`agora`**, en la BD del nuevo servicio que se acuerde. Las tablas de esta sección son propuestas. `proveedor_id` referencia localmente `agora.proveedor.id`; los `tercero_id` son referencias externas validadas por API, sin FK PostgreSQL entre bases. Como base común, las entidades persistentes llevan `id`, `activo`, `fecha_creacion` y `fecha_modificacion`. Las fechas históricas/de vigencia son campos separados de esa auditoría.

| Entidad propuesta | Atributos iniciales adicionales | Aplicación / responsabilidad | Nombre tabla relación |
|---|---|---|---|
| `proveedor` | `tercero_id`, `tipo_registro` (natural/jurídica/consorcio/unión temporal), `estado_registro`, `fecha_registro`, `descripcion_portafolio` | Cabecera compartida. Identidad externa en terceros; estado del registro en Agora, independiente de `tercero.activo`. | Externa: `terceros.tercero` por `tercero_id`. |
| `proveedor_natural` | `proveedor_id`, `perfil_declarado`, `experiencia_laboral_meses`, `experiencia_profesional_meses` | Extensión 0..1 exclusiva de natural. Perfil declarado no concede roles de autorización. Sin nombres/documento/nacimiento duplicados. | Local: `proveedor` por `proveedor_id` (0..1 por proveedor natural). |
| `proveedor_juridico` | `proveedor_id`, `procedencia_codigo`, `nombre_comercial`, `matricula_mercantil`, `camara_comercio_codigo`, `fecha_constitucion`, `fecha_renovacion`, `tipo_organizacion_codigo`, `tamano_empresa_codigo`, `reporta_beneficiarios_finales`, `cotiza_bolsa`, `requiere_revisor_fiscal` | Extensión 0..1 exclusiva de jurídica, propuesta para información societaria del registro. Razón social y NIT siguen en terceros. Una declaración sobre beneficiarios no equivale a una lista de personas beneficiarias. | Local: `proveedor` por `proveedor_id` (0..1 por proveedor jurídico). |
| `contacto_proveedor` | `proveedor_id`, `finalidad`, `info_complementaria_tercero_id` (referencia externa) o `valor_especifico`, `tipo_canal`, `extension`, `nombre_contacto`, `es_principal` | Solo canales de negocio específicos, como tesorería. Si se usa contacto genérico, referenciarlo en terceros y no duplicar su valor; definir alternativas excluyentes en el contrato. Correo/teléfono/dirección general se almacenan en terceros. | Local: `proveedor`; externa opcional: `terceros.info_complementaria_tercero` para contacto reutilizado. |
| `cuenta_bancaria_proveedor` | `proveedor_id`, `entidad_bancaria_id`, `tipo_cuenta_codigo`, `numero_cuenta`, `titular_tercero_id`, `ciudad_apertura_id`, `es_principal`, `vigente_desde`, `vigente_hasta` | 0..N cuentas del proveedor en Agora. Consultar nombre del titular en terceros cuando sea una persona identificada; validar titularidad sin presumir que todo pago admite terceros distintos. | Local: `proveedor`; externa: `terceros.tercero` para titular. Catálogos banco/tipo y territorio por confirmar. |
| `perfil_fiscal_proveedor` | `proveedor_id`, `regimen_codigo`, `gran_contribuyente`, `autorretenedor`, `exencion_ica`, `obligado_facturar_electronicamente`, `prefijo_facturacion`, `rango_facturacion`, `resolucion_facturacion`, `opera_moneda_extranjera`, `vigente_desde`, `vigente_hasta` | Régimen y condiciones fiscales aplicadas al proveedor, propuestos en Agora. Confirmar semántica de retenciones/beneficios de natural antes de añadir campos; no usar texto libre como regla de cálculo. | Local: `proveedor`; catálogo de régimen por confirmar. |
| `responsabilidad_fiscal_proveedor` | `perfil_fiscal_proveedor_id`, `responsabilidad_codigo` | 0..N responsabilidades por perfil; evita columnas booleanas por cada código de un catálogo cambiante. Catálogo/fuente por confirmar. | Local: `perfil_fiscal_proveedor`; catálogo de responsabilidades por confirmar. |
| `informacion_financiera_proveedor` | `proveedor_id`, `fecha_corte`, `moneda_codigo`, `tipo_capital_codigo`, `capital_autorizado`, `capital_suscrito_pagado`, `patrimonio_liquido`, `activos_totales`, `pasivos_totales`, `pasivos_corrientes`, `indice_liquidez_declarado` | 0..N cortes. Montos decimales; separación final de pasivos según formulario acordado. No fijar el año de ejemplo del mockup. | Local: `proveedor`; catálogos moneda/tipo de capital por confirmar. |
| `representacion_proveedor` | `proveedor_id`, `representante_tercero_id`, `tipo_representacion`, `cargo`, `tiene_limitacion_cuantia`, `descripcion_facultades`, `fecha_inicio`, `fecha_fin`, `soporte_proveedor_id` | Principal, suplente/apoderado. Identidad del representante en terceros; relación y facultades para registro en Agora. Fechas/cuantías no conocidas no se inventan. | Locales: `proveedor`, `soporte_proveedor`; externa: `terceros.tercero` para representante. |
| `actividad_proveedor` | `proveedor_id`, `catalogo` (CIIU/UNSPSC), `codigo`, `es_principal`, `fecha_inicio`, `fecha_fin` | Asociación con catálogo externo. CIIU en Core; fuente de UNSPSC por confirmar. Código textual preservando ceros; no duplicar el maestro. | Local: `proveedor`; catálogo externo CIIU de Core (captura `core.ciiu_subclase`), contrato API pendiente; fuente UNSPSC pendiente. |
| `soporte_proveedor` | `proveedor_id`, `tipo_soporte_codigo`, `documento_id`, `fecha_emision`, `fecha_vencimiento`, `estado_revision`, `observacion_revision` | 0..N referencias a RUT, RUP, existencia/representación, certificación bancaria, aportes, etc. Servicio documental por definir; sin binarios en esta propuesta. La evidencia del documento de identidad puede referenciar el mismo documento de terceros. | Local: `proveedor`; documento externo por `documento_id`, servicio/tabla destino pendiente. |
| `declaracion_proveedor` | `proveedor_id`, `tipo_declaracion`, `version_texto`, `respuesta`, `fecha_declaracion`, `declarante_tercero_id`, `cuenta_bancaria_proveedor_id` opcional | Consentimiento, términos, autorización de abono e inexistencia declarada de inhabilidades. Registro de evidencia por versión; no equivale a evaluación/validación del ordenador. | Locales: `proveedor`, opcional `cuenta_bancaria_proveedor`; externa: `terceros.tercero` para declarante. |
| `registro_rup_proveedor` | `proveedor_id`, `numero_registro`, `camara_comercio_codigo`, `fecha_inscripcion`, `fecha_renovacion`, `fecha_vencimiento`, `soporte_proveedor_id` | Propuesta para datos del RUP cuando el formulario los capture; no hacerlos obligatorios por incluirlos en el modelo. | Locales: `proveedor`, `soporte_proveedor`; catálogo cámara de comercio pendiente. |
| `certificado_registro` | `proveedor_id`, `fecha_expedicion`, `ciudad_expedicion_id`, `codigo_verificacion`, `version_plantilla`, `documento_id`, `estado_certificado` | Emisión #17. Identidad consultada en terceros; documento emitido conserva evidencia de lo certificado sin convertirse en maestro editable de identidad. QR derivado del mecanismo de verificación. | Local: `proveedor`; documento y ciudad externos, servicios/catálogos por confirmar. |

La afiliación a EPS/AFP/CCF no se traslada automáticamente a Agora porque no aparezca en el job. Se propone reutilizar **`terceros.seguridad_social_tercero`**, verificando entidades, tipo de afiliación y fechas de su contrato. El estado «pensionado» requiere revisar el catálogo/complemento disponible en terceros; si no lo soporta, decidir una extensión genérica o un atributo de caracterización en Agora antes de habilitar su escritura. Esta es una dependencia puntual pendiente, no una transferencia acreditada del job.

## Familiares y experiencia: validaciones de reutilización

La vista de Agora puede registrar el detalle de familiares y el MID persistirlo en terceros (`tercero`, `datos_identificacion`, `tercero_familiar`, `tipo_parentesco` y contactos complementarios). Queda como tarea confirmar qué datos se requieren, ampliar/homologar parentescos y validar el contrato para familiares existentes/nuevos y cantidades variables. La ausencia de filas reportada en pruebas no demuestra imposibilidad de uso. No se agrega una tabla familiar propia de Agora ni se confunde parentesco con dependencia económica.

Para experiencia laboral, terceros permite varios registros agrupados mediante `info_complementaria_tercero_padre_id`; se propone verificar cabecera `EXP_LABORAL` (136) e hijos 97–104 por episodio. La API compuesta existente para `/padre` está orientada a formación académica y no confirma un contrato de experiencia reutilizable. La experiencia total/profesional en meses del formulario requiere una regla distinta del tiempo en un trabajo concreto. Ver [tareas, agrupación y límites de los contratos](issue-18-soporte-api-terceros.md).

Las referencias locales de las tablas propuestas deben mantener coherencia de proveedor: por ejemplo, el soporte de una representación o la cuenta de una declaración deben pertenecer al mismo proveedor. Las referencias externas se validan por API y no constituyen FK entre bases.

## Consorcios y uniones temporales

La selección aparece en #14, pero los formularios revisados no cierran los campos de este flujo. Se propone esta extensión explícita, sujeta a validación funcional:

| Entidad propuesta | Atributos adicionales | Regla propuesta | Nombre tabla relación |
|---|---|---|---|
| `proveedor_asociacion` | `proveedor_id`, `modalidad` (consorcio/unión temporal), `fecha_constitucion`, `fecha_fin`, `objeto_asociacion`, `soporte_constitucion_id` | Extensión 0..1 de proveedor; no reutilizar la extensión jurídica por similitud visual. Identidad propia y documento, cuando apliquen, en terceros. | Locales: `proveedor`, `soporte_proveedor` por `soporte_constitucion_id`. |
| `miembro_asociacion` | `proveedor_asociacion_id`, `miembro_tercero_id`, `porcentaje_participacion`, `fecha_inicio`, `fecha_fin` | 1..N miembros identificados en terceros. Ser miembro no obliga a tener un registro independiente como proveedor. Sin duplicar nombre/NIT del miembro. | Local: `proveedor_asociacion`; externa: `terceros.tercero` para miembro. |

La asociación usa los contactos, cuentas, actividades, soportes y representación comunes de Agora. El representante se referencia por su propio ID de terceros. Proponer participaciones mayores a 0 y hasta 100, sin miembros repetidos en el mismo período; validar suma de 100 al completar el registro si la regla funcional lo exige. Determinar mínimo de miembros, manejo de cambios y requisitos de identidad antes de cerrar el contrato. No se atribuyen estos campos a un job ni a un formulario ya implementado.

## Inserción y consulta coordinadas por el MID

1. El frontend envía el registro al MID, que separa identidad/identificación de los bloques de proveedor. No envía el mismo bloque a ambos CRUD.
2. Consultar terceros por tipo documental homologado y número. Si existe una coincidencia válida, recuperar su ID; si hay varias, resolver la ambigüedad sin escoger la primera. Si no existe, crear `terceros.tercero` y su `terceros.datos_identificacion` asociado mediante la API y conservar el ID retornado. Actualizar identidad existente en terceros solo con las reglas de actualización acordadas, no por sobrescritura ciega.
3. Con identidad e identificación resueltas, insertar `agora.proveedor` con **`tercero_id = terceros.tercero.id`**, tipo y estado inicial. No confundirlo con `datos_identificacion.id` ni con `id_proveedor` legado. Crear sus extensiones/relaciones utilizando el nuevo `proveedor.id` local.
4. Representantes y miembros se resuelven en terceros con el mismo criterio antes de persistir sus referencias. El alta final de una asociación requiere resolver también su identidad propia; mientras no se confirme el contrato de terceros para ese tipo, no inventar un ID ni sustituirlo por el del representante.
5. Para consultar las vistas, el MID obtiene los datos del proveedor desde Agora CRUD y la identidad, caracterización y contacto genérico vigentes desde terceros; compone la respuesta. Una actualización de datos bancarios o portafolio va a Agora; una de nombres, razón social, identificación, caracterización soportada o contacto genérico va a terceros. Las bajas de proveedor no desactivan automáticamente a la persona compartida.
6. Prever reintentos idempotentes y fallos parciales entre servicios. Si terceros se creó y Agora falló, reanudar con el mismo ID; no borrar la persona compartida como compensación ni duplicarla. Proponer unicidad de `proveedor.tercero_id` para un registro de proveedor por identidad, pendiente de confirmar si se requieren registros múltiples por contexto.

No existe una transacción SQL común entre ambos servicios. Debe definirse el tratamiento de borradores y operación parcial. Cada extensión local debe corresponder al `tipo_registro`, con FK locales y unicidad de `proveedor_id` para extensiones 1:1; los documentos y cuentas se almacenan como texto, los importes/porcentajes como decimal. Las confirmaciones de correo/documento/cuenta pertenecen a validaciones del formulario, no a columnas duplicadas.

## Convivencia con el legado y pendientes concretos

Se podrá diseñar la ejecución de jobs **Agora legado → terceros** junto con una migración **Agora legado → Agora nuevo** durante la transición. La convivencia, conciliación y estrategia de corte son **trabajo futuro**; no forman parte del sprint actual de registro ni se implementan en este análisis. El registro nuevo crea/resuelve directamente la persona y sus datos genéricos en terceros, obtiene su ID y guarda únicamente los bloques propios en Agora.

Quedan pendientes el contrato HTTP/DTO de terceros y Agora, catálogos y restricciones del modelo propuesto, cobertura de campos fiscales y del flujo de asociaciones, datos genéricos marcados para decisión, compatibilidad puntual para desplegar el registro y, en la fase de migración, resultados cuantitativos de conciliación productiva. Los endpoints de Administrativa/JBPM, OIKOS, KRONOS y Core siguen pendientes según [dependencias](issue-18-dependencias-y-alcance.md). El presente esquema atiende registro de proveedores; no incorpora contratos de Argo ni amplía el sprint a cotizaciones.
