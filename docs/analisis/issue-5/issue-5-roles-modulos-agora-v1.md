# Revisión documental de Ágora: roles y módulos — Issue #5

Fecha de revisión: 2026-09-11. Estado: entregable documental preparado para revisión del SM/líder técnico.

- Issue: https://github.com/udistrital/agora_documentacion/issues/5
- Proyecto: https://github.com/orgs/udistrital/projects/120 (Agora-V2).
- Fuente: [Manuales Ágora](https://www.dropbox.com/scl/fo/srigt34zoid2csao98lt0/ALxaaAube_a6Hg0X6rTcXIc?rlkey=k3boze44uax75ochxe8afdeml&dl=0), carpeta enlazada en el issue.

## Alcance y método

Se revisaron las secciones de los nueve PDF de la carpeta que describen roles, módulos y funciones, usando extracción de texto y referencias al número de página del archivo PDF, contando la portada como página 1. Los índices de algunos manuales no coinciden con el cuerpo; las referencias de este documento apuntan al cuerpo.

El issue denomina al sistema «Ágora v1», mientras que los archivos generales indican Ágora V2 y los manuales de cotizaciones V3. Aquí se documenta el sistema histórico descrito en la fuente proporcionada, sin afirmar que esas versiones equivalgan a la versión desplegada actualmente ni al proyecto Agora-V2. Esa correspondencia requiere validación del equipo.

El resultado es un inventario funcional documental, no una auditoría del aplicativo ni de sus permisos implementados. No se inspeccionaron visualmente todas las capturas ni se probaron flujos en producción.

## Fuentes consultadas

Los nombres son los del archivo ZIP descargado de la carpeta. Los identificadores M1–M9 se usan como referencias en las tablas.

| ID | Archivo y ubicación en la carpeta | Páginas PDF |
|---|---|---:|
| M1 | `Manual  ÁGORA V2.pdf` | 40 |
| M2 | `Manual Direcciones ÁGORA.pdf` | 5 |
| M3 | `Manual Contraseñas ÁGORA V2.pdf` | 16 |
| M4 | `Módulo de Cotizaciones/Perfil (Proveedor)/Gestión de Notificaciones - ÁGORA - V3P - Manual de Usuario.pdf` | 36 |
| M5 | `Módulo de Cotizaciones/Perfil (Jefe Dependencia)/Generar Solicitud de Cotización - ÁGORA - V3JD - Manual de Usuario.pdf` | 57 |
| M6 | `Módulo de Cotizaciones/Perfil (Ordenador de Gasto)/Generar Solicitud de Cotización - ÁGORA - V3OG - Manual de Usuario.pdf` | 30 |
| M7 | `Módulo de Cotizaciones/Perfil (Ordenador de Gasto)/Validar Cotizaciones Vinculadas - ÁGORA - V3OG - Manual de Usuario.pdf` | 28 |
| M8 | `Módulo de Cotizaciones/Perfil (Jefe Dependencia)/Gestionar Solicitudes de Cotización - ÁGORA - V3JD - Manual de Usuario.pdf` | 88 |
| M9 | `Módulo de Cotizaciones/Perfil (Ordenador de Gasto)/Gestionar Solicitudes de Cotización - ÁGORA - V3OG - Manual de Usuario.pdf` | 54 |

## Roles y perfiles identificados

| Rol o perfil documental | Función descrita | Evidencia |
|---|---|---|
| Persona Natural | Registra sus datos y mantiene información general y actividades económicas. | M1, pp. 8–17, 29–35. |
| Persona Jurídica | Registra información de la empresa y mantiene sus datos y actividades económicas. Su representante legal debe estar inscrito previamente como Persona Natural. | M1, pp. 18–26, 29–35. |
| Proveedor | Consulta solicitudes disponibles, registra observaciones, responde cotizaciones y consulta la respuesta del solicitante mediante Gestión Notificaciones. | M4, pp. 3, 5, 7–8, 20–35. |
| Jefe de Dependencia | Genera y gestiona solicitudes de cotización, procesa su envío a proveedores y registra decisiones sobre las ofertas. | M5, pp. 3, 5, 7; M8, pp. 7–9, 50, 62–63. |
| Ordenador del Gasto | Genera y gestiona solicitudes; además, valida las cotizaciones vinculadas mediante una decisión de aprobación o rechazo. | M6, pp. 3, 5, 7; M9, pp. 7–8, 36–38; M7, pp. 5, 7, 25–27. |

Persona Natural y Persona Jurídica son tipos de proveedor en el registro (M1, p. 8), y el manual también los denomina roles en actualización (M1, p. 29). Proveedor es el rol nombrado en cotizaciones. Estas cinco denominaciones no demuestran cinco roles técnicos independientes; su correspondencia debe verificarse en la configuración del sistema.

El representante legal es un actor relacionado con la Persona Jurídica, sin evidencia aquí de un rol de acceso independiente. «Solicitante» describe a quien origina la solicitud; los accesos documentados para crearla corresponden a Jefe de Dependencia y Ordenador del Gasto.

## Inventario de módulos y funciones

Se conserva la denominación documental. No se presupone que cada sección corresponda a un menú independiente en la versión actual.

| Módulo o sección | Funciones principales | Usuarios o roles documentados | Evidencia |
|---|---|---|---|
| Acceso | Entrada al registro e inicio de sesión mediante credenciales. | Personas que se registran y usuarios registrados; el ingreso también se describe para los perfiles de cotizaciones. | M1, pp. 7–8; M4–M9, pp. 4–6. |
| Registro | Alta de Persona Natural o Jurídica; información de contacto, financiera, documentos y actividades económicas. Primer ingreso y cambio de clave inicial. | Persona Natural y Persona Jurídica. | M1, pp. 8–28. |
| Actualización Persona | Consulta y actualización de la información general desde Datos Generales. | Persona Natural o Jurídica. | M1, pp. 29–32. |
| Gestión Actividades Económicas | Adición, eliminación y registro de actividades económicas. | Persona Natural o Jurídica. | M1, pp. 33–35. |
| Gestión Certificados | Generación del certificado de registro en PDF. | Persona o empresa registrada, en el contexto del manual general. | M1, pp. 36–37. |
| Mi Sesión | Cambio de contraseña y cierre de sesión. | Usuario con sesión iniciada; documentado en el manual general. | M1, pp. 38–39. |
| Recuperación de Contraseña | Consulta de usuario, validación de identidad y establecimiento de nueva contraseña. | Usuario registrado que necesita recuperar acceso. | M3, pp. 4–10. |
| Gestión Cotizaciones | Generación, gestión y validación de solicitudes/cotizaciones mediante submódulos según el rol. | Jefe de Dependencia y Ordenador del Gasto; validación vinculada exclusiva del segundo. | M5–M9, pp. 5 y 7. |
| Gestión Notificaciones | Gestión de cotizaciones desde la perspectiva del proveedor. | Proveedor. | M4, pp. 5, 7–8. |

El registro de direcciones es una función auxiliar de captura mediante paneles de nomenclaturas y letras. M2, pp. 3–4, describe su uso; no aporta evidencia de un módulo de menú o rol independiente. Su referencia a nomenclaturas DIAN se registra como comportamiento histórico del manual, sin verificar normativa vigente.

### Submódulos de cotizaciones y relación con roles

| Ruta documentada | Funciones | Rol autorizado según el manual | Evidencia |
|---|---|---|---|
| Gestión Cotizaciones → Relacionar Cotización → Generar Solicitud de Cotización | Asociación de necesidad y presupuesto; datos de solicitud, productos/servicios e información de pago. | Jefe de Dependencia y Ordenador del Gasto. | M5, pp. 5, 7, 11–13; M6, pp. 2, 5, 7. |
| Gestión Cotizaciones → Gestionar Solicitud de Cotización → Gestionar Solicitudes de Cotización | Detalle, modificar, procesar, observaciones, cotizaciones, cancelar y gestión de modificaciones. | Jefe de Dependencia y Ordenador del Gasto. | M8, pp. 5, 7–9; M9, pp. 5, 7–8. |
| Gestión Cotizaciones → Validaciones Cotización → Validar Cotizaciones Vinculadas | Consulta de detalle y resultado; aprobación o rechazo con observaciones. | Exclusivamente Ordenador del Gasto. | M7, pp. 5, 7, 25–27. |
| Gestión Notificaciones → Gestionar Solicitudes de Cotización → Gestión Cotizaciones | Consulta de solicitud, observaciones, respuesta/cotización y respuesta del solicitante. | Exclusivamente Proveedor. | M4, pp. 5, 7–8, 31–35. |

La respuesta al proveedor dentro de Gestionar Solicitudes y la validación de cotizaciones vinculadas son acciones documentadas por separado. La primera aparece para ambos roles institucionales (M8, pp. 62–63; M9, pp. 36–38); la segunda está restringida al Ordenador del Gasto (M7, pp. 5 y 25–27).

## Funcionamiento general identificado

1. La persona se registra como Natural o Jurídica, completa sus datos y obtiene credenciales. El registro jurídico requiere la inscripción previa del representante legal como persona natural (M1, pp. 8, 18 y 27–28).
2. La persona mantiene sus datos y actividades económicas y puede generar su certificado de registro (M1, pp. 29–37).
3. El Jefe de Dependencia o el Ordenador del Gasto genera una solicitud. El manual describe información de necesidad/presupuesto y consulta de datos de SICAPITAL (M5, pp. 11–13; M6, pp. 5 y 7).
4. La solicitud se procesa para enviarla a los proveedores que cumplen las condiciones establecidas (M8, p. 50).
5. El Proveedor consulta la solicitud, registra observaciones y responde con la cotización y su soporte; puede consultar la respuesta del solicitante (M4, pp. 8, 17, 20–35).
6. El solicitante gestiona las cotizaciones y registra la decisión correspondiente. El Ordenador del Gasto dispone además de la validación de cotizaciones vinculadas (M8, pp. 62–63; M9, pp. 36–38; M7, pp. 25–27).

Esta secuencia resume las funciones descritas; no sustituye un diagrama validado de estados y transiciones.

## Hallazgos y asuntos por validar

- **Correspondencia de versiones:** confirmar qué significa Ágora v1 frente a los manuales V2/V3 y al proyecto Agora-V2.
- **Roles técnicos:** verificar cómo se relacionan Persona Natural/Jurídica y Proveedor en el control de acceso. No se atribuyen permisos adicionales por inferencia.
- **Navegación:** M1, pp. 29 y 33, repite la ruta Datos Generales → Actualizar información para datos y actividades económicas. Confirmar los nombres reales del menú.
- **Edición de identificación:** M1, p. 29, presenta una redacción ambigua sobre modificar el tipo y número de documento. Requiere contraste con el aplicativo antes de convertirla en regla funcional.
- **Respuesta y modificación:** M4, p. 31, combina una restricción de respuesta única con referencias a Modificar. Se requiere validar las condiciones que habilitan cada acción.
- **Planificación del issue:** el tablero muestra Ready, Sprint 0, prioridad I, actividad Análisis y hito Exploración Inicial. Estimate no tiene valor, aunque el DoR marca estimación completada. El equipo debe registrar la estimación acordada.
- **Distribución de revisión:** los issues #1–#5 tienen el mismo alcance documental y responsables diferentes. Definir si las revisiones son individuales o si se distribuyen módulos; esta revisión cubre el inventario de la carpeta completa.

## Relación con el criterio de aceptación

| Elemento solicitado | Evidencia preparada | Estado |
|---|---|---|
| Revisar manuales | Catálogo M1–M9 y referencias a secciones funcionales. | Revisión documental de roles y módulos realizada. |
| Identificar y listar roles y módulos | Tablas de roles, inventario y submódulos. | Entregable preparado para revisión. |
| Documentación del issue | Este archivo. | Preparado localmente; pendiente publicación/vinculación al issue. |
| Aprobación del SM/líder técnico | No se ha obtenido aprobación. | Pendiente. |

La preparación de este documento no cambia el estado, la estimación ni las casillas del issue en GitHub.
