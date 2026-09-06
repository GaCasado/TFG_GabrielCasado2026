-- Vista de un deporte concreto: recibe $deporte.
-- Sin $deporte (p.ej. al entrar desde el menú "Deportes" del shell) se
-- muestra en su lugar un listado de todos los deportes para elegir uno;
-- no es un caso de error, es la puerta de entrada a esta página.
-- Con $deporte, dos pestañas: clasificaciones disponibles (año/género/
-- categoría) y campeones (puesto = 1 en cualquier año/género/categoría de
-- este deporte; puede haber varios por año, no se asume un único campeón
-- absoluto).

SELECT 'dynamic' AS component, sqlpage.read_file_as_text('shell.json') AS properties;

SET existe = (SELECT COUNT(*) FROM Clasificaciones WHERE deporte = $deporte);

-- Normaliza $tab a exactamente 'clasificaciones' o 'campeones': cualquier
-- otro valor (incluido "no viene en la URL", el caso normal al entrar en
-- la página) cae en 'clasificaciones'. Evitar comparar $tab directamente
-- en cada sitio evita dos bugs: con $tab NULL, "($tab = 'campeones') =
-- FALSE" da NULL (ni una pestaña ni la otra quedan marcadas como activas)
-- y, con un valor de $tab que no sea ninguno de los dos válidos, ninguna
-- de las dos secciones de contenido llegaría a mostrarse.
SET tab_norm = (CASE WHEN $tab = 'campeones' THEN 'campeones' ELSE 'clasificaciones' END);

SELECT 'breadcrumb' AS component;
SELECT 'Inicio' AS title, 'index.sql' AS link;
SELECT COALESCE($deporte, 'Deportes') AS title, TRUE AS active;

-- ---------------------------------------------------------------------------
-- Sin $deporte: listado de todos los deportes (no es un error).
-- ---------------------------------------------------------------------------
SELECT 'title' AS component, 'Deportes' AS contents, 2 AS level
WHERE $deporte IS NULL;

SELECT 'list' AS component, 'Elige un deporte' AS title
WHERE $deporte IS NULL;

SELECT
    deporte AS title,
    CONCAT(
        CAST(COUNT(*) AS CHAR), ' participaciones · ',
        CAST(COUNT(DISTINCT anio) AS CHAR), ' temporadas'
    ) AS description,
    sqlpage.link('deporte.sql', JSON_OBJECT('deporte', deporte)) AS link
FROM Clasificaciones
WHERE $deporte IS NULL
GROUP BY deporte
ORDER BY deporte;

-- ---------------------------------------------------------------------------
-- Con $deporte: la vista de siempre, o el aviso de "no encontrado".
-- ---------------------------------------------------------------------------
SELECT 'title' AS component, $deporte AS contents, 2 AS level
WHERE $deporte IS NOT NULL AND $existe > 0;

SELECT 'alert' AS component,
       'Deporte no encontrado' AS title,
       CONCAT('No hay ninguna clasificación registrada para "', $deporte, '".') AS description,
       'alert-triangle' AS icon,
       'warning' AS color,
       'index.sql' AS link,
       'Volver al buscador' AS link_text
WHERE $deporte IS NOT NULL AND ($existe IS NULL OR $existe = 0);

SELECT 'big_number' AS component, 3 AS columns
WHERE $existe > 0;

-- GROUP BY 1 aquí es seguro (a diferencia de equipo.sql): si el deporte
-- existe, estos tres conteos nunca pueden dar 0 de forma legítima, así
-- que ocultar la fila cuando el resultado del agregado sería 0 solo pasa
-- cuando $existe = 0, que es exactamente lo que queremos.
SELECT 'Temporadas registradas' AS title, CAST(COUNT(DISTINCT anio) AS CHAR) AS value
FROM Clasificaciones WHERE deporte = $deporte AND $existe > 0
GROUP BY 1;

SELECT 'Equipos distintos' AS title, CAST(COUNT(DISTINCT equipo) AS CHAR) AS value
FROM Clasificaciones WHERE deporte = $deporte AND $existe > 0
GROUP BY 1;

SELECT 'Clasificaciones disponibles' AS title, CAST(COUNT(DISTINCT anio, genero, categoria) AS CHAR) AS value
FROM Clasificaciones WHERE deporte = $deporte AND $existe > 0
GROUP BY 1;

SELECT 'tab' AS component
WHERE $existe > 0;

SELECT 'Clasificaciones' AS title, $tab_norm = 'clasificaciones' AS active
WHERE $existe > 0;
SELECT 'Campeones' AS title, $tab_norm = 'campeones' AS active
WHERE $existe > 0;

-- Pestaña "Clasificaciones": una entrada por año/género/categoría disputada.
SELECT 'list' AS component,
       'Combinaciones disputadas' AS title
WHERE $existe > 0 AND $tab_norm = 'clasificaciones';

SELECT
    anio AS title,
    -- "Mixto" si ese año, para este deporte, solo hay un género en los
    -- datos (mismo criterio que en el resto de páginas).
    CONCAT(
        CASE
            WHEN (SELECT COUNT(DISTINCT c2.genero) FROM Clasificaciones AS c2
                  WHERE c2.deporte = $deporte AND c2.anio = combinaciones.anio) = 1
            THEN 'Mixto'
            ELSE CASE genero WHEN 'm' THEN 'Masculino' WHEN 'f' THEN 'Femenino' ELSE genero END
        END,
        ' · ', categoria, 'ª categoría'
    ) AS description,
    sqlpage.link('clasificacion.sql', JSON_OBJECT(
        'anio', anio, 'deporte', deporte, 'genero', genero, 'categoria', categoria
    )) AS link
FROM (
    SELECT DISTINCT anio, deporte, genero, categoria
    FROM Clasificaciones
    WHERE deporte = $deporte
) AS combinaciones
WHERE $tab_norm = 'clasificaciones'
-- El ORDER BY va aquí, en la consulta exterior, no dentro de la
-- subconsulta: MariaDB no garantiza conservar el orden de una subconsulta
-- sin LIMIT al pasar por una consulta exterior sin su propio ORDER BY.
ORDER BY anio DESC, genero, categoria;

-- Pestaña "Campeones": todas las filas con puesto = 1 de este deporte.
-- El año enlaza a la clasificación completa de esa categoría ese año,
-- igual que en la pestaña "Clasificaciones" y en equipo.sql.
SELECT 'table' AS component,
       'Año' AS markdown,
       TRUE AS sort,
       TRUE AS search
WHERE $existe > 0 AND $tab_norm = 'campeones';

SELECT
    CONCAT('[', anio, '](', sqlpage.link('clasificacion.sql', JSON_OBJECT(
        'anio', anio, 'deporte', deporte, 'genero', genero, 'categoria', categoria
    )), ')') AS 'Año',
    CASE
        WHEN (SELECT COUNT(DISTINCT c2.genero) FROM Clasificaciones AS c2
              WHERE c2.deporte = $deporte AND c2.anio = campeones.anio) = 1
        THEN 'Mixto'
        ELSE CASE genero WHEN 'm' THEN 'Masculino' WHEN 'f' THEN 'Femenino' ELSE genero END
    END AS 'Género',
    CONCAT(categoria, 'ª') AS 'Categoría',
    equipo AS 'Equipo',
    COALESCE(CAST(puntos AS CHAR), '—') AS 'Puntos'
FROM Clasificaciones AS campeones
WHERE deporte = $deporte AND puesto = 1 AND $tab_norm = 'campeones'
ORDER BY anio DESC, genero, categoria;
