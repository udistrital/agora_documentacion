-- =============================================================================
-- Script   : rollback_snies.sql
-- Proposito: Revertir insert_snies.sql
-- Orden    : inverso al de insercion (parametro -> tipo_parametro -> area_tipo)
-- Seguridad: no borra el area_tipo si aun tiene otros tipos de parametro.
-- =============================================================================

BEGIN;

DELETE FROM parametros.parametro
WHERE tipo_parametro_id IN (
    SELECT tp.id
    FROM parametros.tipo_parametro tp
    JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
    WHERE tp.nombre IN (
        'AGRONOMÍA, VETERINARIA Y AFINES',
        'BELLAS ARTES',
        'CIENCIAS DE LA EDUCACIÓN',
        'CIENCIAS DE LA SALUD',
        'CIENCIAS SOCIALES Y HUMANAS',
        'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
        'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
        'MATEMÁTICAS Y CIENCIAS NATURALES'
    )
      AND a.nombre = 'SNIES'
      AND a.codigo_abreviacion = 'SNIES'
);

DELETE FROM parametros.tipo_parametro
WHERE nombre IN (
        'AGRONOMÍA, VETERINARIA Y AFINES',
        'BELLAS ARTES',
        'CIENCIAS DE LA EDUCACIÓN',
        'CIENCIAS DE LA SALUD',
        'CIENCIAS SOCIALES Y HUMANAS',
        'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
        'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
        'MATEMÁTICAS Y CIENCIAS NATURALES'
    )
  AND area_tipo_id IN (
      SELECT id
      FROM parametros.area_tipo
      WHERE nombre = 'SNIES'
        AND codigo_abreviacion = 'SNIES'
  );

DELETE FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
  AND a.codigo_abreviacion = 'SNIES'
  AND NOT EXISTS (
      SELECT 1
      FROM parametros.tipo_parametro t
      WHERE t.area_tipo_id = a.id
  );

COMMIT;