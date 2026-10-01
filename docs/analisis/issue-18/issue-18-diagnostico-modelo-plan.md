# Issue #18 — diagnóstico y plan para el registro de personas

Fuentes: estructura y perfilamiento de Agora/terceros en **pruebas**, [análisis funcional #5](../issue-5/issue-5-roles-modulos-agora-v1.md), formularios #12–#17 y jobs confirmados por el responsable como desplegados y operativos en **producción**. La captura inicial de una base incorrecta continúa sustituida.

## Alcance del próximo sprint

El MID y Agora CRUD se enfocan exclusivamente en satisfacer las vistas actuales de **registro de personas/proveedores**: natural, jurídica y la propuesta de consorcio/unión temporal. La entrega es el contrato de integración con la API de terceros y la API propia de Agora, apoyado en una estructura inicial para los datos que capturan esas vistas.

Cotizaciones, ofertas, respuesta del solicitante, validación del ordenador, evaluaciones y demás módulos se abordarán después. Los hallazgos históricos sobre ellos se conservan como referencia, pero no son entidades ni tareas del CRUD/MID de este sprint. La declaración de inhabilidades del formulario pertenece al registro y no constituye un módulo de evaluación.

La [propuesta de entidades y atributos](issue-18-responsabilidades-y-modelo-inicial-crud.md) es la referencia de diseño del CRUD. La [matriz de formularios](issue-18-formularios-gestion-persona.md) identifica los bloques de las vistas y la [matriz de jobs](issue-18-jobs-agora-terceros.md) documenta los campos/tablas de terceros.

## Responsabilidades y dirección de las operaciones

| Componente | Responsabilidad para el registro nuevo |
|---|---|
| Terceros | Maestro de identidad de todas las personas registradas, tengan o no contrato. Nombres/razón social, identificación, caracterización soportada y contacto genérico se crean o actualizan mediante su API. Devuelve el ID de la persona. |
| Agora CRUD | Registro/estado del proveedor y datos propios del formulario según el modelo propuesto: extensiones natural/jurídica/asociación, bancos, régimen, contactos específicos del registro, actividades, soportes y declaraciones. Guarda `proveedor.tercero_id`; no crea un maestro paralelo de identidad. |
| Agora MID | Consulta/resuelve o crea la persona en terceros, obtiene su ID y coordina el alta/actualización de los bloques propios en Agora CRUD. Compone la respuesta de ambos servicios para las vistas. |
| Argo | Responsable funcional de crear, actualizar y mantener las vinculaciones de contratistas en `terceros.vinculacion`. Terceros las persiste; el registro de Agora no las administra ni las crea por el mero hecho de inscribir al proveedor. |

El flujo histórico alimenta terceros desde Agora para población vinculada a contratos, bajo la premisa de que el trabajador mantiene sus datos más actualizados. Los jobs son de producción y respaldan el mapeo analizado. Ese filtro histórico **no se conserva como requisito del registro nuevo**: toda identidad nueva se crea directamente en terceros, aunque todavía no exista contrato.

Para personas existentes se reutiliza el ID tras resolver tipo y número de documento; no se crea un tercero nuevo en cada envío. Las ambigüedades se resuelven antes de vincular. La condición «sin contrato» no permite guardar identidad únicamente en Agora ni esperar a que el job la transfiera. Representantes y miembros también se identifican mediante terceros.

## Aplicabilidad a producción

Según el responsable, normalmente pruebas y producción mantienen la misma estructura. **Se toma esa equivalencia como premisa de diseño: el análisis estructural de pruebas es aplicable como base para producción**, alineado con el código de los jobs productivos. No es necesario repetir el estudio exhaustivo como condición para proponer el esquema o desarrollar los contratos del próximo sprint.

La equivalencia es una inferencia informada, no una comparación directa de ambos esquemas. Antes de desplegar, verificar puntualmente diferencias relevantes de versión, columnas, restricciones, catálogos y contrato API; ajustar solo las que afecten la integración. Los IDs de catálogo no se presumen iguales por compartir estructura.

Los conteos, duplicados, anomalías, tamaños y permisos medidos describen pruebas. No se extrapolan a producción. La conciliación de datos productivos y el dimensionamiento de una futura migración se programarán cuando se aborde esa migración, sin bloquear el diseño actual ni presentar como realizadas mediciones que no se hicieron.

## Orden de implementación propuesto

1. Cerrar el contrato por campo de las vistas: tipo, obligatoriedad, validación, cardinalidad y servicio propietario, usando la propuesta del CRUD. Resolver los campos genéricos expresamente pendientes y la clasificación de consorcios antes de habilitar sus escrituras.
2. Verificar en la API de terceros los recursos de persona e identificación, sus DTO, catálogos, consulta por documento y respuestas de creación/actualización. El análisis identifica tablas de destino; las rutas HTTP no se infieren del nombre de la tabla.
3. Acordar las entidades y operaciones de Agora CRUD para el registro. La cabecera exige el ID real de terceros y las extensiones utilizan el ID local del proveedor; no duplicar nombres/documentos ni copiar IDs legados.
4. Implementar en el MID la coordinación terceros → Agora CRUD: resolver identidad, obtener ID, guardar el registro y componer su consulta. Definir reintentos idempotentes y recuperación de fallos parciales sin borrar una persona compartida.
5. Validar en pruebas alta de una persona sin contrato, reutilización de una existente, actualización por servicio propietario, documentos ambiguos, reintentos y relaciones de representantes/miembros. La creación del proveedor no debe generar una vinculación contractual.
6. Antes del despliegue, verificar compatibilidad de contratos/esquemas/catálogos productivos sin incorporar la planificación de jobs/migración del legado, que se abordará en la transición futura. El mantenimiento contractual de vinculaciones queda en Argo.

No se diseñan ni crean aquí las futuras issues del MID y del CRUD. La migración integral y su PoC constituyen trabajo posterior dentro del panorama de #18, separado de esta entrega de registro.

## Referencias para fases posteriores

El [diagnóstico agregado](issue-18-hallazgos-csv.md) conserva el inventario y la calidad observados en pruebas, incluidos módulos fuera de este sprint. Las dependencias OIKOS, Administrativa/JBPM, KRONOS y Core permanecen en el [registro de dependencias](issue-18-dependencias-y-alcance.md), con endpoints por definir. Se priorizarán las necesarias para los campos del registro, como el catálogo de actividades.

La distinción funcional siguiente se conserva para cuando se aborde cotizaciones; **no es una obligación de implementación del registro actual**.

## En qué pasos se separan respuesta y validación

Ambas acciones pertenecen a **Gestión Cotizaciones**, dentro del paso 6 del resumen funcional de #5: el proveedor ya presentó una cotización (paso 5) y se gestionan su respuesta y validación. Son subprocesos distintos; la documentación revisada no demuestra una secuencia obligatoria entre ambos ni sus condiciones exactas de habilitación.

| Acción / subproceso | Momento y actor según #5 | Ruta documental y fuente | Persistencia candidata |
|---|---|---|---|
| Responder a la cotización del proveedor | Al gestionar las ofertas recibidas. Jefe de Dependencia u Ordenador del Gasto registra la respuesta/decisión que el proveedor puede consultar. | Gestión Cotizaciones → Gestionar Solicitud de Cotización → Gestionar Solicitudes de Cotización. M8, pp. 62–63; M9, pp. 36–38; consulta del proveedor en M4, pp. 31–35. | respuesta_cotizacion_solicitante, vinculada a solicitud_cotizacion, y catálogo resultado_cotizacion. |
| Aprobar o rechazar cotizaciones vinculadas | Al efectuar la validación de cotizaciones vinculadas. Acción exclusiva del Ordenador del Gasto, con observaciones. | Gestión Cotizaciones → Validaciones Cotización → Validar Cotizaciones Vinculadas. M7, pp. 5 y 25–27. | validacion_ordenador, vinculada a objeto_cotizacion; el lugar exacto donde queda la decisión debe confirmarse. |

Por tanto, una respuesta por proveedor no debe sustituir la validación del objeto/proceso. El mismo Ordenador puede intervenir en ambas acciones con propósitos distintos. La tabla validacion_ordenador no muestra campos explícitos de decisión, fecha o actor: falta comprobar si esos hechos se guardan en el estado del objeto, en otro registro o en lógica del aplicativo. No se propone un booleano común ni se inventa un orden de transiciones.


## Soporte adicional verificado en terceros

La [revisión de repositorios y GET de catálogos](issue-18-soporte-api-terceros.md) confirma soporte para caracterización y contacto genérico en `info_complementaria_tercero`, además de seguridad social y familiares. Estos datos no deben duplicarse en Agora. La propuesta elimina `caracterizacion_natural` y la dirección general propia; mantiene los bloques de negocio y `tercero_id`. Algunas funciones del MID requieren homologar IDs/DTO antes de reutilizarse. Planificar jobs legado → terceros y migración legado → Agora nuevo corresponde a la transición futura, fuera del sprint actual.
