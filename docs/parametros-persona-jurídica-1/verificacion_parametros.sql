-- Verificación 1: conteo por tabla (esperado: 1 / 5 / 140)
SELECT
    (
        SELECT COUNT(*)
        FROM parametros.area_tipo
        WHERE nombre = 'Información Tributaria'
          AND codigo_abreviacion = 'IT'
    ) AS area_tipo,
    (
        SELECT COUNT(*)
        FROM parametros.tipo_parametro t
        JOIN parametros.area_tipo a
            ON a.id = t.area_tipo_id
        WHERE a.nombre = 'Información Tributaria'
          AND a.codigo_abreviacion = 'IT'
          AND t.nombre IN (
              'Cámaras de comercio',
              'Responsabilidad fiscal',
              'Tipo de representación',
              'Tipo de declaración',
              'Tipo de documento'
          )
    ) AS tipo_parametro,
    (
        SELECT COUNT(*)
        FROM parametros.parametro p
        JOIN parametros.tipo_parametro t
            ON t.id = p.tipo_parametro_id
        JOIN parametros.area_tipo a
            ON a.id = t.area_tipo_id
        WHERE a.nombre = 'Información Tributaria'
          AND a.codigo_abreviacion = 'IT'
          AND t.nombre IN (
              'Cámaras de comercio',
              'Responsabilidad fiscal',
              'Tipo de representación',
              'Tipo de declaración',
              'Tipo de documento'
          )
    ) AS parametro;

-- Verificación 2: muestra de opciones conocidas (esperado: 6 filas)
SELECT
    t.nombre AS tipo_parametro,
    p.codigo_abreviacion,
    p.nombre,
    p.activo,
    p.numero_orden
FROM parametros.parametro p
JOIN parametros.tipo_parametro t
    ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a
    ON a.id = t.area_tipo_id
WHERE a.nombre = 'Información Tributaria'
  AND a.codigo_abreviacion = 'IT'
  AND (
      (t.nombre = 'Cámaras de comercio'
       AND p.codigo_abreviacion IN (
           'BUCARAMANGA',
           'BOGOTA'
       ))
      OR
      (t.nombre = 'Responsabilidad fiscal'
       AND p.codigo_abreviacion IN (
           '01',
           '48'
       ))
      OR
      (t.nombre = 'Tipo de representación'
       AND p.codigo_abreviacion IN (
           'REP_PRINC',
           'REP_SUPL'
       ))
  )
ORDER BY
    t.nombre,
    p.numero_orden;

-- Verificación 3: códigos de abreviación duplicados dentro del mismo catálogo
-- (esperado: 0 filas)
SELECT
    t.nombre AS tipo_parametro,
    p.codigo_abreviacion,
    COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t
    ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a
    ON a.id = t.area_tipo_id
WHERE a.nombre = 'Información Tributaria'
  AND a.codigo_abreviacion = 'IT'
  AND t.nombre IN (
      'Cámaras de comercio',
      'Responsabilidad fiscal',
      'Tipo de representación',
      'Tipo de declaración',
      'Tipo de documento'
  )
GROUP BY
    t.id,
    t.nombre,
    p.codigo_abreviacion
HAVING COUNT(*) > 1
ORDER BY
    t.nombre,
    p.codigo_abreviacion;

-- Verificación 4: conteo de opciones por catálogo
SELECT
    t.nombre AS tipo_parametro,
    COUNT(p.id) AS total_opciones
FROM parametros.area_tipo a
JOIN parametros.tipo_parametro t
    ON t.area_tipo_id = a.id
LEFT JOIN parametros.parametro p
    ON p.tipo_parametro_id = t.id
WHERE a.nombre = 'Información Tributaria'
  AND a.codigo_abreviacion = 'IT'
  AND t.nombre IN (
      'Cámaras de comercio',
      'Responsabilidad fiscal',
      'Tipo de representación',
      'Tipo de declaración',
      'Tipo de documento'
  )
GROUP BY
    t.id,
    t.nombre
ORDER BY
    t.nombre;

-- Verificación 5: opciones inactivas o con número de orden inválido
-- (esperado: 0 filas)
SELECT
    t.nombre AS tipo_parametro,
    p.codigo_abreviacion,
    p.nombre,
    p.activo,
    p.numero_orden
FROM parametros.parametro p
JOIN parametros.tipo_parametro t
    ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a
    ON a.id = t.area_tipo_id
WHERE a.nombre = 'Información Tributaria'
  AND a.codigo_abreviacion = 'IT'
  AND t.nombre IN (
      'Cámaras de comercio',
      'Responsabilidad fiscal',
      'Tipo de representación',
      'Tipo de declaración',
      'Tipo de documento'
  )
  AND (
      p.activo IS DISTINCT FROM TRUE
      OR p.numero_orden IS NULL
      OR p.numero_orden < 1
  );

-- Verificación 6: nombres de opciones duplicados dentro del mismo catálogo
-- (esperado: 0 filas)
SELECT
    t.nombre AS tipo_parametro,
    p.nombre AS nombre_opcion,
    COUNT(*) AS repeticiones
FROM parametros.parametro p
JOIN parametros.tipo_parametro t
    ON t.id = p.tipo_parametro_id
JOIN parametros.area_tipo a
    ON a.id = t.area_tipo_id
WHERE a.nombre = 'Información Tributaria'
  AND a.codigo_abreviacion = 'IT'
  AND t.nombre IN (
      'Cámaras de comercio',
      'Responsabilidad fiscal',
      'Tipo de representación',
      'Tipo de declaración',
      'Tipo de documento'
  )
GROUP BY
    t.id,
    t.nombre,
    p.nombre
HAVING COUNT(*) > 1
ORDER BY
    t.nombre,
    p.nombre;