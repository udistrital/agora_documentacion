-- =============================================================================
-- Script   : insert_snies.sql
-- Proposito: Inserción para el consumo de datos parametricos (SNIES: Area de conocimiento y 
-- nucleo básico de conocimiento) para el módulo de cotizaciones
-- Esquema  : parametros
-- Tablas   : area_tipo -> tipo_parametro -> parametro  (orden obligatorio por FK)
-- Motor    : PostgreSQL
-- Idempotente: SI. Se puede ejecutar varias veces sin duplicar registros.
-- Supuesto : las columnas "id" tienen secuencia/serial (autoincremental).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1. AREA_TIPO  (1 registro)
-- -----------------------------------------------------------------------------
INSERT INTO parametros.area_tipo (
        nombre,
        descripcion,
        codigo_abreviacion,
        activo,
        numero_orden,
        fecha_creacion,
        fecha_modificacion
    )
SELECT 'SNIES',
    'Clasificaciones sobre el Sistema Nacional de Información de la Educación Superior',
    'SNIES',
    TRUE,
    COALESCE(
        (
            SELECT MAX(numero_orden)
            FROM parametros.area_tipo
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.area_tipo
        WHERE nombre = 'SNIES'
    );

-- -----------------------------------------------------------------------------
-- 2. TIPO_PARAMETRO
-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- 2.1 AGRONOMÍA, VETERINARIA Y AFINES
-- -----------------------------------------------------------------------------
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
SELECT 'AGRONOMÍA, VETERINARIA Y AFINES',
    'Área SNIES enfocada en el estudio de la tierra, plantas y animales',
    'AGRO_VET_AFINES',
    TRUE,
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'AGRONOMÍA, VETERINARIA Y AFINES'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 2.2 BELLAS ARTES
-- -----------------------------------------------------------------------------
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
SELECT 'BELLAS ARTES',
    'Área SNIES enfocada en la creación y expresión artística',
    'BELLAS_ARTES',
    TRUE,
    2,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'BELLAS ARTES'
            AND t.area_tipo_id = a.id
    );
    
-- -----------------------------------------------------------------------------
-- 2.3 CIENCIAS DE LA EDUCACIÓN
-- -----------------------------------------------------------------------------
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
SELECT 'CIENCIAS DE LA EDUCACIÓN',
    'Área SNIES enfocada en el estudio sobre la enseñanza y el aprendizaje',
    'CIENCIAS_EDUCACIÓN',
    TRUE,
    3,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'CIENCIAS DE LA EDUCACIÓN'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 2.4 CIENCIAS DE LA SALUD
-- -----------------------------------------------------------------------------
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
SELECT 'CIENCIAS DE LA SALUD',
    'Área SNIES enfocada en el estudio y promoción de la salud y bienestar',
    'CIENCIAS_SALUD',
    TRUE,
    4,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'CIENCIAS DE LA SALUD'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 2.5 CIENCIAS SOCIALES Y HUMANAS
-- -----------------------------------------------------------------------------
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
SELECT 'CIENCIAS SOCIALES Y HUMANAS',
    'Área SNIES enfocada en el estudio del ser humano, la cultura y la historia',
    'CIENCIAS_HUMANAS',
    TRUE,
    5,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'CIENCIAS SOCIALES Y HUMANAS'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 2.6 ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES
-- -----------------------------------------------------------------------------
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
SELECT 'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES',
    'Área SNIES enfocada en el estudio de negocios, capital y gestión',
    'ECONO_ADMIN_AFINES',
    TRUE,
    6,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 2.7 INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES
-- -----------------------------------------------------------------------------
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
SELECT 'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES',
    'Área SNIES enfocada en el estudio, diseño y tecnología para la transformación del entorno',
    'ING_ARQ_AFINES',
    TRUE,
    7,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 2.8 MATEMÁTICAS Y CIENCIAS NATURALES
-- -----------------------------------------------------------------------------
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
SELECT 'MATEMÁTICAS Y CIENCIAS NATURALES',
    'Área SNIES enfocada en el estudio de los números, la materia y los seres vivos',
    'MAT_NATURALES',
    TRUE,
    8,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'SNIES'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'MATEMÁTICAS Y CIENCIAS NATURALES'
            AND t.area_tipo_id = a.id
    );

-- -----------------------------------------------------------------------------
-- 3. PARAMETRO
-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- 3.1 LISTADO: AGRONOMÍA, VETERINARIA Y AFINES
-- -----------------------------------------------------------------------------
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
        VALUES (
                'AGRONOMÍA',
                'AGRONOMÍA',
                'Núcleo de conocimiento relacionado con la producción agrícola y el estudio de los cultivos.',
                1
            ),
            (
                'MED_VETERINARIA',
                'MEDICINA VETERINARIA',
                'Núcleo de conocimiento relacionado con la salud y el bienestar animal.',
                2
            ),
            (
                'ZOOTECNIA',
                'ZOOTECNIA',
                'Núcleo de conocimiento relacionado con la producción y el manejo de animales.',
                3
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'AGRONOMÍA, VETERINARIA Y AFINES'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.2 LISTADO: BELLAS ARTES
-- -----------------------------------------------------------------------------
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
        VALUES (
                'ART_PLA_VIS_AFINES',
                'ARTES PLÁSTICAS, VISUALES Y AFINES',
                'Núcleo de conocimiento relacionado con las artes plásticas y visuales.',
                1
            ),
            (
                'ART_REP',
                'ARTES REPRESENTATIVAS',
                'Núcleo de conocimiento relacionado con las artes escénicas y representativas.',
                2
            ),
            (
                'DISEÑO',
                'DISEÑO',
                'Núcleo de conocimiento relacionado con el diseño y la creación de soluciones visuales.',
                3
            ),
            (
                'PUBLICIDAD_AFINES',
                'PUBLICIDAD Y AFINES',
                'Núcleo de conocimiento relacionado con la publicidad y la comunicación comercial.',
                4
            ),
            (
                'OTROS_ARTES',
                'OTROS PROGRAMAS ASOCIADOS A BELLAS ARTES',
                'Núcleo de conocimiento correspondiente a otros programas asociados a las bellas artes.',
                5
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'BELLAS ARTES'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.3 LISTADO: CIENCIAS DE LA EDUCACIÓN
-- -----------------------------------------------------------------------------
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
        VALUES (
                'EDUCACIÓN',
                'EDUCACIÓN',
                'Núcleo de conocimiento relacionado con la formación, la enseñanza y el aprendizaje.',
                1
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'CIENCIAS DE LA EDUCACIÓN'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.4 LISTADO: CIENCIAS DE LA SALUD
-- -----------------------------------------------------------------------------
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
        VALUES (
                'BACTERIOLOGÍA',
                'BACTERIOLOGÍA',
                'Núcleo de conocimiento relacionado con el estudio de microorganismos y agentes biológicos.',
                1
            ),
            (
                'ENFERMERÍA',
                'ENFERMERÍA',
                'Núcleo de conocimiento relacionado con el cuidado integral de la salud.',
                2
            ),
            (
                'INST_QUIRÚRGICA',
                'INSTRUMENTACIÓN QUIRÚRGICA',
                'Núcleo de conocimiento relacionado con el apoyo técnico en procedimientos quirúrgicos.',
                3
            ),
            (
                'MEDICINA',
                'MEDICINA',
                'Núcleo de conocimiento relacionado con la prevención, diagnóstico y tratamiento de enfermedades.',
                4
            ),
            (
                'NUTRICIÓN_DIETÉTICA',
                'NUTRICIÓN Y DIETÉTICA',
                'Núcleo de conocimiento relacionado con la nutrición y la alimentación humana.',
                5
            ),
            (
                'ODONTOLOGÍA',
                'ODONTOLOGÍA',
                'Núcleo de conocimiento relacionado con la salud bucal.',
                6
            ),
            (
                'OPTOMETRÍA',
                'OPTOMETRÍA',
                'Núcleo de conocimiento relacionado con la salud visual.',
                7
            ),
            (
                'SALUD_PÚBLICA',
                'SALUD PÚBLICA',
                'Núcleo de conocimiento relacionado con la protección y promoción de la salud colectiva.',
                8
            ),
            (
                'TERAPIAS',
                'TERAPIAS',
                'Núcleo de conocimiento relacionado con procesos terapéuticos y de rehabilitación.',
                9
            ),
            (
                'OTROS_PROG_SALUD',
                'OTROS PROGRAMAS DE CIENCIAS DE LA SALUD',
                'Núcleo de conocimiento correspondiente a otros programas de ciencias de la salud.',
                10
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'CIENCIAS DE LA SALUD'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.5 LISTADO: CIENCIAS SOCIALES Y HUMANAS
-- -----------------------------------------------------------------------------
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
        VALUES (
                'ANTROPOLOGÍA',
                'ANTROPOLOGÍA',
                'Estudio del ser humano y las culturas.',
                1
            ),
            (
                'ARTES_LIBERALES',
                'ARTES LIBERALES',
                'Formación interdisciplinaria en humanidades y ciencias.',
                2
            ),
            (
                'BIBLIOTECOLOGÍA',
                'BIBLIOTECOLOGÍA',
                'Organización y gestión de información documental.',
                3
            ),
            (
                'OTROS_SOC_HUMANAS',
                'OTROS DE CIENCIAS SOCIALES Y HUMANAS',
                'Otros programas de ciencias sociales y humanas.',
                4
            ),
            (
                'CIENCIA_POLÍTICA',
                'CIENCIA POLÍTICA',
                'Estudio de los sistemas políticos y las instituciones públicas.',
                5
            ),
            (
                'REL_INTER',
                'RELACIONES INTERNACIONALES',
                'Estudio de las relaciones entre Estados y actores internacionales.',
                6
            ),
            (
                'COM_SOCIAL',
                'COMUNICACIÓN SOCIAL',
                'Estudio de los procesos de comunicación en la sociedad.',
                7
            ),
            (
                'PERIODISMO_AFINES',
                'PERIODISMO Y AFINES',
                'Investigación y difusión de información periodística.',
                8
            ),
            (
                'DEPORTES',
                'DEPORTES',
                'Estudio y desarrollo de las prácticas deportivas.',
                9
            ),
            (
                'EDUCACIÓN_FÍSICA',
                'EDUCACIÓN FÍSICA',
                'Estudio del movimiento corporal y la actividad física.',
                10
            ),
            (
                'RECREACIÓN',
                'RECREACIÓN',
                'Actividades recreativas y aprovechamiento del tiempo libre.',
                11
            ),
            (
                'DERECHO_AFINES',
                'DERECHO Y AFINES',
                'Estudio de las normas jurídicas y los sistemas legales.',
                12
            ),
            (
                'FILOSOFÍA',
                'FILOSOFÍA',
                'Estudio del pensamiento crítico y la reflexión filosófica.',
                13
            ),
            (
                'TEOLOGÍA_AFINES',
                'TEOLOGÍA Y AFINES',
                'Estudio de la teología y las tradiciones religiosas.',
                14
            ),
            (
                'FORMACIÓN_MIL_POL',
                'FORMACIÓN RELACIONADA CON EL CAMPO MILITAR O POLICIAL',
                'Formación correspondiente al ámbito militar o policial.',
                15
            ),
            (
                'GEOGRAFÍA',
                'GEOGRAFÍA',
                'Estudio del territorio y las relaciones entre sociedad y espacio.',
                16
            ),
            (
                'HISTORIA',
                'HISTORIA',
                'Estudio de los procesos históricos.',
                17
            ),
            (
                'LENGUAS_MODERNAS',
                'LENGUAS MODERNAS',
                'Estudio y aprendizaje de lenguas modernas.',
                18
            ),
            (
                'LITERATURA',
                'LITERATURA',
                'Estudio y análisis de obras literarias.',
                19
            ),
            (
                'LINGÜÍSTICA_AFINES',
                'LINGÜÍSTICA Y AFINES',
                'Estudio científico del lenguaje.',
                20
            ),
            (
                'PSICOLOGÍA',
                'PSICOLOGÍA',
                'Estudio de los procesos mentales y el comportamiento humano.',
                21
            ),
            (
                'SOCIOLOGÍA',
                'SOCIOLOGÍA',
                'Estudio de las sociedades y las relaciones sociales.',
                22
            ),
            (
                'TRABAJO_SOCIAL_AFIN',
                'TRABAJO SOCIAL Y AFINES',
                'Intervención social y promoción del bienestar.',
                23
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'CIENCIAS SOCIALES Y HUMANAS'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.6 LISTADO: ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES
-- -----------------------------------------------------------------------------
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
        VALUES (
                'ADMINISTRACIÓN',
                'ADMINISTRACIÓN',
                'Núcleo de conocimiento relacionado con la gestión de organizaciones y recursos.',
                1
            ),
            (
                'CONTADURÍA_PÚBLICA',
                'CONTADURÍA PÚBLICA',
                'Núcleo de conocimiento relacionado con la información contable y financiera.',
                2
            ),
            (
                'ECONOMÍA',
                'ECONOMÍA',
                'Núcleo de conocimiento relacionado con la producción, distribución y consumo de recursos.',
                3
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'ECONOMÍA, ADMINISTRACIÓN, CONTADURÍA Y AFINES'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.7 LISTADO: INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES
-- -----------------------------------------------------------------------------
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
        VALUES (
                'ARQUITECTURA',
                'ARQUITECTURA',
                'Núcleo de conocimiento relacionado con el diseño y la planificación de espacios y edificaciones.',
                1
            ),
            (
                'ING_ADMIN_AFINES',
                'INGENIERÍA ADMINISTRATIVA Y AFINES',
                'Núcleo de conocimiento relacionado con la gestión de procesos y recursos de ingeniería.',
                2
            ),
            (
                'ING_AGRIC_FOREST',
                'INGENIERÍA AGRÍCOLA, FORESTAL Y AFINES',
                'Núcleo de conocimiento relacionado con la ingeniería aplicada a sistemas agrícolas y forestales.',
                3
            ),
            (
                'ING_AGROINDUSTRIAL',
                'INGENIERÍA AGROINDUSTRIAL',
                'Núcleo de conocimiento relacionado con la transformación industrial de productos agropecuarios.',
                4
            ),
            (
                'ALIMENTOS_AFINES',
                'ALIMENTOS Y AFINES',
                'Núcleo de conocimiento relacionado con la ciencia y tecnología de los alimentos.',
                5
            ),
            (
                'ING_AGRON_PECUARIA',
                'INGENIERÍA AGRONÓMICA, PECUARIA Y AFINES',
                'Núcleo de conocimiento relacionado con la ingeniería aplicada a la producción agrícola y pecuaria.',
                6
            ),
            (
                'ING_AMB_SANITARIA',
                'INGENIERÍA AMBIENTAL, SANITARIA Y AFINES',
                'Núcleo de conocimiento relacionado con la protección ambiental y el saneamiento.',
                7
            ),
            (
                'ING_BIOMÉDICA_AFINES',
                'INGENIERÍA BIOMÉDICA Y AFINES',
                'Núcleo de conocimiento relacionado con la ingeniería aplicada a la medicina y la biología.',
                8
            ),
            (
                'ING_CIVIL_AFINES',
                'INGENIERÍA CIVIL Y AFINES',
                'Núcleo de conocimiento relacionado con el diseño y construcción de infraestructura.',
                9
            ),
            (
                'ING_MINAS_METAL',
                'INGENIERÍA DE MINAS, METALURGIA Y AFINES',
                'Núcleo de conocimiento relacionado con la extracción y transformación de recursos minerales.',
                10
            ),
            (
                'ING_SIST_TELEM',
                'INGENIERÍA DE SISTEMAS, TELEMÁTICA Y AFINES',
                'Núcleo de conocimiento relacionado con sistemas informáticos, redes y telecomunicaciones.',
                11
            ),
            (
                'ING_ELÉCTRICA_AFINES',
                'INGENIERÍA ELÉCTRICA Y AFINES',
                'Núcleo de conocimiento relacionado con la generación y utilización de energía eléctrica.',
                12
            ),
            (
                'ING_ELECT_TELECOM',
                'INGENIERÍA ELECTRÓNICA, TELECOMUNICACIONES Y AFINES',
                'Núcleo de conocimiento relacionado con sistemas electrónicos y de telecomunicaciones.',
                13
            ),
            (
                'ING_INDUSTRIAL_AFIN',
                'INGENIERÍA INDUSTRIAL Y AFINES',
                'Núcleo de conocimiento relacionado con la optimización de procesos y sistemas productivos.',
                14
            ),
            (
                'ING_MECÁNICA_AFINES',
                'INGENIERÍA MECÁNICA Y AFINES',
                'Núcleo de conocimiento relacionado con el diseño y funcionamiento de sistemas mecánicos.',
                15
            ),
            (
                'ING_QUÍMICA_AFINES',
                'INGENIERÍA QUÍMICA Y AFINES',
                'Núcleo de conocimiento relacionado con procesos químicos y transformación de materiales.',
                16
            ),
            (
                'OTRAS_INGENIERÍAS',
                'OTRAS INGENIERÍAS',
                'Núcleo de conocimiento correspondiente a otros programas de ingeniería.',
                17
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'INGENIERÍA, ARQUITECTURA, URBANISMO Y AFINES'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- -----------------------------------------------------------------------------
-- 3.8 LISTADO: MATEMÁTICAS Y CIENCIAS NATURALES
-- -----------------------------------------------------------------------------
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
        VALUES (
                'BIOLOGÍA',
                'BIOLOGÍA',
                'Núcleo de conocimiento relacionado con el estudio de los seres vivos.',
                1
            ),
            (
                'MICROBIOLOGÍA_AFINES',
                'MICROBIOLOGÍA Y AFINES',
                'Núcleo de conocimiento relacionado con los microorganismos y sus procesos biológicos.',
                2
            ),
            (
                'FÍSICA_GEO_OTROS',
                'FÍSICA, GEOLOGÍA Y OTROS',
                'Núcleo de conocimiento relacionado con la materia, la energía y la estructura terrestre.',
                3
            ),
            (
                'PROG_CIENCIAS_NAT',
                'PROGRAMAS DE CIENCIAS NATURALES',
                'Núcleo de conocimiento correspondiente a programas generales de ciencias naturales.',
                4
            ),
            (
                'MATEMÁTICAS',
                'MATEMÁTICAS',
                'Núcleo de conocimiento relacionado con las estructuras, cantidades y relaciones matemáticas.',
                5
            ),
            (
                'ESTADÍSTICA_AFINES',
                'ESTADÍSTICA Y AFINES',
                'Núcleo de conocimiento relacionado con el análisis e interpretación de datos.',
                6
            ),
            (
                'QUÍMICA_AFINES',
                'QUÍMICA Y AFINES',
                'Núcleo de conocimiento relacionado con la composición y transformación de la materia.',
                7
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'MATEMÁTICAS Y CIENCIAS NATURALES'
            AND a.nombre = 'SNIES'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

COMMIT;
