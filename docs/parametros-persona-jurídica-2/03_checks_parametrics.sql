-- =============================================================================
-- Script   : 06_checks_parametrics.sql
-- Propósito: Verificar los registros definidos en 04_inserts_parametrics.sql.
-- Alcance  : 4 tipos y 42 parámetros asociados al área IT.
-- =============================================================================

-- Verificación 1: existencia del área reutilizada.
-- Esperado: area_tipo = 1.
SELECT COUNT(*) AS area_tipo
FROM parametros.area_tipo a
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria';

-- Verificación 2: tipos esperados y su asociación con el área IT.
-- Esperado: 0 filas.
WITH tipos_esperados (
    codigo_tipo,
    nombre_tipo,
    descripcion_tipo
) AS (
    VALUES
        ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO', 'Agrupación de regímenes tributarios.'),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'Modalidad de conformación o representación empresarial.'),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'Canales por los cuales es posible contactar a un proveedor.'),
        ('ESTADOS', 'ESTADOS', 'Estado del usuario en el sistema.')
)
SELECT e.codigo_tipo AS tipo_esperado,
    e.nombre_tipo AS nombre_esperado,
    tp.id AS tipo_parametro_id,
    tp.nombre AS nombre_encontrado,
    tp.descripcion AS descripcion_encontrada,
    a.codigo_abreviacion AS codigo_area,
    a.nombre AS nombre_area,
    tp.activo
FROM tipos_esperados e
    LEFT JOIN parametros.tipo_parametro tp
        ON tp.codigo_abreviacion = e.codigo_tipo
        AND tp.nombre = e.nombre_tipo
    LEFT JOIN parametros.area_tipo a
        ON a.id = tp.area_tipo_id
WHERE tp.id IS NULL
    OR tp.descripcion IS DISTINCT FROM e.descripcion_tipo
    OR tp.activo IS DISTINCT FROM TRUE
    OR a.id IS NULL
    OR a.codigo_abreviacion IS DISTINCT FROM 'IT'
    OR a.nombre IS DISTINCT FROM 'Información Tributaria';

-- Verificación 3: detalle de los parámetros y sus relaciones.
-- Esperado: 42 filas, todas asociadas al tipo y área indicados.
WITH parametros_esperados (
    codigo_tipo,
    nombre_tipo,
    codigo_parametro,
    nombre_parametro,
    descripcion_parametro,
    numero_orden
) AS (
    VALUES
        ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO', 'COMUN_ORDINARIO', 'COMÚN / ORDINARIO (IMPUESTO SOBRE LA RENTA)', 'Clasificación tributaria ordinaria.', 1),
        ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO', 'REGIMEN_SIMPLE_RST', 'RÉGIMEN SIMPLE DE TRIBUTACIÓN (RST)', 'Régimen simple de tributación.', 2),
        ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO', 'REGIMEN_TRIB_ESP', 'RÉGIMEN TRIBUTARIO ESPECIAL (ESAL / FUNDACIONES)', 'Régimen especial para entidades sin ánimo de lucro.', 3),
        ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO', 'ENTIDAD_DER_PUBLICO', 'ENTIDAD DE DERECHO PÚBLICO / OFICIAL', 'Clasificación de entidades públicas u oficiales.', 4),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'ARS', 'ADMINISTRADORA DE RÉGIMEN SUBSIDIADO - A.R.S.', 'administradora del régimen subsidiado de salud.', 1),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'APC', 'ADMINISTRADORA PÚBLICA COOPERATIVA', 'cooperativa pública integrada por entidades estatales.', 2),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'ONG', 'CORPORACIÓN SIN ÁNIMO DE LUCRO, ORGANIZACIÓN NO GUBERNAMENTAL - ONG', 'organización privada sin ánimo de lucro dedicada a fines sociales.', 3),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'ESP', 'EMPRESA DE SERVICIOS PÚBLICOS - E.S.P.', 'empresa que presta servicios públicos domiciliarios.', 4),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'EPS', 'EMPRESA PROMOTORA DE SALUD - E.P.S.', 'entidad promotora encargada de gestionar el aseguramiento en salud.', 5),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'ESE', 'EMPRESA SOCIAL DEL ESTADO - E.S.E.', 'entidad pública que presta servicios de salud.', 6),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'EMP_UNIPERSONAL', 'EMPRESA UNIPERSONAL', 'empresa constituida por una sola persona natural o jurídica.', 7),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'ENT_ESTATAL', 'ENTIDAD ESTATAL', 'organismo perteneciente al estado o sometido a su control.', 8),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'FUND_ÁNIMO_LUCRO', 'FUNDACIÓN SIN ÁNIMO DE LUCRO', 'organización sin ánimo de lucro creada para fines de interés general.', 9),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'INST_ASEGURADORA', 'INSTITUCIÓN ASEGURADORA', 'entidad que ofrece cobertura frente a riesgos asegurables.', 10),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'INV_CIENTÍFICA', 'INSTITUCIÓN DE INVESTIGACIÓN CIENTÍFICA', 'institución dedicada a la investigación científica.', 11),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'INST_FINANCIERA', 'INSTITUCIÓN FINANCIERA', 'entidad que ofrece servicios de intermediación financiera.', 12),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'IPS', 'INSTITUCIÓN PRESTADORA DE SERVICIOS - I.P.S.', 'entidad que presta servicios de salud a usuarios.', 13),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'ORG_MULTILATERAL', 'ORGANISMO MULTILATERAL', 'organismo integrado por varios estados para la cooperación internacional.', 14),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'OTRAS_ECON_SOLID', 'OTRAS ENTIDADES DE ECONOMÍA SOLIDARIA', 'entidad solidaria distinta de cooperativas y mutuales.', 15),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'OTRO', 'OTRO', 'categoría para entidades no contempladas en las demás opciones.', 16),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'SOC_ANÓNIMA', 'SOCIEDAD ANÓNIMA', 'sociedad cuyo capital se representa en acciones.', 17),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'SOC_COM_ACCIONES', 'SOCIEDAD COMANDITA POR ACCIONES', 'sociedad cuyo capital se divide en acciones y cuenta con socios gestores.', 18),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'SOC_COM_SIMPLE', 'SOCIEDAD COMANDITA SIMPLE', 'sociedad con socios gestores y socios comanditarios, sin acciones.', 19),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'SOC_LTDA', 'SOCIEDAD LTDA.', 'sociedad comercial en la que los socios responden hasta sus aportes.', 20),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'SAS', 'SOCIEDAD POR ACCIONES SIMPLIFICADAS - SAS', 'sociedad de capital cuyos accionistas responden hasta sus aportes.', 21),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'UNIV_PRIVADA', 'UNIVERSIDAD PRIVADA', 'institución de educación superior de carácter privado.', 22),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN', 'UNIV_PÚBLICA', 'UNIVERSIDAD PÚBLICA', 'institución de educación superior de carácter público.', 23),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'EMAIL', 'CORREO ELECTRÓNICO', 'Comunicación mediante direcciones electrónicas', 1),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'TEL_FIJO', 'TELÉFONO FIJO', 'Comunicación telefónica mediante línea fija', 2),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'TEL_MOVIL', 'TELÉFONO MÓVIL', 'Comunicación mediante línea celular', 3),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'FAX', 'FAX', 'Transmisión de documentos por fax', 4),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'CORREO_POSTAL', 'CORREO POSTAL', 'Correspondencia física', 5),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'MSJ_TEXTO', 'MENSAJERÍA DE TEXTO (SMS/MMS)', 'Mensajes de texto y multimedia', 6),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'MSJ_INSTA', 'MENSAJERÍA INSTANTÁNEA', 'WhatsApp, Telegram, Signal, Messenger, etc.', 7),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'REDES_SOC', 'REDES SOCIALES', 'Instagram, Facebook, X, LinkedIn, etc.', 8),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'TEL_INTERNET', 'TELEFONÍA POR INTERNET (VoIP)', 'Llamadas mediante servicios de internet', 9),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'CHAT_LINEA', 'CHAT EN LÍNEA', 'Comunicación mediante plataformas web', 10),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'FORMULARIO_WEB', 'FORMULARIO WEB', 'Solicitudes de contacto mediante sitios web', 11),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN', 'NOTIF_ELEC', 'NOTIFICACIONES ELECTRÓNICAS', 'Notificaciones mediante aplicaciones o plataformas', 12),
        ('ESTADOS', 'ESTADOS', 'ACTIVO', 'ACTIVO', 'Estado que indica que el elemento se encuentra activo', 1),
        ('ESTADOS', 'ESTADOS', 'INACTIVO', 'INACTIVO', 'Estado que indica que el elemento no se encuentra activo', 2),
        ('ESTADOS', 'ESTADOS', 'RECHAZADO', 'RECHAZADO', 'Estado que indica que el elemento ha sido rechazado', 3)
)
SELECT a.id AS area_tipo_id,
    tp.id AS tipo_parametro_id,
    p.id AS parametro_id,
    e.codigo_tipo AS tipo_esperado,
    tp.codigo_abreviacion AS tipo_encontrado,
    e.codigo_parametro,
    e.nombre_parametro,
    p.descripcion AS descripcion_encontrada,
    e.numero_orden AS orden_esperado,
    p.numero_orden AS orden_encontrado,
    p.activo,
    p.parametro_padre_id
FROM parametros_esperados e
    LEFT JOIN parametros.parametro p
        ON p.codigo_abreviacion = e.codigo_parametro
        AND p.nombre = e.nombre_parametro
    LEFT JOIN parametros.tipo_parametro tp
        ON tp.id = p.tipo_parametro_id
    LEFT JOIN parametros.area_tipo a
        ON a.id = tp.area_tipo_id
WHERE p.id IS NULL
    OR tp.codigo_abreviacion IS DISTINCT FROM e.codigo_tipo
    OR tp.nombre IS DISTINCT FROM e.nombre_tipo
    OR a.codigo_abreviacion IS DISTINCT FROM 'IT'
    OR a.nombre IS DISTINCT FROM 'Información Tributaria'
    OR p.descripcion IS DISTINCT FROM e.descripcion_parametro
    OR p.numero_orden IS DISTINCT FROM e.numero_orden
    OR p.activo IS DISTINCT FROM TRUE
    OR p.parametro_padre_id IS NOT NULL;

-- Verificación 4: conteos de los grupos y parámetros definidos.
-- Esperado: 1 área, 4 tipos y 42 parámetros.
WITH tipos_esperados(codigo_tipo, nombre_tipo) AS (
    VALUES
        ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO'),
        ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN'),
        ('MED_COMUNICACIÓN', 'MEDIOS DE COMUNICACIÓN'),
        ('ESTADOS', 'ESTADOS')
),
parametros_esperados(codigo_tipo, codigo_parametro) AS (
    VALUES
        ('REG_CONT', 'COMUN_ORDINARIO'),
        ('REG_CONT', 'REGIMEN_SIMPLE_RST'),
        ('REG_CONT', 'REGIMEN_TRIB_ESP'),
        ('REG_CONT', 'ENTIDAD_DER_PUBLICO'),
        ('TIPO_CONFORMACIÓN', 'ARS'),
        ('TIPO_CONFORMACIÓN', 'APC'),
        ('TIPO_CONFORMACIÓN', 'ONG'),
        ('TIPO_CONFORMACIÓN', 'ESP'),
        ('TIPO_CONFORMACIÓN', 'EPS'),
        ('TIPO_CONFORMACIÓN', 'ESE'),
        ('TIPO_CONFORMACIÓN', 'EMP_UNIPERSONAL'),
        ('TIPO_CONFORMACIÓN', 'ENT_ESTATAL'),
        ('TIPO_CONFORMACIÓN', 'FUND_ÁNIMO_LUCRO'),
        ('TIPO_CONFORMACIÓN', 'INST_ASEGURADORA'),
        ('TIPO_CONFORMACIÓN', 'INV_CIENTÍFICA'),
        ('TIPO_CONFORMACIÓN', 'INST_FINANCIERA'),
        ('TIPO_CONFORMACIÓN', 'IPS'),
        ('TIPO_CONFORMACIÓN', 'ORG_MULTILATERAL'),
        ('TIPO_CONFORMACIÓN', 'OTRAS_ECON_SOLID'),
        ('TIPO_CONFORMACIÓN', 'OTRO'),
        ('TIPO_CONFORMACIÓN', 'SOC_ANÓNIMA'),
        ('TIPO_CONFORMACIÓN', 'SOC_COM_ACCIONES'),
        ('TIPO_CONFORMACIÓN', 'SOC_COM_SIMPLE'),
        ('TIPO_CONFORMACIÓN', 'SOC_LTDA'),
        ('TIPO_CONFORMACIÓN', 'SAS'),
        ('TIPO_CONFORMACIÓN', 'UNIV_PRIVADA'),
        ('TIPO_CONFORMACIÓN', 'UNIV_PÚBLICA'),
        ('MED_COMUNICACIÓN', 'EMAIL'),
        ('MED_COMUNICACIÓN', 'TEL_FIJO'),
        ('MED_COMUNICACIÓN', 'TEL_MOVIL'),
        ('MED_COMUNICACIÓN', 'FAX'),
        ('MED_COMUNICACIÓN', 'CORREO_POSTAL'),
        ('MED_COMUNICACIÓN', 'MSJ_TEXTO'),
        ('MED_COMUNICACIÓN', 'MSJ_INSTA'),
        ('MED_COMUNICACIÓN', 'REDES_SOC'),
        ('MED_COMUNICACIÓN', 'TEL_INTERNET'),
        ('MED_COMUNICACIÓN', 'CHAT_LINEA'),
        ('MED_COMUNICACIÓN', 'FORMULARIO_WEB'),
        ('MED_COMUNICACIÓN', 'NOTIF_ELEC'),
        ('ESTADOS', 'ACTIVO'),
        ('ESTADOS', 'INACTIVO'),
        ('ESTADOS', 'RECHAZADO')
)
SELECT (
        SELECT COUNT(*)
        FROM parametros.area_tipo a
        WHERE a.codigo_abreviacion = 'IT'
            AND a.nombre = 'Información Tributaria'
    ) AS area_tipo,
    (
        SELECT COUNT(DISTINCT tp.id)
        FROM parametros.tipo_parametro tp
            JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
            JOIN tipos_esperados e
                ON e.codigo_tipo = tp.codigo_abreviacion
                AND e.nombre_tipo = tp.nombre
        WHERE a.codigo_abreviacion = 'IT'
            AND a.nombre = 'Información Tributaria'
    ) AS tipo_parametro,
    (
        SELECT COUNT(DISTINCT p.id)
        FROM parametros.parametro p
            JOIN parametros.tipo_parametro tp ON tp.id = p.tipo_parametro_id
            JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
            JOIN parametros_esperados e
                ON e.codigo_tipo = tp.codigo_abreviacion
                AND e.codigo_parametro = p.codigo_abreviacion
        WHERE a.codigo_abreviacion = 'IT'
            AND a.nombre = 'Información Tributaria'
    ) AS parametro;

-- Verificación 5: grupos que fueron retirados del script.
-- Esperado: 0 filas.
WITH tipos_retirados(codigo_tipo) AS (
    VALUES
        ('RESP_ICA'),
        ('RESP_IVA'),
        ('CLASIFICACIÓN_PYME'),
        ('REG_MERCANTIL'),
        ('EXC_PRODUCTO'),
        ('CALIDAD_CONTRIB')
)
SELECT a.codigo_abreviacion AS codigo_area,
    tp.codigo_abreviacion AS codigo_tipo_retirado,
    tp.nombre AS tipo_retirado,
    p.codigo_abreviacion AS codigo_parametro,
    p.nombre AS parametro
FROM tipos_retirados e
    JOIN parametros.tipo_parametro tp
        ON tp.codigo_abreviacion = e.codigo_tipo
    JOIN parametros.area_tipo a
        ON a.id = tp.area_tipo_id
    LEFT JOIN parametros.parametro p
        ON p.tipo_parametro_id = tp.id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria';

-- Verificación 6: parámetros adicionales no contemplados en los catálogos.
-- Esperado: 0 filas.
WITH parametros_esperados(codigo_tipo, codigo_parametro) AS (
    VALUES
        ('REG_CONT', 'COMUN_ORDINARIO'),
        ('REG_CONT', 'REGIMEN_SIMPLE_RST'),
        ('REG_CONT', 'REGIMEN_TRIB_ESP'),
        ('REG_CONT', 'ENTIDAD_DER_PUBLICO'),
        ('TIPO_CONFORMACIÓN', 'ARS'),
        ('TIPO_CONFORMACIÓN', 'APC'),
        ('TIPO_CONFORMACIÓN', 'ONG'),
        ('TIPO_CONFORMACIÓN', 'ESP'),
        ('TIPO_CONFORMACIÓN', 'EPS'),
        ('TIPO_CONFORMACIÓN', 'ESE'),
        ('TIPO_CONFORMACIÓN', 'EMP_UNIPERSONAL'),
        ('TIPO_CONFORMACIÓN', 'ENT_ESTATAL'),
        ('TIPO_CONFORMACIÓN', 'FUND_ÁNIMO_LUCRO'),
        ('TIPO_CONFORMACIÓN', 'INST_ASEGURADORA'),
        ('TIPO_CONFORMACIÓN', 'INV_CIENTÍFICA'),
        ('TIPO_CONFORMACIÓN', 'INST_FINANCIERA'),
        ('TIPO_CONFORMACIÓN', 'IPS'),
        ('TIPO_CONFORMACIÓN', 'ORG_MULTILATERAL'),
        ('TIPO_CONFORMACIÓN', 'OTRAS_ECON_SOLID'),
        ('TIPO_CONFORMACIÓN', 'OTRO'),
        ('TIPO_CONFORMACIÓN', 'SOC_ANÓNIMA'),
        ('TIPO_CONFORMACIÓN', 'SOC_COM_ACCIONES'),
        ('TIPO_CONFORMACIÓN', 'SOC_COM_SIMPLE'),
        ('TIPO_CONFORMACIÓN', 'SOC_LTDA'),
        ('TIPO_CONFORMACIÓN', 'SAS'),
        ('TIPO_CONFORMACIÓN', 'UNIV_PRIVADA'),
        ('TIPO_CONFORMACIÓN', 'UNIV_PÚBLICA'),
        ('MED_COMUNICACIÓN', 'EMAIL'),
        ('MED_COMUNICACIÓN', 'TEL_FIJO'),
        ('MED_COMUNICACIÓN', 'TEL_MOVIL'),
        ('MED_COMUNICACIÓN', 'FAX'),
        ('MED_COMUNICACIÓN', 'CORREO_POSTAL'),
        ('MED_COMUNICACIÓN', 'MSJ_TEXTO'),
        ('MED_COMUNICACIÓN', 'MSJ_INSTA'),
        ('MED_COMUNICACIÓN', 'REDES_SOC'),
        ('MED_COMUNICACIÓN', 'TEL_INTERNET'),
        ('MED_COMUNICACIÓN', 'CHAT_LINEA'),
        ('MED_COMUNICACIÓN', 'FORMULARIO_WEB'),
        ('MED_COMUNICACIÓN', 'NOTIF_ELEC'),
        ('ESTADOS', 'ACTIVO'),
        ('ESTADOS', 'INACTIVO'),
        ('ESTADOS', 'RECHAZADO')
)
SELECT tp.codigo_abreviacion AS codigo_tipo,
    tp.nombre AS tipo_parametro,
    p.codigo_abreviacion AS codigo_parametro,
    p.nombre AS parametro
FROM parametros.area_tipo a
    JOIN parametros.tipo_parametro tp ON tp.area_tipo_id = a.id
    JOIN parametros.parametro p ON p.tipo_parametro_id = tp.id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion IN (
        'REG_CONT',
        'TIPO_CONFORMACIÓN',
        'MED_COMUNICACIÓN',
        'ESTADOS'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM parametros_esperados e
        WHERE e.codigo_tipo = tp.codigo_abreviacion
            AND e.codigo_parametro = p.codigo_abreviacion
    );

-- Verificación 7: códigos y nombres duplicados dentro de los cuatro grupos.
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
        'TIPO_CONFORMACIÓN',
        'MED_COMUNICACIÓN',
        'ESTADOS'
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
        'TIPO_CONFORMACIÓN',
        'MED_COMUNICACIÓN',
        'ESTADOS'
    )
GROUP BY tp.id,
    tp.nombre,
    p.nombre
HAVING COUNT(*) > 1
ORDER BY tipo_parametro,
    campo_duplicado,
    valor;

-- Verificación 8: cantidad exacta de valores para TIPO_CONFORMACIÓN.
-- Esperado: 23.
SELECT COUNT(p.id) AS total_tipo_conformacion,
    COUNT(p.id) = 23 AS cumple
FROM parametros.area_tipo a
    JOIN parametros.tipo_parametro tp
        ON tp.area_tipo_id = a.id
    LEFT JOIN parametros.parametro p
        ON p.tipo_parametro_id = tp.id
WHERE a.codigo_abreviacion = 'IT'
    AND a.nombre = 'Información Tributaria'
    AND tp.codigo_abreviacion = 'TIPO_CONFORMACIÓN'
    AND tp.nombre = 'TIPO DE CONFORMACIÓN';