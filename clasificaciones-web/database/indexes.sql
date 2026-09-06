-- Índices secundarios para Clasificaciones.
--
-- Validados con EXPLAIN contra el dataset real del TFG (26 temporadas,
-- 7.479 filas, 18 deportes, 191 equipos) el 2026-08-29, no solo en teoría.
-- Antes/después de cada índice abajo. Este fichero es opcional y no se
-- aplica automáticamente: ejecútalo a mano cuando el dataset ya esté
-- cargado en tu MySQL.
--
-- La PRIMARY KEY existente es (anio, deporte, equipo, genero, categoria).
-- MySQL (InnoDB) puede usar un prefijo de esa clave para filtrar por
-- (anio) o (anio, deporte), pero `equipo` está intercalado ANTES de
-- `genero` y `categoria`, así que la PK no sirve para filtrar bien por
-- (anio, deporte, genero, categoria) ni por (deporte) solo, ni por
-- (equipo) solo.

-- ---------------------------------------------------------------------------
-- idx_clasificacion_lookup
-- Optimiza: clasificacion.sql
--   SELECT ... WHERE anio=? AND deporte=? AND genero=? AND categoria=?
--   ORDER BY puesto
--
-- EXPLAIN antes (solo PK):
--   type=ref  key=PRIMARY  rows=42  Extra="Using where; Using filesort"
--   (la PK solo puede usar anio+deporte como prefijo útil; genero/categoria
--   y el ORDER BY se resuelven aparte, con un filesort)
-- EXPLAIN después:
--   type=range  key=idx_clasificacion_lookup  rows=13  Extra="Using index condition"
--   (filtra las 4 columnas de golpe, sin filesort; de 42 a 13 filas examinadas)
CREATE INDEX idx_clasificacion_lookup
    ON Clasificaciones (anio, deporte, genero, categoria, puesto);

-- ---------------------------------------------------------------------------
-- idx_equipo_historial
-- Optimiza: equipo.sql
--   SELECT ... WHERE equipo = ? ORDER BY anio DESC
--
-- EXPLAIN antes: type=index (recorre TODO el índice PRIMARY, 7.479 filas,
--   10% filtrado) — `equipo` no es prefijo de la PK.
-- EXPLAIN después: type=ref  key=idx_equipo_historial  rows=159  100% filtrado.
CREATE INDEX idx_equipo_historial
    ON Clasificaciones (equipo, anio, deporte, genero, categoria);

-- ---------------------------------------------------------------------------
-- idx_deporte_lookup
-- Optimiza: deporte.sql (WHERE deporte = ?) y la agregación por deporte
-- de estadisticas.sql (GROUP BY deporte).
--
-- Aunque `deporte` sí es el segundo componente de la PK, MySQL no puede
-- usar la PK para un filtro que empieza directamente por `deporte`
-- (necesitaría fijar `anio` primero). Comprobado con EXPLAIN, no asumido:
--
-- deporte.sql, EXPLAIN antes: type=ALL (full table scan, 7.479 filas, 10%
--   filtrado) — sin índice utilizable en absoluto.
-- deporte.sql, EXPLAIN después: type=ref  key=idx_deporte_lookup  rows=1623
--   100% filtrado.
--
-- estadisticas.sql (GROUP BY deporte), EXPLAIN antes: recorre el índice
--   PRIMARY entero y además "Using temporary" (tabla temporal para agrupar).
-- EXPLAIN después: recorre idx_deporte_lookup con "Using index" y SIN
--   "Using temporary" (el índice ya viene ordenado por deporte).
CREATE INDEX idx_deporte_lookup
    ON Clasificaciones (deporte, anio, genero, categoria);

-- ---------------------------------------------------------------------------
-- Coste de mantener estos 3 índices: cada INSERT/UPDATE/DELETE sobre
-- Clasificaciones tiene que actualizar también estos 3 índices además de
-- la PK. Para este dataset (miles de filas, cargadas por temporada y no
-- en un flujo transaccional de alta frecuencia) el coste es insignificante
-- frente a la mejora en las consultas de lectura, que son las que la
-- aplicación ejecuta constantemente. Si en el futuro se hacen cargas
-- masivas de INSERT muy seguidas, considera crear estos índices SPUÉS de
-- la carga en vez de tenerlos activos durante ella.
