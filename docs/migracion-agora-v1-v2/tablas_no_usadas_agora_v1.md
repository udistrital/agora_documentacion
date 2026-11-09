# Tablas no usadas de Ágora V1

Tablas del esquema `agora` de Ágora V1 que no se usan y no hacen parte del modelo nuevo de proveedores (`gestion_personas_crud`). Se documenta su estructura y el destino definido para cada campo en la matriz de migración.

## Resumen

| Tabla (Ágora V1) | Campos | Descripción |
|---|---|---|
| `agora.informacion_sociedad_temporal` | 6 | Sociedades temporales (consorcios / uniones temporales) registradas como proveedor, con representante y suplente. |
| `agora.informacion_sociedad_participan` | 5 | Participantes de una sociedad temporal y su porcentaje de participación. |
| `agora.inhabilidad` | 7 | Inhabilidades del proveedor, con tipo, tiempo, fecha, descripción y soporte. |
| `agora.contrato_proveedor` | 4 | Relación entre contratos y proveedores por vigencia. |
| `agora.contrato_evaluacion` | 8 | Contratos sujetos a evaluación, con evaluador (interventor o supervisor), necesidad, estado y unidad ejecutora. |
| `agora.evaluacion` | 15 | Evaluación de desempeño del proveedor por contrato: criterios con puntaje y clasificación A/B/C. |

## Detalle de tablas

### agora.informacion_sociedad_temporal

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino propuesto | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración | Notas |
|---|---|---|---|---|---|---|---|---|---|
| `id_sociedad` | NUMERIC(14,0) | PK; NOT NULL; DEFAULT nextval('agora.sociedad_id_sociedad_seq'::regclass) |  | `proveedores.sociedad_temporal.id` | SERIAL |  |  |  | Identificador único; llave primaria de la tabla. |
| `id_proveedor_sociedad` | NUMERIC(14,0) | UNIQUE | agora.informacion_proveedor.id_proveedor | `proveedores.sociedad_temporal.id_proveedor_sociedad` | INTEGER | NOT NULL | proveedores.proveedor.id | Identificar el proveedor a partir de `proveedores.proveedor.id`. | Identificación `id_proveedor`; FK de la tabla `informacion_proveedor`. |
| `digito_verificacion` | INTEGER |  |  | `proveedores.sociedad_temporal.digito_verificacion` | INTEGER | NOT NULL |  |  | Dígito de verificación de la sociedad temporal. |
| `representante` | NUMERIC(14,0) |  | agora.informacion_proveedor.id_proveedor | `proveedores.sociedad_temporal.representante` | INTEGER | NOT NULL | terceros.datos_identificacion.numero | Identificar al representante a partir de `terceros.datos_identificacion` con el número. | Documento del representante legal de la sociedad temporal. |
| `representante_suplente` | NUMERIC(14,0) |  | agora.informacion_proveedor.id_proveedor | `proveedores.sociedad_temporal.representante_suplente` | INTEGER | NOT NULL | terceros.datos_identificacion.numero | Identificar al representante a partir de `terceros.datos_identificacion` con el número. | Documento del representante legal suplente de la sociedad temporal. |
| `estado` | BOOLEAN | DEFAULT true |  | `proveedores.sociedad_temporal.estado` | BOOLEAN | DEFAULT true | parametros.parametro.id | Crear el parámetro. | Estado del registro. Es igual al campo `activo` de los lineamientos. |

### agora.informacion_sociedad_participan

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino propuesto | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración | Notas |
|---|---|---|---|---|---|---|---|---|---|
| `id_participante` | NUMERIC(10,0) | PK; NOT NULL; DEFAULT nextval('agora.sociedad_id_participante_seq'::regclass) |  | `proveedores.contratistas_sociedades.id` | SERIAL |  |  |  | Identificador único de cada registro. |
| `id_proveedor_sociedad` | NUMERIC(14,0) |  | agora.informacion_sociedad_temporal.id_proveedor_sociedad | `proveedores.contratistas_sociedades.id_proveedor_sociedad` | INTEGER | NOT NULL | proveedores.proveedor.id | Identificar el proveedor a partir de `proveedores.proveedor.id`. | Identificación `id_proveedor`; FK de la tabla `informacion_proveedor`. |
| `id_contratista` | NUMERIC(14,0) |  | agora.informacion_proveedor.id_proveedor | `proveedores.contratistas_sociedades.id_contratista` | CHARACTER VARYING(50) | NOT NULL | terceros.datos_identificacion.numero | Identificar el proveedor a partir de `terceros.datos_identificacion` con el número. | Número de documento del contratista. |
| `porcentaje_participacion` | NUMERIC(5,3) |  |  | `proveedores.contratistas_sociedades.porcentaje_participacion` | NUMERIC(5,3) |  |  |  | Porcentaje de participación. |
| `estado` | BOOLEAN | DEFAULT true |  | `proveedores.contratistas_sociedades.estado` | INTEGER | NOT NULL | parametros.parametro.id | Crear el parámetro. | Estado del registro. |

### agora.inhabilidad

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino propuesto | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración | Notas |
|---|---|---|---|---|---|---|---|---|---|
| `id_inhabilidad` | NUMERIC | NOT NULL DEFAULT nextval('agora.prov_inhabilidad_id_inhabilidad_seq'::regclass) |  | `proveedores.inhabilidad.id` | SERIAL | NOT NULL DEFAULT nextval('agora.prov_inhabilidad_id_inhabilidad_seq'::regclass) |  | Se asume que representa el `id` del registro. |  |
| `id_proveedor` | NUMERIC | NOT NULL | agora.informacion_proveedor.id_proveedor | `proveedores.inhabilidad.id_proveedor` | NUMERIC | NOT NULL | proveedores.proveedor.id | Identificar el proveedor a partir del número en `terceros.datos_identificacion` y de su `tercero_id`. |  |
| `tipo_inhabilidad` | CHARACTER VARYING(255) | NOT NULL |  | `proveedores.inhabilidad.id_tipo_inhabilidad` | INTEGER | NOT NULL | parametros.parametro.id | Crear los tipos de inhabilidad. |  |
| `tiempo_inhabilidad` | CHARACTER VARYING(255) | NOT NULL |  | `proveedores.inhabilidad.tiempo_inhabilidad` | CHARACTER VARYING(255) | NOT NULL |  |  |  |
| `fecha_inhabilidad` | DATE | NOT NULL |  | `proveedores.inhabilidad.fecha_inhabilidad` | TIMESTAMP | NOT NULL |  |  |  |
| `descripcion` | CHARACTER VARYING(255) | NOT NULL |  | `proveedores.inhabilidad.descripcion` | CHARACTER VARYING(255) | NOT NULL |  |  |  |
| `anexo_soporte` | CHARACTER VARYING(150) |  |  | `proveedores.inhabilidad.anexo_soporte_id` | INTEGER | NOT NULL | proveedores.documento.id | Identificar el anexo de soporte con el enlace en la tabla `proveedores.documento`. |  |

### agora.contrato_proveedor

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino propuesto | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración | Notas |
|---|---|---|---|---|---|---|---|---|---|
| `id_relacion` | INTEGER | NOT NULL DEFAULT nextval('agora.prov_contrato_id_relacion_seq'::regclass) |  | `proveedores.contrato_proveedor.id_contrato_proveedor` | SERIAL |  |  |  |  |
| `id_contrato` | INTEGER | NOT NULL |  | `proveedores.contrato_proveedor.id_contrato` | INTEGER | NOT NULL |  |  |  |
| `id_proveedor` | INTEGER | NOT NULL |  | `proveedores.contrato_proveedor.id_proveedor` | INTEGER | NOT NULL | proveedores.proveedor.id | Identificar el proveedor a partir del número en `terceros.datos_identificacion` y de su `tercero_id`. |  |
| `vigencia` | NUMERIC | NOT NULL |  | `proveedores.contrato_proveedor.vigencia` | INTEGER | NOT NULL |  | La vigencia debe ser un año (2026, 2027, etc.). | Año en que se registra el contrato. |

### agora.contrato_evaluacion

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino propuesto | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración | Notas |
|---|---|---|---|---|---|---|---|---|---|
| `id_contrato` | INTEGER | NOT NULL DEFAULT nextval('agora.prov_contrato_id_contrato_seq'::regclass) | agora.evaluacion.id_contrato | `proveedores.contrato_evaluacion.id_contrato` | SERIAL | NOT NULL DEFAULT nextval('agora.prov_contrato_id_contrato_seq'::regclass) |  |  |  |
| `numero_contrato` | NUMERIC | NOT NULL |  | `proveedores.contrato_evaluacion.numero_contrato` | NUMERIC(10,2) | NOT NULL |  |  |  |
| `vigencia` | NUMERIC | NOT NULL |  | `proveedores.contrato_evaluacion.vigencia` | INTEGER | NOT NULL |  | La vigencia debe ser un año (2026, 2027, etc.). | Vigencia del contrato. |
| `documento_evaluador` | CHARACTER VARYING(25) | NOT NULL |  | `proveedores.contrato_evaluacion.documento_evaluador` | CHARACTER VARYING(25) | NOT NULL | terceros.datos_identificacion.numero | Identificar a partir del NIT en `terceros.datos_identificacion.numero`. | Número de documento de la persona que evalúa el contrato; puede ser un interventor o un supervisor. |
| `fecha_registro` | DATE | NOT NULL |  | `proveedores.contrato_evaluacion.fecha_registro` | TIMESTAMP | NOT NULL |  |  |  |
| `numero_necesidad` | NUMERIC | NOT NULL |  | `proveedores.contrato_evaluacion.numero_necesidad` | NUMERIC(14,0) | NOT NULL |  |  | Número de la necesidad asociada al contrato. |
| `estado` | CHARACTER VARYING(12) |  |  | `proveedores.contrato_evaluacion.estado` | INTEGER | NOT NULL | parametros.parametro.id | Crear los estados de `contrato_evaluacion`. |  |
| `unidad_ejecutora` | NUMERIC | NOT NULL; DEFAULT 1 |  | `proveedores.contrato_evaluacion.unidad_ejecutora` | INTEGER | NOT NULL | kronos.unidad_ejecutora.id | Identificar la unidad ejecutora a partir del `id` en Kronos. |  |

### agora.evaluacion

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino propuesto | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración | Notas |
|---|---|---|---|---|---|---|---|---|---|
| `id_evaluacion` | INTEGER | NOT NULL DEFAULT nextval('agora.prov_evaluacion_id_evaluacion_seq'::regclass) |  | `proveedores.evaluacion.id` | SERIAL |  |  |  |  |
| `id_contrato` | INTEGER | NOT NULL |  | `proveedores.evaluacion.contrato` | INTEGER | NOT NULL |  |  | Identificador del contrato. |
| `fecha_registro` | DATE | NOT NULL |  | `proveedores.evaluacion.fecha_registro` | TIMESTAMP | NOT NULL |  |  | Fecha en que se registró la evaluación. |
| `tiemo_entrega` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.tiempo_entrega` | CHARACTER VARYING(2) | NOT NULL |  |  | 12: sí; 0: no. |
| `cantidades` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.cantidades` | CHARACTER VARYING(2) | NOT NULL |  |  | 12: sí; 0: no. |
| `conformidad` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.conformidad` | CHARACTER VARYING(2) | NOT NULL |  |  | 20: sí; 0: no. |
| `funcionalidad_adicional` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.funcionalidad_adicional` | CHARACTER VARYING(2) | NOT NULL |  |  | 10: sí; 0: no. |
| `reclamaciones` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.reclamaciones` | CHARACTER VARYING(2) | NOT NULL |  |  | 0: sí; 12: no. |
| `reclamacion_solucion` | CHARACTER VARYING(2) | NOT NULL; DEFAULT 0 |  | `proveedores.evaluacion.reclamacion_solucion` | CHARACTER VARYING(2) | NOT NULL; DEFAULT 0 |  |  | 12: sí; 0: no. |
| `servicio_venta` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.servicio_venta` | CHARACTER VARYING(2) | NOT NULL |  |  | 10: sí; 0: no. |
| `procedimientos` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.procedimientos` | CHARACTER VARYING(2) | NOT NULL |  |  | 9: excelente; 6: bueno; 3: regular; 0: malo. |
| `garantia` | CHARACTER VARYING(2) | NOT NULL |  | `proveedores.evaluacion.garantia` | CHARACTER VARYING(2) | NOT NULL |  |  | 0: sí; 15: no. |
| `garantia_satisfaccion` | CHARACTER VARYING(2) | NOT NULL; DEFAULT 0 |  | `proveedores.evaluacion.garantia_satisfaccion` | CHARACTER VARYING(2) |  |  |  | 15: sí; 0: no. |
| `puntaje_total` | NUMERIC | NOT NULL; DEFAULT 0 |  | `proveedores.evaluacion.puntaje_total` | NUMERIC |  |  |  | Puntaje total de la evaluación. |
| `clasificacion` | CHARACTER VARYING | NOT NULL; DEFAULT 0 |  | `proveedores.evaluacion.fecha_registro` | TIMESTAMP | NOT NULL; DEFAULT 0 |  |  | Clasificación:<br>A: mayor o igual a 100 puntos.<br>B: entre 45 y 79 puntos.<br>C: menor o igual a 44 puntos. |
