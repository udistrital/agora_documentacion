BEGIN;

DELETE FROM terceros.info_complementaria ic
USING terceros.grupo_info_complementaria g
WHERE g.id = ic.grupo_info_complementaria_id
AND g.codigo_abreviacion = 'Grupo_9'
AND (
    (ic.nombre = 'Migrante' AND ic.codigo_abreviacion = 'MIGRANTE')
    OR (ic.nombre = 'Víctima del conflicto' AND ic.codigo_abreviacion = 'VICTIMA_CONFLICTO')
    OR (ic.nombre = 'Persona expuesta políticamente (PEP)' AND ic.codigo_abreviacion = 'PERSONA_PEP')
    OR (ic.nombre = 'Posee medicina prepagada actualmente' AND ic.codigo_abreviacion = 'MED_PREPAGADA')
    OR (ic.nombre = 'Posee cuenta AFC (Ahorro para el Fomento de la Construcción)' AND ic.codigo_abreviacion = 'CUENTA_AFC')
    OR (ic.nombre = 'Es responsable del IVA' AND ic.codigo_abreviacion = 'RESPONSABLE_IVA')
    OR (ic.nombre = 'Reside fiscalmente en Colombia' AND ic.codigo_abreviacion = 'RESIDE_FIS_COL')
    OR (ic.nombre = 'Realiza aportes a pensión voluntaria' AND ic.codigo_abreviacion = 'PENSION_VOL')
)
RETURNING
    ic.id,
    ic.nombre,
    ic.codigo_abreviacion,
    ic.grupo_info_complementaria_id;

-- Si el proceso realizó aquellas eliminaciones deseadas, tan solo basta con retirar el comentario sobre
-- la línea de commit para cerrar la transacción
-- COMMIT;


-- Si existe alguna anomalía sobre la eliminación, es necesario quitar las lineas de comentario del
-- rollback
-- ROLLBACK;