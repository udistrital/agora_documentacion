-- =============================================================================
-- Script   : 05_rollback_parametrics.sql
-- Propósito: Revertir los registros de 04_inserts_parametrics.sql.
-- Alcance  : 8 tipos y 26 parámetros definidos en el script de inserción.
-- Seguridad: Solo elimina coincidencias exactas dentro del área IT.
--            No elimina el área_tipo IT.
-- Revisión : Confirmar que estos códigos no existían antes de la inserción;
--            la base no registra aquí la procedencia de cada fila.
-- =============================================================================

BEGIN;

-- 1. Eliminar únicamente los parámetros definidos para cada tipo.
DELETE FROM parametros.parametro p USING (
    VALUES (
        'REG_CONT',
        'RÉGIMEN CONTRIBUTIVO',
        'COMUN_ORDINARIO',
        'COMÚN / ORDINARIO (IMPUESTO SOBRE LA RENTA)'
      ),
      (
        'REG_CONT',
        'RÉGIMEN CONTRIBUTIVO',
        'REGIMEN_SIMPLE_RST',
        'RÉGIMEN SIMPLE DE TRIBUTACIÓN (RST)'
      ),
      (
        'REG_CONT',
        'RÉGIMEN CONTRIBUTIVO',
        'REGIMEN_TRIB_ESP',
        'RÉGIMEN TRIBUTARIO ESPECIAL (ESAL / FUNDACIONES)'
      ),
      (
        'REG_CONT',
        'RÉGIMEN CONTRIBUTIVO',
        'ENTIDAD_DER_PUBLICO',
        'ENTIDAD DE DERECHO PÚBLICO / OFICIAL'
      ),
      (
        'RESP_ICA',
        'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
        'REGIMEN_COMUN_BIM',
        'RÉGIMEN COMÚN (BIMESTRAL SHD)'
      ),
      (
        'RESP_ICA',
        'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
        'REGIMEN_SIMPLIFICADO',
        'RÉGIMEN SIMPLIFICADO / PREFERENCIAL'
      ),
      (
        'RESP_ICA',
        'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
        'NO_SUJETO_EXENTO_ICA',
        'NO SUJETO / EXENTO DE ICA DISTRITAL'
      ),
      (
        'RESP_ICA',
        'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)',
        'REGIMEN_ESP_CONS',
        'RÉGIMEN ESPECIAL CONSORCIOS / UT'
      ),
      (
        'RESP_IVA',
        'RESPONSABLE DE IVA (CÓD. 48 RUT)',
        'RESP_IVA_GRAVADO',
        'RESPONSABLE DE IVA (GRAVADO / BIMESTRAL O CUATRIMESTRAL)'
      ),
      (
        'RESP_IVA',
        'RESPONSABLE DE IVA (CÓD. 48 RUT)',
        'NO_RESP_IVA',
        'NO RESPONSABLE DE IVA (ANTIGUO SIMPLIFICADO)'
      ),
      (
        'RESP_IVA',
        'RESPONSABLE DE IVA (CÓD. 48 RUT)',
        'EXENTO_IVA_OPER_ESP',
        'EXENTO DE IVA POR OPERACIONES ESPECIALES'
      ),
      (
        'CLASIFICACIÓN_PYME',
        'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
        'SI_PEQUEÑA_EMPRESA',
        'SÍ - PEQUEÑA EMPRESA (HASTA 204.653 UVT)'
      ),
      (
        'CLASIFICACIÓN_PYME',
        'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
        'SI_MICROEMPRESA',
        'SÍ - MICROEMPRESA (HASTA 23.563 UVT)'
      ),
      (
        'CLASIFICACIÓN_PYME',
        'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
        'SI_MEDIANA_EMPRESA',
        'SÍ - MEDIANA EMPRESA (HASTA 483.034 UVT)'
      ),
      (
        'CLASIFICACIÓN_PYME',
        'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL',
        'NO_GRAN_EMPRESA',
        'NO - GRAN EMPRESA (MAYOR A 483.034 UVT)'
      ),
      (
        'REG_MERCANTIL',
        'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
        'SI_MATRICULA_ACTIVA',
        'SÍ (MATRÍCULA MERCANTIL ACTIVA Y RENOVADA)'
      ),
      (
        'REG_MERCANTIL',
        'REGISTRO MERCANTIL / MATRÍCULA ACTIVA',
        'NO_EXENTA_LEGAL',
        'NO (EXENTA CONFORME A RÉGIMEN LEGAL)'
      ),
      (
        'EXC_PRODUCTO',
        'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
        'NO_DISTRIB_LOCAL',
        'NO (DISTRIBUCIÓN LOCAL / SERVICIOS NACIONALES)'
      ),
      (
        'EXC_PRODUCTO',
        'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
        'SI_DISTRIB_EXCLUSIVO',
        'SÍ - DISTRIBUIDOR O REPRESENTANTE EXCLUSIVO IMPORTADO'
      ),
      (
        'EXC_PRODUCTO',
        'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN',
        'SI_IMPORT_DIRECTO',
        'SÍ - IMPORTADOR DIRECTO NO EXCLUSIVO'
      ),
      (
        'CALIDAD_CONTRIB',
        'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
        'NO_REG_ORD_COMUN',
        'NO (CONTRIBUYENTE RÉGIMEN ORDINARIO COMÚN)'
      ),
      (
        'CALIDAD_CONTRIB',
        'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
        'SI_CALIF_DIAN',
        'SÍ - CALIFICADO POR RESOLUCIÓN DIAN VIGENTE'
      ),
      (
        'CALIDAD_CONTRIB',
        'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)',
        'AUTORRET_RESOLUCION',
        'AUTORRETENEDOR POR RESOLUCIÓN'
      ),
      (
        'TIPO_CONFORMACIÓN',
        'TIPO DE CONFORMACIÓN',
        'INDIVIDUAL_PRINCIPAL',
        'INDIVIDUAL / PRINCIPAL'
      ),
      (
        'TIPO_CONFORMACIÓN',
        'TIPO DE CONFORMACIÓN',
        'CONJUNTA_MANCOMUNADA',
        'CONJUNTA / MANCOMUNADA'
      ),
      (
        'TIPO_CONFORMACIÓN',
        'TIPO DE CONFORMACIÓN',
        'CONSORCIO_UT',
        'CONSORCIO / UNIÓN TEMPORAL'
      )
  ) AS esperado(
    codigo_tipo,
    nombre_tipo,
    codigo_parametro,
    nombre_parametro
  ),
  parametros.tipo_parametro tp,
  parametros.area_tipo a
WHERE p.tipo_parametro_id = tp.id
  AND tp.area_tipo_id = a.id
  AND a.codigo_abreviacion = 'IT'
  AND a.nombre = 'Información Tributaria'
  AND tp.codigo_abreviacion = esperado.codigo_tipo
  AND tp.nombre = esperado.nombre_tipo
  AND p.codigo_abreviacion = esperado.codigo_parametro
  AND p.nombre = esperado.nombre_parametro;

-- 2. Eliminar los tipos exactos solo si ya no tienen parámetros asociados.
DELETE FROM parametros.tipo_parametro tp USING (
    VALUES ('REG_CONT', 'RÉGIMEN CONTRIBUTIVO'),
      (
        'RESP_ICA',
        'RESPONSABLE DE ICA (BOGOTÁ D.C. - SHD)'
      ),
      ('RESP_IVA', 'RESPONSABLE DE IVA (CÓD. 48 RUT)'),
      (
        'CLASIFICACIÓN_PYME',
        'CLASIFICACIÓN PYME / TAMAÑO EMPRESARIAL'
      ),
      (
        'REG_MERCANTIL',
        'REGISTRO MERCANTIL / MATRÍCULA ACTIVA'
      ),
      (
        'EXC_PRODUCTO',
        'EXCLUSIVIDAD PRODUCTO DE IMPORTACIÓN'
      ),
      (
        'CALIDAD_CONTRIB',
        'CALIDAD DE GRAN CONTRIBUYENTE (DIAN)'
      ),
      ('TIPO_CONFORMACIÓN', 'TIPO DE CONFORMACIÓN')
  ) AS esperado(codigo_tipo, nombre_tipo),
  parametros.area_tipo a
WHERE tp.area_tipo_id = a.id
  AND a.codigo_abreviacion = 'IT'
  AND a.nombre = 'Información Tributaria'
  AND tp.codigo_abreviacion = esperado.codigo_tipo
  AND tp.nombre = esperado.nombre_tipo
  AND NOT EXISTS (
    SELECT 1
    FROM parametros.parametro p
    WHERE p.tipo_parametro_id = tp.id
  );
  
COMMIT;