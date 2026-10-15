-- Verificación: grupos y opciones de información complementaria

-- Resultado esperado: 16 opciones asociadas a los cuatro grupos, 
-- siempre que no existan registros adicionales para esos grupos.

SELECT
    g.id AS grupo_id,
    g.nombre AS grupo_info_complementaria,
    i.id AS info_complementaria_id,
    i.nombre AS nombre,
    i.codigo_abreviacion,
    i.activo,
    i.numero_orden
FROM terceros_crud.grupo_info_complementaria g
JOIN terceros_crud.info_complementaria i
    ON i.grupo_info_complementaria_id = g.id
WHERE g.nombre IN (
    'Procedencia',
    'Tipo de organizacion',
    'Tamaño de empresa',
    'Tipo de capital'
)
ORDER BY
    g.nombre,
    i.numero_orden;

-- Verificación: conteo de grupos y opciones

-- Resultado esperado: 4 grupos y 16 opciones, suponiendo que 
-- cada grupo exista una sola vez y que únicamente se hayan cargado 
-- las opciones descritas en este script.

SELECT
    (
        SELECT COUNT(*)
        FROM terceros_crud.grupo_info_complementaria
        WHERE nombre IN (
            'Procedencia',
            'Tipo de organizacion',
            'Tamaño de empresa',
            'Tipo de capital'
        )
    ) AS grupos_info_complementaria,
    (
        SELECT COUNT(*)
        FROM terceros_crud.info_complementaria i
        JOIN terceros_crud.grupo_info_complementaria g
            ON g.id = i.grupo_info_complementaria_id
        WHERE g.nombre IN (
            'Procedencia',
            'Tipo de organizacion',
            'Tamaño de empresa',
            'Tipo de capital'
        )
    ) AS opciones_info_complementaria;

-- Verificación: detección de grupos duplicados

-- Resultado esperado: 0 filas.

SELECT
    nombre,
    COUNT(*) AS repeticiones
FROM terceros_crud.grupo_info_complementaria
WHERE nombre IN (
    'Procedencia',
    'Tipo de organizacion',
    'Tamaño de empresa',
    'Tipo de capital'
)
GROUP BY nombre
HAVING COUNT(*) > 1;

-- Verificación: detección de opciones duplicadas por grupo

-- Resultado esperado: 0 filas.

SELECT
    g.nombre AS grupo_info_complementaria,
    i.nombre AS nombre,
    COUNT(*) AS repeticiones
FROM terceros_crud.info_complementaria i
JOIN terceros_crud.grupo_info_complementaria g
    ON g.id = i.grupo_info_complementaria_id
WHERE g.nombre IN (
    'Procedencia',
    'Tipo de organizacion',
    'Tamaño de empresa',
    'Tipo de capital'
)
GROUP BY
    g.id,
    g.nombre,
    i.nombre
HAVING COUNT(*) > 1
ORDER BY
    g.nombre,
    i.nombre;
