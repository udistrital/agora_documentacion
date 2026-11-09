# Diccionario de datos — Proveedores (gestion_personas_crud)

Documenta las entidades del esquema `proveedores`, sus campos y tipos de datos ajustados, y la matriz de origen–destino de la migración desde Ágora V1 (`agora.*`).

## Contenido

1. [Convenciones](#1-convenciones)
2. [Entidades](#2-entidades)
3. [Relaciones](#3-relaciones)
4. [Detalle de tablas](#4-detalle-de-tablas)
5. [Matriz origen–destino](#5-matriz-origendestino)

## 1. Convenciones

- Todas las tablas usan `id SERIAL` como llave primaria (`pk_<tabla>`).
- Índices: `idx_<tabla>_<campo>` en llaves foráneas y campos de auditoría.
- **Campos de auditoría** (`campos_auditoria`), presentes en todas las tablas salvo los parámetros:

| Campo | Tipo | Nulo | Valor por defecto | Descripción |
|---|---|---|---|---|
| `activo` | BOOLEAN | No | true | Indica si el registro está activo (borrado lógico). |
| `fecha_creacion` | TIMESTAMP | No | now() | Fecha y hora de creación del registro. |
| `fecha_modificacion` | TIMESTAMP | Sí |  | Fecha y hora de la última modificación. |
| `usuario_modificacion_id` | INTEGER | Sí |  | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). |

- **Campos de parámetro** (`campos_parametro`), usados por tablas paramétricas locales:

| Campo | Tipo | Nulo | Valor por defecto | Descripción |
|---|---|---|---|---|
| `nombre` | VARCHAR(50) | No |  | Nombre del parámetro. |
| `descripcion` | VARCHAR(250) | Sí |  | Descripción del parámetro. |
| `codigo_abreviacion` | VARCHAR(20) | Sí |  | Código o abreviatura del parámetro. |
| `activo` | BOOLEAN | No | true | Indica si el registro está activo (borrado lógico). |
| `numero_orden` | NUMERIC(5,2) | Sí |  | Orden de presentación. |

- Las referencias a otros CRUD (`terceros`, `parametros`, `ubicaciones`) son **lógicas**: se guardan como `INTEGER` sin restricción FK física, porque viven en otras bases de datos.
- Conversiones de tipo frecuentes: `NUMERIC(n,0)` → `INTEGER`; `CHARACTER VARYING` con valores de catálogo → `INTEGER` (id de parámetro); estados `INTEGER`/`VARCHAR` → `BOOLEAN`.

## 2. Entidades

| Tabla | Descripción | Campos | Tablas origen (Ágora V1) |
|---|---|---|---|
| proveedores.proveedor | Entidad principal del proveedor (persona natural o jurídica). Concentra la información común del registro en Ágora: tipo, portafolio, evaluación y estado. | 11 | `agora.informacion_proveedor` |
| proveedores.contacto | Contactos asociados al proveedor. Admite distintos medios de contacto (teléfono, celular, correo, etc.). | 8 | `agora.informacion_proveedor` |
| proveedores.cuenta_bancaria | Cuentas bancarias del proveedor para pagos y cuentas AFC. | 12 | `agora.informacion_persona_juridica`, `agora.informacion_persona_natural`, `agora.informacion_proveedor` |
| proveedores.documento | Documentos de soporte del proveedor (RUT, RUP, anexos). El archivo se referencia por UUID en el gestor documental. | 8 | `agora.informacion_persona_natural`, `agora.informacion_proveedor` |
| proveedores.proveedor_natural | Especialización 1:1 de proveedor para personas naturales: información laboral y beneficios tributarios. | 23 | `agora.informacion_persona_natural` |
| proveedores.perfil_proveedor | Perfil (profesional) declarado por el proveedor. | 6 | `agora.informacion_persona_natural` |
| proveedores.titulo_proveedor_natural | Títulos académicos (profesión / especialidad) del proveedor persona natural. | 8 | `agora.informacion_persona_natural` |
| proveedores.proveedor_juridico | Especialización 1:1 de proveedor para personas jurídicas: procedencia, conformación y responsabilidades tributarias. | 18 | `agora.informacion_persona_juridica` |
| proveedores.actividad_economica_proveedor | Relación N:M entre el proveedor y las actividades económicas CIIU (parametrizadas en Parámetros CRUD). | 7 | `agora.proveedor_actividad_ciiu` |
| proveedores.representacion | Representantes legales del proveedor (tercero que lo representa). | 7 | `agora.proveedor_representante_legal` |
| proveedores.persona_juridica_tipo_entidad | Tabla de rompimiento entre una persona jurídica (NIT) y los tipos de entidad que cumple (EPS, CCF, ARL, AFP…). | 8 | `agora.informacion_persona_juridica_tipo_entidad` |
| proveedores.tipo_conformacion | Parámetro local con los tipos de conformación de una persona jurídica. | 6 | `agora.parametro_tipo_conformacion` |

## 3. Relaciones

**Internas (declaradas en el DBML)**

| Nombre | Padre | Cardinalidad | Hijo |
|---|---|---|---|
| `fk_proveedor_juridico_tipo_conformacion` | `proveedores.tipo_conformacion.id` | 1:N | `proveedores.proveedor_juridico.tipo_conformacion_id` |
| `fk_actividad_economica_proveedor_proveedor` | `proveedores.proveedor.id` | 1:N | `proveedores.actividad_economica_proveedor.proveedor_id` |
| `fk_representacion_proveedor` | `proveedores.proveedor.id` | 1:N | `proveedores.representacion.proveedor_id` |
| `fk_proveedor_natural_proveedor` | `proveedores.proveedor.id` | 1:1 | `proveedores.proveedor_natural.id` |
| `fk_proveedor_juridico_proveedor` | `proveedores.proveedor.id` | 1:1 | `proveedores.proveedor_juridico.id` |
| `fk_contacto_proveedor` | `proveedores.proveedor.id` | 1:N | `proveedores.contacto.proveedor_id` |
| `fk_cuenta_bancaria_proveedor` | `proveedores.proveedor.id` | 1:N | `proveedores.cuenta_bancaria.proveedor_id` |
| `fk_documento_proveedor` | `proveedores.proveedor.id` | 1:N | `proveedores.documento.proveedor_id` |

**Externas (lógicas, según la matriz de migración)**

| Campo | Referencia |
|---|---|
| `proveedores.actividad_economica_proveedor.actividad_economica_id` | `parametros.parametro.id` |
| `proveedores.cuenta_bancaria.entidad_bancaria_id` | `parametros.parametro.id` |
| `proveedores.cuenta_bancaria.tipo_cuenta_bancaria_id` | `parametros.parametro.id` |
| `proveedores.cuenta_bancaria.tipo_cuenta_id` | `parametros.parametro.id` |
| `proveedores.documento.tipo_documento_id` | `parametros.parametro.id` |
| `proveedores.perfil_proveedor.perfil_id` | `terceros.info_complementaria.id` |
| `proveedores.persona_juridica_tipo_entidad.persona_juridica_id` | `terceros.datos_identificacion.numero` |
| `proveedores.persona_juridica_tipo_entidad.tipo_entidad_id` | `terceros.tipo_tercero.nombre` |
| `proveedores.proveedor.estado_proveedor` | `parametros.parametro.id` |
| `proveedores.proveedor.tipo_proveedor` | `parametros.parametro.id` |
| `proveedores.proveedor_juridico.ciudad_origen_id` | `ubicaciones.lugar.id` |
| `proveedores.proveedor_juridico.pais_origen_id` | `ubicaciones.lugar.id` |
| `proveedores.proveedor_juridico.procedencia_empresa_id` | `parametros.parametro.id` |
| `proveedores.proveedor_juridico.regimen_contributivo` | `parametros.parametro.id` |
| `proveedores.proveedor_natural.pais_nacimiento_id` | `ubicaciones.lugar.id` |
| `proveedores.representacion.representante_id` | `terceros.tercero.id` |
| `proveedores.titulo_proveedor_natural.nucleo_basico_conocimiento_snies_id` | `parametros.parametro.id` |

## 4. Detalle de tablas

### proveedores.proveedor

Entidad principal del proveedor (persona natural o jurídica). Concentra la información común del registro en Ágora: tipo, portafolio, evaluación y estado.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | `informacion_proveedor.id_proveedor` (NUMERIC) |
| `tipo_proveedor` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Tipo de proveedor (natural, jurídica, extranjero). | `informacion_proveedor.tipopersona` (CHARACTER VARYING) |
| `descripcion_portafolio` | TEXT | Sí |  |  | Descripción del portafolio de productos o servicios. | `informacion_proveedor.descripcion` (CHARACTER VARYING) |
| `puntaje_evaluacion` | NUMERIC(5,2) | Sí |  |  | Puntaje total de las evaluaciones realizadas al proveedor. | `informacion_proveedor.puntaje_evaluacion` (NUMERIC) |
| `clasificacion_evaluacion` | INTEGER | Sí |  |  | Clasificación del proveedor según el puntaje total. | `informacion_proveedor.clasificacion_evaluacion` (CHARACTER VARYING) |
| `estado_proveedor` | INTEGER | Sí |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Estado del proveedor (activo, inactivo, rechazado). | `informacion_proveedor.estado` (NUMERIC) |
| `consentimiento` | BOOLEAN | Sí | false |  | Aceptación del tratamiento de datos personales. | `informacion_proveedor.consentimiento` (BOOLEAN) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | `informacion_proveedor.fecha_registro` (CHARACTER VARYING(50)) |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | `informacion_proveedor.fecha_ultima_modificacion` (CHARACTER VARYING(50)) |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.contacto

Contactos asociados al proveedor. Admite distintos medios de contacto (teléfono, celular, correo, etc.).

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `nombre_contacto` | VARCHAR(100) | No |  |  | Nombre del contacto. | `informacion_proveedor.nom_asesor` (CHARACTER VARYING(255)) |
| `valor_especifico` | VARCHAR(100) | Sí |  |  | Valor del medio de contacto (número de teléfono o celular, correo, etc.). | `informacion_proveedor.tel_asesor` (CHARACTER VARYING(50)) |
| `proveedor_id` | INTEGER | No |  | FK → `proveedores.proveedor.id`<br>IDX | Proveedor al que pertenece el registro. | — (campo nuevo) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.cuenta_bancaria

Cuentas bancarias del proveedor para pagos y cuentas AFC.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `tipo_cuenta_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Tipo de cuenta (ahorros, corriente). | `informacion_proveedor.tipo_cuenta_bancaria` (CHARACTER VARYING(50)) |
| `numero_cuenta` | VARCHAR(50) | No |  |  | Número de la cuenta bancaria. | `informacion_proveedor.num_cuenta_bancaria` (CHARACTER VARYING(20))<br>`informacion_persona_natural.num_cuenta_bancaria_afc` (CHARACTER VARYING(15)) |
| `entidad_bancaria_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Entidad bancaria de la cuenta. | `informacion_proveedor.id_entidad_bancaria` (NUMERIC)<br>`informacion_persona_natural.id_entidad_bancaria_afc` (NUMERIC(5,0)) |
| `correo_pago` | VARCHAR(320) | Sí |  |  | Correo electrónico para notificaciones de pago. | `informacion_proveedor.correo_pago` (CHARACTER VARYING(320)) |
| `tipo_cuenta_bancaria_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Clasificación de la cuenta bancaria (p. ej. AFC). | `informacion_persona_natural.cuenta_ahorro_afc` (BOOLEAN) |
| `monto_capital_autorizado` | NUMERIC(20,7) | Sí |  |  | Monto de capital autorizado. | `informacion_persona_natural.monto_capital_autorizado` (NUMERIC(16,2))<br>`informacion_persona_juridica.monto_capital_autorizado` (NUMERIC(16,2)) |
| `proveedor_id` | INTEGER | No |  | FK → `proveedores.proveedor.id`<br>IDX | Proveedor al que pertenece el registro. | — (campo nuevo) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.documento

Documentos de soporte del proveedor (RUT, RUP, anexos). El archivo se referencia por UUID en el gestor documental.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `tipo_documento_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Tipo de documento de soporte (RUT, RUP, anexo hijos, declaración de renta). | `informacion_proveedor.anexorut` (CHARACTER VARYING(255))<br>`informacion_proveedor.anexorup` (CHARACTER VARYING(255)) |
| `enlace` | UUID | No |  |  | UUID del archivo en el gestor documental. | `informacion_persona_natural.anexohijos` (CHARACTER VARYING(255))<br>`informacion_persona_natural.anexodeclaracion` (CHARACTER VARYING(255)) |
| `proveedor_id` | INTEGER | No |  | FK → `proveedores.proveedor.id`<br>IDX | Proveedor al que pertenece el registro. | — (campo nuevo) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.proveedor_natural

Especialización 1:1 de proveedor para personas naturales: información laboral y beneficios tributarios.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK<br>FK 1:1 → `proveedores.proveedor.id` | Identificador; es el mismo `id` de `proveedores.proveedor` (relación 1:1). | Hereda de la tabla padre |
| `pais_nacimiento_id` | INTEGER | No |  | Ref. lógica → `ubicaciones.lugar.id`<br>IDX | País de nacimiento. | `informacion_persona_natural.id_pais_nacimiento` (NUMERIC(5,0)) |
| `cargo` | VARCHAR(150) | Sí |  |  | Cargo actual de la persona. | `informacion_persona_natural.cargo` (CHARACTER VARYING(150)) |
| `medicina_prepagada` | BOOLEAN | Sí |  |  | Indica si paga medicina prepagada (beneficio tributario). | `informacion_persona_natural.medicina_prepagada` (BOOLEAN) |
| `valor_uvt_prepagada` | NUMERIC(20,7) | Sí |  |  | Valor en UVT pagado por medicina prepagada. | `informacion_persona_natural.valor_uvt_prepagada` (NUMERIC(10,4)) |
| `interes_vivienda_afc` | NUMERIC(5,4) | Sí |  |  | Intereses de vivienda/AFC expresados como coeficiente (0.02 = 2 %). | `informacion_persona_natural.interes_vivienda_afc` (NUMERIC(10,4)) |
| `dependiente_hijo_mejor_edad` | BOOLEAN | Sí |  |  | Indica si tiene un hijo menor de edad como dependiente. | `informacion_persona_natural.dependiente_hijo_menor_edad` (BOOLEAN) |
| `dependiente_hijo_menos23_estudiando` | BOOLEAN | Sí |  |  | Indica si tiene un hijo de 18 a 23 años que estudia, como dependiente. | `informacion_persona_natural.dependiente_hijo_menos23_estudiando` (BOOLEAN) |
| `dependiente_hijo_mas23_discapacitado` | BOOLEAN | Sí |  |  | Indica si tiene un hijo mayor de 23 años con discapacidad como dependiente. | `informacion_persona_natural.dependiente_hijo_mas23_discapacitado` (BOOLEAN) |
| `dependiente_conyuge` | BOOLEAN | Sí |  |  | Indica si tiene al cónyuge como dependiente. | `informacion_persona_natural.dependiente_conyuge` (BOOLEAN) |
| `dependiente_padre_o_hermano` | BOOLEAN | Sí |  |  | Indica si tiene al padre o a un hermano como dependiente. | `informacion_persona_natural.dependiente_padre_o_hermano` (BOOLEAN) |
| `pensionado` | BOOLEAN | Sí |  |  | Indica si la persona es pensionada. | `informacion_persona_natural.pensionado` (BOOLEAN) |
| `valor_afc` | NUMERIC(20,7) | Sí |  |  | Valor de los aportes a cuenta AFC. | `informacion_persona_natural.valor_afc` (NUMERIC(14,4)) |
| `responsable_iva` | BOOLEAN | Sí |  |  | Indica si es responsable de IVA. | `informacion_persona_natural.responsable_iva` (BOOLEAN) |
| `reside_colombia` | BOOLEAN | Sí |  |  | Indica si reside en Colombia. | `informacion_persona_natural.recide_colombia` (BOOLEAN) |
| `pension_voluntaria` | BOOLEAN | Sí |  |  | Indica si realiza aportes a pensión voluntaria. | `informacion_persona_natural.pension_voluntaria` (BOOLEAN) |
| `valor_pension_voluntaria` | NUMERIC(20,7) | Sí |  |  | Valor de los aportes a pensión voluntaria. | `informacion_persona_natural.valor_pension_voluntaria` (NUMERIC(10,4)) |
| `experiencia_laboral` | INTEGER | Sí |  |  | Experiencia laboral. | `informacion_persona_natural.experiencia_laboral` (NUMERIC(3,0)) |
| `experiencia_profesional` | INTEGER | Sí |  |  | Experiencia profesional. | `informacion_persona_natural.experiencia_profesional` (NUMERIC(3,0)) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.perfil_proveedor

Perfil (profesional) declarado por el proveedor.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `perfil_id` | INTEGER | No |  | Ref. lógica → `terceros.info_complementaria.id`<br>IDX | Perfil declarado por el proveedor. | `informacion_persona_natural.perfil` (NUMERIC(5,0)) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.titulo_proveedor_natural

Títulos académicos (profesión / especialidad) del proveedor persona natural.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `titulo_obtenido` | VARCHAR(150) | No |  |  | Nombre del título obtenido (profesión o especialidad). | `informacion_persona_natural.profesion` (CHARACTER VARYING(150))<br>`informacion_persona_natural.especialidad` (CHARACTER VARYING(100)) |
| `nucleo_basico_conocimiento_snies_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Núcleo básico de conocimiento SNIES del título. | `informacion_persona_natural.id_nucleo_basico` (NUMERIC(10,0)) |
| `perfil_id` | INTEGER | No |  | IDX | Perfil al que se asocia el título. | — (campo nuevo) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.proveedor_juridico

Especialización 1:1 de proveedor para personas jurídicas: procedencia, conformación y responsabilidades tributarias.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK<br>FK 1:1 → `proveedores.proveedor.id` | Identificador; es el mismo `id` de `proveedores.proveedor` (relación 1:1). | Hereda de la tabla padre |
| `procedencia_empresa_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Procedencia de la empresa (nacional / extranjera). | `informacion_persona_juridica.procedencia_empresa` (CHARACTER VARYING(20)) |
| `ciudad_origen_id` | INTEGER | Sí |  | Ref. lógica → `ubicaciones.lugar.id`<br>IDX | Ciudad de origen de la empresa. | `informacion_persona_juridica.id_ciudad_origen` (NUMERIC(10,0)) |
| `pais_origen_id` | INTEGER | Sí |  | Ref. lógica → `ubicaciones.lugar.id`<br>IDX | País de origen de la empresa. | `informacion_persona_juridica.codigo_pais_dian` (NUMERIC(5,0)) |
| `codigo_postal` | VARCHAR(16) | Sí |  |  | Código postal. | `informacion_persona_juridica.codigo_postal` (NUMERIC(20,0)) |
| `tipo_conformacion_id` | INTEGER | No |  | FK → `proveedores.tipo_conformacion.id`<br>IDX | Tipo de conformación de la persona jurídica. | `informacion_persona_juridica.id_tipo_conformacion` (NUMERIC(5,0)) |
| `exclusividad_producto` | BOOLEAN | No |  |  | Indica si tiene exclusividad del producto. | `informacion_persona_juridica.exclusividad_producto` (BOOLEAN) |
| `regimen_contributivo` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Régimen contributivo. | `informacion_persona_juridica.regimen_contributivo` (CHARACTER VARYING(12)) |
| `pyme` | BOOLEAN | No |  |  | Indica si es PYME. | `informacion_persona_juridica.pyme` (BOOLEAN) |
| `registro_mercantil` | BOOLEAN | No |  |  | Indica si cuenta con registro mercantil. | `informacion_persona_juridica.registro_mercantil` (BOOLEAN) |
| `sujeto_retencion` | BOOLEAN | No |  |  | Indica si es sujeto de retención. | `informacion_persona_juridica.sujeto_retencion` (BOOLEAN) |
| `agente_retenedor` | BOOLEAN | No |  |  | Indica si es agente retenedor. | `informacion_persona_juridica.agente_retenedor` (BOOLEAN) |
| `responsable_ica` | BOOLEAN | No |  |  | Indica si es responsable de ICA. | `informacion_persona_juridica.responsable_ICA` (BOOLEAN) |
| `responsable_iva` | BOOLEAN | No |  |  | Indica si es responsable de IVA. | `informacion_persona_juridica.responsable_IVA` (BOOLEAN) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.actividad_economica_proveedor

Relación N:M entre el proveedor y las actividades económicas CIIU (parametrizadas en Parámetros CRUD).

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `proveedor_id` | INTEGER | No |  | FK → `proveedores.proveedor.id`<br>IDX | Proveedor al que pertenece el registro. | `proveedor_actividad_ciiu.id_subclase` (CHARACTER VARYING(4)) |
| `actividad_economica_id` | INTEGER | No |  | Ref. lógica → `parametros.parametro.id`<br>IDX | Actividad económica CIIU. | `proveedor_actividad_ciiu.informacion_proveedor_id` (NUMERIC(10,0)) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.representacion

Representantes legales del proveedor (tercero que lo representa).

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | — (campo nuevo) |
| `proveedor_id` | INTEGER | No |  | FK → `proveedores.proveedor.id`<br>IDX | Proveedor al que pertenece el registro. | `proveedor_representante_legal.id_proveedor` (NUMERIC(10,0)) |
| `representante_id` | INTEGER | No |  | Ref. lógica → `terceros.tercero.id`<br>IDX | Tercero que actúa como representante legal. | `proveedor_representante_legal.id_representante` (CHARACTER VARYING(25)) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | Auditoría |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.persona_juridica_tipo_entidad

Tabla de rompimiento entre una persona jurídica (NIT) y los tipos de entidad que cumple (EPS, CCF, ARL, AFP…).

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único de la tabla de rompimiento. | `informacion_persona_juridica_tipo_entidad.id` (INTEGER) |
| `nombre_perfil_entidad` | VARCHAR(50) | Sí |  |  | Nombre que identifica la relación entidad–tipo cuando aplica (p. ej. diferenciar CAJA de EPS). | `informacion_persona_juridica_tipo_entidad.nombre_perfil_entidad` (CHARACTER VARYING(50)) |
| `tipo_entidad_id` | INTEGER | No |  | Ref. lógica → `terceros.tipo_tercero.nombre`<br>IDX | Tipo de entidad de la relación. | `informacion_persona_juridica_tipo_entidad.tipo_entidad_id` (INTEGER) |
| `persona_juridica_id` | VARCHAR(50) | No |  | Ref. lógica → `terceros.datos_identificacion.numero`<br>IDX | NIT de la persona jurídica. | `informacion_persona_juridica_tipo_entidad.informacion_persona_juridica_id` (CHARACTER VARYING(25)) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | `informacion_persona_juridica_tipo_entidad.estado` (INTEGER) |
| `fecha_creacion` | TIMESTAMP | No | now() | IDX | Fecha y hora de creación del registro. | Auditoría |
| `fecha_modificacion` | TIMESTAMP | Sí |  | IDX | Fecha y hora de la última modificación. | Auditoría |
| `usuario_modificacion_id` | INTEGER | Sí |  | IDX | Tercero que realizó la última modificación (referencia externa a Terceros CRUD). | Auditoría |

### proveedores.tipo_conformacion

Parámetro local con los tipos de conformación de una persona jurídica.

| Campo | Tipo | Nulo | Valor por defecto | Clave / Referencia | Descripción | Origen (Ágora V1) |
|---|---|---|---|---|---|---|
| `id` | SERIAL | No |  | PK | Identificador único (secuencia). | `parametro_tipo_conformacion.id_conformacion` (NUMERIC) |
| `nombre` | VARCHAR(50) | No |  |  | Nombre del parámetro. | `parametro_tipo_conformacion.nombre` (CHARACTER VARYING(150)) |
| `descripcion` | VARCHAR(250) | Sí |  |  | Descripción del parámetro. | `parametro_tipo_conformacion.descripcion` (CHARACTER VARYING(100)) |
| `codigo_abreviacion` | VARCHAR(20) | Sí |  |  | Código o abreviatura del parámetro. | — (campo nuevo) |
| `activo` | BOOLEAN | No | true | IDX | Indica si el registro está activo (borrado lógico). | `parametro_tipo_conformacion.estado` (CHARACTER VARYING(10)) |
| `numero_orden` | NUMERIC(5,2) | Sí |  |  | Orden de presentación. | — (campo nuevo) |

## 5. Matriz origen–destino

Una fila por campo de Ágora V1 con su campo destino en el modelo nuevo (esquema `proveedores` u otro CRUD).

### agora.informacion_proveedor

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `id_proveedor` | NUMERIC | NOT NULL DEFAULT nextval('agora.prov_proveedor_info_id_proveedor_seq'::regclass) | agora.parametro_estandar.id_parametro | `proveedores.proveedor.id` | SERIAL | PK; NOT NULL |  | Identificar el proveedor a partir de `terceros.datos_identificacion` con el número. |
| `tipopersona` | CHARACTER VARYING | NOT NULL |  | `proveedores.proveedor.tipo_proveedor` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `num_documento` | CHARACTER VARYING(25) | NOT NULL |  | `terceros.datos_identificacion.numero` | CHARACTER VARYING(50) | NOT NULL |  |  |
| `id_ciudad_contacto` | NUMERIC | NOT NULL | core.ciudad.id_ciudad | `terceros.tercero.lugar_origen` | INTEGER | NOT NULL | ubicaciones.lugar.id |  |
| `direccion` | CHARACTER VARYING(255) | NOT NULL |  | `terceros.info_complementaria_tercero.dato` | JSONB |  |  |  |
| `correo` | CHARACTER VARYING(320) | NOT NULL |  | `terceros.info_complementaria_tercero.dato` | JSONB |  |  |  |
| `web` | CHARACTER VARYING(255) |  |  | `terceros.info_complementaria_tercero.dato` | JSONB |  |  |  |
| `nom_asesor` | CHARACTER VARYING(255) |  |  | `proveedores.contacto.nombre_contacto` | VARCHAR(100) | NOT NULL |  | Recrear en Terceros. |
| `tel_asesor` | CHARACTER VARYING(50) |  |  | `proveedores.contacto.valor_especifico` | VARCHAR(100) |  |  | Recrear en Terceros. |
| `descripcion` | CHARACTER VARYING |  |  | `proveedores.proveedor.descripcion_portafolio` | TEXT |  |  |  |
| `puntaje_evaluacion` | NUMERIC |  |  | `proveedores.proveedor.puntaje_evaluacion` | NUMERIC(5,2) |  |  | Si no tiene puntaje de evaluación, dejar en NULL. |
| `clasificacion_evaluacion` | CHARACTER VARYING |  |  | `proveedores.proveedor.clasificacion_evaluacion` | INTEGER |  |  | Si no tiene puntaje, no tiene clasificación; dejar en NULL. |
| `estado` | NUMERIC | NOT NULL | agora.parametro_estandar.id_parametro | `proveedores.proveedor.estado_proveedor` | INTEGER |  | parametros.parametro.id |  |
| `tipo_cuenta_bancaria` | CHARACTER VARYING(50) | NOT NULL |  | `proveedores.cuenta_bancaria.tipo_cuenta_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `num_cuenta_bancaria` | CHARACTER VARYING(20) | NOT NULL |  | `proveedores.cuenta_bancaria.numero_cuenta` | VARCHAR(50) | NOT NULL |  |  |
| `id_entidad_bancaria` | NUMERIC | NOT NULL | core.banco.id_codigo | `proveedores.cuenta_bancaria.entidad_bancaria_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `fecha_registro` | CHARACTER VARYING(50) | NOT NULL |  | `proveedores.proveedor.fecha_creacion` | TIMESTAMP | NOT NULL; DEFAULT now() |  |  |
| `fecha_ultima_modificacion` | CHARACTER VARYING(50) | NOT NULL |  | `proveedores.proveedor.fecha_modificacion` | TIMESTAMP |  |  |  |
| `nom_proveedor` | CHARACTER VARYING(150) | NOT NULL |  | `terceros.tercero.nombre_completo` | CHARACTER VARYING(255) | NOT NULL |  |  |
| `anexorut` | CHARACTER VARYING(255) | NOT NULL |  | `proveedores.documento.tipo_documento_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `anexorup` | CHARACTER VARYING(255) |  |  | `proveedores.documento.tipo_documento_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `regimen_contributivo` | CHARACTER VARYING(20) | NOT NULL |  | No se migra |  |  |  |  |
| `consentimiento` | BOOLEAN | DEFAULT true |  | `proveedores.proveedor.consentimiento` | BOOLEAN | DEFAULT false |  | Crear y guardar el texto No/Sí. |
| `correo_pago` | CHARACTER VARYING(320) |  |  | `proveedores.cuenta_bancaria.correo_pago` | VARCHAR(320) |  |  |  |

### agora.informacion_persona_natural

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `tipo_documento` | NUMERIC(5,0) | NOT NULL | agora.parametro_estandar.id_parametro | `terceros.datos_identificacion.tipo_documento_id` | INTEGER | NOT NULL | terceros.tipo_documento.id |  |
| `num_documento_persona` | CHARACTER VARYING(25) | PK; NOT NULL |  | `terceros.datos_identificacion.numero` | VARCHAR(50) | NOT NULL |  |  |
| `digito_verificacion` | NUMERIC(2,0) |  |  | `terceros.datos_identificacion.digito_verficacion` | NUMERIC(2,0) |  |  |  |
| `primer_apellido` | CHARACTER VARYING(50) | NOT NULL |  | `terceros.tercero.primer_apellido` | VARCHAR(100) |  |  |  |
| `segundo_apellido` | CHARACTER VARYING(50) |  |  | `terceros.tercero.segundo_apellido` | VARCHAR(100) |  |  |  |
| `primer_nombre` | CHARACTER VARYING(50) | NOT NULL |  | `terceros.tercero.primer_nombre` | VARCHAR(100) |  |  |  |
| `segundo_nombre` | CHARACTER VARYING(50) |  |  | `terceros.tercero.segundo_nombre` | VARCHAR(100) |  |  |  |
| `id_pais_nacimiento` | NUMERIC(5,0) | NOT NULL | core.pais.id_pais | `proveedores.proveedor_natural.pais_nacimiento_id` | INTEGER | NOT NULL | ubicaciones.lugar.id |  |
| `cargo` | CHARACTER VARYING(150) |  |  | `proveedores.proveedor_natural.cargo` | VARCHAR(150) |  |  |  |
| `perfil` | NUMERIC(5,0) | NOT NULL | agora.parametro_estandar.id_parametro | `proveedores.perfil_proveedor.perfil_id` | INTEGER | NOT NULL | terceros.info_complementaria.id |  |
| `profesion` | CHARACTER VARYING(150) |  |  | `proveedores.titulo_proveedor_natural.titulo_obtenido` | VARCHAR(150) | NOT NULL |  | Si existe, crearla en un registro de `titulo_proveedor_natural`. |
| `especialidad` | CHARACTER VARYING(100) |  |  | `proveedores.titulo_proveedor_natural.titulo_obtenido` | VARCHAR(150) | NOT NULL |  | Si existe, crearla en un registro de `titulo_proveedor_natural`. |
| `genero` | CHARACTER VARYING(20) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id |  |
| `grupo_etnico` | CHARACTER VARYING(20) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id |  |
| `comunidad_lgbt` | BOOLEAN | DEFAULT false |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Crear y guardar el texto No/Sí. |
| `cabeza_familia` | BOOLEAN | NOT NULL; DEFAULT false |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Guardar el texto No/Sí. |
| `personas_a_cargo` | BOOLEAN | NOT NULL; DEFAULT false |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Guardar el texto No/Sí. |
| `numero_personas_a_cargo` | NUMERIC(10,0) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Si no tiene personas a cargo, no crear. |
| `estado_civil` | CHARACTER VARYING(20) | NOT NULL; DEFAULT 'SOLTERO' |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id |  |
| `discapacitado` | BOOLEAN | NOT NULL; DEFAULT false |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Guardar el texto No/Sí. |
| `tipo_discapacidad` | CHARACTER VARYING(20) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Si no tiene discapacidad, no crear. |
| `declarante_renta` | BOOLEAN | NOT NULL; DEFAULT false |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Guardar el texto No/Sí. |
| `medicina_prepagada` | BOOLEAN | NOT NULL; DEFAULT false |  | `proveedores.proveedor_natural.medicina_prepagada` | BOOLEAN |  |  |  |
| `valor_uvt_prepagada` | NUMERIC(10,4) |  |  | `proveedores.proveedor_natural.valor_uvt_prepagada` | NUMERIC(20,7) |  |  |  |
| `cuenta_ahorro_afc` | BOOLEAN | NOT NULL DEFAULT false |  | `proveedores.cuenta_bancaria.tipo_cuenta_bancaria_id` | INTEGER | NOT NULL | parametros.parametro.id | Si el original es true, crear el registro. |
| `num_cuenta_bancaria_afc` | CHARACTER VARYING(15) |  |  | `proveedores.cuenta_bancaria.numero_cuenta` | VARCHAR(50) | NOT NULL |  |  |
| `id_entidad_bancaria_afc` | NUMERIC(5,0) |  | core.banco.id_codigo | `proveedores.cuenta_bancaria.entidad_bancaria_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `interes_vivienda_afc` | NUMERIC(10,4) |  |  | `proveedores.proveedor_natural.interes_vivienda_afc` | NUMERIC(5,4) |  |  | Verificar la conversión de porcentaje a coeficiente (2 % → 0.02). |
| `dependiente_hijo_menor_edad` | BOOLEAN | NOT NULL; DEFAULT false |  | `proveedores.proveedor_natural.dependiente_hijo_mejor_edad` | BOOLEAN |  |  |  |
| `dependiente_hijo_menos23_estudiando` | BOOLEAN | NOT NULL; DEFAULT false |  | `proveedores.proveedor_natural.dependiente_hijo_menos23_estudiando` | BOOLEAN |  |  |  |
| `dependiente_hijo_mas23_discapacitado` | BOOLEAN | NOT NULL; DEFAULT false |  | `proveedores.proveedor_natural.dependiente_hijo_mas23_discapacitado` | BOOLEAN |  |  |  |
| `dependiente_conyuge` | BOOLEAN | NOT NULL; DEFAULT false |  | `proveedores.proveedor_natural.dependiente_conyuge` | BOOLEAN |  |  |  |
| `dependiente_padre_o_hermano` | BOOLEAN | NOT NULL; DEFAULT false |  | `proveedores.proveedor_natural.dependiente_padre_o_hermano` | BOOLEAN |  |  |  |
| `id_nucleo_basico` | NUMERIC(10,0) |  |  | `proveedores.titulo_proveedor_natural.nucleo_basico_conocimiento_snies_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `id_arl` | INTEGER |  | core.parametro_entidad.id | `terceros.seguridad_social_tercero.tercero_entidad_id` | INTEGER | NOT NULL | terceros.tercero.id | Si el original no tiene valor, no crear el registro. |
| `id_eps` | INTEGER |  | core.parametro_entidad.id | `terceros.seguridad_social_tercero.tercero_entidad_id` | INTEGER | NOT NULL | terceros.tercero.id | Si el original no tiene valor, no crear el registro. |
| `id_fondo_pension` | INTEGER |  | core.parametro_entidad.id | `terceros.seguridad_social_tercero.tercero_entidad_id` | INTEGER | NOT NULL | terceros.tercero.id | Si el original no tiene valor, no crear el registro. |
| `id_caja_compensacion` | INTEGER |  | core.parametro_entidad.id | `terceros.seguridad_social_tercero.tercero_entidad_id` | INTEGER | NOT NULL | terceros.tercero.id | Si el original no tiene valor, no crear el registro. |
| `fecha_expedicion_documento` | DATE | NOT NULL |  | `terceros.datos_identificacion.fecha_expedicion` | TIMESTAMP |  |  |  |
| `id_ciudad_expedicion_documento` | NUMERIC | NOT NULL |  | `terceros.datos_identificacion.ciudad_expedicion` | INTEGER |  | ubicaciones.lugar.id | Verificar si el valor corresponde a `core.ciudad` y migrarlo a Ubicaciones. |
| `hijos` | BOOLEAN | NOT NULL |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Guardar el texto No/Sí. |
| `numero_hijos` | NUMERIC(4,0) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Si no tiene hijos, no registrar. |
| `pensionado` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_natural.pensionado` | BOOLEAN |  |  |  |
| `anexohijos` | CHARACTER VARYING(255) |  |  | `proveedores.documento.enlace` | UUID | NOT NULL |  |  |
| `anexodeclaracion` | CHARACTER VARYING(255) |  |  | `proveedores.documento.enlace` | UUID | NOT NULL |  |  |
| `fecha_nacimiento` | DATE |  |  | `terceros.tercero.fecha_nacimiento` | TIMESTAMP |  |  |  |
| `valor_afc` | NUMERIC(14,4) |  |  | `proveedores.proveedor_natural.valor_afc` | NUMERIC(20,7) |  |  |  |
| `responsable_iva` | BOOLEAN |  |  | `proveedores.proveedor_natural.responsable_iva` | BOOLEAN |  |  |  |
| `recide_colombia` | BOOLEAN |  |  | `proveedores.proveedor_natural.reside_colombia` | BOOLEAN |  |  |  |
| `pension_voluntaria` | BOOLEAN |  |  | `proveedores.proveedor_natural.pension_voluntaria` | BOOLEAN |  |  |  |
| `valor_pension_voluntaria` | NUMERIC(10,4) |  |  | `proveedores.proveedor_natural.valor_pension_voluntaria` | NUMERIC(20,7) |  |  |  |
| `migrante` | BOOLEAN |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Crear. |
| `victima_conflicto` | BOOLEAN |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Crear. |
| `identidad_genero` | CHARACTER VARYING(50) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id |  |
| `orientacion_sexual` | CHARACTER VARYING(50) |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id |  |
| `persona_expuesta` | BOOLEAN |  |  | `terceros.info_complementaria_tercero.info_complementaria_id` | INTEGER | NOT NULL | terceros.info_complementaria.id | Crear. |
| `monto_capital_autorizado` | NUMERIC(16,2) |  |  | `proveedores.cuenta_bancaria.monto_capital_autorizado` | NUMERIC(20,7) |  |  |  |
| `experiencia_laboral` | NUMERIC(3,0) |  |  | `proveedores.proveedor_natural.experiencia_laboral` | INTEGER |  |  |  |
| `experiencia_profesional` | NUMERIC(3,0) |  |  | `proveedores.proveedor_natural.experiencia_profesional` | INTEGER |  |  |  |

### agora.informacion_persona_juridica

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `num_nit_empresa` | CHARACTER VARYING(25) | PK; NOT NULL |  | `terceros.datos_identificacion.numero` | VARCHAR(50) | NOT NULL |  | Crear su propio registro de documento de identificación. |
| `digito_verificacion` | NUMERIC(2,0) |  |  | `terceros.datos_identificacion.digito_verficacion` | NUMERIC(2,0) |  |  |  |
| `procedencia_empresa` | CHARACTER VARYING(20) | NOT NULL |  | `proveedores.proveedor_juridico.procedencia_empresa_id` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `id_ciudad_origen` | NUMERIC(10,0) |  | core.ciudad.id_ciudad | `proveedores.proveedor_juridico.ciudad_origen_id` | INTEGER |  | ubicaciones.lugar.id | Migrar `core.ciudad` a `ubicaciones.lugar` y referenciar el nuevo registro. |
| `codigo_pais_dian` | NUMERIC(5,0) |  |  | `proveedores.proveedor_juridico.pais_origen_id` | INTEGER |  | ubicaciones.lugar.id | Registrar el código DIAN en `ubicaciones.valor_atributo_lugar`. |
| `codigo_postal` | NUMERIC(20,0) |  |  | `proveedores.proveedor_juridico.codigo_postal` | VARCHAR(16) |  |  |  |
| `tipo_identificacion_extranjera` | CHARACTER VARYING(50) |  |  | `terceros.datos_identificacion.tipo_documento_id` | INTEGER | NOT NULL | terceros.tipo_documento.id |  |
| `num_cedula_extranjeria` | CHARACTER VARYING(25) |  |  | `terceros.datos_identificacion.numero` | VARCHAR(50) | NOT NULL |  |  |
| `num_pasaporte` | CHARACTER VARYING(25) |  |  | `terceros.datos_identificacion.numero` | VARCHAR(50) | NOT NULL |  | Crear su propio registro de documento de identificación. |
| `id_tipo_conformacion` | NUMERIC(5,0) | NOT NULL | agora.parametro_tipo_conformacion.id_conformacion | `proveedores.proveedor_juridico.tipo_conformacion_id` | INTEGER | NOT NULL | proveedores.tipo_conformacion.id | Recuperar el registro de parámetros que corresponde al valor registrado. |
| `monto_capital_autorizado` | NUMERIC(16,2) | NOT NULL |  | `proveedores.cuenta_bancaria.monto_capital_autorizado` | NUMERIC(20,7) |  |  |  |
| `exclusividad_producto` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.exclusividad_producto` | BOOLEAN | NOT NULL |  |  |
| `regimen_contributivo` | CHARACTER VARYING(12) | NOT NULL |  | `proveedores.proveedor_juridico.regimen_contributivo` | INTEGER | NOT NULL | parametros.parametro.id |  |
| `pyme` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.pyme` | BOOLEAN | NOT NULL |  |  |
| `registro_mercantil` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.registro_mercantil` | BOOLEAN | NOT NULL |  |  |
| `sujeto_retencion` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.sujeto_retencion` | BOOLEAN | NOT NULL |  |  |
| `agente_retenedor` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.agente_retenedor` | BOOLEAN | NOT NULL |  |  |
| `responsable_ICA` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.responsable_ica` | BOOLEAN | NOT NULL |  |  |
| `responsable_IVA` | BOOLEAN | NOT NULL |  | `proveedores.proveedor_juridico.responsable_iva` | BOOLEAN | NOT NULL |  |  |
| `genero` | CHARACTER VARYING(20) | NOT NULL |  | No se migra |  |  |  |  |
| `nom_proveedor` | CHARACTER VARYING(150) | NOT NULL |  | `terceros.tercero.nombre_completo` | VARCHAR(255) | NOT NULL |  |  |

### agora.informacion_persona_juridica_tipo_entidad

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `id` | INTEGER | PK; NOT NULL; DEFAULT nextval('agora.informacion_persona_juridica_tipo_entidad_id_seq'::regclass) |  | `proveedores.persona_juridica_tipo_entidad.id` | SERIAL | PK; NOT NULL |  |  |
| `nombre_perfil_entidad` | CHARACTER VARYING(50) |  |  | `proveedores.persona_juridica_tipo_entidad.nombre_perfil_entidad` | VARCHAR(50) |  |  |  |
| `tipo_entidad_id` | INTEGER | NOT NULL | agora.tipo_entidad.id | `proveedores.persona_juridica_tipo_entidad.tipo_entidad_id` | INTEGER | NOT NULL | terceros.tipo_tercero.nombre | Identificar a partir del NIT en `terceros.datos_identificacion.numero`. |
| `informacion_persona_juridica_id` | CHARACTER VARYING(25) | NOT NULL | agora.informacion_persona_juridica.num_nit_empresa | `proveedores.persona_juridica_tipo_entidad.persona_juridica_id` | VARCHAR(50) | NOT NULL | terceros.datos_identificacion.numero | Identificar a partir del NIT en `terceros.datos_identificacion.numero`. |
| `estado` | INTEGER | NOT NULL |  | `proveedores.persona_juridica_tipo_entidad.activo` | BOOLEAN | NOT NULL; DEFAULT true |  | Traducir 1 a true y 0 a false. |

### agora.parametro_tipo_conformacion

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `id_conformacion` | NUMERIC | NOT NULL |  | `proveedores.tipo_conformacion.id` | SERIAL | PK; NOT NULL |  |  |
| `nombre` | CHARACTER VARYING(150) |  |  | `proveedores.tipo_conformacion.nombre` | VARCHAR(50) | NOT NULL |  |  |
| `descripcion` | CHARACTER VARYING(100) |  |  | `proveedores.tipo_conformacion.descripcion` | VARCHAR(250) |  |  |  |
| `estado` | CHARACTER VARYING(10) |  |  | `proveedores.tipo_conformacion.activo` | BOOLEAN | NOT NULL; DEFAULT true |  | Traducir a booleano con un switch. |

### agora.proveedor_representante_legal

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `id_proveedor` | NUMERIC(10,0) | NOT NULL | agora.informacion_proveedor.id_proveedor | `proveedores.representacion.proveedor_id` | INTEGER | NOT NULL | proveedores.proveedor.id | Determinar el proveedor a través de `terceros.datos_identificacion`. |
| `id_representante` | CHARACTER VARYING(25) | NOT NULL | agora.informacion_persona_natural.id | `proveedores.representacion.representante_id` | INTEGER | NOT NULL | terceros.tercero.id | Determinar el tercero a través de `proveedores.proveedor.id`. |

### agora.proveedor_actividad_ciiu

| Campo origen | Tipo origen | Restricciones origen | FK origen | Campo destino | Tipo destino | Restricciones destino | FK / Ref. destino | Notas de migración |
|---|---|---|---|---|---|---|---|---|
| `id_subclase` | CHARACTER VARYING(4) | NOT NULL |  | `proveedores.actividad_economica_proveedor.proveedor_id` | INTEGER | NOT NULL | proveedores.proveedor.id |  |
| `informacion_proveedor_id` | NUMERIC(10,0) | NOT NULL | agora.informacion_proveedor.proveedor_id | `proveedores.actividad_economica_proveedor.actividad_economica_id` | INTEGER | NOT NULL | parametros.parametro.id | Parametrizar y referenciar el nuevo parámetro. |
