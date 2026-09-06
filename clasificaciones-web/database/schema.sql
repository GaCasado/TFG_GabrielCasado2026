-- Contrato de datos de la aplicación web "clasificaciones-web".
--
-- Cualquier base de datos MySQL que exponga una tabla `Clasificaciones` con
-- exactamente estas columnas puede usarse con esta aplicación sin tocar
-- ni una línea de las páginas .sql. La aplicación no asume nada sobre el
-- contenido (deportes, equipos, años concretos): todo sale de consultas
-- DISTINCT/GROUP BY en tiempo de ejecución.
--
-- Este fichero es documentación del contrato y sirve para sembrar el MySQL
-- de desarrollo local (ver docker-compose.dev.yml). NO forma parte de la
-- imagen de la aplicación web y no se ejecuta automáticamente contra un
-- MySQL de producción.

CREATE TABLE IF NOT EXISTS Clasificaciones (
    anio      VARCHAR(9)  NOT NULL,  -- temporada, p.ej. "2024-2025"; se trata como texto (ver README)
    deporte   VARCHAR(40) NOT NULL,
    equipo    VARCHAR(50) NOT NULL,  -- 50 y no 30: tras unificar nombres de equipo abreviados
                                      -- (ver Incidencias.txt) el más largo ya ocupa 27
    genero    CHAR(1)     NOT NULL DEFAULT 'm',  -- 'm' o 'f'; si falta en la importación se considera 'm'
    puesto    INT         NULL,      -- posición final; -1 = descalificado
    puntos    INT         NULL,
    categoria INT         NOT NULL DEFAULT 1,     -- si solo existe una categoría, vale 1
    asc_desc  INT         NOT NULL DEFAULT 0,     -- 1 = ascenso, -1 = descenso, 0 = permanencia
    alfonso   INT         NULL,      -- posición en un torneo/ránking adicional; -1 = no clasifica
    PRIMARY KEY (anio, deporte, equipo, genero, categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- La collation se fija explícitamente a utf8mb4_unicode_ci porque el driver
-- de MySQL que usa SQLPage vincula los parámetros ($anio, etc.) con esa
-- collation; si la tabla se queda con el valor por defecto de MySQL 8
-- (utf8mb4_0900_ai_ci) cualquier comparación "columna = $parametro" falla
-- con el error 1267 "Illegal mix of collations". Comprobado en pruebas.
