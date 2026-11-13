INSERT INTO terceros.tipo_contribuyente
    (id, nombre, codigo_abreviacion, activo, fecha_creacion, fecha_modificacion)
VALUES
    (1, 'PERSONA NATURAL', 'P_NATURAL', TRUE, LOCALTIMESTAMP, LOCALTIMESTAMP),
    (2, 'PERSONA JURIDICA', 'P_JURIDICA', TRUE, LOCALTIMESTAMP, LOCALTIMESTAMP)
ON CONFLICT (id) DO NOTHING;

SELECT setval(
    'terceros.tipo_contribuyente_id_seq',
    GREATEST((SELECT COALESCE(MAX(id), 1) FROM terceros.tipo_contribuyente), 1)
);
