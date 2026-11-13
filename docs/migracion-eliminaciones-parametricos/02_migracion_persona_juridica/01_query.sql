SELECT p.id,
    p.nombre,
    p.codigo_abreviacion,
    p.tipo_parametro_id,
    tp.codigo_abreviacion AS tipo_parametro,
    at.codigo_abreviacion AS area_tipo
FROM parametros.parametro p
    INNER JOIN parametros.tipo_parametro tp ON tp.id = p.tipo_parametro_id
    INNER JOIN parametros.area_tipo at ON at.id = tp.area_tipo_id
WHERE at.codigo_abreviacion = 'IT'
    AND tp.codigo_abreviacion = 'TRIBUTARIA_COMP'
    AND (
        (
            p.nombre = 'Cuenta con beneficiarios finales reportados en el RUB'
            AND p.codigo_abreviacion = 'BEN_FIN_RUB'
        )
        OR (
            p.nombre = 'Cotiza en bolsa de valores de Colombia (BVC)'
            AND p.codigo_abreviacion = 'COTIZA_BVC'
        )
        OR (
            p.nombre = 'Obligación a contar con revisor fiscal'
            AND p.codigo_abreviacion = 'REV_FISCAL'
        )
        OR (
            p.nombre = 'Gran contribuyente DIAN'
            AND p.codigo_abreviacion = 'CONTRIBUYENTE_DIAN'
        )
        OR (
            p.nombre = 'Autorretenedor en renta'
            AND p.codigo_abreviacion = 'AUTO_RENTA'
        )
        OR (
            p.nombre = 'Aplica exención ICA Bogotá'
            AND p.codigo_abreviacion = 'ICA_BOG'
        )
        OR (
            p.nombre = 'Obligación de factura electrónica'
            AND p.codigo_abreviacion = 'FAC_ELEC'
        )
        OR (
            p.nombre = 'Operaciones en moneda extranjera'
            AND p.codigo_abreviacion = 'MONEDA_EXT'
        )
        OR (
            p.nombre = 'RUP vigente'
            AND p.codigo_abreviacion = 'RUP_VIGENTE'
        )
    )
ORDER BY p.id;