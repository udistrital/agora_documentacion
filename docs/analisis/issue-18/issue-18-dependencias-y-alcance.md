# Issue #18 — dependencias identificadas y alcance

Actualizado: 2026-09-30. Fuente de las orientaciones: aclaraciones del responsable del proyecto. La evidencia estructural procede de las capturas de pruebas; no constituye verificación de APIs desplegadas.

## Alcance vigente y evidencia productiva

El trabajo actual y el próximo sprint se limitan al registro de personas: contrato con terceros y estructura/API propia de Agora para las vistas revisadas. Toda identidad nueva se crea en terceros, incluso sin contrato; se reutiliza la existente cuando corresponda y Agora conserva su ID. Los jobs confirmados son de producción; su selección contractual histórica no condiciona las altas nuevas. Argo mantiene las vinculaciones de contratistas en terceros. La estructura de pruebas se considera una base aplicable a producción bajo la equivalencia habitual informada, con verificación puntual antes del despliegue; las cifras de datos no se extrapolan. Cotizaciones, respuestas, validaciones y otros módulos se abordarán después.


## Foco actual

El trabajo inmediato es **Agora–terceros**, en particular gestión de personas/proveedores y la clasificación de los atributos de los formularios del sprint. Se usa Agora para proveedores y gestión de cotizaciones/notificaciones; Argo para contratos. La reconstrucción del dominio contractual de Argo no forma parte de este análisis.

Los esquemas presentes en la base compartida no son por ello propiedad del nuevo CRUD de Agora. Algunos soportan dependencias de Agora y otros de Argo; su presencia o una copia local no implica que deban duplicarse en el modelo nuevo. Las dependencias siguientes se registran para evitar decisiones de diseño incompatibles, sin ampliar el alcance inmediato a implementarlas.

## Dependencias y orientación de integración

| Dominio / servicio | Información o función | Orientación comunicada | Evidencia y pendientes |
|---|---|---|---|
| Terceros | Personas e identificaciones; otros datos compartidos según contrato | Reutilizar el soporte existente cuando la semántica coincida. Evaluar extensiones genéricas si sirven a otros aplicativos. | Prioridad actual. Hay esquema de pruebas, formularios y jobs confirmados como operativos. Los campos transferidos pertenecen a terceros; conciliación y contrato API pendientes. Ver el modelo inicial enlazado abajo. |
| OIKOS | Infraestructura física: edificios, espacios, salones y otros objetos del dominio | El esquema local se alimenta del servicio OIKOS de producción, alojado en otra BD, según el responsable. Para peticiones del dominio consumir directamente la API OIKOS. No crear un maestro de infraestructura en Agora. | Si un caso de uso requiere persistir una referencia, guardar el ID externo; todavía no definir columnas/FK hasta identificar esa necesidad. Confirmar endpoints y entorno de consumo: la procedencia productiva de la réplica no significa que pruebas deba llamar automáticamente a producción. |
| Administrativa / Administrativa JBPM | Acceso a información procedente de SICAPITAL | Consumir los endpoints de estos servicios que expongan la información necesaria. | Identificar servicios/repositorios, endpoints, claves y datos realmente requeridos por la versión actual. El nombre del esquema no acredita el endpoint ni su contrato. |
| SICAPITAL | Información financiera, incluidos CDP/CRP según contexto informado | Mantenerlo como origen de la información correspondiente y acceder mediante la integración expuesta por Administrativa/JBPM cuando aplique. | Confirmar el recorrido concreto por caso de uso; no diseñar lectura directa de su BD como contrato del nuevo CRUD. |
| Kronos | Unidad ejecutora | Resolver mediante una API del dominio Kronos. | API y endpoint por definir en una fase posterior. El repositorio movimientos_contables_mid fue mencionado como candidato, no como elección confirmada ni como evidencia de que exponga unidad ejecutora. |
| Core | Códigos de actividad económica | Core es la fuente del catálogo según el responsable. La relación del proveedor con actividades es distinta de la propiedad del catálogo. | La captura contiene core.ciiu_subclase; falta precisar mecanismo/API de consulta, versión y equivalencias. Los 810 códigos sin correspondencia encontrados en pruebas siguen requiriendo revisión. |
| Argo | Contratos y mantenimiento de vinculaciones de contratistas en terceros | Argo crea, actualiza y mantiene `terceros.vinculacion` para su dominio contractual; Agora no administra ese flujo. | Fuera del foco actual. El job de personas naturales inspeccionado selecciona contratistas mediante tablas de Argo: es una dependencia histórica del job, no una obligación demostrada de exigir contrato para registrar una persona en el CRUD nuevo. |
| Arka | Dominio ajeno al alcance futuro de Agora | Según el responsable, ya no tendría relación con Agora. | Excluirlo de las dependencias previstas y de los nuevos flujos. Esto no autoriza borrar su esquema ni modificar consumidores de Argo u otros sistemas. |
| Titán | Nómina, mencionado en el contexto previo | No se establece una integración requerida para gestión de personas por el hecho de coexistir jobs de nómina. | Fuera del foco inmediato; incorporar únicamente si se confirma un caso de uso de Agora. |

Referencia aportada como candidato futuro para Kronos: https://github.com/udistrital/movimientos_contables_mid. No se ha validado su idoneidad para unidad ejecutora.

## Endpoints pendientes de definición

**Administrativa/Administrativa JBPM, OIKOS, KRONOS y Core tienen pendientes sus endpoints.** La orientación de consumir APIs identifica el dominio responsable; no acredita que exista un contrato disponible o que se haya elegido un servicio.

| Dependencia | Definición pendiente |
|---|---|
| Administrativa / JBPM | Identificar los endpoints que entregarán la información necesaria de SICAPITAL, sus servicios responsables y los casos de uso de Agora que los consumirán. |
| OIKOS | Identificar endpoints para los objetos de infraestructura requeridos y sus IDs. Confirmar entorno y contrato antes de definir referencias persistentes en Agora. |
| KRONOS | Identificar API y endpoint para unidad ejecutora. `movimientos_contables_mid` sigue siendo únicamente un candidato para revisión futura. |
| Core | Revisar si ya existe un servicio para el catálogo, incluso si su fuente está en otra BD; si corresponde crear un endpoint sobre el esquema Core; o si se requiere una exposición directa mediante WSO2. Evaluar y acordar la alternativa con arquitectura, sin dar ninguna por seleccionada. |

Para cada contrato se debe registrar servicio responsable, método/ruta, versión, entorno, autenticación, parámetros, estructura de respuesta e identificador de referencia. El esquema Core que contiene actividades económicas es distinto del módulo `core` del frontend mencionado en #13. La identificación de estas dependencias no desplaza la prioridad Agora–terceros.

## Consecuencias para gestión_persona

1. Separar los campos del formulario por concepto y dueño candidato, no por ubicación histórica de la tabla. Distinguir persona, identificación, condición de proveedor, información del proceso y referencias externas.
2. Contrastar el job con el esquema/API vigente y los campos del formulario. El job muestra qué se transfiere en ese flujo; no declara por sí solo qué dato debe pertenecer a cada servicio.
3. Evitar duplicar en Agora maestros de infraestructura, unidad ejecutora o códigos de actividad económica. Definir referencias solo cuando el flujo del formulario/proceso las necesite.
4. Para atributos ausentes en terceros, evaluar si son genéricos y reutilizables. Si son específicos de Agora, su permanencia allí es una hipótesis razonable; si son compartidos, valorar ampliar terceros con contrato y validaciones claras. La propuesta inicial sitúa bancos y régimen en Agora; los posibles cambios por reutilización genérica deben decidirse antes de implementar.
5. No convertir copias históricas ni lecturas directas de BD de Talend en el contrato del CRUD nuevo. Confirmar cómo se evitarán escrituras concurrentes o duplicadas entre los formularios y los jobs.

## Pendientes para cerrar la primera entrega del CRUD

- Formularios identificados en las issues #12–#17 y contrastados inicialmente en la [matriz de formularios](issue-18-formularios-gestion-persona.md). Confirmar reglas, obligatoriedad, catálogos y cobertura de consorcios/uniones temporales y personas extranjeras.
- Despliegue y funcionamiento de los jobs confirmados por el responsable. Completar conciliación de resultados y revisión de cobertura de actualizaciones/bajas, no solo altas.
- Matriz por campo: evidencia del job, soporte del esquema/API, dueño candidato, regla y decisión pendiente/aprobada.
- Compatibilidad puntual con producción antes del despliegue, partiendo de la equivalencia estructural habitual. La conciliación/migración productiva se tratará en su fase; no bloquea el diseño del registro.

## Responsabilidad del registro actual

Los datos transferidos son responsabilidad de terceros. Ver [responsabilidades y modelo inicial del CRUD](issue-18-responsabilidades-y-modelo-inicial-crud.md) para el destino por tabla, las extensiones natural/jurídica/asociación y la coordinación del MID mediante `proveedor.tercero_id`.

## Complemento: vinculaciones de terceros

La segunda revisión de Talend confirma INSERT a `terceros.vinculacion` en el job de naturales, con persona principal, tipo, cargo, dependencia homologada, período, fechas y auditoría. Estos datos pertenecen a terceros; no deben duplicarse en Agora CRUD ni crearse automáticamente al registrar al proveedor. Argo es responsable de crear, actualizar y mantener ese vínculo contractual en terceros; Agora no lo administra. No se encontró la misma salida en el job de jurídicas. Ver [mapeo y cobertura](issue-18-jobs-agora-terceros.md#vinculación-escritura-confirmada-y-corrección-de-cobertura). La reutilización de este recurso para representantes o miembros de consorcio requiere validar semántica y catálogos; el job no acredita esas relaciones.

## Soporte adicional verificado en terceros

La [revisión de repositorios y GET de catálogos](issue-18-soporte-api-terceros.md) confirma soporte para caracterización y contacto genérico en `info_complementaria_tercero`, además de seguridad social y familiares. Estos datos no deben duplicarse en Agora. La propuesta elimina `caracterizacion_natural` y la dirección general propia; mantiene los bloques de negocio y `tercero_id`. Algunas funciones del MID requieren homologar IDs/DTO antes de reutilizarse. Planificar jobs legado → terceros y migración legado → Agora nuevo corresponde a la transición futura, fuera del sprint actual.
