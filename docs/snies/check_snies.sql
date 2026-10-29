-- Verificación de inserciones SNIES
-- Motor: PostgreSQL
-- Todas las sentencias son SELECT; no modifican datos.

-- Verificación 1: conteo por tabla (esperado: 1 / 8 / 69)
SELECT
    (
        SELECT COUNT(*)
        FROM parametros.area_tipo a
        WHERE a.nombre = 'SNIES'
          AND a.codigo_abreviacion = 'SNIES'
    ) AS area_tipo,
    (
        SELECT COUNT(*)
        FROM parametros.tipo_parametro t
        JOIN parametros.area_tipo a
            ON a.id = t.area_tipo_id
        WHERE a.nombre = 'SNIES'
          AND a.codigo_abreviacion = 'SNIES'
          AND t.nombre IN (
              'AGRONOMÍA, VETERINARIA Y AFINES',
              'BELLAS ARTES',
              'CIENCIAS DE LA EDUCACIÓN',
              'CIENCIAS DE LA SALUD',
              'CIENCIAS SOCIALES Y HUMANAS',
              'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
              'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
              'MATEMÁTICAS Y CIENCIAS NATURALES'
          )
    ) AS tipo_parametro,
    (
        SELECT COUNT(*)
        FROM parametros.parametro p
        JOIN parametros.tipo_parametro t
            ON t.id = p.tipo_parametro_id
        JOIN parametros.area_tipo a
            ON a.id = t.area_tipo_id
        WHERE a.nombre = 'SNIES'
          AND a.codigo_abreviacion = 'SNIES'
          AND t.nombre IN (
              'AGRONOMÍA, VETERINARIA Y AFINES',
              'BELLAS ARTES',
              'CIENCIAS DE LA EDUCACIÓN',
              'CIENCIAS DE LA SALUD',
              'CIENCIAS SOCIALES Y HUMANAS',
              'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
              'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
              'MATEMÁTICAS Y CIENCIAS NATURALES'
          )
    ) AS parametro;

-- Verificación 2: opciones conocidas, una por cada área (esperado: 8 filas)
WITH opciones_esperadas(tipo_parametro, codigo_abreviacion, nombre, numero_orden) AS (
    VALUES
        ('AGRONOMÍA, VETERINARIA Y AFINES', 'AGRONOMÍA', 'AGRONOMÍA', 1),
        ('BELLAS ARTES', 'ART_PLA_VIS_AFINES', 'ARTES PLÁSTICAS, VISUALES Y AFINES', 1),
        ('CIENCIAS DE LA EDUCACIÓN', 'EDUCACIÓN', 'EDUCACIÓN', 1),
        ('CIENCIAS DE LA SALUD', 'BACTERIOLOGÍA', 'BACTERIOLOGÍA', 1),
        ('CIENCIAS SOCIALES Y HUMANAS', 'ANTROPOLOGÍA', 'ANTROPOLOGÍA', 1),
        ('ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES', 'ADMINISTRACIÓN', 'ADMINISTRACIÓN', 1),
        ('INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES', 'ARQUITECTURA', 'ARQUITECTURA', 1),
        ('MATEMÁTICAS Y CIENCIAS NATURALES', 'BIOLOGÍA', 'BIOLOGÍA', 1)
)
SELECT
    e.tipo_parametro,
    e.codigo_abreviacion AS codigo_esperado,
    e.nombre AS nombre_esperado,
    p.codigo_abreviacion,
    p.nombre,
    p.activo,
    p.numero_orden
FROM opciones_esperadas e
LEFT JOIN parametros.area_tipo a
    ON a.nombre = 'SNIES'
   AND a.codigo_abreviacion = 'SNIES'
LEFT JOIN parametros.tipo_parametro t
    ON t.area_tipo_id = a.id
   AND t.nombre = e.tipo_parametro
LEFT JOIN parametros.parametro p
    ON p.tipo_parametro_id = t.id
   AND p.codigo_abreviacion = e.codigo_abreviacion
ORDER BY e.tipo_parametro;

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
WHERE a.nombre = 'SNIES'
  AND a.codigo_abreviacion = 'SNIES'
  AND t.nombre IN (
      'AGRONOMÍA, VETERINARIA Y AFINES',
      'BELLAS ARTES',
      'CIENCIAS DE LA EDUCACIÓN',
      'CIENCIAS DE LA SALUD',
      'CIENCIAS SOCIALES Y HUMANAS',
      'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
      'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
      'MATEMÁTICAS Y CIENCIAS NATURALES'
  )
GROUP BY t.id, t.nombre, p.codigo_abreviacion
HAVING COUNT(*) > 1
ORDER BY t.nombre, p.codigo_abreviacion;

-- Verificación 4: conteo de opciones por catálogo
WITH conteos_esperados(tipo_parametro, total_esperado) AS (
    VALUES
        ('AGRONOMÍA, VETERINARIA Y AFINES', 3),
        ('BELLAS ARTES', 5),
        ('CIENCIAS DE LA EDUCACIÓN', 1),
        ('CIENCIAS DE LA SALUD', 10),
        ('CIENCIAS SOCIALES Y HUMANAS', 23),
        ('ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES', 3),
        ('INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES', 17),
        ('MATEMÁTICAS Y CIENCIAS NATURALES', 7)
)
SELECT
    e.tipo_parametro,
    e.total_esperado,
    COUNT(p.id) AS total_encontrado
FROM conteos_esperados e
LEFT JOIN parametros.area_tipo a
    ON a.nombre = 'SNIES'
   AND a.codigo_abreviacion = 'SNIES'
LEFT JOIN parametros.tipo_parametro t
    ON t.area_tipo_id = a.id
   AND t.nombre = e.tipo_parametro
LEFT JOIN parametros.parametro p
    ON p.tipo_parametro_id = t.id
GROUP BY e.tipo_parametro, e.total_esperado
ORDER BY e.tipo_parametro;

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
WHERE a.nombre = 'SNIES'
  AND a.codigo_abreviacion = 'SNIES'
  AND t.nombre IN (
      'AGRONOMÍA, VETERINARIA Y AFINES',
      'BELLAS ARTES',
      'CIENCIAS DE LA EDUCACIÓN',
      'CIENCIAS DE LA SALUD',
      'CIENCIAS SOCIALES Y HUMANAS',
      'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
      'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
      'MATEMÁTICAS Y CIENCIAS NATURALES'
  )
  AND (
      p.activo IS DISTINCT FROM TRUE
      OR p.numero_orden IS NULL
      OR p.numero_orden < 1
  )
ORDER BY t.nombre, p.numero_orden;

-- Verificación 6: nombres duplicados dentro del mismo catálogo
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
WHERE a.nombre = 'SNIES'
  AND a.codigo_abreviacion = 'SNIES'
  AND t.nombre IN (
      'AGRONOMÍA, VETERINARIA Y AFINES',
      'BELLAS ARTES',
      'CIENCIAS DE LA EDUCACIÓN',
      'CIENCIAS DE LA SALUD',
      'CIENCIAS SOCIALES Y HUMANAS',
      'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
      'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
      'MATEMÁTICAS Y CIENCIAS NATURALES'
  )
GROUP BY t.id, t.nombre, p.nombre
HAVING COUNT(*) > 1
ORDER BY t.nombre, p.nombre;