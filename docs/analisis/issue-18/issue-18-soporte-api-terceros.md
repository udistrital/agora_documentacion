# Issue #18 — soporte de terceros para caracterización y contacto

Revisión: 2026-10-01. Se inspeccionó la imagen local de tablas, los dos repositorios y catálogos por GET en los entornos indicados por el responsable. No se hicieron POST, PUT, PATCH ni DELETE, ni se consultaron registros personales. Los cuerpos de respuesta y las direcciones internas no se incorporan al repositorio público.

## Evidencia y límites

Repositorios clonados en el workspace, rama `develop`:

- [terceros_crud](https://github.com/udistrital/terceros_crud/tree/8c8be317675d189d1336c048649c9addb9519e58), commit `8c8be317675d189d1336c048649c9addb9519e58`.
- [terceros_mid](https://github.com/udistrital/terceros_mid/tree/ae1f522ed7240916bc1b8f3579db17e25d863cf6), commit `ae1f522ed7240916bc1b8f3579db17e25d863cf6`.

El código describe el contrato de esa revisión; no se comprobó que ese commit exacto sea el desplegado. Las pruebas GET acreditan únicamente las rutas y respuestas indicadas a continuación. La imagen confirma nombres de tablas, no reglas funcionales ni contratos por sí sola.

| GET ejecutado | Pruebas | Producción | Resultado |
|---|---|---|---|
| CRUD `/v1/grupo_info_complementaria?limit=100` | 200 | 200 | 40 grupos en cada entorno. |
| CRUD `/v1/info_complementaria?limit=500` | 200 | 200 | 286 definiciones en cada entorno; respuesta menor al límite solicitado. |
| MID `/v1/tipo/` | 200 | 200 | Mismos seis tipos publicados: contratista, proveedor, funcionarios, jefeDependencia, funcionarioPlanta y ordenadoresGasto. |
| MID `/v1/` | 404 | 404 | La raíz no es una ruta funcional publicada; no significa que el servicio esté inaccesible. |

Se accedió a los destinos internos de producción propuestos por el responsable. No fue necesario utilizar la pasarela WSO2, cuyo acceso no se verificó. Estos GET no validan permisos de escritura ni la consulta de personas.

Los catálogos son ampliamente coincidentes, pero no idénticos: por ejemplo, `VEHICULO` tiene ID 443 en pruebas y 442 en producción. En los IDs comunes de `info_complementaria` no se observaron diferencias de nombre, abreviatura, activo o tipo de dato; sí una diferencia de fechas técnicas. Los grupos comparten IDs/nombres/abreviaturas, con una diferencia de descripción/fechas. Esto respalda reutilizar el análisis estructural, pero no copiar IDs ciegamente entre entornos.

## Cómo almacena la información terceros

[Modelo InfoComplementariaTercero](https://github.com/udistrital/terceros_crud/blob/8c8be317675d189d1336c048649c9addb9519e58/models/info_complementaria_tercero.go):

- `grupo_info_complementaria`: agrupa conceptos, por ejemplo género, etnia o contacto.
- `info_complementaria`: define una opción o atributo, con grupo, nombre, abreviatura y `tipo_de_dato`.
- `info_complementaria_tercero`: asocia `tercero_id` e `info_complementaria_id`; guarda `dato` (JSONB), activo, auditoría y un padre opcional para agrupar información compuesta.

En catálogos de opciones, la selección puede expresarse con `InfoComplementariaId` y sin `Dato`, como hace el MID para género/estado civil. En atributos como teléfono o dirección, `Dato` contiene el valor. **En el DTO Go, `Dato` es un string que contiene JSON**, no un objeto JSON arbitrario enviado directamente. Los consumidores existentes usan formas distintas (`Data`, `value`, `principal`/`alterno`); acordar la forma por concepto antes de escribir. Un JSON válido no demuestra compatibilidad semántica.

El controlador CRUD expone GET/POST de colección y GET/PUT por ID bajo `/v1/info_complementaria_tercero`. Por código, las referencias se representan como `TerceroId: {Id: ...}` e `InfoComplementariaId: {Id: ...}`. La actualización usa el ID del registro complementario; no es un UPSERT por persona/concepto. Antes de crear, consultar lo existente y decidir actualización, multiplicidad o historial; no añadir filas duplicadas en cada envío. No se probaron escrituras.

## Reparto corregido por campo del formulario

Los IDs siguientes son evidencia del catálogo consultado, no constantes recomendadas. Resolver grupo y opción/atributo, validar activo y unicidad; algunos códigos se repiten o están vacíos.

| Datos de la vista | Evidencia del catálogo | Destino y decisión |
|---|---|---|
| Género | Grupo 6; opciones 29–31 y 313 | **Terceros**, `info_complementaria_tercero`. Homologar las opciones de la vista. |
| Grupo étnico | Grupo 3; opciones 13–17 | **Terceros**, misma tabla. El MID usa `TipoPoblacion`; no asumir que «población» cubre cualquier condición social. |
| Discapacidad | Grupo 1; opciones 1–7 | **Terceros**, misma tabla; acordar selección múltiple y significado de «no aplica». |
| Estado civil | Grupo 2; opciones 8–12 | **Terceros**, misma tabla. |
| Orientación sexual | Grupo `ORIENTACION_SEXUAL` (1636), opciones 328–331 | **Terceros**, misma tabla. |
| Identidad de género / reconocimiento identitario | Grupo `IDENTIDAD_GENERO` (1637), opciones 332–335 | **Terceros** si el campo de la vista expresa ese concepto; no mezclar con sexo/género ni orientación. |
| Cabeza de familia | `CABEZA_FAMILIA`, ID 42, grupo 9 | **Terceros**, mismo mecanismo; acordar formato de `Dato`. |
| Personas a cargo y cantidad | `PERSONAS_A_CARGO` 43 y `NUM_PERSONAS_A_CARGO` 44, grupo 9 | **Terceros**. Diferenciar booleano y cantidad. |
| Hijos y cantidad | `HIJOS` 45 y `NUMERO_HIJOS` 46, grupo 9; también existe `TIENE_HIJOS` 292 | **Terceros**; seleccionar una representación canónica con los consumidores, sin escribir ambas por conveniencia. |
| Teléfono, celular y correo general | `TELEFONO` 48, `CELULAR` 49, `CORREO` 50, grupo 10; correo alterno 312 | **Terceros**, contacto genérico de persona natural o jurídica. No duplicarlo en `contacto_proveedor`. |
| Dirección y lugar de residencia | `DIRECCIÓN` 51, `LUGAR_RESIDENCIA` 55, grupo 10 | **Terceros**, dirección general y referencia territorial. Los componentes del generador de direcciones requieren formato acordado; pueden ser campos de captura que construyen la dirección, no columnas propias de Agora. |
| Código postal / localidad | 52 / 87, grupo 10 | **Terceros** cuando los capture la vista; no añadir campos obligatorios nuevos por existir catálogo. |
| EPS/AFP/CCF | Tabla `seguridad_social_tercero`; código MID de alta de EPS | **Terceros**, con `TerceroId`, `TerceroEntidadId`, fechas y activo. Confirmar clasificación de las entidades y fecha de inicio real; no reutilizar el complemento «EPS» de vacunación para afiliación. |
| Familiares identificados | `tercero_familiar`: `TerceroId`, `TerceroFamiliarId`, `TipoParentescoId` | **Terceros** si se capturan personas relacionadas. «Tiene hijos/personas a cargo» no obliga a crear familiares ni revela su identidad. |
| Migrante, víctima, PEP, pensionado | No se localizó un concepto inequívoco equivalente en los catálogos consultados | **Definición pendiente**: preferir extensión genérica acordada de terceros para caracterización reutilizable. No inferir víctima a partir de «desplazados» de inscripción académica ni crear una tabla amplia de caracterización en Agora. PEP puede requerir distinguir declaración y evaluación de negocio. |
| Nombre comercial, web y constitución de empresa | Hay grupo «Información empresarial» con atributos similares, sin códigos únicos en varios casos | Reutilización en terceros **pendiente de validar contexto**: pueden describir la empresa de una persona, no a la persona jurídica como tal. No reemplazan el NIT/razón social de identidad ni prueban equivalencia con matrícula/constitución mercantil. |
| Experiencia laboral/profesional en meses y perfil declarado | Existen grupos de experiencia laboral y tipo perfil | Confirmar semántica: historial laboral no equivale a totales declarados para el registro. Mantener propuesta de Agora solo para los datos específicos de ese registro, sin replicar un historial genérico. |
| Canal exclusivo de tesorería/notificación, bancos, régimen, portafolio, soportes y declaraciones del registro | No se acreditó equivalencia genérica completa para esos usos | Mantener la propuesta de Agora para el negocio. Si el canal utiliza un contacto genérico existente, referenciar su complemento de terceros en lugar de duplicar el valor. |

## Uso de terceros_mid y precauciones concretas de integración

El [controlador de personas](https://github.com/udistrital/terceros_mid/blob/ae1f522ed7240916bc1b8f3579db17e25d863cf6/controllers/sga_tercero.go) y el [servicio](https://github.com/udistrital/terceros_mid/blob/ae1f522ed7240916bc1b8f3579db17e25d863cf6/services/sga_tercero_service.go) implementan:

| Ruta relativa | Uso en el código revisado | Validación realizada |
|---|---|---|
| `/v1/personas/` POST/PUT | Alta/actualización compuesta de persona | Solo lectura de código. El alta exige campos naturales y fija tipo contribuyente 1; no es un contrato universal para jurídicas/consorcios. |
| `/v1/personas/complementarios` POST/PUT | Discapacidad, población, estado civil, orientación, identidad de género y otros bloques; también afiliación EPS | Solo lectura de código; revisar compatibilidad del DTO y catálogos antes de reutilizar. |
| `/v1/personas/:tercero_id/complementarios` GET | Consulta compuesta de complementos | Ruta identificada en código, sin solicitar datos personales. |
| `/v1/personas/contacto` POST y `/v1/personas/:tercero_id/contacto` GET | Contactos compuestos | Solo lectura de código; se encontraron IDs fijos incompatibles con catálogos actuales. |
| `/v1/tipo/` GET | Nombres de consultas de terceros disponibles | GET 200 en ambos entornos. |

**Incompatibilidad observada:** `GuardarDatosContacto` utiliza 41 como estrato, 51 como teléfono y 54 como dirección. Los catálogos consultados en ambos entornos indican 41 = COMUNIDAD_LGBT, 51 = DIRECCIÓN y 54 = ESTRATO_RESPONSABLE. Además, `GuardarDatosComplementarios` usa 42 para GrupoSisben, mientras el catálogo indica CABEZA_FAMILIA. Esto demuestra que no basta con que exista la función: **no recomendar su escritura sin corregir/homologar esos IDs y verificar el DTO**. No se afirma que el mismo commit esté desplegado ni se ejecutó una petición que produjera esa escritura.

Para el primer contrato de Agora MID se propone consumir los recursos de `terceros_crud` para los datos genéricos con IDs resueltos del catálogo y payload acordado. Reutilizar operaciones de `terceros_mid` solo después de validar su compatibilidad, o ajustar ese servicio como trabajo explícito si se elige esa vía. La necesidad de adaptar un MID no cambia la propiedad del dato: sigue en terceros.

El [helper de proveedores](https://github.com/udistrital/terceros_mid/blob/ae1f522ed7240916bc1b8f3579db17e25d863cf6/helpers/tipos/proveedores.go) consulta identificaciones/personas activas; no comprueba inscripción en el nuevo Agora. Su nombre no sustituye el estado de `agora.proveedor`. El [helper de contratistas](https://github.com/udistrital/terceros_mid/blob/ae1f522ed7240916bc1b8f3579db17e25d863cf6/helpers/tipos/contratistas.go) obtiene tipos CPS/OPS/PS de parámetros y consulta vinculaciones; su mantenimiento contractual sigue correspondiendo a Argo.

## Efecto sobre la propuesta de Agora y transición futura

Se retira `caracterizacion_natural` del esquema propuesto y no se crea una tabla propia para la dirección general. Contactos genéricos, caracterización soportada y afiliaciones se consultan/persisten en terceros. Agora conserva la relación `proveedor.tercero_id` y sus entidades de negocio; los datos genéricos sin catálogo equivalente quedan como decisión puntual de extensión, no como columnas automáticas en Agora.

La ejecución de jobs **Agora legado → terceros** y la migración **Agora legado → Agora nuevo** pueden diseñarse conjuntamente durante la transición. Esa planificación, conciliación, corte y convivencia operativa es **trabajo futuro**, fuera de la entrega actual de registro. No se modificaron jobs, repositorios de terceros ni bases de datos.

## Familiares: captura en Agora y persistencia en terceros

Según la observación del responsable en pruebas, `tercero_familiar` está vacía y `tipo_parentesco` contiene MADRE (1), PADRE (2) y HERMANO (3). Esto describe esa captura; no prueba ausencia de uso en todos los entornos. La estructura relaciona dos filas de `tercero`: titular (`tercero_id`) y familiar (`tercero_familiar_id`), con su parentesco (`tipo_parentesco_id`).

La vista de Agora puede capturar los familiares y su MID coordinar el registro, **persistiéndolos en terceros**, sin crear un maestro familiar paralelo en Agora. Los complementos «tiene hijos» o «personas a cargo» solo registran la declaración/cantidad: no identifican familiares ni acreditan dependencia económica de una persona concreta. La relación `tercero_familiar` tampoco tiene campos propios de dependencia económica, vigencia o soporte de esa condición.

Tareas pendientes antes de habilitar el detalle de familiares:

1. Confirmar si las vistas deben capturar familiares identificados o únicamente los indicadores/cantidades actuales. Definir cuándo es requerido el detalle y si las personas a cargo pueden no ser familiares.
2. Definir el mínimo de identidad del familiar: nombre, identificación cuando aplique, reglas para menores/personas sin documento y nacimiento si se necesita. No exigir todos estos datos sin validación funcional ni inventar documentos para obtener un ID.
3. Resolver o crear al familiar en `tercero`, registrar su identificación en `datos_identificacion` cuando corresponda y crear `tercero_familiar` con ambos IDs y el parentesco. Contactos necesarios del familiar se guardan como complementos del propio familiar.
4. Completar/homologar `tipo_parentesco` para los casos aprobados (por ejemplo, hijo/hija o cónyuge); los tres valores aportados no cubren todos los dependientes. Acordar dirección del parentesco, prohibición de autorrelación, duplicados y manejo de bajas.
5. Si se requiere dependencia económica individual, definir condición, vigencia y evidencia necesaria, y dónde representarlas: complemento/relación genérica extendida en terceros o evidencia específica de un trámite de Agora. No equiparar automáticamente parentesco y dependencia.
6. Validar el contrato de las operaciones con casos de cero, uno y varios familiares, existente/nuevo y reintentos antes de habilitar escritura desde las vistas.

Hay soporte de código, pero no se probó escritura: CRUD publica `/v1/tercero_familiar/` y `/v1/tercero_familiar/informacion_familiar`. La operación compuesta [AddInformacionFamiliar](https://github.com/udistrital/terceros_crud/blob/8c8be317675d189d1336c048649c9addb9519e58/models/tercero_familiar.go) inserta siempre el tercero familiar y luego relación/contactos; no resuelve por sí sola un familiar preexistente. Para reutilizar identidades se debe orquestar explícitamente la resolución y la relación, o ajustar la operación compuesta.

En el MID, `ActualizarInfoFamiliar` accede a posiciones 0 y 1 de las listas de familiares y contactos, además de utilizar IDs de contacto fijos. No es evidencia de soporte genérico para cualquier cantidad de dependientes. Su adaptación/prueba queda pendiente; el modelo relacional sí permite varias relaciones por titular.

## Empresas y experiencias: catálogo frente a registros de una persona

Los valores 336–349 aportados tienen **`grupo_info_complementaria_id = 1638`**. Es también el ID observado por GET para «Información empresarial». La mención a «grupo 58» no coincide con esa columna; queda por aclarar si 58 identifica otro recurso o una referencia de interfaz. No usarlo como ID de grupo sin homologación.

Las filas de `info_complementaria` son **definiciones de campos**, no una empresa o experiencia concreta. Cada persona puede tener múltiples filas en `info_complementaria_tercero`. El modelo revisado no impone una única fila por par persona/definición y dispone de `info_complementaria_tercero_padre_id`, por lo que **no limita estructuralmente a una sola experiencia**. Sin agrupación, repetir NIT/fechas/cargo no permitiría reconstruir con seguridad qué campos pertenecen al mismo episodio.

Para el grupo 19, se propone validar este uso del soporte existente:

| Registro conceptual | InfoComplementariaId | Relación |
|---|---|---|
| Experiencia A | 136 (`EXP_LABORAL`), si se confirma su función como cabecera | Registro padre de la persona. |
| NIT, inicio, fin, dedicación, vinculación, cargo, descripción y soporte de A | 97–104 | Cada fila referencia el ID del registro padre A mediante `InfoCompleTerceroPadreId`. |
| Experiencia B | Otra fila para 136, de la misma persona | Padre B distinto; puede corresponder incluso a otro período en la misma empresa. |
| Campos de B | Nuevas filas para 97–104 | Referencian el padre B, sin sobrescribir A. |

Es una **propuesta de contrato**, no una constatación de cómo las aplicaciones guardan hoy la experiencia. Verificar `Dato`, semántica de 136, consistencia del tercero padre/hijo, consultas por padre, actualizaciones, bajas y reintentos. El endpoint CRUD `/info_complementaria_tercero/padre` revisado espera campos de formación académica (`ProgramaAcademico`, `TituloTrabajoGrado`, etc.); no es un endpoint genérico de experiencia que pueda reutilizarse sin adaptación. El modelo permite el agrupamiento, pero la operación compuesta apropiada debe acordarse.

El valor 364 mide tiempo en **esa actividad/trabajo**, no experiencia total ni profesional acumulada. Los totales de la vista requieren decidir si se declaran o se calculan, cómo tratar períodos simultáneos y qué cuenta como profesional. Los campos 359–392 de encuesta/satisfacción no son todos atributos de un episodio laboral. No agruparlos automáticamente ni usar `Grupo_19`, repetido como abreviatura, como identificador único.

Para empresas (grupo 1638) también debe definirse el sujeto: empresa propia descrita por una persona, empresa empleadora en una experiencia o persona jurídica registrada como proveedor. Si se necesitan varias empresas, acordar cabecera/relación para separar sus datos y usar identidad jurídica en terceros cuando corresponda; las definiciones 336–349 por sí solas no demuestran ese contrato. No duplicar NIT/razón social como maestro alterno de una jurídica ya identificada.

## IDs fijos: no es truncamiento

No se encontraron números recortados como causa de lo descrito. En las funciones señaladas, **el MID construye la petición con un `InfoComplementariaId` numérico fijo**. Por ejemplo, intenta registrar un teléfono con ID 51, mientras el catálogo consultado identifica 51 como DIRECCIÓN. El CRUD recibe la referencia enviada y puede persistirla como tal si pasa las validaciones; no deduce que el dato pretendía ser un teléfono.

La incompatibilidad está entre las constantes del código revisado del MID y el significado de los IDs del catálogo. No se ha establecido si deriva de un cambio histórico de catálogo, otra configuración o una versión distinta desplegada. Tampoco se ha demostrado que existan datos mal guardados por ese motivo. Corresponde homologar las referencias y probar el contrato antes de reutilizar esas funciones.

## Diferencia entre terceros_crud y terceros_mid

| Servicio | Función en el código revisado | Papel para Agora |
|---|---|---|
| `terceros_crud` | Expone recursos persistentes como `tercero`, `datos_identificacion`, `info_complementaria_tercero`, `tercero_familiar` y `vinculacion`; opera sobre la BD y también tiene algunas operaciones compuestas. | Destino de identidad, caracterización y relaciones genéricas. Se consumen sus APIs, no SQL directo. |
| `terceros_mid` | Compone consultas y operaciones de varios recursos/servicios, aplica reglas y adapta respuestas a casos de uso. Algunas funciones están orientadas a flujos académicos o tipos particulares de persona. | Reutilizar funciones cuyo contrato, catálogos y cardinalidades coincidan; no asumir que todas sirven sin cambios para los formularios de Agora. |
| Agora MID propuesto | Coordina datos genéricos de terceros y bloques de negocio de Agora CRUD para las vistas actuales. | Puede consumir terceros CRUD directamente o una operación validada de terceros MID; el dato genérico sigue perteneciendo a terceros en ambos casos. |

## Resolución de catálogos por código y entorno

Las peticiones deben resolver primero el grupo por `CodigoAbreviacion` y luego el atributo/opción por su `CodigoAbreviacion` dentro de ese grupo, comprobando activo y una única coincidencia. El ID retornado en el entorno de destino es el que se utiliza en relaciones y payloads. Los IDs numéricos citados en este análisis documentan la evidencia; no deben convertirse en constantes del nuevo MID.

Si el grupo o el atributo carece de código, o este se repite (por ejemplo, `Grupo_19`), queda pendiente homologar el catálogo con su responsable. No seleccionar la primera coincidencia ni recurrir a un ID de otro entorno como respaldo. Esta resolución evita depender de la igualdad accidental de IDs entre pruebas y producción.
