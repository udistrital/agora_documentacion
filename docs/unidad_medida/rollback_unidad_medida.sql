-- =============================================================================
-- Script   : rollback_unidad_medida.sql
-- Proposito: Revertir insert_unidad_medida.sql
-- Orden    : inverso al de insercion (parametro -> tipo_parametro)
-- Seguridad: limita la eliminacion a Unidad de Comercializacion y conserva el
--            area_tipo UM, que es compartida con otros elementos.
-- =============================================================================

BEGIN;

DELETE FROM parametros.parametro
WHERE tipo_parametro_id IN (
    SELECT tp.id
    FROM parametros.tipo_parametro tp
    JOIN parametros.area_tipo a ON a.id = tp.area_tipo_id
    WHERE tp.nombre = 'UNIDAD DE COMERCIALIZACIÓN'
      AND tp.codigo_abreviacion = 'U_COMERCIO'
      AND a.codigo_abreviacion = 'UM'
)
  AND codigo_abreviacion IN (
      'UND',
      'CAJA',
      'PAQUETE',
      'PQT_UND',
      'DOCENA',
      'MEDIA_DOC',
      'PAR',
      'JUEGO',
      'KIT',
      'LOTE',
      'BOLSA',
      'BULTO',
      'SACO',
      'ESTIBA',
      'ROLLO',
      'BOBINA',
      'ENVASE',
      'BOTELLA',
      'LATA',
      'FRASCO',
      'SERVICIO',
      'HORA_SERV',
      'JORNADA',
      'DIA_SERV',
      'MES_SERV',
      'VISITA',
      'SESION',
      'CONSULTA',
      'PROCED',
      'PROYECTO',
      'CONTRATO',
      'LICENCIA',
      'SUSCRIP',
      'MEMBRESIA',
      'ACCESO',
      'ENTRADA',
      'BOLETO',
      'CUPO',
      'MATRICULA',
      'INSCRIPCION',
      'CREDITO',
      'PUNTO',
      'TRANSACCION',
      'OPERACION',
      'DOCUMENTO',
      'PAGINA',
      'COPIA',
      'IMPRESION',
      'PUBLICACION',
      'ANUNCIO',
      'REGISTRO',
      'SOLICITUD',
      'EXPEDIENTE',
      'EVENTO',
      'VIAJE',
      'ENVIO',
      'ENTREGA',
      'PALABRA',
      'CARACTER',
      'USUARIO',
      'CUENTA',
      'DISPOSITIVO',
      'PTO_SERV'
  );

DELETE FROM parametros.tipo_parametro
WHERE nombre = 'UNIDAD DE COMERCIALIZACIÓN'
  AND codigo_abreviacion = 'U_COMERCIO'
  AND area_tipo_id IN (
      SELECT id
      FROM parametros.area_tipo
      WHERE codigo_abreviacion = 'UM'
  );

COMMIT;