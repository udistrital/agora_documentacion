# Issue #66 — Documentación de pruebas de integración de proveedores

**Proyecto:** Ágora
**Componente principal:** `agora_mid`
**Ambiente:** Local aislado
**Fecha de corte:** 12 de noviembre de 2026
**Estado:** En ejecución

---

## 1. Objetivo

Documentar la preparación del ambiente local aislado y las verificaciones realizadas para probar las operaciones de lectura y escritura del registro de proveedores mediante `agora_mid`.

El alcance contempla:

- Registro de proveedores naturales y jurídicos.
- Actualización de información del proveedor.
- Consulta individual y consulta de listados.
- Integración con los servicios CRUD de gestión de personas y terceros.
- Verificación de relaciones entre entidades.
- Comprobación de persistencia en PostgreSQL.
- Validación de errores, reintentos e idempotencia.

Las pruebas deben permitir contrastar las respuestas HTTP del MID con los registros realmente almacenados en las bases de datos.

## 2. Alcance y estado de las pruebas

Este documento consolida los resultados obtenidos hasta la fecha de corte. No todos los escenarios de la matriz han sido ejecutados.

Se utilizan las siguientes clasificaciones:

- **Verificado:** existe evidencia de ejecución o inspección que respalda el resultado.
- **Parcial:** se realizaron verificaciones, pero no cubren el escenario completo.
- **Pendiente:** no existe evidencia suficiente de ejecución.
- **Bloqueado:** existe una dependencia o condición que impide completar la prueba.

No se considera aprobada una operación de escritura únicamente por recibir una respuesta HTTP satisfactoria. La persistencia debe verificarse mediante consultas SQL.

## 3. Arquitectura del ambiente local

El ambiente se encuentra definido en `issue-66/docker/docker-compose.yml`.

Está compuesto por cinco servicios:

| Servicio Compose | Contenedor | Función |
|---|---|---|
| `db-gestion` | `issue66-db-gestion` | Base de datos de gestión de personas |
| `db-terceros` | `issue66-db-terceros` | Base de datos de terceros |
| `gestion-personas-crud` | `issue66-gestion-personas-crud` | Servicio CRUD de proveedores |
| `terceros-crud` | `issue66-terceros-crud` | Servicio CRUD de terceros |
| `agora-mid` | `issue66-agora-mid` | Capa de integración y orquestación |

### 3.1. Puertos publicados

| Servicio | Puerto interno | Puerto local |
|---|---:|---:|
| agora-mid | 8080 | 18080 |
| gestion-personas-crud | 8081 | 18081 |
| terceros-crud | 8082 | 18082 |
| db-gestion | 5432 | 15432 |
| db-terceros | 5432 | 15433 |

### 3.2. Bases de datos

Se utilizan dos instancias independientes de PostgreSQL 10.

**Gestión de personas**

- Base de datos: `issue66_gestion`
- Usuario: `issue66`
- Esquema principal: `proveedores`
- Puerto local: `15432`
- Volumen: `gestion_data`
- Script de inicialización: `gestion_personas_crud/database/agora_proveedores.sql`

**Terceros**

- Base de datos: `issue66_terceros`
- Usuario: `issue66`
- Esquema principal: `terceros`
- Puerto local: `15433`
- Volumen: `terceros_data`
- Script de inicialización: `terceros_crud/sql/Terceros_Schema.sql`

Los scripts SQL se montan en `/docker-entrypoint-initdb.d/` en modo de solo lectura. La inicialización automática de PostgreSQL se realiza cuando el directorio de datos está vacío. Los scripts no se vuelven a ejecutar automáticamente en cada reinicio del contenedor.

Las credenciales incluidas en el Compose son exclusivamente para el ambiente local aislado. No deben utilizarse en producción.

### 3.3. Red y comunicación interna

Los cinco servicios pertenecen a la red Docker `issue66`, de tipo `bridge`.

La comunicación entre contenedores utiliza los nombres de los servicios y sus puertos internos:

- `http://gestion-personas-crud:8081`
- `http://terceros-crud:8082`
- `http://parametros-crud:8080`

### 3.4. Dependencias de inicio

Los servicios CRUD tienen dependencia de sus respectivas bases de datos mediante `depends_on` con condición `service_healthy`.

Los healthchecks de PostgreSQL ejecutan `pg_isready`, con intervalo de cinco segundos, timeout de cinco segundos y quince reintentos.

El MID depende de los dos servicios CRUD mediante `depends_on`. Esta dependencia establece el orden de inicio, pero no incluye una condición de salud HTTP para los servicios CRUD.

### 3.5. Dependencia de parámetros

El MID tiene configurada la variable `AGORA_MID_PARAMETROS_CRUD_URL=http://parametros-crud:8080`.

Sin embargo, `parametros-crud` no está definido como servicio dentro del Compose del Issue #66. Por tanto, no se considera disponible dentro del ambiente aislado actual. Debe verificarse si las operaciones que se desean probar requieren esta dependencia y definir su incorporación o una alternativa controlada.

## 4. Construcción de imágenes Docker

Los tres microservicios utilizan Dockerfiles independientes:

- `issue-66/docker/Dockerfile.gestion_personas_crud`
- `issue-66/docker/Dockerfile.terceros_crud`
- `issue-66/docker/Dockerfile.agora_mid`

Los Dockerfiles implementan una construcción multietapa:

1. Primera etapa basada en una imagen de Go.
2. Compilación del ejecutable para `linux/amd64`.
3. Segunda etapa basada en `gcr.io/distroless/base-debian12`.
4. Copia del ejecutable y los archivos de configuración.
5. Inicio mediante `ENTRYPOINT ["/main"]`.

### 4.1. Versiones de Go

| Microservicio | Imagen de compilación | Arquitectura |
|---|---|---|
| gestion-personas-crud | `golang:1.27` | linux/amd64 |
| terceros-crud | `golang:1.25.5` | linux/amd64 |
| agora-mid | `golang:1.27.1` | linux/amd64 |

Los tres Dockerfiles utilizan como imagen final `gcr.io/distroless/base-debian12`.

El Dockerfile de `agora_mid` copia adicionalmente:

- `config/relaciones_proveedor.yaml`
- `config/global_blacklist.yaml`
- Directorio `swagger`

La configuración fuerza la arquitectura `linux/amd64`, aunque el equipo de desarrollo utilizado sea un MacBook Air con procesador Apple Silicon.

No se documentan identificadores de commit ni versiones de código de los repositorios porque todavía no se han registrado como evidencia de esta ejecución.

## 5. Validación de Docker Compose

Se ejecutó desde la raíz del repositorio:

```bash
docker compose -f issue-66/docker/docker-compose.yml config --quiet
```

**Resultado:** ejecución sin errores ni salida de diagnóstico. Esto verifica que Docker Compose pudo interpretar la configuración del archivo.

Adicionalmente, se verificó el levantamiento de los cinco contenedores y el estado de las bases de datos.

### 5.1. Estado observado

| Contenedor | Resultado observado |
|---|---|
| issue66-db-gestion | Up / healthy |
| issue66-db-terceros | Up / healthy |
| issue66-gestion-personas-crud | Up |
| issue66-terceros-crud | Up |
| issue66-agora-mid | Up |

En los registros del MID se observó: `http server Running on http://:8080`.

## 6. Comandos de operación del ambiente

Los siguientes comandos deben ejecutarse desde la raíz de `agora_documentacion`.

### 6.1. Validar configuración

```bash
docker compose -f issue-66/docker/docker-compose.yml config --quiet
```

### 6.2. Construir y levantar

```bash
docker compose -f issue-66/docker/docker-compose.yml up -d --build
```

### 6.3. Consultar estado

```bash
docker compose -f issue-66/docker/docker-compose.yml ps
```

### 6.4. Consultar registros

```bash
docker compose -f issue-66/docker/docker-compose.yml logs -f
```

Para consultar un servicio específico:

```bash
docker logs --tail 60 issue66-agora-mid
```

### 6.5. Detener servicios

```bash
docker compose -f issue-66/docker/docker-compose.yml stop
```

### 6.6. Iniciar servicios detenidos

```bash
docker compose -f issue-66/docker/docker-compose.yml start
```

### 6.7. Eliminar contenedores y red

```bash
docker compose -f issue-66/docker/docker-compose.yml down
```

Este comando conserva los volúmenes nombrados.

**Precaución:** no utilizar `down -v` durante las pruebas sin autorización y respaldo, porque elimina los volúmenes y los datos persistentes de las bases de datos.

## 7. Pruebas HTTP ejecutadas

Las pruebas se realizaron contra los servicios locales.

### 7.1. Healthcheck del MID

Solicitud:

```bash
curl -i http://localhost:18080/
```

Resultado observado:

- HTTP 200.
- Respuesta: `{"status":"ok"}`.

**Estado:** Verificado.

### 7.2. Healthcheck de gestión de personas

Solicitud:

```bash
curl -i http://localhost:18081/
```

Resultado observado:

- HTTP 200.
- Respuesta: `{"status":"ok"}`.

**Estado:** Verificado.

### 7.3. Consulta de listado mediante MID

Solicitud:

```bash
curl -i -X POST http://localhost:18080/v1/proveedor/consulta/lista \
  -H "Content-Type: application/json" \
  -d '{}'
```

Resultado observado:

- HTTP 200.
- Lista vacía.
- Total de registros: 0.

**Estado:** Verificado para la consulta de listado sin registros.

### 7.4. Consulta directa al CRUD

Solicitud:

```bash
curl -i http://localhost:18081/v1/proveedor/
```

Resultado observado:

- HTTP 200.
- Lista vacía.

**Estado:** Verificado para la consulta directa sin registros.

### 7.5. Consulta individual de proveedor inexistente

Solicitud:

```bash
curl -i -X POST http://localhost:18080/v1/proveedor/consulta \
  -H "Content-Type: application/json" \
  -d '{"id":1}'
```

Resultado observado:

- HTTP 404.
- El proveedor consultado no existe en el ambiente.

**Estado:** Verificado para el caso de identificador inexistente.

### 7.6. Prueba PATCH sobre proveedor inexistente

Solicitud:

```bash
curl -i -X PATCH http://localhost:18081/v1/proveedor/999999 \
  -H "Content-Type: application/json" \
  -d '{"Id":999999}'
```

Resultado observado:

- HTTP 404.
- Los registros del contenedor muestran que la solicitud PATCH llegó al servicio y recibió respuesta 404.

**Hallazgo:** la ruta de actualización del controlador de proveedor inspeccionado registra PUT, no PATCH. Esta respuesta por sí sola no demuestra una actualización ni una escritura.

### 7.7. Prueba PUT sobre proveedor inexistente

Solicitud:

```bash
curl -i -X PUT http://localhost:18081/v1/proveedor/999999 \
  -H "Content-Type: application/json" \
  -d '{"Id":999999}'
```

Resultado observado:

- HTTP 400.
- Mensaje: `The request contains an incorrect data type or an invalid parameter`.
- En los registros se observó la ruta `PUT /v1/proveedor/:id` y la ausencia del registro consultado.

**Hallazgo:** PUT alcanza el controlador registrado. El error se produjo al intentar operar sobre un identificador inexistente. No constituye evidencia de una actualización exitosa.

### 7.8. Estado de persistencia

Se ejecutó:

```sql
SELECT COUNT(*) FROM proveedores.proveedor;
```

Resultado observado: `0`.

No se han creado proveedores mediante el MID en las pruebas documentadas hasta la fecha de corte. Por consiguiente, todavía no existe evidencia de una operación completa de escritura seguida de lectura y verificación SQL.

## 8. Contratos de lectura y escritura identificados en el MID

La inspección del controlador `agora_mid/controllers/proveedor.go` permitió identificar las siguientes rutas:

| Método | Ruta | Operación |
|---|---|---|
| POST | `/v1/proveedor/consulta` | Consulta individual |
| POST | `/v1/proveedor/consulta/lista` | Consulta de listado |
| POST | `/v1/proveedor` | Creación |
| PATCH | `/v1/proveedor` | Actualización |

### 8.1. Consulta individual

El cuerpo contempla:

- `id`
- `fields`

Se valida que el identificador sea positivo y que los campos solicitados no contengan cadenas vacías.

Respuestas documentadas en el controlador:

- 200: consulta satisfactoria.
- 206: respuesta con advertencias.
- 400: solicitud inválida.
- 404: proveedor inexistente.
- 502: error de dependencia.
- 504: timeout.

### 8.2. Consulta de listado

La ruta es `POST /v1/proveedor/consulta/lista`.

El cuerpo contempla:

- `query`
- `fields`
- `limit`
- `offset`

La prueba ejecutada con `{}` devolvió una lista vacía y HTTP 200.

### 8.3. Escritura

El MID utiliza:

- `POST /v1/proveedor` para creación.
- `PATCH /v1/proveedor` para actualización.

La escritura requiere un objeto JSON y valida la coherencia entre el tipo de registro y la rama natural o jurídica.

Se identificó que:

- `TipoRegistroId` debe ser un entero positivo.
- No se permite enviar simultáneamente las ramas natural y jurídica.
- Una rama natural no debe incluir `ProveedorJuridico`.
- Una rama no natural no debe incluir `ProveedorNatural`.
- `X-Autor-Id` se utiliza como identificador de autor cuando contiene un entero positivo.

El valor concreto de `TipoRegistroNatural` depende de la configuración externa y no se presume en este documento.

Los resultados HTTP contemplados por el controlador incluyen 200, 206, 400, 502 y 504, según el resultado de la operación.

## 9. Resolución de relaciones y escritura

La inspección de `helper/write_engine.go`, `services/write_resolver.go` y `services/write_resolvers_nucleo.go` permitió identificar el funcionamiento general del motor.

### 9.1. Validación previa

El motor valida los campos declarados como escribibles en el YAML, los campos inmutables y las relaciones permitidas.

También procesa relaciones anidadas y puede transformar referencias con identificadores en campos de tipo `...Id`.

La validación se realiza antes de materializar las escrituras.

### 9.2. Resolución de registros existentes

El resolver:

1. Revisa si el payload contiene un identificador.
2. Si no lo contiene, puede buscar por clave natural configurada.
3. Si encuentra un registro existente, utiliza PATCH.
4. Si no encuentra un registro, utiliza POST.

Para las operaciones POST, el resolver requiere recuperar un identificador en la respuesta del servicio.

### 9.3. Relaciones identificadas

| Entidad | Servicio | Endpoint |
|---|---|---|
| Proveedor | gestion-personas-crud | `/v1/proveedor` |
| Tercero | terceros | `/v1/tercero` |
| Datos de identificación | terceros | `/v1/datos_identificacion` |
| Proveedor natural | gestion-personas-crud | `/v1/proveedor_natural` |
| Proveedor jurídico | gestion-personas-crud | `/v1/proveedor_juridico` |
| Contacto | gestion-personas-crud | `/v1/contacto` |
| Cuenta bancaria | gestion-personas-crud | `/v1/cuenta_bancaria` |

Se identificaron claves naturales configuradas para:

- Proveedor: `TerceroId`.
- Datos de identificación: `Numero` y `TipoDocumentoId`.

La verificación dinámica de idempotencia todavía está pendiente.

## 10. Hallazgos de compatibilidad entre YAML, modelos y CRUD

La inspección del archivo `agora_mid/config/relaciones_proveedor.yaml` y de los modelos de los servicios CRUD identificó diferencias que deben resolverse antes de ejecutar escenarios completos de escritura.

### 10.1. Proveedor principal

El modelo de `gestion_personas_crud` contiene el campo `TipoProveedor`.

El YAML del MID utiliza `TipoRegistroId`.

No se ha identificado una transformación explícita entre ambos nombres en los componentes inspeccionados. Debe verificarse si existe una conversión en otra capa o si se requiere ajustar el contrato.

### 10.2. Proveedor natural

El modelo contiene campos como:

- `PaisNacimientoId`
- `Cargo`
- `ExperienciaLaboral`
- `ExperienciaProfesional`

El YAML contempla:

- `PerfilDeclarado`
- `ExperienciaLaboralMeses`
- `ExperienciaProfesionalMeses`

Se requiere verificar la correspondencia de nombres y tipos.

Además, `PaisNacimientoId` aparece como campo requerido en el modelo inspeccionado y no figura entre los campos escribibles identificados en el YAML.

### 10.3. Proveedor jurídico

El modelo contiene campos como:

- `ProcedenciaEmpresaId`
- `CiudadOrigenId`
- `PaisOrigenId`
- `CodigoPostal`
- `TipoConformacionId`
- `ExclusividadProducto`
- `RegimenContributivo`
- `Pyme`
- `RegistroMercantil`
- `SujetoRetencion`
- `AgenteRetenedor`
- `ResponsableIca`
- `ResponsableIva`

El YAML contempla campos como:

- `NombreComercial`
- `MatriculaMercantil`
- `FechaConstitucion`
- `FechaRenovacion`
- `ReportaBeneficiosFinales`
- `CotizaBolsa`
- `RequiereRevisorFiscal`

No se ha identificado correspondencia directa para varios de estos campos en el modelo inspeccionado.

### 10.4. Contacto

El modelo utiliza:

- `Proposito`
- `TipoCanalContactoId`

El YAML utiliza:

- `Finalidad`
- `TipoCanal`

También contempla `EsPrincipal`, cuya correspondencia no se identificó en el modelo inspeccionado.

### 10.5. Cuenta bancaria

El modelo contiene:

- `TipoCuentaId`
- `NumeroCuenta`
- `EntidadBancariaId`
- `ContactoId`
- `TipoCuentaBancariaId`
- `MontoCapitalAutorizado`
- `ProveedorId`

El YAML contempla adicionalmente:

- `NombreTitular`
- `CiudadAperturaId`
- `EsPrincipal`

No se identificó correspondencia directa de estos últimos campos en el modelo inspeccionado.

Se observó también que `TipoCuentaBancariaId` está definido como booleano en el modelo revisado, aspecto que requiere validación frente al contrato esperado.

### 10.6. Operaciones PUT y PATCH en los CRUD

La inspección de los controladores de `gestion_personas_crud` y `terceros_crud` encontró registros de rutas PUT para las entidades revisadas, pero no registros de rutas PATCH.

Esto es relevante porque el resolver de escritura del MID utiliza PATCH cuando encuentra un registro existente.

Debe comprobarse y corregirse la compatibilidad entre el método HTTP enviado por el MID y los métodos registrados por los CRUD.

### 10.7. Auditoría

El controlador del MID reconoce `X-Autor-Id` y propaga el dato como `AutorModificacionId`.

En los modelos de `gestion_personas_crud` inspeccionados aparecen campos como `UsuarioModificacionId`.

En los modelos de `terceros_crud` revisados no se encontraron campos `AutorModificacionId` ni `UsuarioModificacionId`; se observaron otros campos de usuario, como `UsuarioWSO2` en Tercero.

No se ha demostrado que el dato de autor enviado por el MID se almacene correctamente en todas las entidades.

## 11. Hallazgos de base de datos

La inspección del esquema `proveedores` permitió identificar doce tablas:

1. `actividad_economica_proveedor`
2. `contacto`
3. `cuenta_bancaria`
4. `documento`
5. `estado_proveedor`
6. `perfil_proveedor`
7. `persona_juridica_tipo_entidad`
8. `proveedor`
9. `proveedor_juridico`
10. `proveedor_natural`
11. `representacion`
12. `titulo_proveedor_natural`

La tabla principal `proveedor` contiene, entre otros:

- `id`
- `tipo_proveedor`
- `descripcion_portafolio`
- `consentimiento`
- `tercero_id`
- `activo`
- `fecha_creacion`
- `fecha_modificacion`
- `usuario_modificacion_id`

Se observaron doce claves primarias y doce claves foráneas en las restricciones inspeccionadas. Las claves foráneas observadas son diferibles (`DEFERRABLE`).

Se identificaron valores por defecto para identificadores mediante secuencias, campos de estado activo y fechas de creación.

La inspección también identificó campos obligatorios en las ramas natural y jurídica que deben tenerse en cuenta al construir payloads.

La verificación de índices únicos, restricciones adicionales y correspondencia integral de todos los campos debe completarse antes de cerrar la validación de integridad.

## 12. Matriz de escenarios

La matriz completa se conserva en `issue-66/escenarios/matriz_escenarios.md`.

Contiene los escenarios de:

- Registro de proveedores naturales y jurídicos.
- Consultas individuales y listados.
- Actualizaciones completas y parciales.
- Validaciones de payloads y relaciones.
- Reintentos y recuperación.
- Verificación de persistencia en PostgreSQL.

La matriz define los resultados esperados, pero no representa por sí misma evidencia de ejecución.

## 13. Estado de las nueve actividades del Issue #66

| N.º | Actividad | Estado | Observación |
|---:|---|---|---|
| 1 | Matriz de escenarios de creación, actualización y lectura | Parcial | Matriz inicial elaborada; payloads y resultados específicos pendientes |
| 2 | Docker Compose local y servicios | Parcial | Cinco servicios definidos y ambiente levantado; falta verificar versiones y commits exactos de los microservicios y resolver dependencia de parámetros |
| 3 | Esquemas, migraciones y datos sintéticos | Parcial | Esquema inspeccionado; faltan datos sintéticos y validación completa de catálogos |
| 4 | Payloads y resultados esperados | Parcial | Campos y contratos identificados; faltan payloads completos compatibles con los modelos |
| 5 | Scripts Bash/Python de pruebas | Pendiente | Se realizaron solicitudes manuales con curl; no hay suite automatizada documentada |
| 6 | Read-after-write y comparación con SQL | Parcial | Consultas básicas ejecutadas; no existe registro creado mediante MID para comparar |
| 7 | Rechazo, reintento y actualización | Parcial | Se inspeccionaron validaciones y métodos HTTP; no hay ciclo E2E de actualización ni reintentos |
| 8 | Resumen de escenarios y evidencias | Parcial | Se documentaron respuestas HTTP, logs y hallazgos; faltan evidencias de los escenarios completos |
| 9 | Setup, ejecución y limpieza | Parcial | Compose, Dockerfiles y comandos documentados; falta validar procedimiento completo de ejecución y limpieza |

Ninguna de las nueve actividades se considera formalmente cerrada con la evidencia disponible.

## 14. Bloqueantes y pendientes técnicos

### 14.1. Compatibilidad de métodos HTTP

El MID utiliza PATCH para actualizar registros existentes, mientras que los controladores CRUD inspeccionados registran PUT.

Debe definirse si se adaptarán los CRUD para aceptar PATCH o si se modificará el resolver del MID para utilizar el método soportado por los servicios.

### 14.2. Correspondencia de campos

Se deben revisar las diferencias entre:

- `TipoRegistroId` y `TipoProveedor`.
- Campos de proveedor natural.
- Campos de proveedor jurídico.
- Campos de contacto.
- Campos de cuenta bancaria.

No se debe ejecutar una prueba de escritura completa hasta contar con un payload compatible con los modelos reales y sus restricciones.

### 14.3. Dependencia parametros-crud

Debe determinarse si las pruebas requieren `parametros-crud` y cómo estará disponible dentro del ambiente aislado.

### 14.4. Datos sintéticos

Se requiere definir datos de prueba únicos y controlados para evitar duplicados y contaminación entre escenarios.

### 14.5. Auditoría

Debe verificarse la correspondencia y persistencia de los campos de autor y usuario de modificación.

### 14.6. Escrituras parciales y recuperación

Se requiere probar el comportamiento cuando una relación falla después de que otra entidad ya fue creada o modificada.

También debe verificarse la idempotencia mediante repetición de solicitudes con las mismas claves naturales.

## 15. Plan de continuación

1. Revisar y resolver las discrepancias entre YAML, modelos y tablas.
2. Confirmar los métodos HTTP soportados por cada CRUD y su compatibilidad con el resolver.
3. Identificar la dependencia real de `parametros-crud`.
4. Definir payloads mínimos y completos para proveedor natural y jurídico.
5. Preparar datos sintéticos controlados.
6. Ejecutar creación mediante el MID.
7. Ejecutar consultas de lectura posteriores a la escritura.
8. Comparar las respuestas del MID con los registros de PostgreSQL.
9. Ejecutar actualizaciones y verificar conservación de campos no modificados.
10. Probar duplicados, errores de relaciones y reintentos.
11. Automatizar las pruebas y conservar sus evidencias.
12. Actualizar los estados de las nueve actividades del Issue #66.

## 16. Conclusión

El ambiente Docker local del Issue #66 está definido y se ha levantado con cinco servicios, dos bases de datos PostgreSQL independientes y comunicación interna mediante una red bridge.

Se verificó la interpretación del archivo Docker Compose, la disponibilidad HTTP del MID y del CRUD de gestión de personas, la consulta de listados vacíos y la respuesta ante un proveedor inexistente.

La inspección estática permitió identificar diferencias relevantes entre el YAML de relaciones del MID, los modelos de los servicios CRUD y el esquema de base de datos. También se identificó una incompatibilidad potencial entre el uso de PATCH por el MID y las rutas PUT registradas en los CRUD.

A la fecha de corte no se ha demostrado una creación de proveedor mediante el MID con persistencia verificada en ambas bases de datos. Por tanto, las pruebas E2E de escritura, actualización, idempotencia y read-after-write permanecen pendientes.

El ambiente está preparado para continuar las pruebas, pero el cierre del Issue #66 requiere resolver las discrepancias de contrato y obtener evidencias de persistencia real.

---

**Documento de trabajo:** Issue #66
**Matriz complementaria:** `escenarios/matriz_escenarios.md`
**Infraestructura:** `docker/docker-compose.yml` y Dockerfiles asociados
**Estado general:** En ejecución; pruebas de integración completas pendientes.
