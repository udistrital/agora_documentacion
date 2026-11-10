-- ELIMINACIÓN DE LAS INSERCIONES REALIZADAS EN EL ARCHIVO 01_inserts_parametrics.sql

BEGIN;

DELETE FROM parametros.parametro p
USING (
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
) AS esperado(codigo_tipo, codigo_parametro),
parametros.tipo_parametro tp,
parametros.area_tipo a
WHERE p.tipo_parametro_id = tp.id
    AND tp.area_tipo_id = a.id
    AND a.codigo_abreviacion = 'IT'
    AND tp.codigo_abreviacion = esperado.codigo_tipo
    AND p.codigo_abreviacion = esperado.codigo_parametro;

DELETE FROM parametros.tipo_parametro tp
USING (
    VALUES
        ('REG_CONT'),
        ('TIPO_CONFORMACIÓN'),
        ('MED_COMUNICACIÓN'),
        ('ESTADOS')
) AS esperado(codigo_tipo),
parametros.area_tipo a
WHERE tp.area_tipo_id = a.id
    AND a.codigo_abreviacion = 'IT'
    AND tp.codigo_abreviacion = esperado.codigo_tipo
    AND NOT EXISTS (
        SELECT 1
        FROM parametros.parametro p
        WHERE p.tipo_parametro_id = tp.id
    );

COMMIT;