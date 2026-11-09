SELECT
    p.id,
    p.nombre,
    p.codigo_abreviacion
FROM parametros.parametro p
INNER JOIN parametros.tipo_parametro tp
    ON tp.id = p.tipo_parametro_id
INNER JOIN parametros.area_tipo at
    ON at.id = tp.area_tipo_id
WHERE at.codigo_abreviacion = 'IT'
  AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
  AND p.codigo_abreviacion IN (
      'BEN_FIN_RUB',
      'COTIZA_BVC',
      'REV_FISCAL',
      'CONTRIBUYENTE_DIAN',
      'AUTO_RENTA',
      'ICA_BOG',
      'FAC_ELEC',
      'MONEDA_EXT',
      'RUP_VIGENTE'
  );

-- Resultado esperado: 0 registros.