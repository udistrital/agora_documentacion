# Issue #18 — formularios de gestión de personas y responsabilidades

Actualizado: 2026-09-30. Fuentes: issues del frontend, sus mockups HTML y revisión inicial de Talend. Los jobs fueron confirmados como desplegados y operativos en producción. **Los atributos transferidos pertenecen a terceros**; el resto se organiza en una propuesta inicial de Agora CRUD, sin aprobar una migración. Ver [responsabilidades y modelo inicial del CRUD](issue-18-responsabilidades-y-modelo-inicial-crud.md). El soporte en una tabla tampoco confirma disponibilidad en la API.

## Alcance vigente y evidencia productiva

El trabajo actual y el próximo sprint se limitan al registro de personas: contrato con terceros y estructura/API propia de Agora para las vistas revisadas. Toda identidad nueva se crea en terceros, incluso sin contrato; se reutiliza la existente cuando corresponda y Agora conserva su ID. Los jobs confirmados son de producción; su selección contractual histórica no condiciona las altas nuevas. Argo mantiene las vinculaciones de contratistas en terceros. La estructura de pruebas se considera una base aplicable a producción bajo la equivalencia habitual informada, con verificación puntual antes del despliegue; las cifras de datos no se extrapolan. Cotizaciones, respuestas, validaciones y otros módulos se abordarán después.


## Fuentes y cobertura

| Issue | Alcance revisado | Implicación |
|---|---|---|
| [#12](https://github.com/udistrital/agora_documentacion/issues/12) | Microfrontend raíz | Estructura e integración; no define atributos de persona. |
| [#13](https://github.com/udistrital/agora_documentacion/issues/13) | Base del microfrontend de gestión de personas | Organización técnica; no constituye contrato de persistencia. |
| [#14](https://github.com/udistrital/agora_documentacion/issues/14) | Selección inicial: natural, jurídica, consorcio/unión temporal | La selección determina el flujo. Falta homologarla con los catálogos; no asumir que sus opciones son IDs de terceros. |
| [#15](https://github.com/udistrital/agora_documentacion/issues/15) | Natural: identificación/caracterización; afiliaciones/finanzas; documentos; actividades/declaración | Revisados los cuatro mockups HTML adjuntos. |
| [#16](https://github.com/udistrital/agora_documentacion/issues/16) | Jurídica: sociedad/representación; finanzas; documentos/RUES/RUP; actividades/declaración | Revisados los cuatro mockups HTML y el paso 1 del [PR #3](https://github.com/udistrital/agora_gestion_personas_mf/pull/3), versión `fb18a8ff47df0aa09e0df406f095a2bb0b25605d`. Esto no acredita despliegue ni integración con backend. |
| [#17](https://github.com/udistrital/agora_documentacion/issues/17) | Certificado de registro | Revisada la plantilla HTML y variables compartidas en comentarios. Documento de salida, no otro registro de identidad. |

Mockups de #15: [paso 1](https://github.com/user-attachments/files/32651020/code.html), [paso 2](https://github.com/user-attachments/files/32651034/code.html), [paso 3](https://github.com/user-attachments/files/32651055/code.html), [paso 4](https://github.com/user-attachments/files/32651065/code.html).
Mockups de #16: [paso 1](https://github.com/user-attachments/files/32651177/code.html), [paso 2](https://github.com/user-attachments/files/32651188/code.html), [paso 3](https://github.com/user-attachments/files/32651214/code.html), [paso 4](https://github.com/user-attachments/files/32651231/code.html).

## Clasificación inicial de campos

Agrupación funcional de atributos observados, pendiente de convertir en contrato campo a campo con tipos, cardinalidad, obligatoriedad y validaciones. Los ejemplos no sustituyen el inventario completo del formulario.

| Formulario / paso | Atributos observados | Responsabilidad / propuesta inicial y validación |
|---|---|---|
| Natural 1 | Nombres, apellidos, fecha de nacimiento | Responsabilidad de terceros (`tercero`): el job transfiere estos conceptos. Confirmar reglas y conciliación con personas existentes. |
| Natural 1; jurídica 1 | Tipo/número de documento, NIT, dígito de verificación; fecha y ubicación de expedición en natural | Responsabilidad de terceros (`datos_identificacion`). El job natural fija CC y no transfiere todos los datos de ubicación: no copiar esas limitaciones al formulario. Homologar tipos y ubicaciones. |
| Jurídica 1 | Razón social | Responsabilidad de terceros (`tercero.nombre_completo`): el job jurídico la utiliza como nombre completo. |
| Natural 1 | Género, país de nacimiento, grupo étnico, reconocimiento identitario, orientación sexual, condición migrante, víctima, hijos, cabeza de familia, personas a cargo, estado civil y discapacidad | Terceros: `info_complementaria_tercero` para género, etnia, identidad/orientación, estado civil, discapacidad, hijos y dependientes; `tercero.lugar_origen` según homologación. Migrante/víctima quedan pendientes de concepto genérico; ver la revisión de APIs. |
| Natural 1 | Perfil/rol principal, experiencia laboral/profesional en meses, PEP, información tributaria | Propuesta Agora: `proveedor_natural` para perfil/experiencia específica y `perfil_fiscal_proveedor`. PEP requiere definir concepto y distinguir declaración de evaluación. No confundir perfil declarado con permisos de acceso. Precisar campos tributarios adicionales. |
| Natural 1; jurídica 1 | Dirección y sus componentes, departamento/municipio, correos, teléfonos, extensión, sitio web; contacto de emergencia o comercial | Contacto y dirección generales: terceros, `info_complementaria_tercero`, con soporte acreditado en catálogos. Agora conserva solo finalidad/contactos específicos del negocio; emergencia/web y formato de dirección se validan por concepto. La dirección de residencia/sede no demuestra una dependencia de OIKOS, cuyo dominio informado es infraestructura universitaria. |
| Jurídica 1 | Procedencia, nombre comercial, matrícula y cámara de comercio, constitución/renovación, figura jurídica, tamaño empresarial | Propuesta Agora: `proveedor_juridico`; identidad/razón social/documento permanecen en terceros. Una extensión genérica posterior requiere decisión expresa. |
| Jurídica 1 | Identidad/contacto del representante, cargo, limitación estatutaria, suplente/apoderado | Identidad del representante en terceros; propuesta Agora: `representacion_proveedor` para relación, vigencia y facultades. No duplicar automáticamente a la persona por ser representante. |
| Jurídica 1 | Beneficiarios finales, cotización en bolsa, revisor fiscal, gran contribuyente, autorretención, exención ICA y responsabilidades fiscales | Propuesta Agora: `proveedor_juridico`, `perfil_fiscal_proveedor` y `responsabilidad_fiscal_proveedor`. Los controles del mockup no acreditan una integración con entidades externas. |
| Natural 2 | Pensionado, EPS, AFP, caja de compensación | Propuesta: reutilizar `terceros.seguridad_social_tercero`; verificar correspondencia/API y destino del estado pensionado. El job de alta revisado no demuestra sincronización de estos campos. |
| Natural 2; jurídica 2 | Banco, tipo/número de cuenta, titular/plaza cuando aplique, correo de tesorería; autorización de abono en natural | Propuesta Agora: `cuenta_bancaria_proveedor`, `contacto_proveedor` y `declaracion_proveedor`. Identidad del titular en terceros. |
| Natural 2; jurídica 2 | Patrimonio/capital, liquidez; capital autorizado/suscrito, activos y pasivos en jurídica | Propuesta Agora: `informacion_financiera_proveedor`. Definir período de referencia; no transformar fechas o valores de ejemplo del mockup en reglas fijas. |
| Jurídica 2 | Responsable/contacto de tesorería, facturación electrónica, prefijo/rango, resolución, operaciones en moneda extranjera | Propuesta Agora: `contacto_proveedor` y `perfil_fiscal_proveedor`. No deducir integración SICAPITAL de la mera presencia de estos campos. |
| Natural 3; jurídica 3; certificación bancaria en jurídica 2 | RUT, RUP/cámara de comercio y otros soportes; existencia/representación, documento del representante y aportes en jurídica | Propuesta Agora: `soporte_proveedor` y `registro_rup_proveedor`; definir servicio documental, referencias, vigencia y validación. Separar identidad de evidencia exigida para el registro en Agora; no decidir almacenamiento binario por la pantalla. |
| Natural 4; jurídica 4 | Actividades CIIU, portafolio/capacidad; clasificación UNSPSC en jurídica | CIIU: catálogo Core con endpoint pendiente; asociación en `actividad_proveedor` y portafolio en `proveedor`, propuestos en Agora. Confirmar por separado fuente de UNSPSC, sin atribuirla automáticamente a Core. |
| Natural 4; jurídica 1 y 4 | Consentimientos, declaraciones y aceptación de términos | Propuesta Agora: `declaracion_proveedor`, con versión/fecha/declarante. Una declaración de inexistencia de inhabilidades no equivale a validación institucional ni a resultado de consulta externa. |
| Certificado #17 | Titular, tipo/número de documento, fecha de registro, fecha/ciudad de expedición, código de verificación, QR y firmas | Componer identidad desde terceros y registro/emisión desde Agora (`proveedor` y `certificado_registro` propuestos). La fecha de expedición del certificado es distinta de la del documento de identidad. Definir verificación y trazabilidad. |

Los campos de confirmación de documento, correo o cuenta son controles de consistencia de la interfaz: no requieren por sí mismos columnas duplicadas. Los valores de listas y reglas visuales de los mockups necesitan validación funcional antes de convertirse en catálogos o restricciones del backend.

## Decisiones para el primer contrato del CRUD

1. Identidad e identificaciones transferidas son responsabilidad de terceros, respaldada por Talend y la confirmación del responsable; verificar el contrato API y resolver ambigüedades antes de vincular o crear registros.
2. Usar la estructura inicial enlazada para los bloques de Agora, incluidos banco y régimen. Cerrar las decisiones genéricas expresamente marcadas antes de implementar, sin duplicar propietarios.
3. Especificar operaciones de consulta, alta y actualización, identificadores compartidos y tratamiento de duplicados. Coordinar esas escrituras con los jobs confirmados operativos; falta conciliación cuantitativa y regla de convivencia con el legado.
4. Completar cobertura de consorcios/uniones temporales y variantes extranjeras: #14 anuncia esas opciones, pero las dos secuencias revisadas no cierran todos sus contratos.
5. Mantener pendientes los [endpoints externos](issue-18-dependencias-y-alcance.md). No bloquear la identificación de campos Agora–terceros por decisiones futuras de infraestructura/unidad ejecutora.
6. Usar la estructura de pruebas como base aplicable a producción y verificar compatibilidad puntual antes del despliegue. Las métricas de calidad/volumen actuales siguen describiendo pruebas; no se exige repetir el estudio exhaustivo para este sprint.

Ver [análisis del job](issue-18-jobs-agora-terceros.md) y [plan del modelo](issue-18-diagnostico-modelo-plan.md). La revisión documental no ejecutó formularios ni verificó escrituras de APIs.

## Complemento: vinculaciones de terceros

La segunda revisión de Talend confirma INSERT a `terceros.vinculacion` en el job de naturales, con persona principal, tipo, cargo, dependencia homologada, período, fechas y auditoría. Estos datos pertenecen a terceros; no deben duplicarse en Agora CRUD ni crearse automáticamente al registrar al proveedor. Argo es responsable de crear, actualizar y mantener ese vínculo contractual en terceros; Agora no lo administra. No se encontró la misma salida en el job de jurídicas. Ver [mapeo y cobertura](issue-18-jobs-agora-terceros.md#vinculación-escritura-confirmada-y-corrección-de-cobertura). La reutilización de este recurso para representantes o miembros de consorcio requiere validar semántica y catálogos; el job no acredita esas relaciones.

## Revisión de soporte API

La [matriz de catálogos y contratos de terceros](issue-18-soporte-api-terceros.md) corrige la propuesta inicial: caracterización soportada y contacto genérico pertenecen a terceros. También documenta IDs fijos incompatibles en algunas funciones del MID; no consumir sus escrituras sin homologación.
