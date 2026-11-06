BEGIN;

-- ============================================================
-- 1. INSERCIÓN DE TIPO_PARAMETRO
-- ÁREA: INFORMACIÓN TRIBUTARIA (IT)
-- ============================================================

-- Se utiliza MAX(numero_orden) + 1 para continuar la
-- numeración existente del área, sin reiniciar el consecutivo.

WITH nuevos_tipos AS (
    SELECT *
    FROM (
            VALUES (
                    'RÉGIMEN CONTRIBUTIVO',
                    'Agrupación de regímenes tributarios.',
                    'REG_CONT'
                ),
                (
                    'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
                    'Clasificación de responsabilidad frente al ICA.',
                    'RESP_ICA'
                ),
                (
                    'RESPONSABLE DE IVA (CÓD. 48 RUT)',
                    'Clasificación de responsabilidad frente al IVA.',
                    'RESP_IVA'
                ),
                (
                    'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
                    'Clasificación empresarial según su tamaño.',
                    'CLASIFICACIÓN_PYME'
                ),
                (
                    'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
                    'Estado de la matrícula mercantil empresarial.',
                    'REG_MERCANTIL'
                ),
                (
                    'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
                    'Condición de exclusividad en productos importados.',
                    'EXC_PRODUCTO'
                ),
                (
                    'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
                    'Clasificación tributaria de grandes contribuyentes.',
                    'CALIDAD_CONTRIB'
                ),
                (
                    'TIPO DE CONFORMACIÓN',
                    'Modalidad de conformación o representación empresarial.',
                    'TIPO_CONFORMACIÓN'
                )
        ) AS v(nombre, descripcion, codigo_abreviacion)
)
INSERT INTO parametros.tipo_parametro (
        nombre,
        descripcion,
        codigo_abreviacion,
        activo,
        numero_orden,
        fecha_creacion,
        fecha_modificacion,
        area_tipo_id
    )
SELECT v.nombre,
    v.descripcion,
    v.codigo_abreviacion,
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + ROW_NUMBER() OVER (
        ORDER BY v.orden
    ),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM (
        SELECT n.*,
            ROW_NUMBER() OVER (
                ORDER BY n.codigo_abreviacion
            ) AS orden
        FROM nuevos_tipos n
    ) v
    CROSS JOIN parametros.area_tipo a
WHERE a.codigo_abreviacion = 'IT'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro existente
        WHERE existente.area_tipo_id = a.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- ============================================================
-- 2. INSERCIÓN DE PARAMETROS
-- CATÁLOGOS ASOCIADOS A CADA TIPO_PARAMETRO
-- ============================================================
INSERT INTO parametros.parametro (
        nombre,
        descripcion,
        codigo_abreviacion,
        activo,
        numero_orden,
        fecha_creacion,
        fecha_modificacion,
        tipo_parametro_id,
        parametro_padre_id
    )
SELECT v.nombre,
    v.descripcion,
    v.codigo_abreviacion,
    TRUE,
    v.numero_orden,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    tp.id,
    NULL
FROM (
        VALUES 

            -- --------------------------------------------------------
            -- 2.1 RÉGIMEN CONTRIBUTIVO
            -- --------------------------------------------------------
            (
                'REG_CONT',
                'COMÚN / ORDINARIO (IMPUESTO SOBRE LA RENTA)',
                'Clasificación tributaria ordinaria.',
                'COMUN_ORDINARIO',
                1
            ),
            (
                'REG_CONT',
                'RÉGIMEN SIMPLE DE TRIBUTACIÓN (RST)',
                'Régimen simple de tributación.',
                'REGIMEN_SIMPLE_RST',
                2
            ),
            (
                'REG_CONT',
                'RÉGIMEN TRIBUTARIO ESPECIAL (ESAL / FUNDACIONES)',
                'Régimen especial para entidades sin ánimo de lucro.',
                'REGIMEN_TRIB_ESP',
                3
            ),
            (
                'REG_CONT',
                'ENTIDAD DE DERECHO PÚBLICO / OFICIAL',
                'Clasificación de entidades públicas u oficiales.',
                'ENTIDAD_DER_PUBLICO',
                4
            ),

            -- --------------------------------------------------------
            -- 2.2 RESPONSABLE DE ICA
            -- --------------------------------------------------------
            (
                'RESP_ICA',
                'RÉGIMEN COMÚN (BIMESTRAL SHD)',
                'Responsabilidad de ICA bajo régimen común.',
                'REGIMEN_COMUN_BIM',
                1
            ),
            (
                'RESP_ICA',
                'RÉGIMEN SIMPLIFICADO / PREFERENCIAL',
                'Responsabilidad de ICA bajo régimen preferencial.',
                'REGIMEN_SIMPLIFICADO',
                2
            ),
            (
                'RESP_ICA',
                'NO SUJETO / EXENTO DE ICA DISTRITAL',
                'Condición de no sujeción o exención de ICA.',
                'NO_SUJETO_EXENTO_ICA',
                3
            ),
            (
                'RESP_ICA',
                'RÉGIMEN ESPECIAL CONSORCIOS / UT',
                'Responsabilidad de ICA para consorcios y UT.',
                'REGIMEN_ESP_CONS',
                4
            ),

            -- --------------------------------------------------------
            -- 2.3 RESPONSABLE DE IVA
            -- --------------------------------------------------------
            (
                'RESP_IVA',
                'RESPONSABLE DE IVA (GRAVADO / BIMESTRAL O CUATRIMESTRAL)',
                'Responsabilidad tributaria frente al IVA.',
                'RESP_IVA_GRAVADO',
                1
            ),
            (
                'RESP_IVA',
                'NO RESPONSABLE DE IVA (ANTIGUO SIMPLIFICADO)',
                'Condición de no responsabilidad frente al IVA.',
                'NO_RESP_IVA',
                2
            ),
            (
                'RESP_IVA',
                'EXENTO DE IVA POR OPERACIONES ESPECIALES',
                'Condición de exención de IVA en operaciones especiales.',
                'EXENTO_IVA_OPER_ESP',
                3
            ),

            -- --------------------------------------------------------
            -- 2.4 CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL
            -- --------------------------------------------------------
            (
                'CLASIFICACIÓN_PYME',
                'SÍ - PEQUEÑA EMPRESA (HASTA 204.653 UVT)',
                'Clasificación empresarial como pequeña empresa.',
                'SI_PEQUEÑA_EMPRESA',
                1
            ),
            (
                'CLASIFICACIÓN_PYME',
                'SÍ - MICROEMPRESA (HASTA 23.563 UVT)',
                'Clasificación empresarial como microempresa.',
                'SI_MICROEMPRESA',
                2
            ),
            (
                'CLASIFICACIÓN_PYME',
                'SÍ - MEDIANA EMPRESA (HASTA 483.034 UVT)',
                'Clasificación empresarial como mediana empresa.',
                'SI_MEDIANA_EMPRESA',
                3
            ),
            (
                'CLASIFICACIÓN_PYME',
                'NO - GRAN EMPRESA (MAYOR A 483.034 UVT)',
                'Clasificación empresarial como gran empresa.',
                'NO_GRAN_EMPRESA',
                4
            ),

            -- --------------------------------------------------------
            -- 2.5 REGISTRO MERCANTIL / MATRÍCULA ACTIVA
            -- --------------------------------------------------------
            (
                'REG_MERCANTIL',
                'SÍ (MATRÍCULA MERCANTIL ACTIVA Y RENOVADA)',
                'Confirma matrícula mercantil activa y renovada.',
                'SI_MATRICULA_ACTIVA',
                1
            ),
            (
                'REG_MERCANTIL',
                'NO (EXENTA CONFORME A RÉGIMEN LEGAL)',
                'Exención de matrícula conforme al régimen legal.',
                'NO_EXENTA_LEGAL',
                2
            ),

            -- --------------------------------------------------------
            -- 2.6 EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN
            -- --------------------------------------------------------
            (
                'EXC_PRODUCTO',
                'NO (DISTRIBUCIÓN LOCAL / SERVICIOS NACIONALES)',
                'Distribución local o prestación de servicios nacionales.',
                'NO_DISTRIB_LOCAL',
                1
            ),
            (
                'EXC_PRODUCTO',
                'SÍ - DISTRIBUIDOR O REPRESENTANTE EXCLUSIVO IMPORTADO',
                'Representación o distribución exclusiva de importados.',
                'SI_DISTRIB_EXCLUSIVO',
                2
            ),
            (
                'EXC_PRODUCTO',
                'SÍ - IMPORTADOR DIRECTO NO EXCLUSIVO',
                'Importación directa sin exclusividad comercial.',
                'SI_IMPORT_DIRECTO',
                3
            ),

            -- --------------------------------------------------------
            -- 2.7 CALIDAD DE GRAN CONTRIBUYENTE (DIAN)
            -- --------------------------------------------------------
            (
                'CALIDAD_CONTRIB',
                'NO (CONTRIBUYENTE RÉGIMEN ORDINARIO COMÚN)',
                'Condición de contribuyente ordinario no calificado.',
                'NO_REG_ORD_COMUN',
                1
            ),
            (
                'CALIDAD_CONTRIB',
                'SÍ - CALIFICADO POR RESOLUCIÓN DIAN VIGENTE',
                'Calificación de gran contribuyente por resolución DIAN.',
                'SI_CALIF_DIAN',
                2
            ),
            (
                'CALIDAD_CONTRIB',
                'AUTORRETENEDOR POR RESOLUCIÓN',
                'Condición de autorretenedor mediante resolución.',
                'AUTORRET_RESOLUCION',
                3
            ),

            -- --------------------------------------------------------
            -- 2.8 TIPO DE CONFORMACIÓN
            -- --------------------------------------------------------
            (
                'TIPO_CONFORMACIÓN',
                'INDIVIDUAL / PRINCIPAL',
                'Conformación individual o principal.',
                'INDIVIDUAL_PRINCIPAL',
                1
            ),
            (
                'TIPO_CONFORMACIÓN',
                'CONJUNTA / MANCOMUNADA',
                'Conformación conjunta o mancomunada.',
                'CONJUNTA_MANCOMUNADA',
                2
            ),
            (
                'TIPO_CONFORMACIÓN',
                'CONSORCIO / UNIÓN TEMPORAL',
                'Conformación mediante consorcio o unión temporal.',
                'CONSORCIO_UT',
                3
            )
    ) AS v(
        codigo_tipo_parametro,
        nombre,
        descripcion,
        codigo_abreviacion,
        numero_orden
    )
    INNER JOIN parametros.tipo_parametro tp ON tp.codigo_abreviacion = v.codigo_tipo_parametro
    INNER JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );
    
COMMIT;