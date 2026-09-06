-- Histórico de un equipo: recibe $equipo.

SELECT 'dynamic' AS component, sqlpage.read_file_as_text('shell.json') AS properties;

SET existe = (SELECT COUNT(*) FROM Clasificaciones WHERE equipo = $equipo);

SELECT 'breadcrumb' AS component;
SELECT 'Inicio' AS title, 'index.sql' AS link;
SELECT $equipo AS title, TRUE AS active;

SELECT 'title' AS component, $equipo AS contents, 2 AS level
WHERE $existe > 0;

SELECT 'alert' AS component,
       'Equipo no encontrado' AS title,
       CONCAT('No hay ninguna clasificación registrada para "', COALESCE($equipo, '?'), '".') AS description,
       'alert-triangle' AS icon,
       'warning' AS color,
       'index.sql' AS link,
       'Volver al buscador' AS link_text
WHERE $existe IS NULL OR $existe = 0;

-- Resumen: solo participaciones, primeros puestos, ascensos y descensos
-- (recuentos simples y bien definidos; nada de "mejor equipo de la historia").
SELECT 'big_number' AS component, 4 AS columns
WHERE $existe > 0;

-- OJO: aquí NO se puede usar el truco de GROUP BY para ocultar filas,
-- porque "0 ascensos" o "0 primeros puestos" son valores legítimos que sí
-- queremos mostrar para un equipo que existe. La sección entera ya queda
-- oculta si el equipo no existe gracias al 'big_number' AS component de
-- arriba (esa fila sí desaparece con $existe=0, al no ser un agregado).
SELECT 'Participaciones' AS title, CAST(COUNT(*) AS CHAR) AS value
FROM Clasificaciones WHERE equipo = $equipo;

SELECT 'Primeros puestos' AS title, CAST(COUNT(*) AS CHAR) AS value
FROM Clasificaciones WHERE equipo = $equipo AND puesto = 1;

SELECT 'Ascensos' AS title, CAST(COUNT(*) AS CHAR) AS value
FROM Clasificaciones WHERE equipo = $equipo AND asc_desc = 1;

SELECT 'Descensos' AS title, CAST(COUNT(*) AS CHAR) AS value
FROM Clasificaciones WHERE equipo = $equipo AND asc_desc = -1;

SELECT 'table' AS component,
       TRUE AS sort,
       TRUE AS search
WHERE $existe > 0;

-- Orden en la subconsulta interna (columnas reales), igual que en
-- clasificacion.sql: SQLPage exige que el ORDER BY use columnas presentes
-- en su propio SELECT, y aquí todas las columnas de salida están renombradas.
SELECT
    anio AS 'Año',
    deporte AS 'Deporte',
    -- "Mixto" si para ese año+deporte concreto solo existe un género en
    -- los datos (mismo criterio que en el resto de páginas).
    CASE
        WHEN (SELECT COUNT(DISTINCT c2.genero) FROM Clasificaciones AS c2
              WHERE c2.anio = ordenado.anio AND c2.deporte = ordenado.deporte) = 1
        THEN 'Mixto'
        ELSE CASE genero WHEN 'm' THEN 'Masculino' WHEN 'f' THEN 'Femenino' ELSE genero END
    END AS 'Género',
    CONCAT(categoria, 'ª') AS 'Categoría',
    -- Flecha pegada a la posición en vez de una columna "Estado" aparte:
    -- solo se añade si asciende o desciende, nada si permanece igual.
    CONCAT(
        CASE WHEN puesto = -1 THEN 'DSQ' WHEN puesto IS NULL THEN '—' ELSE CAST(puesto AS CHAR) END,
        CASE asc_desc WHEN 1 THEN ' ▲' WHEN -1 THEN ' ▼' ELSE '' END
    ) AS 'Posición',
    COALESCE(CAST(puntos AS CHAR), '—') AS 'Puntos',
    -- Posición en el Trofeo Alfonso ese mismo año (independiente de la
    -- posición de liga de arriba: un equipo puede tener una sin la otra).
    CASE WHEN alfonso = -1 THEN 'DSQ' WHEN alfonso IS NULL THEN '—' ELSE CAST(alfonso AS CHAR) END AS 'Trofeo Alfonso'
FROM (
    SELECT * FROM Clasificaciones
    WHERE equipo = $equipo
    ORDER BY anio DESC, deporte, genero, categoria
) AS ordenado;
