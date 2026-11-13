BEGIN;

-- ============================================================
-- 1. INSERCIÓN DE TIPO_PARAMETRO
-- ÁREA: INFORMACIÓN TRIBUTARIA (IT)
-- ============================================================
WITH nuevos_tipos (
    nombre,
    descripcion,
    codigo_abreviacion
) AS (
    VALUES (
            'RÉGIMEN CONTRIBUTIVO',
            'Agrupación de regímenes tributarios.',
            'REG_CONT'
        ),
        (
            'TIPO DE CONFORMACIÓN',
            'Modalidad de conformación o representación empresarial.',
            'TIPO_CONFORMACIÓN'
        ),
        (
            'MEDIOS DE COMUNICACIÓN',
            'Canales por los cuales es posible contactar a un proveedor.',
            'MED_COMUNICACIÓN'
        ),
        (
            'ESTADOS',
            'Estado del usuario en el sistema.',
            'ESTADOS'
        )
),
tipos_ordenados AS (
    SELECT n.*,
        ROW_NUMBER() OVER (
            ORDER BY n.codigo_abreviacion
        ) AS orden
    FROM nuevos_tipos n
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
    ) + v.orden,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM tipos_ordenados v
    CROSS JOIN parametros.area_tipo a
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
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
DELETE FROM parametros.parametro p USING (
        VALUES (
                'INDIVIDUAL_PRINCIPAL',
                'INDIVIDUAL / PRINCIPAL',
                'Conformación individual o principal.'
            ),
            (
                'CONJUNTA_MANCOMUNADA',
                'CONJUNTA / MANCOMUNADA',
                'Conformación conjunta o mancomunada.'
            ),
            (
                'CONSORCIO_UT',
                'CONSORCIO / UNIÓN TEMPORAL',
                'Conformación mediante consorcio o unión temporal.'
            )
    ) AS retirados(codigo_abreviacion, nombre, descripcion),
    parametros.tipo_parametro tp,
    parametros.area_tipo a
WHERE p.tipo_parametro_id = tp.id
    AND tp.area_tipo_id = a.id
    AND a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion = 'TIPO_CONFORMACIÓN'
    AND tp.nombre = 'TIPO DE CONFORMACIÓN'
    AND p.codigo_abreviacion = retirados.codigo_abreviacion
    AND p.nombre = retirados.nombre
    AND p.descripcion = retirados.descripcion;
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
                'REG_CONT',
                'RÉGIMEN CONTRIBUTIVO',
                'COMÚN / ORDINARIO (IMPUESTO SOBRE LA RENTA)',
                'Clasificación tributaria ordinaria.',
                'COMUN_ORDINARIO',
                1
            ),
            (
                'REG_CONT',
                'RÉGIMEN CONTRIBUTIVO',
                'RÉGIMEN SIMPLE DE TRIBUTACIÓN (RST)',
                'Régimen simple de tributación.',
                'REGIMEN_SIMPLE_RST',
                2
            ),
            (
                'REG_CONT',
                'RÉGIMEN CONTRIBUTIVO',
                'RÉGIMEN TRIBUTARIO ESPECIAL (ESAL / FUNDACIONES)',
                'Régimen especial para entidades sin ánimo de lucro.',
                'REGIMEN_TRIB_ESP',
                3
            ),
            (
                'REG_CONT',
                'RÉGIMEN CONTRIBUTIVO',
                'ENTIDAD DE DERECHO PÚBLICO / OFICIAL',
                'Clasificación de entidades públicas u oficiales.',
                'ENTIDAD_DER_PUBLICO',
                4
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'ADMINISTRADORA DE RÉGIMEN SUBSIDIADO - A.R.S.',
                'administradora del régimen subsidiado de salud.',
                'ARS',
                1
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'ADMINISTRADORA PÚBLICA COOPERATIVA',
                'cooperativa pública integrada por entidades estatales.',
                'APC',
                2
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'CORPORACIÓN SIN ÁNIMO DE LUCRO, ORGANIZACIÓN NO GUBERNAMENTAL - ONG',
                'organización privada sin ánimo de lucro dedicada a fines sociales.',
                'ONG',
                3
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'EMPRESA DE SERVICIOS PÚBLICOS - E.S.P.',
                'empresa que presta servicios públicos domiciliarios.',
                'ESP',
                4
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'EMPRESA PROMOTORA DE SALUD - E.P.S.',
                'entidad promotora encargada de gestionar el aseguramiento en salud.',
                'EPS',
                5
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'EMPRESA SOCIAL DEL ESTADO - E.S.E.',
                'entidad pública que presta servicios de salud.',
                'ESE',
                6
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'EMPRESA UNIPERSONAL',
                'empresa constituida por una sola persona natural o jurídica.',
                'EMP_UNIPERSONAL',
                7
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'ENTIDAD ESTATAL',
                'organismo perteneciente al estado o sometido a su control.',
                'ENT_ESTATAL',
                8
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'FUNDACIÓN SIN ÁNIMO DE LUCRO',
                'organización sin ánimo de lucro creada para fines de interés general.',
                'FUND_ÁNIMO_LUCRO',
                9
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'INSTITUCIÓN ASEGURADORA',
                'entidad que ofrece cobertura frente a riesgos asegurables.',
                'INST_ASEGURADORA',
                10
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'INSTITUCIÓN DE INVESTIGACIÓN CIENTÍFICA',
                'institución dedicada a la investigación científica.',
                'INV_CIENTÍFICA',
                11
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'INSTITUCIÓN FINANCIERA',
                'entidad que ofrece servicios de intermediación financiera.',
                'INST_FINANCIERA',
                12
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'INSTITUCIÓN PRESTADORA DE SERVICIOS - I.P.S.',
                'entidad que presta servicios de salud a usuarios.',
                'IPS',
                13
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'ORGANISMO MULTILATERAL',
                'organismo integrado por varios estados para la cooperación internacional.',
                'ORG_MULTILATERAL',
                14
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'OTRAS ENTIDADES DE ECONOMÍA SOLIDARIA',
                'entidad solidaria distinta de cooperativas y mutuales.',
                'OTRAS_ECON_SOLID',
                15
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'OTRO',
                'categoría para entidades no contempladas en las demás opciones.',
                'OTRO',
                16
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'SOCIEDAD ANÓNIMA',
                'sociedad cuyo capital se representa en acciones.',
                'SOC_ANÓNIMA',
                17
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'SOCIEDAD COMANDITA POR ACCIONES',
                'sociedad cuyo capital se divide en acciones y cuenta con socios gestores.',
                'SOC_COM_ACCIONES',
                18
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'SOCIEDAD COMANDITA SIMPLE',
                'sociedad con socios gestores y socios comanditarios, sin acciones.',
                'SOC_COM_SIMPLE',
                19
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'SOCIEDAD LTDA.',
                'sociedad comercial en la que los socios responden hasta sus aportes.',
                'SOC_LTDA',
                20
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'SOCIEDAD POR ACCIONES SIMPLIFICADAS - SAS',
                'sociedad de capital cuyos accionistas responden hasta sus aportes.',
                'SAS',
                21
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'UNIVERSIDAD PRIVADA',
                'institución de educación superior de carácter privado.',
                'UNIV_PRIVADA',
                22
            ),
            (
                'TIPO_CONFORMACIÓN',
                'TIPO DE CONFORMACIÓN',
                'UNIVERSIDAD PÚBLICA',
                'institución de educación superior de carácter público.',
                'UNIV_PÚBLICA',
                23
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'CORREO ELECTRÓNICO',
                'Comunicación mediante direcciones electrónicas',
                'EMAIL',
                1
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'TELÉFONO FIJO',
                'Comunicación telefónica mediante línea fija',
                'TEL_FIJO',
                2
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'TELÉFONO MÓVIL',
                'Comunicación mediante línea celular',
                'TEL_MOVIL',
                3
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'FAX',
                'Transmisión de documentos por fax',
                'FAX',
                4
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'CORREO POSTAL',
                'Correspondencia física',
                'CORREO_POSTAL',
                5
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'MENSAJERÍA DE TEXTO (SMS/MMS)',
                'Mensajes de texto y multimedia',
                'MSJ_TEXTO',
                6
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'MENSAJERÍA INSTANTÁNEA',
                'WhatsApp, Telegram, Signal, Messenger, etc.',
                'MSJ_INSTA',
                7
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'REDES SOCIALES',
                'Instagram, Facebook, X, LinkedIn, etc.',
                'REDES_SOC',
                8
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'TELEFONÍA POR INTERNET (VoIP)',
                'Llamadas mediante servicios de internet',
                'TEL_INTERNET',
                9
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'CHAT EN LÍNEA',
                'Comunicación mediante plataformas web',
                'CHAT_LINEA',
                10
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'FORMULARIO WEB',
                'Solicitudes de contacto mediante sitios web',
                'FORMULARIO_WEB',
                11
            ),
            (
                'MED_COMUNICACIÓN',
                'MEDIOS DE COMUNICACIÓN',
                'NOTIFICACIONES ELECTRÓNICAS',
                'Notificaciones mediante aplicaciones o plataformas',
                'NOTIF_ELEC',
                12
            ),
            (
                'ESTADOS',
                'ESTADOS',
                'ACTIVO',
                'Estado que indica que el elemento se encuentra activo',
                'ACTIVO',
                1
            ),
            (
                'ESTADOS',
                'ESTADOS',
                'INACTIVO',
                'Estado que indica que el elemento no se encuentra activo',
                'INACTIVO',
                2
            ),
            (
                'ESTADOS',
                'ESTADOS',
                'RECHAZADO',
                'Estado que indica que el elemento ha sido rechazado',
                'RECHAZADO',
                3
            )
    ) AS v (
        codigo_tipo_parametro,
        nombre_tipo_parametro,
        nombre,
        descripcion,
        codigo_abreviacion,
        numero_orden
    )
    INNER JOIN parametros.tipo_parametro tp ON tp.codigo_abreviacion = v.codigo_tipo_parametro
    AND tp.nombre = v.nombre_tipo_parametro
    INNER JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );
    
COMMIT;