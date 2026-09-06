# clasificaciones-web

Aplicación web ligera, hecha con [SQLPage](https://sql-page.com), para **consultar**
(no editar) una base de datos histórica de clasificaciones deportivas.

## Qué es

Una interfaz de solo lectura reutilizable: cualquier MySQL que exponga una
tabla `Clasificaciones` con el esquema descrito en
[`database/schema.sql`](database/schema.sql) puede conectarse a esta misma
aplicación sin tocar ni una línea de código. No hay ningún deporte, equipo,
año ni categoría escrito a mano en las páginas — todo sale de consultas a
la base de datos.

## Arquitectura

```
Navegador → SQLPage → MySQL
```

SQLPage se conecta directamente a MySQL y renderiza HTML a partir de
consultas SQL (`web/*.sql`). No hay backend intermedio, ni API REST, ni
frontend en JavaScript aparte.

## Requisitos

- Docker
- Docker Compose
- Un MySQL accesible (propio, en producción) — o usa el MySQL de desarrollo
  incluido, ver más abajo.

## Configuración

```bash
cp .env.example .env
```

Edita `.env` con la cadena de conexión a tu MySQL (`DATABASE_URL`) y su
contraseña (`DATABASE_PASSWORD`, separada de la URL a propósito). `.env`
está en `.gitignore`: nunca se sube al repositorio.

## Ejecución

Tres formas de arrancarla, según a qué MySQL te conectes:

**A. Contra un MySQL ya existente y accesible por red/IP** (un MySQL
gestionado, o cualquier servidor al que ya llegues sin más):

```bash
docker compose up -d
```

**B. Contra el contenedor de datos del propio proyecto** (`clasificaciones-data`,
ver `../clasificaciones-data/`) — así es como se despliega tanto en local
como en el servidor externo real, ver el
[README de clasificaciones-data](../clasificaciones-data/README.md) para
el flujo completo:

```bash
docker compose -f docker-compose.yml -f docker-compose.network.yml up -d
```

**C. En local, sin ninguna base de datos propia**, con el MySQL de
desarrollo desechable y un puñado de filas de ejemplo (`database/sample_data.sql`,
datos inventados, no reales):

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

Abre `http://localhost:8080` (o el puerto que pongas en `SQLPAGE_PORT`).

## Contrato de datos

```sql
CREATE TABLE Clasificaciones (
    anio      VARCHAR(9),   -- temporada como texto, p.ej. "2024-2025"
    deporte   VARCHAR(30),
    equipo    VARCHAR(30),
    genero    CHAR(1),      -- 'm' o 'f'
    puesto    INT,          -- -1 = descalificado
    puntos    INT,
    categoria INT,          -- si solo hay una categoría, vale 1
    asc_desc  INT,          -- 1 ascenso, -1 descenso, 0 permanencia
    alfonso   INT,          -- -1 = no clasifica
    PRIMARY KEY (anio, deporte, equipo, genero, categoria)
);
```

Ver [`database/schema.sql`](database/schema.sql) (documentación del
contrato) y [`database/indexes.sql`](database/indexes.sql) (índices
opcionales, cada uno con la consulta que justifica su existencia).

## Reutilización con otros datasets

Para apuntar la misma aplicación a otra base de datos con otros deportes,
equipos o temporadas, **solo hace falta cambiar `DATABASE_URL` /
`DATABASE_PASSWORD`** en el `.env` (o las variables de entorno del
contenedor). Mientras esa base exponga la tabla `Clasificaciones` con el
esquema de arriba, no hace falta tocar ningún fichero `.sql` de `web/`.

## Estructura

```
clasificaciones-web/
├── docker-compose.yml         # servicio SQLPage (conecta a MySQL externo)
├── docker-compose.dev.yml     # + MySQL local de desarrollo con datos de ejemplo
├── docker-compose.network.yml # + red compartida con clasificaciones-data
├── .env.example
├── config/
│   └── sqlpage.json         # configuración de SQLPage sin credenciales
├── web/                     # web root: páginas .sql + shell compartido
│   ├── shell.json           # cabecera/menú común a todas las páginas
│   ├── assets/style.css     # CSS mínimo, solo lo que Tabler/SQLPage no resuelven solos
│   ├── index.sql            # cifras globales + buscador de una clasificación
│   ├── clasificacion.sql    # tabla de liga + Trofeo Alfonso de una clasificación
│   ├── equipo.sql           # histórico de un equipo (con su Trofeo Alfonso año a año)
│   ├── deporte.sql          # listado de deportes; con ?deporte=, sus clasificaciones y campeones
│   ├── estadisticas.sql     # cifras globales + explorador de 12 estadísticas por equipo/deporte/año
│   └── 404.sql
└── database/
    ├── schema.sql            # el contrato, documentado
    ├── indexes.sql           # índices opcionales, con justificación
    └── sample_data.sql       # datos de ejemplo MÍNIMOS, solo para desarrollo
```

## Estado

En producción, conectada al dataset real (26 temporadas, 7.479 filas) a
través de `clasificaciones-data`. Probada de extremo a extremo con Docker
real: las 6 páginas cargan sin errores, con datos reales y con casos
límite (combinación inexistente, equipo inexistente, deporte inexistente,
categoría única, un solo género, tab inválido en la URL). Los 3 índices de
`database/indexes.sql` están validados con `EXPLAIN` contra el dataset
real y se aplican automáticamente al construir la imagen de datos (ver
`clasificaciones-data/Dockerfile`): eliminan un full table scan en
`deporte.sql`, un recorrido completo del índice primario en `equipo.sql`,
y un filesort en `clasificacion.sql`.
