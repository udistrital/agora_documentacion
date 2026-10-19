-- =============================================================================
-- Script   : 03_verificacion_tipo_documento_cotizaciones.sql
-- Esperado : 3 valores únicos en el catálogo Tipo de documento de Cotizaciones.
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
  AND t.codigo_abreviacion = 'TIP_DOC_COT'
ORDER BY p.numero_orden;

-- 2. Comparación uno a uno entre los códigos esperados y los encontrados.
WITH esperados(codigo_abreviacion, nombre, numero_orden) AS (
  VALUES
    ('ESTUDIOS_PREVIOS', 'Estudios previos', 1),
    ('ANEXO_TECNICO', 'Anexo técnico', 2),
    ('CDP', 'Certificado de disponibilidad presupuestal (CDP)', 3)
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
  ON t.area_tipo_id = a.id AND t.codigo_abreviacion = 'TIP_DOC_COT'
LEFT JOIN parametros.parametro p
  ON p.tipo_parametro_id = t.id AND p.codigo_abreviacion = e.codigo_abreviacion
ORDER BY e.numero_orden;

-- 3. Conteo esperado: 3 parámetros dentro del alcance de solicitud/publicación.
SELECT COUNT(*) AS cantidad_encontrada,
       3 AS cantidad_esperada,
       CASE WHEN COUNT(*) = 3 THEN 'OK' ELSE 'REVISAR' END AS resultado
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TIP_DOC_COT'
  AND p.codigo_abreviacion IN ('ESTUDIOS_PREVIOS', 'ANEXO_TECNICO', 'CDP');

-- 4. Documentos de etapas posteriores: no deben cargarse en este catálogo en este alcance.
SELECT p.codigo_abreviacion, p.nombre
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TIP_DOC_COT'
  AND p.codigo_abreviacion IN (
      'COTIZACION_OFERENTE', 'CERTIFICACION_BANCARIA',
      'CATALOGO_TECNICO_FABRICANTE', 'CERTIFICACION_EXPERIENCIA'
  );
-- Resultado esperado: 0 filas.

-- 5. Duplicados por código o por nombre dentro del tipo (esperado: 0 filas).
SELECT 'CODIGO' AS criterio, p.codigo_abreviacion AS valor, COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TIP_DOC_COT'
GROUP BY p.codigo_abreviacion
HAVING COUNT(*) > 1
UNION ALL
SELECT 'NOMBRE' AS criterio, p.nombre AS valor, COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'TIP_DOC_COT'
GROUP BY p.nombre
HAVING COUNT(*) > 1;
