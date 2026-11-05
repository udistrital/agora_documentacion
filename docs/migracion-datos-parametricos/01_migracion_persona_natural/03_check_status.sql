SELECT
    ic.id,
    ic.nombre,
    ic.codigo_abreviacion
FROM terceros.info_complementaria ic
INNER JOIN terceros.grupo_info_complementaria g
    ON g.id = ic.grupo_info_complementaria_id
WHERE g.codigo_abreviacion = 'Grupo_9'
AND ic.codigo_abreviacion IN (
    'MIGRANTE',
    'VICTIMA_CONFLICTO',
    'PERSONA_PEP',
    'MED_PREPAGADA',
    'CUENTA_AFC',
    'RESPONSABLE_IVA',
    'RESIDE_FIS_COL',
    'PENSION_VOL',
    'HIJOS',
    'NUMERO_HIJOS',
    'CABEZA_FAMILIA',
    'PERSONAS_A_CARGO',
    'NUM_PERSONAS_A_CARGO',
    'DECLARANTE_RENTA'
);

-- La respuesta debe ser 0, tras la eliminación