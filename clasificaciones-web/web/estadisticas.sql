-- Estadísticas globales, deliberadamente sencillas (ver README / punto 20
-- de las instrucciones: nada de BI, solo recuentos claramente definidos).

SELECT 'dynamic' AS component, sqlpage.read_file_as_text('shell.json') AS properties;

SELECT 'title' AS component, 'Estadísticas' AS contents;

SELECT 'big_number' AS component, 4 AS columns;

SELECT 'Registros totales' AS title, CAST(COUNT(*) AS CHAR) AS value FROM Clasificaciones;
SELECT 'Temporadas' AS title, CAST(COUNT(DISTINCT anio) AS CHAR) AS value FROM Clasificaciones;
SELECT 'Deportes' AS title, CAST(COUNT(DISTINCT deporte) AS CHAR) AS value FROM Clasificaciones;
SELECT 'Equipos' AS title, CAST(COUNT(DISTINCT equipo) AS CHAR) AS value FROM Clasificaciones;

-- =============================================================================
-- Explorador de estadísticas: catálogo fijo de preguntas ya definidas de
-- antemano (cada una con su propio bloque de SQL, parametrizado de forma
-- segura con $parametros normales de SQLPage — nada de SQL generado en
-- tiempo real). "(Todos)" en un filtro significa simplemente "no filtres
-- por esto", nunca cambia la forma del resultado.
-- =============================================================================

SELECT 'text' AS component;
SELECT 'Explorador de estadísticas' AS contents, TRUE AS bold;

SELECT 'form' AS component,
       'GET' AS method,
       'estadisticas.sql' AS action,
       TRUE AS auto_submit,
       'filtros-clasificacion' AS class;

SELECT 'stat' AS name,
       'select' AS type,
       '¿Qué estadística quieres consultar?' AS label,
       12 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', label, 'value', value, 'selected', value = $stat)) AS options
FROM (
    SELECT '(elige una estadística)' AS label, '' AS value, 0 AS orden UNION ALL
    SELECT 'Número de veces campeón (Rector o Alfonso)', 'titulos', 1 UNION ALL
    SELECT 'Número de veces en el top 2/3/4 del Trofeo Rector', 'top_rector', 2 UNION ALL
    SELECT 'Ascensos y descensos', 'asc_desc', 3 UNION ALL
    SELECT 'Mejor y peor puesto histórico', 'mejor_peor', 5 UNION ALL
    SELECT 'Puntuación media por temporada', 'puntuacion_media', 6 UNION ALL
    SELECT 'Temporadas distintas participadas', 'temporadas', 7 UNION ALL
    SELECT 'Comparativa entre dos equipos', 'comparativa', 8 UNION ALL
    SELECT 'Equipos con más títulos', 'ranking_titulos', 9 UNION ALL
    SELECT 'Equipos con más apariciones en el Trofeo Alfonso', 'ranking_alfonso', 10 UNION ALL
    SELECT 'Campeones distintos en una temporada', 'campeones_temporada', 11 UNION ALL
    SELECT 'Equipos descalificados en una temporada', 'descalificados_temporada', 12 UNION ALL
    SELECT 'Media de posición en el Trofeo Rector', 'media_posicion', 13
) AS opciones
GROUP BY 1
ORDER BY MIN(orden);

-- -----------------------------------------------------------------------------
-- El resto de campos de filtro (equipo, deporte, género, año, trofeo, top N)
-- son filas de ESTE MISMO formulario, no de uno nuevo: cada uno solo
-- aparece si $stat lo necesita (ver el WHERE de cada uno), pero todos
-- viven dentro del único <form> de arriba. Es importante que sea uno
-- solo: con auto_submit, un <form> HTML al enviarse por GET solo manda
-- SUS PROPIOS campos, así que si "stat" estuviera en un formulario aparte,
-- elegir un equipo aquí abajo perdería el "stat" ya elegido y la página
-- volvería a pedir "elige una estadística" (efecto "se resetea").
-- -----------------------------------------------------------------------------

-- Equipo (obligatorio): estadísticas 1,2,3,5,6,7,13.
SELECT 'equipo' AS name, 'select' AS type, 'Equipo' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', equipo, 'value', equipo, 'selected', equipo = $equipo)) AS options
FROM (SELECT DISTINCT equipo FROM Clasificaciones ORDER BY equipo) AS equipos
WHERE $stat IN ('titulos','top_rector','asc_desc','mejor_peor','puntuacion_media','temporadas','media_posicion')
GROUP BY 1;

-- Equipo A / Equipo B (obligatorios): estadística 8 (comparativa).
SELECT 'equipo_a' AS name, 'select' AS type, 'Equipo A' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', equipo, 'value', equipo, 'selected', equipo = $equipo_a)) AS options
FROM (SELECT DISTINCT equipo FROM Clasificaciones ORDER BY equipo) AS equipos
WHERE $stat = 'comparativa'
GROUP BY 1;

SELECT 'equipo_b' AS name, 'select' AS type, 'Equipo B' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', equipo, 'value', equipo, 'selected', equipo = $equipo_b)) AS options
FROM (SELECT DISTINCT equipo FROM Clasificaciones ORDER BY equipo) AS equipos
WHERE $stat = 'comparativa'
GROUP BY 1;

-- Deporte "(Todos)": estadísticas 1,2,3,5,6,7,8,9,10.
SELECT 'deporte' AS name, 'select' AS type, 'Deporte' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', label, 'value', value, 'selected', value = COALESCE($deporte, ''))) AS options
FROM (
    SELECT '(Todos)' AS label, '' AS value, 0 AS orden UNION ALL
    SELECT deporte, deporte, 1 FROM (SELECT DISTINCT deporte FROM Clasificaciones) t
) AS opciones
WHERE $stat IN ('titulos','top_rector','asc_desc','mejor_peor','puntuacion_media','temporadas','comparativa','ranking_titulos','ranking_alfonso')
GROUP BY 1
ORDER BY MIN(orden), MIN(label);

-- Género "(Todos)": mismas estadísticas que Deporte.
SELECT 'genero' AS name, 'select' AS type, 'Género' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', label, 'value', value, 'selected', value = COALESCE($genero, ''))) AS options
FROM (
    SELECT '(Todos)' AS label, '' AS value, 0 AS orden UNION ALL
    SELECT CASE genero WHEN 'm' THEN 'Masculino' WHEN 'f' THEN 'Femenino' ELSE genero END, genero, 1
    FROM (SELECT DISTINCT genero FROM Clasificaciones) t
) AS opciones
WHERE $stat IN ('titulos','top_rector','asc_desc','mejor_peor','puntuacion_media','temporadas','comparativa','ranking_titulos','ranking_alfonso')
GROUP BY 1
ORDER BY MIN(orden), MIN(label);

-- Año "(Todos)": estadísticas 1,9,10,11,12,13.
SELECT 'anio' AS name, 'select' AS type, 'Año' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', label, 'value', value, 'selected', value = COALESCE($anio, ''))) AS options
FROM (
    SELECT '(Todos)' AS label, '' AS value, 0 AS orden, NULL AS anio_ord UNION ALL
    SELECT anio, anio, 1, anio FROM (SELECT DISTINCT anio FROM Clasificaciones) t
) AS opciones
WHERE $stat IN ('titulos','ranking_titulos','ranking_alfonso','campeones_temporada','descalificados_temporada','media_posicion')
GROUP BY 1
ORDER BY MIN(orden), MIN(anio_ord) DESC;

-- Trofeo (obligatorio, con valor por defecto): estadística 1.
SELECT 'tipo' AS name, 'select' AS type, 'Trofeo' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', label, 'value', value, 'selected', value = COALESCE($tipo, 'rector'))) AS options
FROM (
    SELECT 'Trofeo Rector (liga/fase final)' AS label, 'rector' AS value, 1 AS orden UNION ALL
    SELECT 'Trofeo Alfonso XIII', 'alfonso', 2
) AS opciones
WHERE $stat = 'titulos'
GROUP BY 1
ORDER BY MIN(orden);

-- Umbral top N (obligatorio, con valor por defecto): estadística 2.
SELECT 'n' AS name, 'select' AS type, 'Top' AS label, 4 AS width,
       JSON_ARRAYAGG(JSON_OBJECT('label', label, 'value', value, 'selected', value = COALESCE($n, '4'))) AS options
FROM (
    SELECT 'Top 2' AS label, '2' AS value UNION ALL
    SELECT 'Top 3', '3' UNION ALL
    SELECT 'Top 4', '4'
) AS opciones
WHERE $stat = 'top_rector'
GROUP BY 1
ORDER BY MIN(value);

-- -----------------------------------------------------------------------------
-- Avisos de "falta un dato obligatorio": las estadísticas que necesitan un
-- equipo (o dos, en la comparativa) no muestran nada por debajo del
-- formulario hasta que se elige; sin este aviso, esa espera parece una
-- página rota en vez de una página que solo necesita un dato más.
-- -----------------------------------------------------------------------------
SELECT 'alert' AS component,
       'Falta elegir un equipo' AS title,
       'Selecciona un equipo arriba para ver este dato.' AS description,
       'info-circle' AS icon,
       'info' AS color
WHERE $stat IN ('titulos','top_rector','asc_desc','mejor_peor',
                 'puntuacion_media','temporadas','media_posicion')
  AND COALESCE($equipo, '') = '';

SELECT 'alert' AS component,
       'Faltan equipos por elegir' AS title,
       'Selecciona el Equipo A y el Equipo B arriba para compararlos.' AS description,
       'info-circle' AS icon,
       'info' AS color
WHERE $stat = 'comparativa'
  AND (COALESCE($equipo_a, '') = '' OR COALESCE($equipo_b, '') = '');

-- =============================================================================
-- Resultados. Cada bloque solo se ejecuta para su $stat y, si necesita un
-- equipo obligatorio, solo cuando ya se ha elegido.
-- =============================================================================

-- Nota sobre el patrón usado en todos los bloques de abajo: la fila de
-- valor va SIN FROM y SIN GROUP BY, con el resultado calculado en una
-- subconsulta escalar dentro del SELECT. Así el WHERE de fuera decide con
-- total independencia si la fila aparece (evita que un "0" legítimo -p.ej.
-- un equipo con 0 ascensos- desaparezca) y la subconsulta calcula el valor
-- real sin más filtro que el suyo propio (evita que, al no ser este el
-- $stat activo, un COUNT(*) sin agrupar devuelva igualmente una fila
-- fantasma que se cuele en el bloque que sí está activo).

-- 1) Número de veces campeón (Rector o Alfonso) ------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'titulos' AND COALESCE($equipo, '') <> '';

SELECT
    CASE COALESCE($tipo, 'rector') WHEN 'alfonso' THEN 'Veces campeón del Trofeo Alfonso XIII'
                                     ELSE 'Veces campeón del Trofeo Rector' END AS title,
    CAST((
        SELECT COUNT(*) FROM Clasificaciones
        WHERE equipo = $equipo
          AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
          AND (COALESCE($genero, '') = '' OR genero = $genero)
          AND (COALESCE($anio, '') = '' OR anio = $anio)
          AND (CASE WHEN COALESCE($tipo, 'rector') = 'alfonso' THEN alfonso = 1 ELSE puesto = 1 END)
    ) AS CHAR) AS value
WHERE $stat = 'titulos' AND COALESCE($equipo, '') <> '';

-- 2) Top 2/3/4 del Trofeo Rector ----------------------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'top_rector' AND COALESCE($equipo, '') <> '';

SELECT
    CONCAT('Veces en el top ', COALESCE($n, '4'), ' del Trofeo Rector') AS title,
    CAST((
        SELECT COUNT(*) FROM Clasificaciones
        WHERE equipo = $equipo
          AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
          AND (COALESCE($genero, '') = '' OR genero = $genero)
          AND puesto BETWEEN 1 AND CAST(COALESCE($n, '4') AS UNSIGNED)
    ) AS CHAR) AS value
WHERE $stat = 'top_rector' AND COALESCE($equipo, '') <> '';

-- 3) Ascensos y descensos ------------------------------------------------------
SELECT 'big_number' AS component, 2 AS columns
WHERE $stat = 'asc_desc' AND COALESCE($equipo, '') <> '';

SELECT 'Ascensos' AS title,
       CAST((
           SELECT COUNT(*) FROM Clasificaciones
           WHERE equipo = $equipo AND asc_desc = 1
             AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR genero = $genero)
       ) AS CHAR) AS value
WHERE $stat = 'asc_desc' AND COALESCE($equipo, '') <> '';

SELECT 'Descensos' AS title,
       CAST((
           SELECT COUNT(*) FROM Clasificaciones
           WHERE equipo = $equipo AND asc_desc = -1
             AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR genero = $genero)
       ) AS CHAR) AS value
WHERE $stat = 'asc_desc' AND COALESCE($equipo, '') <> '';

-- 5) Mejor y peor puesto histórico ---------------------------------------------
SELECT 'big_number' AS component, 2 AS columns
WHERE $stat = 'mejor_peor' AND COALESCE($equipo, '') <> '';

SELECT 'Mejor puesto' AS title,
       COALESCE(CAST((
           SELECT MIN(puesto) FROM Clasificaciones
           WHERE equipo = $equipo AND puesto IS NOT NULL AND puesto <> -1
             AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR genero = $genero)
       ) AS CHAR), 'Sin datos') AS value
WHERE $stat = 'mejor_peor' AND COALESCE($equipo, '') <> '';

SELECT 'Peor puesto' AS title,
       COALESCE(CAST((
           SELECT MAX(puesto) FROM Clasificaciones
           WHERE equipo = $equipo AND puesto IS NOT NULL AND puesto <> -1
             AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR genero = $genero)
       ) AS CHAR), 'Sin datos') AS value
WHERE $stat = 'mejor_peor' AND COALESCE($equipo, '') <> '';

-- 6) Puntuación media por temporada --------------------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'puntuacion_media' AND COALESCE($equipo, '') <> '';

SELECT 'Puntuación media por temporada' AS title,
       COALESCE(CAST((
           SELECT ROUND(AVG(puntos), 2) FROM Clasificaciones
           WHERE equipo = $equipo
             AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR genero = $genero)
       ) AS CHAR), 'Sin datos') AS value
WHERE $stat = 'puntuacion_media' AND COALESCE($equipo, '') <> '';

-- 7) Temporadas distintas participadas -----------------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'temporadas' AND COALESCE($equipo, '') <> '';

SELECT 'Temporadas distintas participadas' AS title,
       CAST((
           SELECT COUNT(DISTINCT anio) FROM Clasificaciones
           WHERE equipo = $equipo
             AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR genero = $genero)
       ) AS CHAR) AS value
WHERE $stat = 'temporadas' AND COALESCE($equipo, '') <> '';

-- 8) Comparativa entre dos equipos ---------------------------------------------
-- Se comparan solo las (anio, deporte, genero, categoria) donde AMBOS
-- equipos tienen puesto real (no NULL); un DQ (-1) siempre cuenta como
-- "por detrás" de cualquier puesto real.
SELECT 'alert' AS component,
       'Elige dos equipos distintos' AS title,
       'Equipo A y Equipo B tienen que ser diferentes para comparar algo.' AS description,
       'alert-triangle' AS icon,
       'warning' AS color
WHERE $stat = 'comparativa' AND COALESCE($equipo_a,'') <> '' AND COALESCE($equipo_b,'') <> ''
  AND $equipo_a = $equipo_b;

SELECT 'big_number' AS component, 3 AS columns
WHERE $stat = 'comparativa' AND COALESCE($equipo_a,'') <> '' AND COALESCE($equipo_b,'') <> ''
  AND $equipo_a <> $equipo_b;

SELECT CONCAT($equipo_a, ' por delante') AS title,
       CAST((
           SELECT COUNT(*) FROM Clasificaciones AS a
           JOIN Clasificaciones AS b
             ON a.anio = b.anio AND a.deporte = b.deporte AND a.genero = b.genero AND a.categoria = b.categoria
           WHERE a.equipo = $equipo_a AND b.equipo = $equipo_b
             AND a.puesto IS NOT NULL AND b.puesto IS NOT NULL
             AND (COALESCE($deporte, '') = '' OR a.deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR a.genero = $genero)
             AND (CASE WHEN a.puesto = -1 THEN 999999 ELSE a.puesto END) < (CASE WHEN b.puesto = -1 THEN 999999 ELSE b.puesto END)
       ) AS CHAR) AS value
WHERE $stat = 'comparativa' AND COALESCE($equipo_a,'') <> '' AND COALESCE($equipo_b,'') <> '' AND $equipo_a <> $equipo_b;

SELECT CONCAT($equipo_b, ' por delante') AS title,
       CAST((
           SELECT COUNT(*) FROM Clasificaciones AS a
           JOIN Clasificaciones AS b
             ON a.anio = b.anio AND a.deporte = b.deporte AND a.genero = b.genero AND a.categoria = b.categoria
           WHERE a.equipo = $equipo_a AND b.equipo = $equipo_b
             AND a.puesto IS NOT NULL AND b.puesto IS NOT NULL
             AND (COALESCE($deporte, '') = '' OR a.deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR a.genero = $genero)
             AND (CASE WHEN a.puesto = -1 THEN 999999 ELSE a.puesto END) > (CASE WHEN b.puesto = -1 THEN 999999 ELSE b.puesto END)
       ) AS CHAR) AS value
WHERE $stat = 'comparativa' AND COALESCE($equipo_a,'') <> '' AND COALESCE($equipo_b,'') <> '' AND $equipo_a <> $equipo_b;

SELECT 'Veces que coincidieron' AS title,
       CAST((
           SELECT COUNT(*) FROM Clasificaciones AS a
           JOIN Clasificaciones AS b
             ON a.anio = b.anio AND a.deporte = b.deporte AND a.genero = b.genero AND a.categoria = b.categoria
           WHERE a.equipo = $equipo_a AND b.equipo = $equipo_b
             AND a.puesto IS NOT NULL AND b.puesto IS NOT NULL
             AND (COALESCE($deporte, '') = '' OR a.deporte = $deporte)
             AND (COALESCE($genero, '') = '' OR a.genero = $genero)
       ) AS CHAR) AS value
WHERE $stat = 'comparativa' AND COALESCE($equipo_a,'') <> '' AND COALESCE($equipo_b,'') <> '' AND $equipo_a <> $equipo_b;

-- 9) Equipos con más títulos (ranking) ------------------------------------------
SELECT 'table' AS component, TRUE AS search, 'Títulos' AS align_right
WHERE $stat = 'ranking_titulos';

SELECT
    equipo AS 'Equipo',
    CAST(titulos AS CHAR) AS 'Títulos'
FROM (
    SELECT equipo, COUNT(*) AS titulos
    FROM Clasificaciones
    WHERE puesto = 1
      AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
      AND (COALESCE($genero, '') = '' OR genero = $genero)
      AND (COALESCE($anio, '') = '' OR anio = $anio)
    GROUP BY equipo
    ORDER BY titulos DESC, equipo ASC
    LIMIT 20
) AS ranking
WHERE $stat = 'ranking_titulos';

-- 10) Equipos con más apariciones en el Trofeo Alfonso (ranking) -----------------
SELECT 'table' AS component, TRUE AS search, 'Apariciones' AS align_right
WHERE $stat = 'ranking_alfonso';

SELECT
    equipo AS 'Equipo',
    CAST(apariciones AS CHAR) AS 'Apariciones'
FROM (
    SELECT equipo, COUNT(*) AS apariciones
    FROM Clasificaciones
    WHERE alfonso IS NOT NULL AND alfonso <> -1
      AND (COALESCE($deporte, '') = '' OR deporte = $deporte)
      AND (COALESCE($genero, '') = '' OR genero = $genero)
      AND (COALESCE($anio, '') = '' OR anio = $anio)
    GROUP BY equipo
    ORDER BY apariciones DESC, equipo ASC
    LIMIT 20
) AS ranking
WHERE $stat = 'ranking_alfonso';

-- 11) Campeones distintos en una temporada ---------------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'campeones_temporada';

SELECT
    CASE WHEN COALESCE($anio, '') = '' THEN 'Campeones distintos (toda la historia)'
         ELSE CONCAT('Campeones distintos en ', $anio) END AS title,
    CAST((
        SELECT COUNT(DISTINCT equipo) FROM Clasificaciones
        WHERE puesto = 1
          AND (COALESCE($anio, '') = '' OR anio = $anio)
    ) AS CHAR) AS value
WHERE $stat = 'campeones_temporada';

-- 12) Equipos descalificados en una temporada -------------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'descalificados_temporada';

SELECT
    CASE WHEN COALESCE($anio, '') = '' THEN 'Equipos descalificados (toda la historia)'
         ELSE CONCAT('Equipos descalificados en ', $anio) END AS title,
    CAST((
        SELECT COUNT(DISTINCT equipo) FROM Clasificaciones
        WHERE puesto = -1
          AND (COALESCE($anio, '') = '' OR anio = $anio)
    ) AS CHAR) AS value
WHERE $stat = 'descalificados_temporada';

-- 13) Media de posición en el Trofeo Rector ---------------------------------------
SELECT 'big_number' AS component, 1 AS columns
WHERE $stat = 'media_posicion' AND COALESCE($equipo, '') <> '';

SELECT
    CASE WHEN COALESCE($anio, '') = '' THEN CONCAT('Media de posición de ', $equipo, ' en el Trofeo Rector (toda la historia)')
         ELSE CONCAT('Media de posición de ', $equipo, ' en el Trofeo Rector en ', $anio) END AS title,
    COALESCE(CAST((
        SELECT ROUND(AVG(puesto), 2) FROM Clasificaciones
        WHERE equipo = $equipo AND puesto IS NOT NULL AND puesto <> -1
          AND (COALESCE($anio, '') = '' OR anio = $anio)
    ) AS CHAR), 'Sin datos') AS value
WHERE $stat = 'media_posicion' AND COALESCE($equipo, '') <> '';
