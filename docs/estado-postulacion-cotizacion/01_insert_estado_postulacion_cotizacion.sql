-- =============================================================================
-- Script   : 01_insert_estado_postulacion_cotizacion.sql
-- Issue    : #41 - Creación de scripts SQL de los parámetros de Cotizaciones
-- Catálogo : Estado de postulación del proveedor
-- Fuente   : Issue #34, comentario de seguimiento del 16-10-2026: estados del invitado “invitado, participa, declina, sin respuesta” incluidos como supuesto para avanzar; revisar contra el diagrama adjunto.
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
              (t.codigo_abreviacion = 'EST_POST_COT' AND t.nombre IS DISTINCT FROM 'Estado de postulación del proveedor')
              OR
              (t.nombre = 'Estado de postulación del proveedor' AND t.codigo_abreviacion IS DISTINCT FROM 'EST_POST_COT')
          )
    ) THEN
        RAISE EXCEPTION 'Conflicto de identidad para el tipo %, código % en el área %.',
            'Estado de postulación del proveedor', 'EST_POST_COT', 'Gestión de Cotizaciones';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM parametros.tipo_parametro t
        JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE a.nombre = 'Gestión de Cotizaciones'
          AND a.codigo_abreviacion = 'COTIZACIONES'
          AND (t.codigo_abreviacion = 'EST_POST_COT' OR t.nombre = 'Estado de postulación del proveedor')
    ) > 1 THEN
        RAISE EXCEPTION 'Hay varios tipos con el nombre % o código % en el área %.',
            'Estado de postulación del proveedor', 'EST_POST_COT', 'Gestión de Cotizaciones';
    END IF;
END $$;

-- 2. Tipo de parámetro propio de este catálogo.
INSERT INTO parametros.tipo_parametro
    (nombre, descripcion, codigo_abreviacion, activo, numero_orden,
     fecha_creacion, fecha_modificacion, area_tipo_id)
SELECT 'Estado de postulación del proveedor',
       'Estados propuestos de postulación; validar con diagrama #34. [Semilla: issue #41]',
       'EST_POST_COT',
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
        AND (t.codigo_abreviacion = 'EST_POST_COT'
             OR t.nombre = 'Estado de postulación del proveedor')
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
    ('INVITADO', 'Invitado', 'Proveedor convocado a la solicitud.', 1),
    ('SIN_RESPUESTA', 'Sin respuesta', 'Proveedor invitado que aún no ha indicado si participa.', 2),
    ('PARTICIPA', 'Participa', 'Proveedor que indicó participación en el proceso.', 3),
    ('DECLINA', 'Declina', 'Proveedor que indicó que no participará.', 4)
) AS v(codigo_abreviacion, nombre, descripcion, numero_orden)
JOIN parametros.area_tipo a ON a.nombre = 'Gestión de Cotizaciones'
JOIN parametros.tipo_parametro t
  ON t.area_tipo_id = a.id
 AND t.codigo_abreviacion = 'EST_POST_COT'
WHERE NOT EXISTS (
    SELECT 1 FROM parametros.parametro p
    WHERE p.tipo_parametro_id = t.id
      AND (p.codigo_abreviacion = v.codigo_abreviacion OR p.nombre = v.nombre)
);

COMMIT;
