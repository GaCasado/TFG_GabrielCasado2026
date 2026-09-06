-- Muestra una clasificación concreta: (anio, deporte, genero, categoria).
-- Dos tablas: la clasificación de liga (Posición-Equipo-Puntos, solo
-- equipos con puesto) y, debajo, el Trofeo Alfonso (Posición-Equipo, solo
-- equipos con posición en ese trofeo). Un mismo equipo puede aparecer en
-- las dos si tiene ambas cosas.

SELECT 'dynamic' AS component, sqlpage.read_file_as_text('shell.json') AS properties;

-- ¿Existe esta combinación? Si no, mostramos un aviso claro en vez de una
-- tabla vacía o un error de SQL.
SET existe = (
    SELECT COUNT(*) FROM Clasificaciones
    WHERE anio = $anio AND deporte = $deporte AND genero = $genero AND categoria = $categoria
);

-- Si para este año+deporte solo hay un género en los datos, se etiqueta
-- como "Mixto" en vez de "Masculino"/"Femenino" (mismo criterio que
-- index.sql, equipo.sql y deporte.sql).
SET es_mixto = (
    SELECT COUNT(DISTINCT genero) = 1
    FROM Clasificaciones
    WHERE anio = $anio AND deporte = $deporte
);

SELECT 'breadcrumb' AS component;
SELECT 'Inicio' AS title, 'index.sql' AS link;
SELECT $deporte AS title, sqlpage.link('deporte.sql', JSON_OBJECT('deporte', $deporte)) AS link
WHERE $deporte IS NOT NULL;
SELECT CONCAT(
           $anio, ' · ',
           CASE WHEN $es_mixto THEN 'Mixto'
                ELSE CASE $genero WHEN 'm' THEN 'Masculino' WHEN 'f' THEN 'Femenino' ELSE $genero END
           END,
           ' · ', $categoria, 'ª categoría'
       ) AS title,
       TRUE AS active;

SELECT 'title' AS component, $deporte AS contents, 2 AS level
WHERE $existe > 0;

SELECT 'alert' AS component,
       'No se ha encontrado esa clasificación' AS title,
       CONCAT(
           'No hay datos para ', COALESCE($deporte, '?'), ' · ', COALESCE($anio, '?'),
           ' · ', COALESCE($genero, '?'), ' · categoría ', COALESCE($categoria, '?'), '.'
       ) AS description,
       'alert-triangle' AS icon,
       'warning' AS color,
       'index.sql' AS link,
       'Volver al buscador' AS link_text
WHERE $existe IS NULL OR $existe = 0;

-- ---------------------------------------------------------------------------
-- Clasificación de liga: solo equipos con puesto (los que no tienen puesto
-- —p.ej. equipos que solo aparecen en el Trofeo Alfonso— van únicamente en
-- la tabla de abajo).
-- ---------------------------------------------------------------------------
SELECT 'table' AS component,
       'Posición' AS align_center,
       'Puntos' AS align_center
WHERE $existe > 0;

-- El ORDER BY va en esta misma consulta (nada de envolverla en una
-- subconsulta "FROM (... ORDER BY ...) AS x"): MariaDB, a diferencia de
-- MySQL, no garantiza que el orden de una subconsulta sin LIMIT se
-- conserve al pasar por una consulta exterior sin su propio ORDER BY —
-- en la práctica, sencillamente no lo hace, y las filas acababan
-- reordenadas alfabéticamente por equipo en vez de por posición.
-- Comprobado directamente contra la base de datos real.
SELECT
    CASE WHEN puesto = -1 THEN 'DSQ' ELSE CAST(puesto AS CHAR) END AS 'Posición',
    equipo AS 'Equipo',
    COALESCE(CAST(puntos AS CHAR), '—') AS 'Puntos'
FROM Clasificaciones
WHERE anio = $anio AND deporte = $deporte AND genero = $genero AND categoria = $categoria
  AND puesto IS NOT NULL
ORDER BY
    CASE WHEN puesto = -1 THEN 1 ELSE 0 END,
    puesto ASC,
    equipo ASC;

-- ---------------------------------------------------------------------------
-- Trofeo Alfonso: todos los equipos de esta clasificación con posición en
-- ese trofeo (alfonso IS NOT NULL AND alfonso <> -1), tengan o no puesto
-- en la liga.
-- ---------------------------------------------------------------------------
SET hay_alfonso = (
    SELECT COUNT(*) FROM Clasificaciones
    WHERE anio = $anio AND deporte = $deporte AND genero = $genero AND categoria = $categoria
      AND alfonso IS NOT NULL AND alfonso <> -1
);

SELECT 'title' AS component, 'Trofeo Alfonso' AS contents, 3 AS level
WHERE $hay_alfonso > 0;

SELECT 'table' AS component,
       'Posición' AS align_center
WHERE $hay_alfonso > 0;

SELECT
    CAST(alfonso AS CHAR) AS 'Posición',
    equipo AS 'Equipo'
FROM Clasificaciones
WHERE anio = $anio AND deporte = $deporte AND genero = $genero AND categoria = $categoria
  AND alfonso IS NOT NULL AND alfonso <> -1
ORDER BY alfonso ASC, equipo ASC;
