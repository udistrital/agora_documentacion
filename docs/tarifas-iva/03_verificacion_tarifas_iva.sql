-- =============================================================================
-- Script   : 03_verificacion_tarifas_iva.sql
-- Esperado : 2 valores únicos en el catálogo Tarifa de IVA.
-- =============================================================================

-- 1. Valores encontrados, orden, código y estado activo.
SELECT a.nombre AS area,
       t.nombre AS tipo_parametro,
       p.id AS parametro_id,
       p.nombre AS parametro,
       p.codigo_abreviacion,
       p.numero_orden,
       p.activo
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TARIFA_IVA_COT'
ORDER BY p.numero_orden;

-- 2. Comparación uno a uno entre los códigos esperados y los encontrados.
WITH esperados(codigo_abreviacion, nombre, numero_orden) AS (
  VALUES
    ('IVA_05', '5 %', 1),
    ('IVA_19', '19 %', 2)
)
SELECT e.codigo_abreviacion,
       e.nombre AS nombre_esperado,
       e.numero_orden AS orden_esperado,
       p.nombre AS nombre_encontrado,
       p.numero_orden AS orden_encontrado,
       CASE WHEN p.id IS NULL THEN 'FALTA'
            WHEN p.nombre <> e.nombre THEN 'NOMBRE_DISTINTO'
            WHEN p.numero_orden <> e.numero_orden THEN 'ORDEN_DISTINTO'
            WHEN NOT p.activo THEN 'INACTIVO'
            ELSE 'OK' END AS resultado
FROM esperados e
LEFT JOIN parametros.area_tipo a ON a.nombre = 'Gestión de Cotizaciones'
LEFT JOIN parametros.tipo_parametro t
  ON t.area_tipo_id = a.id AND t.codigo_abreviacion = 'TARIFA_IVA_COT'
LEFT JOIN parametros.parametro p
  ON p.tipo_parametro_id = t.id AND p.codigo_abreviacion = e.codigo_abreviacion
ORDER BY e.numero_orden;

-- 3. Conteo esperado: 2 parámetros. El resultado debe coincidir.
SELECT COUNT(*) AS cantidad_encontrada,
       2 AS cantidad_esperada,
       CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'REVISAR' END AS resultado
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TARIFA_IVA_COT'
  AND p.codigo_abreviacion IN ('IVA_05', 'IVA_19');

-- 4. Duplicados por código o por nombre dentro del tipo (esperado: 0 filas).
SELECT 'CODIGO' AS criterio, p.codigo_abreviacion AS valor, COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TARIFA_IVA_COT'
GROUP BY p.codigo_abreviacion
HAVING COUNT(*) > 1
UNION ALL
SELECT 'NOMBRE' AS criterio, p.nombre AS valor, COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TARIFA_IVA_COT'
GROUP BY p.nombre
HAVING COUNT(*) > 1;
