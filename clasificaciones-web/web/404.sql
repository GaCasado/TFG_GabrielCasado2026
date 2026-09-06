-- Página servida cuando se pide un fichero .sql que no existe.

SELECT 'dynamic' AS component, sqlpage.read_file_as_text('shell.json') AS properties;

SELECT 'alert' AS component,
       'Página no encontrada' AS title,
       'La página que buscas no existe.' AS description,
       'alert-triangle' AS icon,
       'warning' AS color,
       'index.sql' AS link,
       'Volver al inicio' AS link_text;
