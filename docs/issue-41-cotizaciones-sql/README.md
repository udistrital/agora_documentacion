# Issue #41 — Scripts SQL de parámetros para Cotizaciones

Rama propuesta: `docs/issue-41/scripts-sql`
Repositorio destino: `udistrital/agora_documentacion`
Motor: PostgreSQL. Esquema: `parametros`.

## Alcance de este avance

Este paquete crea catálogos nuevos o tipos de parámetro diferenciados para el alcance de solicitud y publicación. Cada catálogo incluido tiene inserción, rollback y verificación en una carpeta propia, siguiendo el patrón de `docs/entidades-bancarias/`.

| Carpeta | Código tipo parámetro | Valores | Fuente/estado |
|---|---|---:|---|
| `tipo-necesidad` | `TIP_NEC_COT` | 3 | Issue #32; M5 p.38: Bien, Servicio, Bienes y servicios |
| `tipo-forma-pago` | `TIP_FOR_PAG_COT` | 2 | Issue #32; M5 pp.28–30: Contraentrega, Pagos parciales |
| `clasificacion-requisito-documental` | `CLAS_REQ_DOC_COT` | 2 | Issue #32; RF-011: Obligatorio, Complementario |
| `estado-cargue-masivo` | `EST_CARGUE_COT` | 3 | Issue #32: Procesado, Procesado parcial, Rechazado; hipótesis de RF-008 |
| `motivo-rechazo-cargue` | `MOT_RECH_CARGUE_COT` | 3 | Issue #32: Tipo de dato, Valor no homologado, Campo obligatorio; lista no exhaustiva |
| `tipo-documento-cotizaciones` | `TIP_DOC_COT` | 3 | Issue #32: estudios previos, anexo técnico y CDP para solicitud/publicación |
| `estado-solicitud-cotizacion` | `EST_SOL_COT` | 9 | Estados propuestos en issue #32; deben contrastarse con el diagrama/transiciones de #34 |
| `estado-postulacion-cotizacion` | `EST_POST_COT` | 4 | Supuesto reportado en issue #34: Invitado, Sin respuesta, Participa, Declina; validar con el diagrama |
| `tarifas-iva` | `TARIFA_IVA_COT` | 2 | Issue #32 menciona 5 % y 19 %; DIAN confirma esos porcentajes para los supuestos tributarios aplicables. Confirmar catálogo completo con negocio |

Todos los valores se insertan con `numero_orden` explícito. Los códigos de tipo parámetro se prefijan para Cotizaciones y no modifican `TIP_DOC` ni los valores de personas de la issue #26.

## Compatibilidad con el esquema de parametros_crud

El modelo publicado en [`udistrital/parametros_crud`, `database/parametros.dbm`](https://github.com/udistrital/parametros_crud/blob/master/database/parametros.dbm) define `descripcion` como `VARCHAR(100)` en `area_tipo`, `tipo_parametro` y `parametro`. Por eso las descripciones de los valores se mantienen concisas: el INSERT agrega la marca `[Semilla: issue #41]`, que también cuenta dentro del límite de 100 caracteres. Esta comprobación estática no sustituye la ejecución en una base local o de pruebas.

## Catálogos que se reutilizan — no crear aquí

- Actividades económicas CIIU: usar el catálogo preparado en la issue #26.
- Tipo de contrato: consultar catálogo existente; confirmar mapeo de los valores de los mockups, sin duplicarlo aquí.
- Unidad de medida: reutilizar valores existentes.
- Tipos de documento del registro de personas: no modificarlos; los documentos de Cotizaciones incluidos en la etapa actual están bajo el tipo diferenciado `TIP_DOC_COT`.
- Catálogos de personas naturales y jurídicas cubiertos por la issue #26: fuera de alcance.

## Pendientes documentados (no se crea SQL hasta confirmar la fuente/decisión)

1. **Tipo de proceso** (`COTIZACIÓN`, `ESTUDIO DE MERCADO`): issue #32 los propone, pero también indica que hay que validar su correspondencia. Confirmar la definición de negocio, código y alcance antes de publicar el catálogo.
2. **Medio de pago**: los mockups del análisis mencionan tarjeta de crédito institucional, transferencia electrónica, consignación bancaria y cheque de gerencia; el propio análisis los deja por confirmar. Verificar la fuente institucional responsable y si corresponde reutilizar un servicio existente antes de crear valores.
3. **Área de conocimiento y Núcleo Básico del Conocimiento**: el MEN/SNIES documenta la taxonomía clásica de ocho áreas y 55 NBC, pero informa que la clasificación CINE-F 2013 A.C. la reemplaza desde 2020, manteniéndose visible la clasificación anterior para programas históricos. Antes de cargar un catálogo es necesario acordar si Cotizaciones debe utilizar la clasificación histórica de área/NBC o la clasificación vigente CINE-F y obtener los códigos oficiales completos. Fuentes: [glosario SNIES](https://snies.mineducacion.gov.co/portal/DOCUMENTOS/Glosario/) y [MEN sobre CINE-F 2013 A.C.](https://snies.mineducacion.gov.co/1778/w3-article-391382.html).
4. **Lista definitiva de motivos de rechazo del cargue** y los tres estados del cargue masivo: el detalle completo depende de RF-008, pendiente en #34. En este avance solo se cargan los valores explícitamente nombrados en #32.
5. **Estados de solicitud y postulación**: los valores del SQL son provisionales y no deben tratarse como contrato aprobado hasta contrastarlos con el diagrama de #34 y compartir el mapeo con quien desarrolla el CRUD (#40).
6. **IVA**: se incluyeron 5 % y 19 % porque aparecen en #32 y se halló soporte DIAN para los casos tributarios correspondientes. Las capturas antiguas con 16 % y 10 % no se cargaron como tarifas vigentes. Este catálogo no implica que todas las operaciones se graven en esas dos tarifas ni sustituye la regla tributaria del producto concreto.
7. **Documentos de etapas posteriores (fuera del alcance actual)**: `COTIZACION_OFERENTE`, `CERTIFICACION_BANCARIA`, `CATALOGO_TECNICO_FABRICANTE` y `CERTIFICACION_EXPERIENCIA` no se cargan en este catálogo porque corresponden a documentos de la oferta/postulación del proveedor, no a la etapa de solicitud y publicación que limita la issue #41. El rollback conserva estos códigos únicamente para limpiar filas semilla si se hubiese ejecutado una revisión anterior del script; el INSERT actual no los genera. Reconsiderarlos para carga en una issue posterior solo si se amplía el alcance funcional.
8. **Estado actual de la BD `parametros`**: no se contó con conexión a una base local/de pruebas para consultar el contenido real de `area_tipo`, `tipo_parametro` y `parametro`. Los scripts comprueban existencia por área/tipo/código para evitar duplicados; antes de ejecutarlos se debe revisar el preflight de abajo y verificar colisiones de códigos/nombres.

## Códigos que debe consumir el CRUD

- `TIP_NEC_COT`: `BIEN`, `SERVICIO`, `BIENES_SERVICIOS`
- `TIP_FOR_PAG_COT`: `CONTRAENTREGA`, `PAGOS_PARCIALES`
- `CLAS_REQ_DOC_COT`: `OBLIGATORIO`, `COMPLEMENTARIO`
- `EST_CARGUE_COT`: `PROCESADO`, `PROCESADO_PARCIAL`, `RECHAZADO` (hipótesis hasta cierre RF-008)
- `MOT_RECH_CARGUE_COT`: `TIPO_DATO`, `VALOR_NO_HOMOLOGADO`, `CAMPO_OBLIGATORIO` (mínimo identificado)
- `TIP_DOC_COT`: `ESTUDIOS_PREVIOS`, `ANEXO_TECNICO`, `CDP`
- `EST_SOL_COT`: `BORRADOR`, `PUBLICADA`, `ABIERTA`, `CERRADA`, `EN_EVALUACION`, `SELECCIONADA`, `VALIDADA`, `DESIERTA`, `CANCELADA` (provisional)
- `EST_POST_COT`: `INVITADO`, `SIN_RESPUESTA`, `PARTICIPA`, `DECLINA` (provisional)
- `TARIFA_IVA_COT`: `IVA_05`, `IVA_19` (verificar aplicabilidad por bien/servicio)

## Preflight de la base de datos (ejecutar antes de la inserción)

```sql
SELECT 'area_tipo' AS tabla, id, nombre, codigo_abreviacion, activo
FROM parametros.area_tipo
WHERE nombre = 'Gestión de Cotizaciones' OR codigo_abreviacion = 'COTIZACIONES'
UNION ALL
SELECT 'tipo_parametro', t.id, t.nombre, t.codigo_abreviacion, t.activo
FROM parametros.tipo_parametro t
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
ORDER BY 1, 2;

SELECT t.nombre AS tipo_parametro, t.codigo_abreviacion, p.nombre AS parametro,
       p.codigo_abreviacion AS codigo_parametro, p.numero_orden, p.activo
FROM parametros.tipo_parametro t
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
LEFT JOIN parametros.parametro p ON p.tipo_parametro_id = t.id
WHERE a.nombre = 'Gestión de Cotizaciones'
   OR t.codigo_abreviacion IN ('TIP_DOC', 'TIP_DOC_COT', 'TARIFA_IVA_COT')
ORDER BY a.nombre, t.numero_orden, p.numero_orden;
```

Si ya existe un tipo con el mismo nombre pero distinto código, detenerse y reconciliar el inventario en lugar de crear un duplicado. Los scripts de inserción son idempotentes respecto al área, tipo y código de parámetro. Los insert agregan la marca de origen `[Semilla: issue #41]` a las descripciones que crean. El rollback elimina únicamente filas propias identificadas por esa marca y los códigos del catálogo; no borra filas preexistentes sin marca. Los tipos y el área solo se eliminan si también fueron creados por esta semilla y quedan vacíos.

## Orden sugerido de aplicación

1. Ejecutar primero `01_insert_*.sql` de cada carpeta (cada script respeta dependencias internas área → tipo → parámetro).
2. Correr el `03_verificacion_*.sql` correspondiente a cada catálogo y guardar la salida.
3. Para probar rollback, ejecutar el `02_rollback_*.sql` de un catálogo de prueba y después su inserción y verificación. Si se prueban todos, revertir en orden inverso de aplicación.
4. No ejecutar en producción hasta revisar el preflight y alinear los códigos/estados con el equipo CRUD.

## Fuentes web consultadas

- MEN/SNIES, [Glosario: Área de conocimiento y Núcleo Básico del Conocimiento](https://snies.mineducacion.gov.co/portal/DOCUMENTOS/Glosario/).
- MEN/SNIES, [Adopción de CINE-F 2013 A.C. (10-02-2020)](https://snies.mineducacion.gov.co/1778/w3-article-391382.html).
- DIAN, [Compilación Jurídica — Concepto 10763 de 2024](https://normograma.dian.gov.co/dian/compilacion/docs/oficio_dian_10763_2024.htm).
