-- =============================================================================
-- Script   : 02_rollback_clasificacion_requisito_documental.sql
-- Issue    : #41 - revierte los códigos del catálogo Clasificación del requisito documental.
-- Seguridad: no elimina catálogos de otros tipos ni el área mientras tenga hijos.
-- =============================================================================
BEGIN;

-- El tipo de parámetro es exclusivo de Cotizaciones y usa código diferenciado.
DELETE FROM parametros.parametro p
USING parametros.tipo_parametro t, parametros.area_tipo a
WHERE p.tipo_parametro_id = t.id
  AND t.area_tipo_id = a.id
  AND a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'CLAS_REQ_DOC_COT'
  AND p.codigo_abreviacion IN ('OBLIGATORIO', 'COMPLEMENTARIO')
  AND p.descripcion LIKE '%[Semilla: issue #41]%';

-- Elimina el tipo solo si queda vacío después de borrar sus valores propios.
DELETE FROM parametros.tipo_parametro t
USING parametros.area_tipo a
WHERE t.area_tipo_id = a.id
  AND a.nombre = 'Gestión de Cotizaciones'
  AND t.codigo_abreviacion = 'CLAS_REQ_DOC_COT'
  AND t.descripcion LIKE '%[Semilla: issue #41]%'
  AND NOT EXISTS (
      SELECT 1 FROM parametros.parametro p WHERE p.tipo_parametro_id = t.id
  );

-- El área es compartida por los catálogos de Cotizaciones: solo se elimina vacía.
DELETE FROM parametros.area_tipo a
WHERE a.nombre = 'Gestión de Cotizaciones'
  AND a.codigo_abreviacion = 'COTIZACIONES'
  AND a.descripcion LIKE '%[Semilla: issue #41]%'
  AND NOT EXISTS (
      SELECT 1 FROM parametros.tipo_parametro t WHERE t.area_tipo_id = a.id
  );

COMMIT;
