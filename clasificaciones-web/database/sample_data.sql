-- Dataset MÍNIMO de ejemplo, solo para desarrollo local.
--
-- Esto NO son datos reales: son unas pocas filas inventadas que ejercitan
-- todos los casos que la aplicación debe interpretar (posición normal,
-- descalificado, ascenso/descenso/permanencia, "no clasifica" en la
-- columna alfonso, un equipo presente en 1ª y 2ª categoría, dos temporadas
-- para poder navegar el histórico de un equipo). Sirve para comprobar que
-- la web funciona antes de conectarla a un MySQL con datos reales.

INSERT INTO Clasificaciones (anio, deporte, equipo, genero, puesto, puntos, categoria, asc_desc, alfonso) VALUES
('2023-2024', 'BALONCESTO', 'INFORMATICA',     'm', 1,  30, 1,  0,  1),
('2023-2024', 'BALONCESTO', 'FISICAS',         'm', 2,  27, 1,  0,  2),
('2023-2024', 'BALONCESTO', 'QUIMICAS',        'm', 3,  22, 1, -1, -1),
('2023-2024', 'BALONCESTO', 'MATEMATICAS',     'm', -1, NULL, 1, -1, -1),
('2023-2024', 'BALONCESTO', 'DERECHO',         'm', 1,  18, 2,  1, -1),
('2023-2024', 'BALONCESTO', 'ECONOMICAS',      'm', 2,  15, 2,  0, -1),
('2023-2024', 'BALONCESTO', 'INFORMATICA',     'f', 1,  24, 1,  0,  1),
('2023-2024', 'BALONCESTO', 'FISICAS',         'f', 2,  20, 1,  0, -1),
('2023-2024', 'VOLEIBOL',   'DERECHO',         'm', 1,  16, 1,  0,  1),
('2023-2024', 'VOLEIBOL',   'INFORMATICA',     'm', 2,  14, 1,  0,  2),
('2024-2025', 'BALONCESTO', 'INFORMATICA',     'm', 2,  26, 1,  0,  2),
('2024-2025', 'BALONCESTO', 'FISICAS',         'm', 1,  29, 1,  0,  1),
('2024-2025', 'BALONCESTO', 'DERECHO',         'm', 4,  12, 1, -1, -1),
('2024-2025', 'BALONCESTO', 'INFORMATICA',     'f', 1,  25, 1,  0,  1),
('2024-2025', 'VOLEIBOL',   'DERECHO',         'm', 1,  17, 1,  0,  1);
