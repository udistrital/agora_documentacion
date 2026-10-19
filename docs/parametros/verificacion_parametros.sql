-- ============================================================
-- VALIDACIÓN DE INFORMACIÓN TRIBUTARIA COMPLEMENTARIA
-- ============================================================

-- ============================================================
-- Verificación 1: existencia del área y del tipo general.
-- Esperado: area_tipo = 1, tipo_parametro = 1.
-- ============================================================
SELECT
    (
        SELECT COUNT(*)
        FROM parametros.area_tipo
        WHERE codigo_abreviacion = 'IT'
    ) AS area_tipo,
    (
        SELECT COUNT(*)
        FROM parametros.tipo_parametro tp
        INNER JOIN parametros.area_tipo a
            ON a.id = tp.area_tipo_id
        WHERE a.codigo_abreviacion = 'IT'
          AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
    ) AS tipo_parametro;

-- ============================================================
-- Verificación 2: listado de las nueve preguntas.
-- Esperado: 9 filas, todas activas y con orden del 1 al 9.
-- ============================================================
SELECT
    tp.nombre AS tipo_parametro,
    tp.codigo_abreviacion AS codigo_tipo_parametro,
    p.codigo_abreviacion AS codigo_parametro,
    p.nombre AS pregunta,
    p.descripcion,
    p.activo,
    p.numero_orden
FROM parametros.parametro p
INNER JOIN parametros.tipo_parametro tp
    ON tp.id = p.tipo_parametro_id
INNER JOIN parametros.area_tipo a
    ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
  AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
  AND p.codigo_abreviacion IN (
      'BEN_FIN_RUB',
      'COTIZA_BVC',
      'REV_FISCAL',
      'CONTRIBUYENTE_DIAN',
      'AUTO_RENTA',
      'ICA_BOG',
      'RUP_VIGENTE',
      'FAC_ELEC',
      'MONEDA_EXT'
  )
ORDER BY p.numero_orden;

-- ============================================================
-- Verificación 3: códigos de pregunta duplicados dentro
-- del tipo general.
-- Esperado: 0 filas.
-- ============================================================
SELECT
    tp.codigo_abreviacion AS codigo_tipo_parametro,
    p.codigo_abreviacion AS codigo_parametro,
    COUNT(*) AS repeticiones
FROM parametros.parametro p
INNER JOIN parametros.tipo_parametro tp
    ON tp.id = p.tipo_parametro_id
INNER JOIN parametros.area_tipo a
    ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
  AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
GROUP BY
    tp.id,
    tp.codigo_abreviacion,
    p.codigo_abreviacion
HAVING COUNT(*) > 1
ORDER BY p.codigo_abreviacion;

-- ============================================================
-- Verificación 4: conteo de preguntas por tipo general.
-- Esperado: 9 parámetros.
-- ============================================================
SELECT
    tp.codigo_abreviacion AS codigo_tipo_parametro,
    tp.nombre AS tipo_parametro,
    COUNT(p.id) AS total_preguntas
FROM parametros.tipo_parametro tp
INNER JOIN parametros.area_tipo a
    ON a.id = tp.area_tipo_id
LEFT JOIN parametros.parametro p
    ON p.tipo_parametro_id = tp.id
WHERE a.codigo_abreviacion = 'IT'
  AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
GROUP BY
    tp.id,
    tp.codigo_abreviacion,
    tp.nombre;

-- ============================================================
-- Verificación 5: preguntas inactivas o con número de orden
-- inválido.
-- Esperado: 0 filas.
-- ============================================================
SELECT
    p.codigo_abreviacion,
    p.nombre,
    p.activo,
    p.numero_orden
FROM parametros.parametro p
INNER JOIN parametros.tipo_parametro tp
    ON tp.id = p.tipo_parametro_id
INNER JOIN parametros.area_tipo a
    ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
  AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
  AND (
      p.activo IS DISTINCT FROM TRUE
      OR p.numero_orden IS NULL
      OR p.numero_orden < 1
  )
ORDER BY p.numero_orden;
