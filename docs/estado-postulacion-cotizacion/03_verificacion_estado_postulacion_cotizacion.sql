-- =============================================================================
-- Script   : 03_verificacion_estado_postulacion_cotizacion.sql
-- Esperado : 4 valores únicos en el catálogo Estado de postulación del proveedor.
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
  AND t.codigo_abreviacion = 'EST_POST_COT'
ORDER BY p.numero_orden;

-- 2. Comparación uno a uno entre los códigos esperados y los encontrados.
WITH esperados(codigo_abreviacion, nombre, numero_orden) AS (
  VALUES
    ('INVITADO', 'Invitado', 1),
    ('SIN_RESPUESTA', 'Sin respuesta', 2),
    ('PARTICIPA', 'Participa', 3),
    ('DECLINA', 'Declina', 4)
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
  ON t.area_tipo_id = a.id AND t.codigo_abreviacion = 'EST_POST_COT'
LEFT JOIN parametros.parametro p
  ON p.tipo_parametro_id = t.id AND p.codigo_abreviacion = e.codigo_abreviacion
ORDER BY e.numero_orden;

-- 3. Conteo esperado: 4 parámetros. El resultado debe coincidir.
SELECT COUNT(*) AS cantidad_encontrada,
       4 AS cantidad_esperada,
       CASE WHEN COUNT(*) = 4 THEN 'OK' ELSE 'REVISAR' END AS resultado
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'EST_POST_COT'
  AND p.codigo_abreviacion IN ('INVITADO', 'SIN_RESPUESTA', 'PARTICIPA', 'DECLINA');

-- 4. Duplicados por código o por nombre dentro del tipo (esperado: 0 filas).
SELECT 'CODIGO' AS criterio, p.codigo_abreviacion AS valor, COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'EST_POST_COT'
GROUP BY p.codigo_abreviacion
HAVING COUNT(*) > 1
UNION ALL
SELECT 'NOMBRE' AS criterio, p.nombre AS valor, COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'EST_POST_COT'
GROUP BY p.nombre
HAVING COUNT(*) > 1;
