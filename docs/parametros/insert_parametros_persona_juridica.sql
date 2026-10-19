BEGIN;
-- ============================================================
-- 1. INSERCIÓN DE TIPO_PARAMETRO ASOCIADO AL AREA DE IT
-- ============================================================
-- ============================================================
-- 1.1 CAMARAS DE COMERCIO
-- ============================================================
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
SELECT 'Cámaras de comercio',
    'Catálogo de cámaras de comercio.',
    'CAM_COM',
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'Información Tributaria'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.codigo_abreviacion = 'CAM_COM'
            AND t.area_tipo_id = a.id
    );

-- ============================================================
-- 1.2 RESPONSABILIDAD FISCAL
-- ============================================================
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
SELECT 'Responsabilidad fiscal',
    'Catálogo de responsabilidades fiscales.',
    'RESP_FIS',
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'Información Tributaria'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.codigo_abreviacion = 'RESP_FIS'
            AND t.area_tipo_id = a.id
    );

-- ============================================================
-- 1.3 TIPO DE REPRESENTACIÓN
-- ============================================================
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
SELECT 'Tipo de representación',
    'Catálogo de tipos de representación.',
    'TIP_REP',
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'Información Tributaria'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.codigo_abreviacion = 'TIP_REP'
            AND t.area_tipo_id = a.id
    );

-- ============================================================
-- 1.4 TIPO DE DECLARACIÓN
-- ============================================================
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
SELECT 'Tipo de declaración',
    'Catálogo de tipos de declaración.',
    'TIP_DEC',
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'Información Tributaria'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.codigo_abreviacion = 'TIP_DEC'
            AND t.area_tipo_id = a.id
    );

-- ============================================================
-- 1.5 TIPO DE DOCUMENTO
-- ============================================================
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
SELECT 'Tipo de documento',
    'Catálogo de tipos de documento a subir por el usuario en el sistema de proveedores Ágora.',
    'TIP_DOC',
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.nombre = 'Información Tributaria'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.codigo_abreviacion = 'TIP_DOC'
            AND t.area_tipo_id = a.id
    );

-- ============================================================
-- 1.6 TIPO DE PARÁMETRO GENERAL: INFORMACIÓN TRIBUTARIA COMPLEMENTARIA
-- ============================================================
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
SELECT 'Información tributaria complementaria',
    'Agrupa los parámetros relacionados con las obligaciones, condiciones y características tributarias de la persona o entidad.',
    'TRIBUTARIA_COMP',
    TRUE,
    COALESCE(
        (
            SELECT MAX(tp.numero_orden)
            FROM parametros.tipo_parametro tp
            WHERE tp.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.codigo_abreviacion = 'IT'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro tp
        WHERE tp.codigo_abreviacion = 'INFO_TRIBUTARIA_COMP'
            AND tp.area_tipo_id = a.id
    );


-- ============================================================
-- 2. INSERCIÓN DE PARAMETRO POR CADA TIPO DE PARÁMETRO
-- ============================================================

-- ============================================================
-- 2.1 LISTADO DE CÁMARAS DE COMERCIO
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
    ROW_NUMBER() OVER (
        ORDER BY v.nombre
    ),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    tp.id,
    NULL
FROM (
        VALUES (
                'ABURRA_SUR',
                'Aburrá sur',
                'Camara de comercio de Aburrá sur'
            ),
            (
                'AGUACHICA',
                'Aguachica',
                'Camara de comercio de Aguachica'
            ),
            (
                'AMAZONAS',
                'Amazonas',
                'Camara de comercio de Amazonas'
            ),
            (
                'ARAUCA',
                'Arauca',
                'Camara de comercio de Arauca'
            ),
            (
                'ARMENIA_QUINDIO',
                'Armenia y del Quindío',
                'Camara de comercio de Armenia y del Quindío'
            ),
            (
                'BARRANCABERMEJA',
                'Barrancabermeja',
                'Camara de comercio de Barrancabermeja'
            ),
            (
                'BARRANQUILLA',
                'Barranquilla',
                'Camara de comercio de Barranquilla'
            ),
            (
                'BOGOTA',
                'Bogotá',
                'Camara de comercio de Bogotá'
            ),
            (
                'BUCARAMANGA',
                'Bucaramanga',
                'Camara de comercio de Bucaramanga'
            ),
            (
                'BUENAVENTURA',
                'Buenaventura',
                'Camara de comercio de Buenaventura'
            ),
            ('BUGA', 'Buga', 'Camara de comercio de Buga'),
            ('CALI', 'Cali', 'Camara de comercio de Cali'),
            (
                'CARTAGENA',
                'Cartagena',
                'Camara de comercio de Cartagena'
            ),
            (
                'CARTAGO',
                'Cartago',
                'Camara de comercio de Cartago'
            ),
            (
                'CASANARE',
                'Casanare',
                'Camara de comercio de Casanare'
            ),
            ('CAUCA', 'Cauca', 'Camara de comercio de Cauca'),
            ('CHOCO', 'Chocó', 'Camara de comercio de Chocó'),
            (
                'CHINCHINA',
                'Chinchiná',
                'Camara de comercio de Chinchiná'
            ),
            (
                'DOSQUEBRADAS',
                'Dosquebradas',
                'Camara de comercio de Dosquebradas'
            ),
            (
                'DUITAMA',
                'Duitama',
                'Camara de comercio de Duitama'
            ),
            (
                'FACATATIVA_NORDESTE_CUNDINAMARCA',
                'Facatativá y Nordeste de Cundinamarca',
                'Camara de comercio de Facatativá y Nordeste de Cundinamarca'
            ),
            (
                'FLORENCIA_CAQUETA',
                'Florencia para el Caquetá',
                'Camara de comercio de Florencia para el Caquetá'
            ),
            (
                'GIRARDOT_ALTO_MAGDALENA_TEQUENDAMA',
                'Girardot, Alto Magdalena y Tequendama',
                'Camara de comercio de Girardot, Alto Magdalena y Tequendama'
            ),
            (
                'HONDA_GUADUAS_NORTE_TOLIMA',
                'Honda, Guaduas y Norte del Tolima',
                'Camara de comercio de Honda, Guaduas y Norte del Tolima'
            ),
            ('HUILA', 'Huila', 'Camara de comercio de Huila'),
            (
                'IBAGUE',
                'Ibagué',
                'Camara de comercio de Ibagué'
            ),
            (
                'IPIALES',
                'Ipiales',
                'Camara de comercio de Ipiales'
            ),
            (
                'LA_DORADA_PUERTO_BOYACA_PUERTO_SALGAR_ORIENTE_CALDAS',
                'La Dorada, Puerto Boyacá, Puerto Salgar y Oriente de Caldas',
                'Camara de comercio de La Dorada, Puerto Boyacá, Puerto Salgar y Oriente de Caldas'
            ),
            (
                'LA_GUAJIRA',
                'La Guajira',
                'Camara de comercio de La Guajira'
            ),
            (
                'MAGANGUE',
                'Magangué',
                'Camara de comercio de Magangué'
            ),
            (
                'MAGDALENA_MEDIO_NORDESTE_ANTIOQUENO',
                'Magdalena Medio y Nordeste Antioqueño',
                'Camara de comercio de Magdalena Medio y Nordeste Antioqueño'
            ),
            (
                'MANIZALES_CALDAS',
                'Manizales por Caldas',
                'Camara de comercio de Manizales por Caldas'
            ),
            (
                'MEDELLIN_ANTIOQUIA',
                'Medellín para Antioquia',
                'Camara de comercio de Medellín para Antioquia'
            ),
            (
                'MONTERIA',
                'Monteria',
                'Camara de comercio de Monteria'
            ),
            ('OCANA', 'Ocaña', 'Camara de comercio de Ocaña'),
            (
                'PALMIRA',
                'Palmira',
                'Camara de comercio de Palmira'
            ),
            (
                'PAMPLONA',
                'Pamplona',
                'Camara de comercio de Pamplona'
            ),
            ('PASTO', 'Pasto', 'Camara de comercio de Pasto'),
            (
                'PIEDEMONTE_ARAUCANO',
                'Piedemonte Araucano',
                'Camara de comercio de Piedemonte Araucano'
            ),
            (
                'PUTUMAYO',
                'Putumayo',
                'Camara de comercio de Putumayo'
            ),
            (
                'SAN_ANDRES_PROVIDENCIA_SANTA_CATALINA',
                'San Andrés, Providencia y Santa Catalina',
                'Camara de comercio de San Andrés, Providencia y Santa Catalina'
            ),
            (
                'SAN_JOSE',
                'San José',
                'Camara de comercio de San José'
            ),
            (
                'SANTA_MARTA_MAGDALENA',
                'Santa Marta para el Magdalena',
                'Camara de comercio de Santa Marta para el Magdalena'
            ),
            (
                'SANTA_ROSA_DE_CABAL',
                'Santa Rosa de Cabal',
                'Camara de comercio de Santa Rosa de Cabal'
            ),
            (
                'SEVILLA',
                'Sevilla',
                'Camara de comercio de Sevilla'
            ),
            (
                'SINCELEJO',
                'Sincelejo',
                'Camara de comercio de Sincelejo'
            ),
            (
                'SOACHA',
                'Soacha',
                'Camara de comercio de Soacha'
            ),
            (
                'SOGAMOSO',
                'Sogamoso',
                'Camara de comercio de Sogamoso'
            ),
            ('TULUA', 'Tuluá', 'Camara de comercio de Tuluá'),
            (
                'TUMACO',
                'Tumaco',
                'Camara de comercio de Tumaco'
            ),
            ('TUNJA', 'Tunja', 'Camara de comercio de Tunja'),
            ('URABA', 'Urabá', 'Camara de comercio de Urabá'),
            (
                'VALLEDUPAR_VALLE_RIO_CESAR',
                'Valledupar para el Valle del Río Cesar',
                'Camara de comercio de Valledupar para el Valle del Río Cesar'
            ),
            (
                'VILLAVICENCIO',
                'Villavicencio',
                'Camara de comercio de Villavicencio'
            )
    ) AS v(codigo_abreviacion, nombre, descripcion)
    CROSS JOIN (
        SELECT tp.id
        FROM parametros.tipo_parametro tp
            INNER JOIN parametros.area_tipo area ON area.id = tp.area_tipo_id
        WHERE tp.nombre = 'Cámaras de comercio'
            AND area.nombre = 'Información Tributaria'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- ============================================================
-- 2.2 LISTADO DE RESPONSABILIDAD FISCAL
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
        VALUES (
                '01',
                'Aporte especial para la administración de justicia.',
                'Aporte especial para la administración de justicia.',
                1
            ),
            (
                '02',
                'Gravamen a los Movimientos Financieros (GMF).',
                'Gravamen a los Movimientos Financieros (GMF).',
                2
            ),
            (
                '03',
                'Impuesto al Patrimonio.',
                'Impuesto al Patrimonio.',
                3
            ),
            (
                '04',
                'Impuesto sobre la Renta y Complementarios — Régimen Tributario Especial.',
                'Impuesto sobre la Renta y Complementarios — Régimen Tributario Especial.',
                4
            ),
            (
                '05',
                'Impuesto sobre la Renta y Complementarios — Régimen Ordinario.',
                'Impuesto sobre la Renta y Complementarios — Régimen Ordinario.',
                5
            ),
            (
                '06',
                'Ingresos y patrimonio.',
                'Ingresos y patrimonio.',
                6
            ),
            (
                '07',
                'Retención en la Fuente a título de renta.',
                'Retención en la Fuente a título de renta.',
                7
            ),
            (
                '08',
                'Retención Timbre Nacional.',
                'Retención Timbre Nacional.',
                8
            ),
            (
                '09',
                'Retención en la Fuente en el Impuesto sobre las Ventas.',
                'Retención en la Fuente en el Impuesto sobre las Ventas.',
                9
            ),
            (
                '10',
                'Obligado aduanero.',
                'Obligado aduanero.',
                10
            ),
            (
                '13',
                'Gran contribuyente.',
                'Gran contribuyente.',
                11
            ),
            (
                '14',
                'Informante de exógena.',
                'Informante de exógena.',
                12
            ),
            ('15', 'Autorretenedor.', 'Autorretenedor.', 13),
            (
                '16',
                'Obligación de facturar por ingresos de bienes y/o servicios excluidos.',
                'Obligación de facturar por ingresos de bienes y/o servicios excluidos.',
                14
            ),
            (
                '17',
                'Profesionales de compra y venta de divisas.',
                'Profesionales de compra y venta de divisas.',
                15
            ),
            (
                '18',
                'Precios de transferencia.',
                'Precios de transferencia.',
                16
            ),
            (
                '19',
                'Productor y/o exportador de bienes exentos.',
                'Productor y/o exportador de bienes exentos.',
                17
            ),
            ('20', 'Obtención NIT.', 'Obtención NIT.', 18),
            (
                '21',
                'Declarar el ingreso o salida del país de divisas o moneda legal colombiana.',
                'Declarar el ingreso o salida del país de divisas o moneda legal colombiana.',
                19
            ),
            (
                '22',
                'Obligado a cumplir deberes formales a nombre de terceros.',
                'Obligado a cumplir deberes formales a nombre de terceros.',
                20
            ),
            (
                '23',
                'Agente de retención en el impuesto sobre las ventas.',
                'Agente de retención en el impuesto sobre las ventas.',
                21
            ),
            (
                '26',
                'Declaración informativa individual de precios de transferencia.',
                'Declaración informativa individual de precios de transferencia.',
                22
            ),
            (
                '32',
                'Impuesto Nacional a la Gasolina y al ACPM.',
                'Impuesto Nacional a la Gasolina y al ACPM.',
                23
            ),
            (
                '33',
                'Impuesto Nacional al Consumo.',
                'Impuesto Nacional al Consumo.',
                24
            ),
            (
                '36',
                'Establecimiento permanente.',
                'Establecimiento permanente.',
                25
            ),
            (
                '39',
                'Proveedor de Servicios Tecnológicos (PST).',
                'Proveedor de Servicios Tecnológicos (PST).',
                26
            ),
            (
                '41',
                'Declaración anual de activos en el exterior.',
                'Declaración anual de activos en el exterior.',
                27
            ),
            (
                '42',
                'Obligado a llevar contabilidad.',
                'Obligado a llevar contabilidad.',
                28
            ),
            (
                '45',
                'Autorretenedor de rendimientos financieros.',
                'Autorretenedor de rendimientos financieros.',
                29
            ),
            (
                '46',
                'IVA prestadores de servicios desde el exterior.',
                'IVA prestadores de servicios desde el exterior.',
                30
            ),
            (
                '47',
                'Régimen Simple de Tributación (SIMPLE).',
                'Régimen Simple de Tributación (SIMPLE).',
                31
            ),
            (
                '48',
                'Impuesto sobre las ventas (IVA).',
                'Impuesto sobre las ventas (IVA).',
                32
            ),
            (
                '49',
                'No responsable de IVA.',
                'No responsable de IVA.',
                33
            ),
            (
                '50',
                'No responsable de consumo de restaurantes y bares.',
                'No responsable de consumo de restaurantes y bares.',
                34
            ),
            (
                '52',
                'Facturador electrónico.',
                'Facturador electrónico.',
                35
            ),
            (
                '53',
                'Persona jurídica no responsable de IVA.',
                'Persona jurídica no responsable de IVA.',
                36
            ),
            (
                '54',
                'Intercambio automático de información CRS.',
                'Intercambio automático de información CRS.',
                37
            ),
            (
                '55',
                'Informante de beneficiarios finales.',
                'Informante de beneficiarios finales.',
                38
            ),
            (
                '56',
                'Impuesto al carbono.',
                'Impuesto al carbono.',
                39
            ),
            (
                '58',
                'Intercambio automático de información FATCA.',
                'Intercambio automático de información FATCA.',
                40
            ),
            (
                '59',
                'Autorretención especial renta.',
                'Autorretención especial renta.',
                41
            ),
            (
                '60',
                'Autorretención por concepto de intereses y rendimientos financieros de entidades vigiladas por la Superintendencia Financiera.',
                'Autorretención por concepto de intereses y rendimientos financieros de entidades vigiladas por la Superintendencia Financiera.',
                42
            ),
            (
                '61',
                'Autorretención por concepto de comisiones de entidades vigiladas por la Superintendencia Financiera.',
                'Autorretención por concepto de comisiones de entidades vigiladas por la Superintendencia Financiera.',
                43
            ),
            (
                '62',
                'Impuesto nacional sobre productos plásticos de un solo uso.',
                'Impuesto nacional sobre productos plásticos de un solo uso.',
                44
            ),
            (
                '63',
                'Impuesto a las bebidas ultraprocesadas azucaradas.',
                'Impuesto a las bebidas ultraprocesadas azucaradas.',
                45
            ),
            (
                '64',
                'Impuesto a los productos comestibles ultraprocesados.',
                'Impuesto a los productos comestibles ultraprocesados.',
                46
            ),
            (
                '65',
                'Renta por presencia económica significativa en Colombia (PES).',
                'Renta por presencia económica significativa en Colombia (PES).',
                47
            ),
            (
                '66',
                'Intercambio automático de información DPI.',
                'Intercambio automático de información DPI.',
                48
            ),
            (
                '67',
                'Intercambio automático de información CARF.',
                'Intercambio automático de información CARF.',
                49
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT tp.id
        FROM parametros.tipo_parametro tp
            INNER JOIN parametros.area_tipo area ON area.id = tp.area_tipo_id
        WHERE tp.nombre = 'Responsabilidad fiscal'
            AND area.nombre = 'Información Tributaria'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- ============================================================
-- 2.3 LISTADO DE REPRESENTACIÓN
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
        VALUES (
                'REP_PRINC',
                'Representante legal principal',
                'Rol de Representante legal principal',
                1
            ),
            (
                'REP_SUPL',
                'Representante legal suplente',
                'Rol de Representante legal suplente',
                2
            ),
            (
                'SUPL_ORD',
                'Primer suplente / segundo suplente',
                'Rol de Primer suplente / segundo suplente',
                3
            ),
            (
                'REP_CONJ',
                'Representante legal conjunto o mancomunado',
                'Rol de Representante legal conjunto o mancomunado',
                4
            ),
            (
                'REP_SUC',
                'Representante legal de sucursal',
                'Rol de Representante legal de sucursal',
                5
            ),
            (
                'REP_EXT',
                'Representante legal de una sociedad extranjera',
                'Rol de Representante legal de una sociedad extranjera',
                6
            ),
            ('LIQ', 'Liquidador', 'Rol de Liquidador', 7),
            (
                'APOD_GEN',
                'Apoderado general',
                'Rol de Apoderado general',
                8
            ),
            (
                'APOD_ESP',
                'Apoderado especial',
                'Rol de Apoderado especial',
                9
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT tp.id
        FROM parametros.tipo_parametro tp
            INNER JOIN parametros.area_tipo area ON area.id = tp.area_tipo_id
        WHERE tp.nombre = 'Tipo de representación'
            AND area.nombre = 'Información Tributaria'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- ============================================================
-- 2.4 LISTADO TIPO DE DECLARACIÓN
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
        VALUES (
                'CONSENTIMIENTO_REGISTRO_VERIFICACION',
                'Consentimiento expreso de registro y verificación',
                'Consentimiento expreso de registro y verificación',
                1
            ),
            (
                'DECLARACION_INEXISTENCIA_INHABILIDADES',
                'Declaración juramentada de inexistencia de inhabilidades, incompatibilidades y conflicto de intereses',
                'Declaración juramentada de inexistencia de inhabilidades, incompatibilidades y conflicto de intereses',
                2
            ),
            (
                'DECLARACION_VERACIDAD_ACTUALIZACION',
                'Declaración de veracidad, actualización y completitud de la información',
                'Declaración de veracidad, actualización y completitud de la información',
                3
            ),
            (
                'DECLARACION_NO_INHABILIDADES_SOCIEDAD',
                'Declaración de no inhabilidades o incompatibilidades para la sociedad y sus representantes',
                'Declaración de no inhabilidades o incompatibilidades para la sociedad y sus representantes',
                4
            ),
            (
                'DECLARACION_AUTORIZACION_SAGRILAFT',
                'Declaración de autorización para validaciones institucionales de cumplimiento y prevención de riesgos (SAGRILAFT)',
                'Declaración de autorización para validaciones institucionales de cumplimiento y prevención de riesgos (SAGRILAFT)',
                5
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT tp.id
        FROM parametros.tipo_parametro tp
            INNER JOIN parametros.area_tipo area ON area.id = tp.area_tipo_id
        WHERE tp.nombre = 'Tipo de declaración'
            AND area.nombre = 'Información Tributaria'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- ============================================================
-- 2.5 LISTADO TIPO DE DOCUMENTO
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
        VALUES ('RUT', 'RUT', 'Documento RUT', 1),
            (
                'CERTIFICADO_EXISTENCIA',
                'Certificado de existencia',
                'Documento de Certificado de existencia',
                2
            ),
            (
                'CEDULA_REPRESENTANTE',
                'Cédula del representante',
                'Documento, Cédula del representante',
                3
            ),
            ('RUP', 'RUP', 'Documento RUP', 4),
            (
                'CERTIFICACION_APORTES',
                'Certificación de aportes',
                'Documento, Certificación de aportes',
                5
            )
    ) AS v(
        codigo_abreviacion,
        nombre,
        descripcion,
        numero_orden
    )
    CROSS JOIN (
        SELECT tp.id
        FROM parametros.tipo_parametro tp
            INNER JOIN parametros.area_tipo area ON area.id = tp.area_tipo_id
        WHERE tp.nombre = 'Tipo de documento'
            AND area.nombre = 'Información Tributaria'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

-- ============================================================
-- 2.6 PREGUNTAS TIPO DE PARÁMETRO GENERAL: INFORMACIÓN TRIBUTARIA COMPLEMENTARIA
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
SELECT
    v.nombre,
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
        (
            'Cuenta con beneficiarios finales reportados en el RUB',
            'Define si cuenta con beneficiarios finales reportados en el RUB.',
            'BEN_FIN_RUB',
            1
        ),
        (
            'Cotiza en bolsa de valores de Colombia (BVC)',
            'Define si cotiza en bolsa de valores de Colombia (BVC).',
            'COTIZA_BVC',
            2
        ),
        (
            'Obligación a contar con revisor fiscal',
            'Define si tiene la obligación de contar con revisor fiscal.',
            'REV_FISCAL',
            3
        ),
        (
            'Gran contribuyente DIAN',
            'Define si tiene la condición de gran contribuyente DIAN.',
            'CONTRIBUYENTE_DIAN',
            4
        ),
        (
            'Autorretenedor en renta',
            'Define si tiene la condición de autorretenedor en renta.',
            'AUTO_RENTA',
            5
        ),
        (
            'Aplica exención ICA Bogotá',
            'Define si aplica la exención del ICA en Bogotá.',
            'ICA_BOG',
            6
        ),
        (
            'RUP vigente',
            'Define si cuenta con un RUP vigente.',
            'RUP_VIGENTE',
            7
        ),
        (
            'Obligación de factura electrónica',
            'Define si tiene la obligación de facturar electrónicamente.',
            'FAC_ELEC',
            8
        ),
        (
            'Operaciones en moneda extranjera',
            'Define si realiza operaciones en moneda extranjera.',
            'MONEDA_EXT',
            9
        )
) AS v(nombre, descripcion, codigo_abreviacion, numero_orden)
CROSS JOIN (
    SELECT tp.id
    FROM parametros.tipo_parametro tp
    INNER JOIN parametros.area_tipo area
        ON area.id = tp.area_tipo_id
    WHERE tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
      AND area.codigo_abreviacion = 'IT'
) AS tp
WHERE NOT EXISTS (
    SELECT 1
    FROM parametros.parametro existente
    WHERE existente.tipo_parametro_id = tp.id
      AND existente.codigo_abreviacion = v.codigo_abreviacion
);

COMMIT;
