-- =============================================================================
-- Script   : 06_checks_parametrics.sql
-- Propósito: Verificar los registros definidos en 04_inserts_parametrics.sql.
-- Alcance  : 8 tipos y 26 parámetros presentes en el script fuente.
-- =============================================================================

-- Verificación 1: detalle de las agrupaciones y sus parámetros.
-- Esperado: 8 tipos y 26 parámetros; todos asociados al área IT.
SELECT a.id AS area_tipo_id,
    a.nombre AS area_tipo,
    tp.id AS tipo_parametro_id,
    tp.nombre AS tipo_parametro,
    p.id AS parametro_id,
    p.nombre AS parametro,
    p.codigo_abreviacion,
    p.descripcion,
    p.numero_orden,
    p.activo
FROM parametros.area_tipo a
    JOIN parametros.tipo_parametro tp ON tp.area_tipo_id = a.id
    JOIN parametros.parametro p ON p.tipo_parametro_id = tp.id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion IN (
        'REG_CONT',
        'RESP_ICA',
        'RESP_IVA',
        'CLASIFICACIÓN_PYME',
        'REG_MERCANTIL',
        'EXC_PRODUCTO',
        'CALIDAD_CONTRIB',
        'TIPO_CONFORMACIÓN'
    )
    AND p.codigo_abreviacion IN (
        'COMUN_ORDINARIO',
        'REGIMEN_SIMPLE_RST',
        'REGIMEN_TRIB_ESP',
        'ENTIDAD_DER_PUBLICO',
        'REGIMEN_COMUN_BIM',
        'REGIMEN_SIMPLIFICADO',
        'NO_SUJETO_EXENTO_ICA',
        'REGIMEN_ESP_CONS',
        'RESP_IVA_GRAVADO',
        'NO_RESP_IVA',
        'EXENTO_IVA_OPER_ESP',
        'SI_PEQUEÑA_EMPRESA',
        'SI_MICROEMPRESA',
        'SI_MEDIANA_EMPRESA',
        'NO_GRAN_EMPRESA',
        'SI_MATRICULA_ACTIVA',
        'NO_EXENTA_LEGAL',
        'NO_DISTRIB_LOCAL',
        'SI_DISTRIB_EXCLUSIVO',
        'SI_IMPORT_DIRECTO',
        'NO_REG_ORD_COMUN',
        'SI_CALIF_DIAN',
        'AUTORRET_RESOLUCION',
        'INDIVIDUAL_PRINCIPAL',
        'CONJUNTA_MANCOMUNADA',
        'CONSORCIO_UT'
    )
ORDER BY tp.numero_orden,
    p.numero_orden;

-- Verificación 2: conteos exactos de los registros definidos.
-- Esperado: area_tipo = 1, tipo_parametro = 8, parametro = 26.
WITH tipos_esperados(codigo_tipo, nombre_tipo) AS (
    VALUES ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO'),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)'
        ),
        ('RESP_IVA', 'RESPONSABLE DE IVA (CÓD. 48 RUT)'),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL'
        ),
        (
            'REG_MERCANTIL',
            'REGISTRO MERCANTIL / MATRÍCULA ACTIVA'
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN'
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)'
        ),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN')
),
parametros_esperados(
    codigo_tipo,
    nombre_tipo,
    codigo_parametro,
    nombre_parametro
) AS (
    VALUES (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'COMUN_ORDINARIO',
            'COMÚN / ORDINARIO (IMPUESTO SOBRE LA RENTA)'
        ),
        (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'REGIMEN_SIMPLE_RST',
            'RÉGIMEN SIMPLE DE TRIBUTACIÓN (RST)'
        ),
        (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'REGIMEN_TRIB_ESP',
            'RÉGIMEN TRIBUTARIO ESPECIAL (ESAL / FUNDACIONES)'
        ),
        (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'ENTIDAD_DER_PUBLICO',
            'ENTIDAD DE DERECHO PÚBLICO / OFICIAL'
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'REGIMEN_COMUN_BIM',
            'RÉGIMEN COMÚN (BIMESTRAL SHD)'
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'REGIMEN_SIMPLIFICADO',
            'RÉGIMEN SIMPLIFICADO / PREFERENCIAL'
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'NO_SUJETO_EXENTO_ICA',
            'NO SUJETO / EXENTO DE ICA DISTRITAL'
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'REGIMEN_ESP_CONS',
            'RÉGIMEN ESPECIAL CONSORCIOS / UT'
        ),
        (
            'RESP_IVA',
            'RESPONSABLE DE IVA (CÓD. 48 RUT)',
            'RESP_IVA_GRAVADO',
            'RESPONSABLE DE IVA (GRAVADO / BIMESTRAL O CUATRIMESTRAL)'
        ),
        (
            'RESP_IVA',
            'RESPONSABLE DE IVA (CÓD. 48 RUT)',
            'NO_RESP_IVA',
            'NO RESPONSABLE DE IVA (ANTIGUO SIMPLIFICADO)'
        ),
        (
            'RESP_IVA',
            'RESPONSABLE DE IVA (CÓD. 48 RUT)',
            'EXENTO_IVA_OPER_ESP',
            'EXENTO DE IVA POR OPERACIONES ESPECIALES'
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'SI_PEQUEÑA_EMPRESA',
            'SÍ - PEQUEÑA EMPRESA (HASTA 204.653 UVT)'
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'SI_MICROEMPRESA',
            'SÍ - MICROEMPRESA (HASTA 23.563 UVT)'
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'SI_MEDIANA_EMPRESA',
            'SÍ - MEDIANA EMPRESA (HASTA 483.034 UVT)'
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'NO_GRAN_EMPRESA',
            'NO - GRAN EMPRESA (MAYOR A 483.034 UVT)'
        ),
        (
            'REG_MERCANTIL',
            'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
            'SI_MATRICULA_ACTIVA',
            'SÍ (MATRÍCULA MERCANTIL ACTIVA Y RENOVADA)'
        ),
        (
            'REG_MERCANTIL',
            'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
            'NO_EXENTA_LEGAL',
            'NO (EXENTA CONFORME A RÉGIMEN LEGAL)'
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
            'NO_DISTRIB_LOCAL',
            'NO (DISTRIBUCIÓN LOCAL / SERVICIOS NACIONALES)'
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
            'SI_DISTRIB_EXCLUSIVO',
            'SÍ - DISTRIBUIDOR O REPRESENTANTE EXCLUSIVO IMPORTADO'
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
            'SI_IMPORT_DIRECTO',
            'SÍ - IMPORTADOR DIRECTO NO EXCLUSIVO'
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
            'NO_REG_ORD_COMUN',
            'NO (CONTRIBUYENTE RÉGIMEN ORDINARIO COMÚN)'
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
            'SI_CALIF_DIAN',
            'SÍ - CALIFICADO POR RESOLUCIÓN DIAN VIGENTE'
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
            'AUTORRET_RESOLUCION',
            'AUTORRETENEDOR POR RESOLUCIÓN'
        ),
        (
            'TIPO_CONFORMACIÓN',
            'TIPO DE CONFORMACIÓN',
            'INDIVIDUAL_PRINCIPAL',
            'INDIVIDUAL / PRINCIPAL'
        ),
        (
            'TIPO_CONFORMACIÓN',
            'TIPO DE CONFORMACIÓN',
            'CONJUNTA_MANCOMUNADA',
            'CONJUNTA / MANCOMUNADA'
        ),
        (
            'TIPO_CONFORMACIÓN',
            'TIPO DE CONFORMACIÓN',
            'CONSORCIO_UT',
            'CONSORCIO / UNIÓN TEMPORAL'
        )
)
SELECT (
        SELECT COUNT(*)
        FROM parametros.area_tipo a
        WHERE a.nombre = 'Información Tributaria'
            AND a.codigo_abreviacion = 'IT'
    ) AS area_tipo,
    (
        SELECT COUNT(DISTINCT tp.id)
        FROM parametros.tipo_parametro tp
            JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
            JOIN tipos_esperados e ON e.codigo_tipo = tp.codigo_abreviacion
            AND e.nombre_tipo = tp.nombre
        WHERE a.nombre = 'Información Tributaria'
            AND a.codigo_abreviacion = 'IT'
    ) AS tipo_parametro,
    (
        SELECT COUNT(DISTINCT p.id)
        FROM parametros.parametro p
            JOIN parametros.tipo_parametro tp ON tp.id = p.tipo_parametro_id
            JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
            JOIN parametros_esperados e ON e.codigo_tipo = tp.codigo_abreviacion
            AND e.nombre_tipo = tp.nombre
            AND e.codigo_parametro = p.codigo_abreviacion
            AND e.nombre_parametro = p.nombre
        WHERE a.nombre = 'Información Tributaria'
            AND a.codigo_abreviacion = 'IT'
    ) AS parametro;

-- Verificación 3: códigos o nombres duplicados dentro de los catálogos.
-- Esperado: 0 filas.
SELECT 'codigo_abreviacion' AS campo_duplicado,
    tp.nombre AS tipo_parametro,
    p.codigo_abreviacion AS valor,
    COUNT(*) AS repeticiones
FROM parametros.parametro p
    JOIN parametros.tipo_parametro tp ON tp.id = p.tipo_parametro_id
    JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion IN (
        'REG_CONT',
        'RESP_ICA',
        'RESP_IVA',
        'CLASIFICACIÓN_PYME',
        'REG_MERCANTIL',
        'EXC_PRODUCTO',
        'CALIDAD_CONTRIB',
        'TIPO_CONFORMACIÓN'
    )
    AND p.codigo_abreviacion IN (
        'COMUN_ORDINARIO',
        'REGIMEN_SIMPLE_RST',
        'REGIMEN_TRIB_ESP',
        'ENTIDAD_DER_PUBLICO',
        'REGIMEN_COMUN_BIM',
        'REGIMEN_SIMPLIFICADO',
        'NO_SUJETO_EXENTO_ICA',
        'REGIMEN_ESP_CONS',
        'RESP_IVA_GRAVADO',
        'NO_RESP_IVA',
        'EXENTO_IVA_OPER_ESP',
        'SI_PEQUEÑA_EMPRESA',
        'SI_MICROEMPRESA',
        'SI_MEDIANA_EMPRESA',
        'NO_GRAN_EMPRESA',
        'SI_MATRICULA_ACTIVA',
        'NO_EXENTA_LEGAL',
        'NO_DISTRIB_LOCAL',
        'SI_DISTRIB_EXCLUSIVO',
        'SI_IMPORT_DIRECTO',
        'NO_REG_ORD_COMUN',
        'SI_CALIF_DIAN',
        'AUTORRET_RESOLUCION',
        'INDIVIDUAL_PRINCIPAL',
        'CONJUNTA_MANCOMUNADA',
        'CONSORCIO_UT'
    )
GROUP BY tp.id,
    tp.nombre,
    p.codigo_abreviacion
HAVING COUNT(*) > 1
UNION ALL
SELECT 'nombre' AS campo_duplicado,
    tp.nombre AS tipo_parametro,
    p.nombre AS valor,
    COUNT(*) AS repeticiones
FROM parametros.parametro p
    JOIN parametros.tipo_parametro tp ON tp.id = p.tipo_parametro_id
    JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion IN (
        'REG_CONT',
        'RESP_ICA',
        'RESP_IVA',
        'CLASIFICACIÓN_PYME',
        'REG_MERCANTIL',
        'EXC_PRODUCTO',
        'CALIDAD_CONTRIB',
        'TIPO_CONFORMACIÓN'
    )
    AND p.codigo_abreviacion IN (
        'COMUN_ORDINARIO',
        'REGIMEN_SIMPLE_RST',
        'REGIMEN_TRIB_ESP',
        'ENTIDAD_DER_PUBLICO',
        'REGIMEN_COMUN_BIM',
        'REGIMEN_SIMPLIFICADO',
        'NO_SUJETO_EXENTO_ICA',
        'REGIMEN_ESP_CONS',
        'RESP_IVA_GRAVADO',
        'NO_RESP_IVA',
        'EXENTO_IVA_OPER_ESP',
        'SI_PEQUEÑA_EMPRESA',
        'SI_MICROEMPRESA',
        'SI_MEDIANA_EMPRESA',
        'NO_GRAN_EMPRESA',
        'SI_MATRICULA_ACTIVA',
        'NO_EXENTA_LEGAL',
        'NO_DISTRIB_LOCAL',
        'SI_DISTRIB_EXCLUSIVO',
        'SI_IMPORT_DIRECTO',
        'NO_REG_ORD_COMUN',
        'SI_CALIF_DIAN',
        'AUTORRET_RESOLUCION',
        'INDIVIDUAL_PRINCIPAL',
        'CONJUNTA_MANCOMUNADA',
        'CONSORCIO_UT'
    )
GROUP BY tp.id,
    tp.nombre,
    p.nombre
HAVING COUNT(*) > 1
ORDER BY tipo_parametro,
    campo_duplicado,
    valor;

-- Verificación 4: total de parámetros por cada agrupación.
-- Esperado: 4, 4, 3, 4, 2, 3, 3 y 3 respectivamente.
SELECT tp.nombre AS tipo_parametro,
    COUNT(p.id) AS total_parametros
FROM parametros.area_tipo a
    JOIN parametros.tipo_parametro tp ON tp.area_tipo_id = a.id
    LEFT JOIN parametros.parametro p ON p.tipo_parametro_id = tp.id
    AND p.codigo_abreviacion IN (
        'COMUN_ORDINARIO',
        'REGIMEN_SIMPLE_RST',
        'REGIMEN_TRIB_ESP',
        'ENTIDAD_DER_PUBLICO',
        'REGIMEN_COMUN_BIM',
        'REGIMEN_SIMPLIFICADO',
        'NO_SUJETO_EXENTO_ICA',
        'REGIMEN_ESP_CONS',
        'RESP_IVA_GRAVADO',
        'NO_RESP_IVA',
        'EXENTO_IVA_OPER_ESP',
        'SI_PEQUEÑA_EMPRESA',
        'SI_MICROEMPRESA',
        'SI_MEDIANA_EMPRESA',
        'NO_GRAN_EMPRESA',
        'SI_MATRICULA_ACTIVA',
        'NO_EXENTA_LEGAL',
        'NO_DISTRIB_LOCAL',
        'SI_DISTRIB_EXCLUSIVO',
        'SI_IMPORT_DIRECTO',
        'NO_REG_ORD_COMUN',
        'SI_CALIF_DIAN',
        'AUTORRET_RESOLUCION',
        'INDIVIDUAL_PRINCIPAL',
        'CONJUNTA_MANCOMUNADA',
        'CONSORCIO_UT'
    )
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion IN (
        'REG_CONT',
        'RESP_ICA',
        'RESP_IVA',
        'CLASIFICACIÓN_PYME',
        'REG_MERCANTIL',
        'EXC_PRODUCTO',
        'CALIDAD_CONTRIB',
        'TIPO_CONFORMACIÓN'
    )
GROUP BY tp.id,
    tp.nombre
ORDER BY tp.nombre;

-- Verificación 5: tipos ausentes, inactivos o asociados a otra área.
-- Esperado: 0 filas.
WITH tipos_esperados(codigo_tipo, nombre_tipo) AS (
    VALUES ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO'),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)'
        ),
        ('RESP_IVA', 'RESPONSABLE DE IVA (CÓD. 48 RUT)'),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL'
        ),
        (
            'REG_MERCANTIL',
            'REGISTRO MERCANTIL / MATRÍCULA ACTIVA'
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN'
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)'
        ),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN')
)
SELECT e.codigo_tipo,
    e.nombre_tipo,
    tp.id AS tipo_parametro_id,
    a.id AS area_tipo_id,
    a.codigo_abreviacion AS codigo_area,
    tp.activo
FROM tipos_esperados e
    LEFT JOIN parametros.tipo_parametro tp ON tp.codigo_abreviacion = e.codigo_tipo
    AND tp.nombre = e.nombre_tipo
    LEFT JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
WHERE tp.id IS NULL
    OR a.id IS NULL
    OR a.codigo_abreviacion IS DISTINCT
FROM 'IT'
    OR a.nombre IS DISTINCT
FROM 'Información Tributaria'
    OR tp.activo IS DISTINCT
FROM TRUE;

-- Verificación 6: parámetros faltantes, mal asociados, inactivos
-- o con un número de orden distinto al definido en la inserción.
-- Esperado: 0 filas.
WITH parametros_esperados(
    codigo_tipo,
    nombre_tipo,
    codigo_parametro,
    nombre_parametro,
    numero_orden
) AS (
    VALUES (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'COMUN_ORDINARIO',
            'COMÚN / ORDINARIO (IMPUESTO SOBRE LA RENTA)',
            1
        ),
        (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'REGIMEN_SIMPLE_RST',
            'RÉGIMEN SIMPLE DE TRIBUTACIÓN (RST)',
            2
        ),
        (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'REGIMEN_TRIB_ESP',
            'RÉGIMEN TRIBUTARIO ESPECIAL (ESAL / FUNDACIONES)',
            3
        ),
        (
            'REG_CONT',
            'RÉGIMEN CONTRIBUTIVO',
            'ENTIDAD_DER_PUBLICO',
            'ENTIDAD DE DERECHO PÚBLICO / OFICIAL',
            4
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'REGIMEN_COMUN_BIM',
            'RÉGIMEN COMÚN (BIMESTRAL SHD)',
            1
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'REGIMEN_SIMPLIFICADO',
            'RÉGIMEN SIMPLIFICADO / PREFERENCIAL',
            2
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'NO_SUJETO_EXENTO_ICA',
            'NO SUJETO / EXENTO DE ICA DISTRITAL',
            3
        ),
        (
            'RESP_ICA',
            'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
            'REGIMEN_ESP_CONS',
            'RÉGIMEN ESPECIAL CONSORCIOS / UT',
            4
        ),
        (
            'RESP_IVA',
            'RESPONSABLE DE IVA (CÓD. 48 RUT)',
            'RESP_IVA_GRAVADO',
            'RESPONSABLE DE IVA (GRAVADO / BIMESTRAL O CUATRIMESTRAL)',
            1
        ),
        (
            'RESP_IVA',
            'RESPONSABLE DE IVA (CÓD. 48 RUT)',
            'NO_RESP_IVA',
            'NO RESPONSABLE DE IVA (ANTIGUO SIMPLIFICADO)',
            2
        ),
        (
            'RESP_IVA',
            'RESPONSABLE DE IVA (CÓD. 48 RUT)',
            'EXENTO_IVA_OPER_ESP',
            'EXENTO DE IVA POR OPERACIONES ESPECIALES',
            3
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'SI_PEQUEÑA_EMPRESA',
            'SÍ - PEQUEÑA EMPRESA (HASTA 204.653 UVT)',
            1
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'SI_MICROEMPRESA',
            'SÍ - MICROEMPRESA (HASTA 23.563 UVT)',
            2
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'SI_MEDIANA_EMPRESA',
            'SÍ - MEDIANA EMPRESA (HASTA 483.034 UVT)',
            3
        ),
        (
            'CLASIFICACIÓN_PYME',
            'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
            'NO_GRAN_EMPRESA',
            'NO - GRAN EMPRESA (MAYOR A 483.034 UVT)',
            4
        ),
        (
            'REG_MERCANTIL',
            'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
            'SI_MATRICULA_ACTIVA',
            'SÍ (MATRÍCULA MERCANTIL ACTIVA Y RENOVADA)',
            1
        ),
        (
            'REG_MERCANTIL',
            'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
            'NO_EXENTA_LEGAL',
            'NO (EXENTA CONFORME A RÉGIMEN LEGAL)',
            2
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
            'NO_DISTRIB_LOCAL',
            'NO (DISTRIBUCIÓN LOCAL / SERVICIOS NACIONALES)',
            1
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
            'SI_DISTRIB_EXCLUSIVO',
            'SÍ - DISTRIBUIDOR O REPRESENTANTE EXCLUSIVO IMPORTADO',
            2
        ),
        (
            'EXC_PRODUCTO',
            'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
            'SI_IMPORT_DIRECTO',
            'SÍ - IMPORTADOR DIRECTO NO EXCLUSIVO',
            3
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
            'NO_REG_ORD_COMUN',
            'NO (CONTRIBUYENTE RÉGIMEN ORDINARIO COMÚN)',
            1
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
            'SI_CALIF_DIAN',
            'SÍ - CALIFICADO POR RESOLUCIÓN DIAN VIGENTE',
            2
        ),
        (
            'CALIDAD_CONTRIB',
            'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
            'AUTORRET_RESOLUCION',
            'AUTORRETENEDOR POR RESOLUCIÓN',
            3
        ),
        (
            'TIPO_CONFORMACIÓN',
            'TIPO DE CONFORMACIÓN',
            'INDIVIDUAL_PRINCIPAL',
            'INDIVIDUAL / PRINCIPAL',
            1
        ),
        (
            'TIPO_CONFORMACIÓN',
            'TIPO DE CONFORMACIÓN',
            'CONJUNTA_MANCOMUNADA',
            'CONJUNTA / MANCOMUNADA',
            2
        ),
        (
            'TIPO_CONFORMACIÓN',
            'TIPO DE CONFORMACIÓN',
            'CONSORCIO_UT',
            'CONSORCIO / UNIÓN TEMPORAL',
            3
        )
)
SELECT e.codigo_tipo AS tipo_esperado,
    e.codigo_parametro,
    e.nombre_parametro,
    e.numero_orden AS orden_esperado,
    tp.codigo_abreviacion AS tipo_encontrado,
    a.codigo_abreviacion AS area_encontrada,
    p.numero_orden AS orden_encontrado,
    p.activo
FROM parametros_esperados e
    LEFT JOIN parametros.parametro p ON p.codigo_abreviacion = e.codigo_parametro
    AND p.nombre = e.nombre_parametro
    LEFT JOIN parametros.tipo_parametro tp ON tp.id = p.tipo_parametro_id
    LEFT JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
WHERE p.id IS NULL
    OR tp.codigo_abreviacion IS DISTINCT
FROM e.codigo_tipo
    OR tp.nombre IS DISTINCT
FROM e.nombre_tipo
    OR a.codigo_abreviacion IS DISTINCT
FROM 'IT'
    OR a.nombre IS DISTINCT
FROM 'Información Tributaria'
    OR p.numero_orden IS DISTINCT
FROM e.numero_orden
    OR p.activo IS DISTINCT
FROM TRUE
    OR p.parametro_padre_id IS NOT NULL;