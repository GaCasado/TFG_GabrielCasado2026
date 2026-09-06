# clasificaciones-data

Imagen Docker de **solo datos**: un MariaDB 10.11 con el dataset real de
clasificaciones (1990-91 a 2023-24, ~7.500 filas) ya cargado dentro,
construido a partir de los ficheros de `sql/` de este repositorio.

MariaDB en vez de MySQL: las imágenes oficiales recientes de `mysql:8.0`/
`8.4` están compiladas exigiendo instrucciones de CPU x86-64-v2 (SSE4.2,
POPCNT) que algunas CPU virtuales genéricas no tienen — se detectó al
desplegar en un servidor real (ver `Dockerfile`). `mariadb:10.11` es un
sustituto directo: mismo protocolo de red MySQL, mismo dialecto SQL en
todo lo que usa esta aplicación.

Vive separada de `clasificaciones-web` a propósito: la web es genérica y
reutilizable, esta imagen es la que lleva "tus" datos concretos. Puedes
tener varias imágenes de datos distintas y apuntar la misma web a
cualquiera de ellas cambiando solo configuración.

## Configuración

```bash
cp .env.example .env
```

Edita `.env` con contraseñas reales. **Nunca pongas contraseñas reales en
este README, en `docker-compose.yml` ni en ningún fichero que subas a
git** — `.env` está en `.gitignore` justo para eso. Para un servidor
externo real, usa contraseñas fuertes (generadas, no palabras tipo
`admin_pass`/`pass`): esta base de datos va a ser accesible desde otro
contenedor por red.

## Arrancarla

```bash
docker compose up -d --build
```

La primera vez (volumen de datos vacío) tarda unos segundos en crear el
esquema y cargar los ~7.500 registros; puedes seguirlo con
`docker compose logs -f`. Esto también crea la red Docker compartida
`clasificaciones-net`, que `clasificaciones-web` usará para conectarse
(ver más abajo) — por eso conviene arrancar **esto primero**.

## Conectar clasificaciones-web

En `clasificaciones-web/.env`:

```env
DATABASE_URL=mysql://clasificaciones_app@clasificaciones-data:3306/clasificaciones
DATABASE_PASSWORD=<el mismo valor que MYSQL_PASSWORD aquí>
```

Y arrancar `clasificaciones-web` con el override de red (además del
fichero base):

```bash
cd ../clasificaciones-web
docker compose -f docker-compose.yml -f docker-compose.network.yml up -d
```

`clasificaciones-data` (nombre del contenedor) resuelve por DNS interno de
Docker porque ambos servicios están en la misma red `clasificaciones-net`.
No hace falta publicar el puerto de la base de datos para esto, ni usar
`host.docker.internal`, ni IPs — funciona igual en tu máquina que en un
servidor Linux real.

## Actualizar el dataset

Esta imagen "hornea" los datos en el momento de construirla. Si cambias
algo en `sql/`, reconstrúyela y empieza con un volumen nuevo para que se
recargue:

```bash
docker compose down -v   # -v borra el volumen de datos viejo
docker compose up -d --build
```

No hay actualización en caliente: es coherente con que esto es una foto
fija de un dataset concreto, no una base de datos editable desde la web.

## Notas

- Ninguna contraseña real está escrita en `Dockerfile` ni en
  `docker-compose.yml`: se leen de `.env` en tiempo de arranque, igual que
  en la imagen oficial de MySQL/MariaDB.
- Esta imagen no expone ningún endpoint HTTP: solo la base de datos. Toda
  la interfaz web la sirve `clasificaciones-web`.
- El puerto publicado al host (`MYSQL_PORT` en `.env`, 3306 por defecto)
  es solo para que puedas inspeccionar la base con un cliente MySQL desde
  fuera de Docker si quieres (el cliente `mysql` funciona igual contra
  MariaDB); `clasificaciones-web` no lo usa.
