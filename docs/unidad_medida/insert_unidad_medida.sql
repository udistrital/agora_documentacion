-- =============================================================================
-- Script   : insert_unidad_medida.sql
-- Proposito: Inserción para el consumo de datos parametricos (Unidad de medida: mercado)
-- Esquema  : parametros
-- Tablas   : area_tipo -> tipo_parametro -> parametro  (orden obligatorio por FK)
-- Motor    : PostgreSQL
-- Idempotente: SI. Se puede ejecutar varias veces sin duplicar registros.
-- Supuesto : las columnas "id" tienen secuencia/serial (autoincremental).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1. UNIDAD DE COMERCIALIZACIÓN
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
SELECT 'UNIDAD DE COMERCIALIZACIÓN',
    'Unidades para comercialización de productos y prestación de servicios.',
    'U_COMERCIO',
    TRUE,
    COALESCE(
        (
            SELECT MAX(t.numero_orden)
            FROM parametros.tipo_parametro t
            WHERE t.area_tipo_id = a.id
        ),
        0
    ) + 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    a.id
FROM parametros.area_tipo a
WHERE a.codigo_abreviacion = 'UM'
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.tipo_parametro t
        WHERE t.nombre = 'UNIDAD DE COMERCIALIZACIÓN'
            AND t.area_tipo_id = a.id
    );
    
-- -----------------------------------------------------------------------------
-- 2. LISTADO: UNIDAD DE COMERCIALIZACIÓN
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
        VALUES ('UNIDAD', 'Elemento individual.', 'UND', 1),
            (
                'CAJA',
                'Productos agrupados en una caja.',
                'CAJA',
                2
            ),
            (
                'PAQUETE',
                'Conjunto de productos empacados.',
                'PAQUETE',
                3
            ),
            (
                'PAQUETE POR UNIDAD',
                'Paquete contabilizado individualmente.',
                'PQT_UND',
                4
            ),
            (
                'DOCENA',
                'Conjunto de doce unidades.',
                'DOCENA',
                5
            ),
            (
                'MEDIA DOCENA',
                'Conjunto de seis unidades.',
                'MEDIA_DOC',
                6
            ),
            ('PAR', 'Conjunto de dos elementos.', 'PAR', 7),
            (
                'JUEGO',
                'Conjunto de elementos relacionados.',
                'JUEGO',
                8
            ),
            (
                'KIT',
                'Conjunto de artículos para una finalidad.',
                'KIT',
                9
            ),
            (
                'LOTE',
                'Grupo de productos o elementos.',
                'LOTE',
                10
            ),
            (
                'BOLSA',
                'Productos empacados en bolsas.',
                'BOLSA',
                11
            ),
            (
                'BULTO',
                'Mercancía agrupada en bultos.',
                'BULTO',
                12
            ),
            (
                'SACO',
                'Productos empacados en sacos.',
                'SACO',
                13
            ),
            (
                'PALÉ / ESTIBA',
                'Mercancía agrupada para transporte.',
                'ESTIBA',
                14
            ),
            (
                'ROLLO',
                'Material comercializado en rollos.',
                'ROLLO',
                15
            ),
            (
                'BOBINA',
                'Material enrollado en bobinas.',
                'BOBINA',
                16
            ),
            ('ENVASE', 'Recipiente individual.', 'ENVASE', 17),
            (
                'BOTELLA',
                'Producto envasado en botella.',
                'BOTELLA',
                18
            ),
            ('LATA', 'Producto envasado en lata.', 'LATA', 19),
            (
                'FRASCO',
                'Producto envasado en frasco.',
                'FRASCO',
                20
            ),
            (
                'SERVICIO',
                'Servicio prestado o contratado.',
                'SERVICIO',
                21
            ),
            (
                'HORA DE SERVICIO',
                'Servicio facturado por hora.',
                'HORA_SERV',
                22
            ),
            (
                'JORNADA',
                'Trabajo o servicio por jornada.',
                'JORNADA',
                23
            ),
            (
                'DÍA DE SERVICIO',
                'Servicio facturado por día.',
                'DIA_SERV',
                24
            ),
            (
                'MES DE SERVICIO',
                'Servicio facturado por mes.',
                'MES_SERV',
                25
            ),
            (
                'VISITA',
                'Servicio contabilizado por visita.',
                'VISITA',
                26
            ),
            (
                'SESIÓN',
                'Servicio contabilizado por sesión.',
                'SESION',
                27
            ),
            (
                'CONSULTA',
                'Servicio contabilizado por consulta.',
                'CONSULTA',
                28
            ),
            (
                'PROCEDIMIENTO',
                'Servicio por procedimiento realizado.',
                'PROCED',
                29
            ),
            (
                'PROYECTO',
                'Trabajo contabilizado por proyecto.',
                'PROYECTO',
                30
            ),
            (
                'CONTRATO',
                'Unidad de contratación.',
                'CONTRATO',
                31
            ),
            (
                'LICENCIA',
                'Derecho de uso de un producto o software.',
                'LICENCIA',
                32
            ),
            (
                'SUSCRIPCIÓN',
                'Servicio contratado por suscripción.',
                'SUSCRIP',
                33
            ),
            (
                'MEMBRESÍA',
                'Acceso asociado a una membresía.',
                'MEMBRESIA',
                34
            ),
            (
                'ACCESO',
                'Acceso individual a un recurso o servicio.',
                'ACCESO',
                35
            ),
            (
                'ENTRADA',
                'Ingreso a un evento o lugar.',
                'ENTRADA',
                36
            ),
            (
                'BOLETO',
                'Boleto individual de acceso o transporte.',
                'BOLETO',
                37
            ),
            (
                'CUPO',
                'Plaza o capacidad asignada.',
                'CUPO',
                38
            ),
            (
                'MATRÍCULA',
                'Inscripción o matrícula individual.',
                'MATRICULA',
                39
            ),
            (
                'INSCRIPCIÓN',
                'Registro de inscripción individual.',
                'INSCRIPCION',
                40
            ),
            (
                'CRÉDITO',
                'Unidad de crédito académico o comercial.',
                'CREDITO',
                41
            ),
            (
                'PUNTO',
                'Punto acumulable o asignable.',
                'PUNTO',
                42
            ),
            (
                'TRANSACCIÓN',
                'Operación comercial individual.',
                'TRANSACCION',
                43
            ),
            (
                'OPERACIÓN',
                'Operación contabilizada.',
                'OPERACION',
                44
            ),
            (
                'DOCUMENTO',
                'Documento individual procesado.',
                'DOCUMENTO',
                45
            ),
            (
                'PÁGINA',
                'Página contabilizada o facturada.',
                'PAGINA',
                46
            ),
            (
                'COPIA',
                'Reproducción individual de un documento.',
                'COPIA',
                47
            ),
            (
                'IMPRESIÓN',
                'Trabajo de impresión contabilizado.',
                'IMPRESION',
                48
            ),
            (
                'PUBLICACIÓN',
                'Publicación individual.',
                'PUBLICACION',
                49
            ),
            (
                'ANUNCIO',
                'Anuncio contratado o publicado.',
                'ANUNCIO',
                50
            ),
            (
                'REGISTRO',
                'Registro procesado individualmente.',
                'REGISTRO',
                51
            ),
            (
                'SOLICITUD',
                'Solicitud tramitada.',
                'SOLICITUD',
                52
            ),
            (
                'EXPEDIENTE',
                'Expediente gestionado.',
                'EXPEDIENTE',
                53
            ),
            (
                'EVENTO',
                'Evento organizado o prestado.',
                'EVENTO',
                54
            ),
            (
                'VIAJE',
                'Trayecto o servicio de transporte.',
                'VIAJE',
                55
            ),
            (
                'ENVÍO',
                'Envío de mercancía o documentación.',
                'ENVIO',
                56
            ),
            (
                'ENTREGA',
                'Entrega individual de un producto.',
                'ENTREGA',
                57
            ),
            (
                'PALABRA',
                'Unidad de cobro por contenido o traducción.',
                'PALABRA',
                58
            ),
            (
                'CARÁCTER',
                'Unidad de procesamiento de texto.',
                'CARACTER',
                59
            ),
            (
                'USUARIO',
                'Usuario contabilizado o licenciado.',
                'USUARIO',
                60
            ),
            (
                'CUENTA',
                'Cuenta individual registrada.',
                'CUENTA',
                61
            ),
            (
                'DISPOSITIVO',
                'Dispositivo registrado o licenciado.',
                'DISPOSITIVO',
                62
            ),
            (
                'PUNTO DE SERVICIO',
                'Punto físico de atención o prestación.',
                'PTO_SERV',
                63
            )
    ) AS v(
        nombre,
        descripcion,
        codigo_abreviacion,
        numero_orden
    )
    CROSS JOIN (
        SELECT t.id
        FROM parametros.tipo_parametro t
            INNER JOIN parametros.area_tipo a ON a.id = t.area_tipo_id
        WHERE t.nombre = 'UNIDAD DE COMERCIALIZACIÓN'
            AND a.codigo_abreviacion = 'UM'
    ) AS tp
WHERE NOT EXISTS (
        SELECT 1
        FROM parametros.parametro existente
        WHERE existente.tipo_parametro_id = tp.id
            AND existente.codigo_abreviacion = v.codigo_abreviacion
    );

COMMIT;