-- Página de inicio: cifras generales + buscador de una clasificación concreta.
-- Una clasificación queda identificada por (anio, deporte, genero, categoria).
-- Todas las opciones de los selectores y todas las cifras salen de la base
-- de datos: no hay ningún deporte, año ni categoría escrito a mano aquí.
--
-- Los 4 desplegables se ven siempre desde el principio (sin desplegables
-- en cascada que dependan unos de otros): se eligen los 4 y se pulsa
-- "Buscar". Si al pulsar falta alguno, se avisa exactamente de cuál sin
-- salir de esta página; si están los 4, se pasa directamente a la
-- clasificación (o al aviso de "no encontrada" de esa página, si la
-- combinación elegida no existe).

-- "redirect" tiene que ser el primerísimo componente del fichero: una vez
-- que se manda cualquier otra cosa (aunque sea el shell), ya no se puede
-- cambiar de página con una redirección HTTP de verdad.
SET faltan = (
    SELECT NULLIF(GROUP_CONCAT(campo SEPARATOR ', '), '')
    FROM (
        SELECT 'año' AS campo WHERE COALESCE($anio, '') = ''
        UNION ALL SELECT 'deporte' WHERE COALESCE($deporte, '') = ''
        UNION ALL SELECT 'género' WHERE COALESCE($genero, '') = ''
        UNION ALL SELECT 'categoría' WHERE COALESCE($categoria, '') = ''
    ) AS pendientes
);

SELECT 'redirect' AS component,
       sqlpage.link('clasificacion.sql', JSON_OBJECT(
           'anio', $anio, 'deporte', $deporte, 'genero', $genero, 'categoria', $categoria
       )) AS link
WHERE $intentado = '1' AND $faltan IS NULL;

SELECT 'dynamic' AS component, sqlpage.read_file_as_text('shell.json') AS properties;

SELECT 'title' AS component, 'Clasificaciones deportivas' AS contents;

-- Cifras generales de todo el dataset.
SELECT 'big_number' AS component, 4 AS columns;

SELECT 'Temporadas' AS title, CAST(COUNT(DISTINCT anio) AS CHAR) AS value FROM Clasificaciones;
SELECT 'Deportes' AS title, CAST(COUNT(DISTINCT deporte) AS CHAR) AS value FROM Clasificaciones;
SELECT 'Deportes masculinos' AS title, CAST(COUNT(DISTINCT deporte) AS CHAR) AS value
FROM Clasificaciones WHERE genero = 'm';
SELECT 'Deportes femeninos' AS title, CAST(COUNT(DISTINCT deporte) AS CHAR) AS value
FROM Clasificaciones WHERE genero = 'f';

SELECT 'text' AS component;
SELECT 'Elige año, deporte, género y categoría, y pulsa Buscar.' AS contents;

-- Si ya se pulsó "Buscar" pero falta algo, se avisa exactamente de qué
-- (en vez de dejar el formulario ahí sin más explicación).
SELECT 'alert' AS component,
       'Faltan datos por elegir' AS title,
       CONCAT('Selecciona ', $faltan, ' para poder buscar la clasificación.') AS description,
       'alert-triangle' AS icon,
       'warning' AS color
WHERE $intentado = '1' AND $faltan IS NOT NULL;

SELECT 'form' AS component,
       'GET' AS method,
       'index.sql' AS action,
       'Buscar' AS validate,
       'filtros-clasificacion' AS class;

-- Marca que el formulario ya se ha enviado al menos una vez (para poder
-- distinguir "acabas de entrar" de "has pulsado Buscar y falta algo").
SELECT 'intentado' AS name, 'hidden' AS type, '1' AS value;

-- Los 4 campos se ven siempre, sin depender unos de otros: cada uno lista
-- todos sus valores posibles en el dataset completo.
SELECT 'anio' AS name,
       'select' AS type,
       'Año' AS label,
       6 AS width,
       JSON_ARRAYAGG(JSON_OBJECT(
           'label', label, 'value', value, 'selected', value = COALESCE($anio, '')
       )) AS options
FROM (
    SELECT '(elige un año)' AS label, '' AS value, 0 AS orden, NULL AS anio_ord UNION ALL
    SELECT anio, anio, 1, anio FROM (SELECT DISTINCT anio FROM Clasificaciones) t
) AS opciones
GROUP BY 1
ORDER BY MIN(orden), MIN(anio_ord) DESC;

SELECT 'deporte' AS name,
       'select' AS type,
       'Deporte' AS label,
       6 AS width,
       JSON_ARRAYAGG(JSON_OBJECT(
           'label', label, 'value', value, 'selected', value = COALESCE($deporte, '')
       )) AS options
FROM (
    SELECT '(elige un deporte)' AS label, '' AS value, 0 AS orden UNION ALL
    SELECT deporte, deporte, 1 FROM (SELECT DISTINCT deporte FROM Clasificaciones) t
) AS opciones
GROUP BY 1
ORDER BY MIN(orden), MIN(label);

SELECT 'genero' AS name,
       'select' AS type,
       'Género' AS label,
       6 AS width,
       JSON_ARRAYAGG(JSON_OBJECT(
           'label', label, 'value', value, 'selected', value = COALESCE($genero, '')
       )) AS options
FROM (
    SELECT '(elige un género)' AS label, '' AS value, 0 AS orden UNION ALL
    SELECT CASE genero WHEN 'm' THEN 'Masculino' WHEN 'f' THEN 'Femenino' ELSE genero END, genero, 1
    FROM (SELECT DISTINCT genero FROM Clasificaciones) t
) AS opciones
GROUP BY 1
ORDER BY MIN(orden), MIN(label);

SELECT 'categoria' AS name,
       'select' AS type,
       'Categoría' AS label,
       6 AS width,
       JSON_ARRAYAGG(JSON_OBJECT(
           'label', label, 'value', value, 'selected', value = COALESCE($categoria, '')
       )) AS options
FROM (
    SELECT '(elige una categoría)' AS label, '' AS value, 0 AS orden, NULL AS cat_ord UNION ALL
    SELECT CONCAT(categoria, 'ª categoría'), CAST(categoria AS CHAR), 1, categoria
    FROM (SELECT DISTINCT categoria FROM Clasificaciones) t
) AS opciones
GROUP BY 1
ORDER BY MIN(orden), MIN(cat_ord);
