# TFG Gabriel Casado Valcárcel — Sistema de digitalización y reconocimiento automático de actas deportivas

Repositorio del Trabajo de Fin de Grado en Ingeniería Informática (Facultad
de Informática, Universidad Complutense de Madrid). Contiene todo lo
necesario para revisar los datos, y para reconstruir y ejecutar la
aplicación en cualquier máquina con Docker.

## Qué hay aquí

```
TFG Gabriel Final/
├── TFG_Gabriel_Casado_Valcarcel.docx   # la memoria
├── Incidencias.txt                     # incidencias de datos encontradas y cómo se resolvieron
├── CONTEXTO_PARA_CLAUDE_CODE.md        # convenciones del esquema de datos usadas durante la digitalización
├── pdf/                                # los 27 cuadernillos originales (documento fuente de cada año)
├── sql/                                # los 26 ficheros SQL verificados, uno por temporada
├── clasificaciones-data/               # imagen Docker: base de datos con el dataset ya cargado
└── clasificaciones-web/                # imagen Docker: aplicación web SQLPage de solo lectura
```

- **`pdf/`** son los documentos originales escaneados de la Oficina de
  Deportes de la UCM: contra ellos se puede comprobar, año a año, que cada
  fila de `sql/` es fiel al documento fuente (ver memoria, apartado 3.4).
- **`sql/`** es el resultado de ese proceso de verificación: un `INSERT`
  por equipo y clasificación, ya corregido y normalizado. Es lo que
  `clasificaciones-data` carga al construirse.
- **`clasificaciones-data/`** y **`clasificaciones-web/`** son dos
  imágenes Docker independientes (memoria, capítulo 5): una con los datos,
  otra con la aplicación. Cada una tiene su propio `README.md` con el
  detalle completo; aquí abajo va el camino más corto para levantarlas
  juntas en local.

## Puesta en marcha rápida (local)

Requisitos: Docker y Docker Compose.

```bash
# 1) Base de datos (crea también la red compartida "clasificaciones-net")
cd clasificaciones-data
cp .env.example .env      # rellena contraseñas (valen las de ejemplo para probar en local)
docker compose up -d --build

# 2) Aplicación web, conectada a esa base de datos
cd ../clasificaciones-web
cp .env.example .env      # DATABASE_PASSWORD debe coincidir con MYSQL_PASSWORD del paso 1
docker compose -f docker-compose.yml -f docker-compose.network.yml up -d
```

Abre `http://localhost:8080`. La primera vez tarda unos segundos en cargar
los ~7.500 registros; `docker compose logs -f` en `clasificaciones-data`
para seguirlo.

Para pararlo (sin perder los datos cargados): `docker compose down` en
cada carpeta. Para instrucciones más detalladas —incluida la opción de
arrancar solo la web con un MySQL de desarrollo desechable y datos de
ejemplo— ver [`clasificaciones-web/README.md`](clasificaciones-web/README.md)
y [`clasificaciones-data/README.md`](clasificaciones-data/README.md).

## Despliegue en un servidor

Mismo procedimiento que en local (misma imagen, mismo `docker compose`),
cambiando únicamente las contraseñas de `.env` por unas robustas y
generadas para ese entorno, y activando `SQLPAGE_ENVIRONMENT=production`
en `clasificaciones-web/.env`. Si la CPU del servidor no admite las
imágenes recientes de MySQL (incidencia real descrita en la memoria,
apartado 5.4), `clasificaciones-data` ya usa MariaDB 10.11 por ese motivo
y no requiere ningún cambio adicional.

## Cómo revisar los datos

Cada fichero de `sql/` corresponde a un documento de `pdf/` (mismo año en
el nombre). `Incidencias.txt` documenta, año a año, cualquier caso dudoso
o patrón de error encontrado durante la verificación y el criterio
seguido para resolverlo — es el punto de partida más rápido para auditar
una temporada concreta sin tener que releer el PDF entero.

## Reproducir la extracción de un año nuevo

`CONTEXTO_PARA_CLAUDE_CODE.md` documenta el contrato de datos (columnas,
convenciones de `NULL`/`-1`, etc.) que se siguió para transcribir cada
cuadernillo a SQL. La memoria (capítulo 3) explica en detalle el proceso
seguido: transcripción asistida por Claude Code a partir del PDF
original, verificada dato a dato contra ese mismo documento y con
comprobaciones automáticas de consistencia antes de aceptar cada fichero.
