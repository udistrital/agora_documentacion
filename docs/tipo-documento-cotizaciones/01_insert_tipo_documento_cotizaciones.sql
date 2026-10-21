-- =============================================================================
-- Script   : 01_insert_tipo_documento_cotizaciones.sql
-- Issue    : #41 - Creación de scripts SQL de los parámetros de Cotizaciones
-- Catálogo : Tipo de documento de Cotizaciones
-- Fuente   : Issue #32, propuesta V2; documentos de la etapa de solicitud/publicación: estudios previos, anexo técnico y CDP.
-- Motor    : PostgreSQL | Esquema: parametros
-- Orden    : area_tipo -> tipo_parametro -> parametro
-- Idempotente: sí; identifica registros mediante códigos de abreviación.
-- =============================================================================
BEGIN;

-- Validación preventiva de identidad del área (issue #41).
-- Detiene la transacción si el nombre y el código apuntan a filas incompatibles o duplicadas.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM parametros.area_tipo a
        WHERE (a.nombre = 'Gestión de Cotizaciones' AND a.codigo_abreviacion IS DISTINCT FROM 'COTIZACIONES')
           OR (a.codigo_abreviacion = 'COTIZACIONES' AND a.nombre IS DISTINCT FROM 'Gestión de Cotizaciones')
    ) THEN
        RAISE EXCEPTION 'Conflicto de identidad para el área %, código %; revise parametros.area_tipo.',
            'Gestión de Cotizaciones', 'COTIZACIONES';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM parametros.area_tipo a
        WHERE a.nombre = 'Gestión de Cotizaciones' OR a.codigo_abreviacion = 'COTIZACIONES'
    ) > 1 THEN
        RAISE EXCEPTION 'Hay varias filas para el área %, código %; revise parametros.area_tipo.',
            'Gestión de Cotizaciones', 'COTIZACIONES';
    END IF;
END $$;


-- 1. Área dedicada. Se reutiliza si ya existe por nombre o código.
INSERT INTO parametros.area_tipo
    (nombre, descripcion, codigo_abreviacion, activo, numero_orden,
     fecha_creacion, fecha_modificacion)
SELECT 'Gestión de Cotizaciones',
       'Catálogos exclusivos o diferenciados del módulo de Cotizaciones. [Semilla: issue #41]',
       'COTIZACIONES',
       TRUE,
       COALESCE((SELECT MAX(numero_orden) FROM parametros.area_tipo), 0) + 1,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM parametros.area_tipo a
    WHERE a.nombre = 'Gestión de Cotizaciones' OR a.codigo_abreviacion = 'COTIZACIONES'
);

-- Validación preventiva de identidad del tipo de parámetro (issue #41).
-- Permite que exista el tipo correcto; rechaza colisiones por nombre/código y duplicados.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE a.nombre = 'Gestión de Cotizaciones'
          AND a.codigo_abreviacion = 'COTIZACIONES'
          AND (
              (t.codigo_abreviacion = 'TIP_DOC_COT' AND t.nombre IS DISTINCT FROM 'Tipo de documento de Cotizaciones')
              OR
              (t.nombre = 'Tipo de documento de Cotizaciones' AND t.codigo_abreviacion IS DISTINCT FROM 'TIP_DOC_COT')
          )
    ) THEN
        RAISE EXCEPTION 'Conflicto de identidad para el tipo %, código % en el área %.',
            'Tipo de documento de Cotizaciones', 'TIP_DOC_COT', 'Gestión de Cotizaciones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM parametros.tipo_parametro t
        JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE a.nombre = 'Gestión de Cotizaciones'
          AND a.codigo_abreviacion = 'COTIZACIONES'
          AND (t.codigo_abreviacion = 'TIP_DOC_COT' OR t.nombre = 'Tipo de documento de Cotizaciones')
    ) > 1 THEN
        RAISE EXCEPTION 'Hay varios tipos con el nombre % o código % en el área %.',
            'Tipo de documento de Cotizaciones', 'TIP_DOC_COT', 'Gestión de Cotizaciones';
    END IF;
END $$;

-- 2. Tipo de parámetro propio de este catálogo.
INSERT INTO parametros.tipo_parametro
    (nombre, descripcion, codigo_abreviacion, activo, numero_orden,
     fecha_creacion, fecha_modificacion, area_tipo_id)
SELECT 'Tipo de documento de Cotizaciones',
       'Documentos de Cotizaciones separados del catálogo de personas. [Semilla: issue #41]',
       'TIP_DOC_COT',
       TRUE,
       COALESCE((SELECT MAX(t.numero_orden)
                 FROM parametros.tipo_parametro t
                 WHERE t.area_tipo_id = a.id), 0) + 1,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND NOT EXISTS (
      SELECT 1 FROM parametros.tipo_parametro t
      WHERE t.area_tipo_id = a.id
        AND (t.codigo_abreviacion = 'TIP_DOC_COT'
             OR t.nombre = 'Tipo de documento de Cotizaciones')
  );

-- 3. Valores: solo se insertan los códigos que aún no existen en este tipo.
INSERT INTO parametros.parametro
    (nombre, descripcion, codigo_abreviacion, activo, numero_orden,
     fecha_creacion, fecha_modificacion, tipo_parametro_id, parametro_padre_id)
SELECT v.nombre,
       v.descripcion || ' [Semilla: issue #41]',
       v.codigo_abreviacion,
       TRUE,
       v.numero_orden,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       t.id,
       NULL
FROM (VALUES
    ('ESTUDIOS_PREVIOS', 'Estudios previos', 'Documento de estudios previos asociado a la solicitud.', 1),
    ('ANEXO_TECNICO', 'Anexo técnico', 'Anexo que contiene las especificaciones técnicas de la solicitud.', 2),
    ('CDP', 'Certificado de disponibilidad presupuestal (CDP)', 'Certificado de disponibilidad presupuestal asociado a la solicitud.', 3)
) AS v(codigo_abreviacion, nombre, descripcion, numero_orden)
JOIN parametros.area_tipo a ON a.nombre = 'Gestión de Cotizaciones'
JOIN parametros.tipo_parametro t
  ON t.area_tipo_id = a.id
 AND t.codigo_abreviacion = 'TIP_DOC_COT'
WHERE NOT EXISTS (
    SELECT 1 FROM parametros.parametro p
    WHERE p.tipo_parametro_id = t.id
      AND (p.codigo_abreviacion = v.codigo_abreviacion OR p.nombre = v.nombre)
);

COMMIT;
