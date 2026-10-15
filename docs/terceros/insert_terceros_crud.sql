= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = -- CATÁLOGOS PARAMÉTRICOS - TERCEROS CRUD
-- ============================================================
BEGIN;
-- ============================================================
-- GRUPOS DE INFORMACIÓN COMPLEMENTARIA
-- ============================================================
INSERT INTO terceros_crud.grupo_info_complementaria (
        nombre,
        descripcion,
        codigo_abreviacion,
        activo,
        fecha_creacion,
        fecha_modificacion
    )
VALUES (
        'Procedencia',
        'Procedencia de la organización o entidad',
        'PROCEDENCIA',
        TRUE,
        NOW (),
        NOW ()
    ),
    (
        'Tipo de organizacion',
        'Tipo de organización de la empresa',
        'TIPO_ORG',
        TRUE,
        NOW (),
        NOW ()
    ),
    (
        'Tamaño de empresa',
        'Tamaño de la empresa',
        'TAMAÑO_EMPRESA',
        TRUE,
        NOW (),
        NOW ()
    ),
    (
        'Tipo de capital',
        'Tipo de capital gestionado por la empresa',
        'TIPO_CAPITAL',
        TRUE,
        NOW (),
        NOW ()
    );
-- ============================================================
-- PROCEDENCIA
-- ============================================================
INSERT INTO terceros_crud.info_complementaria (
        nombre,
        grupo_info_complementaria_id,
        activo,
        fecha_creacion,
        fecha_modificacion,
        codigo_abreviacion
    )
VALUES (
        'Nacional (Constituida en Colombia)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Procedencia'
        ),
        TRUE,
        NOW (),
        NOW (),
        'NACIONAL'
    ),
    (
        'Extranjera con Sucursal en Colombia',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Procedencia'
        ),
        TRUE,
        NOW (),
        NOW (),
        'EXTRANJERA_CON_SUCURSAL'
    ),
    (
        'Extranjera sin Domicilio en el País',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Procedencia'
        ),
        TRUE,
        NOW (),
        NOW (),
        'EXTRANJERA_SIN_DOMICILIO'
    );
-- ============================================================
-- TIPO DE ORGANIZACIÓN
-- ============================================================
INSERT INTO terceros_crud.info_complementaria (
        nombre,
        grupo_info_complementaria_id,
        activo,
        fecha_creacion,
        fecha_modificacion,
        codigo_abreviacion
    )
VALUES (
        'Sociedad por Acciones Simplificada - S.A.S.',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de organizacion'
        ),
        TRUE,
        NOW (),
        NOW (),
        'SAS'
    ),
    (
        'Sociedad Anónima - S.A.',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de organizacion'
        ),
        TRUE,
        NOW (),
        NOW (),
        'SA'
    ),
    (
        'Sociedad de Responsabilidad Limitada - Ltda.',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de organizacion'
        ),
        TRUE,
        NOW (),
        NOW (),
        'LTDA'
    ),
    (
        'Entidad Sin Ánimo de Lucro - ESAL',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de organizacion'
        ),
        TRUE,
        NOW (),
        NOW (),
        'ESAL'
    ),
    (
        'Sucursal de Sociedad Extranjera',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de organizacion'
        ),
        TRUE,
        NOW (),
        NOW (),
        'SUCURSAL_EXTRANJERA'
    );
-- ============================================================
-- TAMAÑO EMPRESARIAL
-- ============================================================
INSERT INTO terceros_crud.info_complementaria (
        nombre,
        grupo_info_complementaria_id,
        activo,
        fecha_creacion,
        fecha_modificacion,
        codigo_abreviacion
    )
VALUES (
        'Microempresa (Hasta 23.563 UVT Servicios)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tamaño de empresa'
        ),
        TRUE,
        NOW (),
        NOW (),
        'MICRO'
    ),
    (
        'Pequeña Empresa (Hasta 204.653 UVT Servicios)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tamaño de empresa'
        ),
        TRUE,
        NOW (),
        NOW (),
        'PEQUEÑA'
    ),
    (
        'Mediana Empresa (Hasta 483.034 UVT Servicios)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tamaño de empresa'
        ),
        TRUE,
        NOW (),
        NOW (),
        'MEDIANA'
    ),
    (
        'Gran Empresa (Mayor a 483.034 UVT)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tamaño de empresa'
        ),
        TRUE,
        NOW (),
        NOW (),
        'GRAN'
    );
-- ============================================================
-- TIPO DE CAPITAL
-- ============================================================
INSERT INTO terceros_crud.info_complementaria (
        nombre,
        grupo_info_complementaria_id,
        activo,
        fecha_creacion,
        fecha_modificacion,
        codigo_abreviacion
    )
VALUES (
        'Capital Privado Nacional (100%)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de capital'
        ),
        TRUE,
        NOW (),
        NOW (),
        'CAP_PRIVADO_NACIONAL'
    ),
    (
        'Economía Mixta con aporte estatal',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de capital'
        ),
        TRUE,
        NOW (),
        NOW (),
        'ECO_MIXSTA_APORTE_ESTATAL'
    ),
    (
        'Capital Privado con Inversión Extranjera',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de capital'
        ),
        TRUE,
        NOW (),
        NOW (),
        'CAP_PRIVADO_INVERSION_EXTRANJERA'
    ),
    (
        'Entidad Sin Ánimo de Lucro (Patrimonio Institucional)',
        (
            SELECT id
            FROM terceros_crud.grupo_info_complementaria
            WHERE nombre = 'Tipo de capital'
        ),
        TRUE,
        NOW (),
        NOW (),
        'ENTIDAD_SIN_ANIMO_LUCRO'
    );
COMMIT;
