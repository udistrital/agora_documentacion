-- Verificación de inserción de UNIDAD_MEDIDA
-- Motor: PostgreSQL
-- Todas las sentencias son SELECT; no modifican datos.
-- Salida esperada:
--   Verificación 1: registros con nombre, código y área esperados = 1.
--   Verificación 2: registros con código UNIDAD_MEDIDA en el área 4 = 1.
--   Verificación 3: detalle con nombre/código esperados, área 4 y activo = TRUE.
--   Verificación 4: el orden asignado es mayor que el máximo de los otros tipos
--                   del área 4; se muestran también ambos máximos para revisión.

-- Verificación 1: existencia del registro esperado (esperado: 1)
SELECT COUNT(*) AS registros_esperados
FROM parametros.tipo_parametro t
WHERE t.nombre = 'UNIDAD DE MEDIDA'
  AND t.codigo_abreviacion = 'UNIDAD_MEDIDA'
  AND t.area_tipo_id = 4;

-- Verificación 2: cantidad de registros con el código en el área 4 (esperado: 1)
SELECT
    COUNT(*) AS registros_con_codigo_en_area_4,
    CASE
        WHEN COUNT(*) = 1 THEN 'CORRECTO'
        ELSE 'REVISAR'
    END AS resultado
FROM parametros.tipo_parametro t
WHERE t.codigo_abreviacion = 'UNIDAD_MEDIDA'
  AND t.area_tipo_id = 4;

-- Verificación 3: integridad y detalle del registro
SELECT
    t.id,
    t.nombre,
    t.codigo_abreviacion,
    t.area_tipo_id,
    t.activo,
    t.numero_orden,
    CASE
        WHEN t.nombre = 'UNIDAD DE MEDIDA'
         AND t.codigo_abreviacion = 'UNIDAD_MEDIDA'
         AND t.area_tipo_id = 4
         AND t.activo IS TRUE THEN 'CORRECTO'
        ELSE 'REVISAR'
    END AS resultado
FROM parametros.tipo_parametro t
WHERE t.nombre = 'UNIDAD DE MEDIDA'
   OR t.codigo_abreviacion = 'UNIDAD_MEDIDA'
ORDER BY t.id;

-- Verificación 4: orden dinámico respecto a los otros tipos del área 4
SELECT
    t.id,
    t.numero_orden AS numero_orden_asignado,
    (
        SELECT MAX(area4.numero_orden)
        FROM parametros.tipo_parametro area4
        WHERE area4.area_tipo_id = 4
    ) AS maximo_orden_area_4,
    (
        SELECT MAX(otro.numero_orden)
        FROM parametros.tipo_parametro otro
        WHERE otro.area_tipo_id = 4
          AND otro.id <> t.id
    ) AS maximo_orden_otros_tipos_area_4,
    CASE
        WHEN t.area_tipo_id = 4
         AND t.numero_orden > COALESCE((
             SELECT MAX(otro.numero_orden)
             FROM parametros.tipo_parametro otro
             WHERE otro.area_tipo_id = 4
               AND otro.id <> t.id
         ), 0) THEN 'CORRECTO'
        ELSE 'REVISAR'
    END AS resultado_orden
FROM parametros.tipo_parametro t
WHERE t.nombre = 'UNIDAD DE MEDIDA'
   OR t.codigo_abreviacion = 'UNIDAD_MEDIDA'
ORDER BY t.id;
