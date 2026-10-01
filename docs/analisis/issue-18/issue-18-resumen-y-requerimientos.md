# Issue #18 — resumen y requerimientos de la etapa actual

## Decisiones vigentes

- **Próximo sprint: registro de personas.** El MID y Agora CRUD satisfarán las vistas de registro mediante la API de terceros y la API propia de Agora. Cotizaciones, respuestas, validaciones y demás módulos quedan para etapas posteriores.
- **Toda identidad nueva se crea en terceros**, tenga o no contrato; si ya existe, se resuelve y reutiliza su ID. Agora guarda `proveedor.tercero_id` y los datos propios del registro.
- **Argo mantiene las vinculaciones de contratistas en `terceros.vinculacion`.** Terceros es el destino de persistencia; Agora no asume su mantenimiento contractual.
- **Los jobs revisados son de producción y están operativos**, según confirmación del responsable. El flujo histórico cubre personas con contexto contractual; el nuevo registro no dependerá de ese filtro ni de una ejecución posterior del job para crear identidad.
- **La estructura de pruebas sirve como base para producción**, bajo la equivalencia habitual informada. Se verificará compatibilidad puntual antes del despliegue; no se requiere repetir el estudio exhaustivo para desarrollar esta entrega. Los resultados de calidad y volumen siguen siendo exclusivos de pruebas.

## Evidencia disponible

La captura inicial sobre una base incorrecta fue sustituida por `AgoraFinal` y `Terceros`, y sus exportaciones de calidad. En pruebas se inventariaron 46 tablas/340 columnas de Agora y 13 tablas/112 columnas de terceros, con acceso de lectura. Se revisaron los formularios #12–#17 y los jobs, incluidos los INSERT a persona, identificación y vinculación.

El perfilamiento detectó ambigüedades de identificación y otras anomalías que orientan las validaciones: por ejemplo, 19.783 grupos de documento activo asociados a varios terceros. Este dato no acredita el mismo problema o volumen en producción. Los hallazgos completos, incluidos módulos futuros, permanecen en el [diagnóstico](issue-18-hallazgos-csv.md). CSV, SQL y metadatos de conexión siguen excluidos de Git.

## Entrega de análisis para el sprint

1. [Responsabilidades y modelo inicial del CRUD](issue-18-responsabilidades-y-modelo-inicial-crud.md): entidades/atributos del registro natural, jurídico y asociación, referencias a terceros y flujo coordinado por el MID.
2. [Jobs y campos de destino](issue-18-jobs-agora-terceros.md): evidencia productiva del mapeo y separación entre persistencia en terceros y mantenimiento contractual por Argo.
3. [Formularios](issue-18-formularios-gestion-persona.md): relación con las vistas del frontend y decisiones pendientes por bloque.
4. [Plan del registro](issue-18-diagnostico-modelo-plan.md): orden de implementación y aplicabilidad del análisis a producción.
5. [Dependencias](issue-18-dependencias-y-alcance.md): dominios identificados y endpoints pendientes.

## Pendientes concretos

Cerrar tipos, obligatoriedad y cardinalidades; verificar rutas/DTO y catálogos de la API de terceros; resolver campos genéricos y clasificación de consorcios; acordar el contrato de Agora CRUD y la coordinación del MID, incluidos duplicados y fallos parciales. La convivencia con jobs productivos y la migración del legado se diseñarán en una etapa futura; Argo conserva su responsabilidad contractual.

La conciliación productiva, migración integral y PoC medida quedan para su fase correspondiente. No son condición para proponer el modelo del registro ni implican desarrollar los demás módulos ahora. No se han creado las issues MID/CRUD ni ejecutado cambios en las bases de datos.

## Soporte adicional verificado en terceros

La [revisión de repositorios y GET de catálogos](issue-18-soporte-api-terceros.md) confirma soporte para caracterización y contacto genérico en `info_complementaria_tercero`, además de seguridad social y familiares. Estos datos no deben duplicarse en Agora. La propuesta elimina `caracterizacion_natural` y la dirección general propia; mantiene los bloques de negocio y `tercero_id`. Algunas funciones del MID requieren homologar IDs/DTO antes de reutilizarse. Planificar jobs legado → terceros y migración legado → Agora nuevo corresponde a la transición futura, fuera del sprint actual.

## Precisiones sobre familiares y experiencia

Validar captura de familiares desde Agora con persistencia en terceros: datos mínimos de identidad, parentesco, contactos y eventual condición de dependencia. El catálogo de parentescos aportado no cubre todos los casos; los contratos compuestos requieren revisar reuso de personas y cardinalidad. Para experiencia, validar varias cabeceras y sus complementos hijos en terceros, sin equiparar tiempo de un empleo con experiencia acumulada. Ver [soporte API](issue-18-soporte-api-terceros.md). El [modelo propuesto](issue-18-responsabilidades-y-modelo-inicial-crud.md) incluye ahora la columna **Nombre tabla relación**, distinguiendo relaciones locales, externas y catálogos pendientes.
