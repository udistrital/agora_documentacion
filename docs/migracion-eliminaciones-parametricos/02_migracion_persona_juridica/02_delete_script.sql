BEGIN;

DELETE FROM parametros.parametro p
USING parametros.tipo_parametro tp,
      parametros.area_tipo at
WHERE tp.id = p.tipo_parametro_id
  AND at.id = tp.area_tipo_id
  AND at.codigo_abreviacion = 'IT'
  AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
  AND (
      (p.nombre = 'Cuenta con beneficiarios finales reportados en el RUB'
       AND p.codigo_abreviacion = 'BEN_FIN_RUB')
      OR (p.nombre = 'Cotiza en bolsa de valores de Colombia (BVC)'
       AND p.codigo_abreviacion = 'COTIZA_BVC')
      OR (p.nombre = 'Obligación a contar con revisor fiscal'
       AND p.codigo_abreviacion = 'REV_FISCAL')
      OR (p.nombre = 'Gran contribuyente DIAN'
       AND p.codigo_abreviacion = 'CONTRIBUYENTE_DIAN')
      OR (p.nombre = 'Autorretenedor en renta'
       AND p.codigo_abreviacion = 'AUTO_RENTA')
      OR (p.nombre = 'Aplica exención ICA Bogotá'
       AND p.codigo_abreviacion = 'ICA_BOG')
      OR (p.nombre = 'Obligación de factura electrónica'
       AND p.codigo_abreviacion = 'FAC_ELEC')
      OR (p.nombre = 'Operaciones en moneda extranjera'
       AND p.codigo_abreviacion = 'MONEDA_EXT')
      OR (p.nombre = 'RUP vigente'
       AND p.codigo_abreviacion = 'RUP_VIGENTE')
  )
RETURNING
    p.id,
    p.nombre,
    p.codigo_abreviacion,
    p.tipo_parametro_id;


-- Confirmar únicamente después de validar los registros afectados.
-- COMMIT;

-- Si se identifica alguna anomalía:
-- ROLLBACK;