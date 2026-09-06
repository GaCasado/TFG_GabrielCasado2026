# Imagen de DATOS: MariaDB con el dataset real de clasificaciones ya
# cargado dentro. Independiente de la imagen de la web (clasificaciones-web):
# cada una tiene su propio ciclo de vida, tal como pide la arquitectura del
# proyecto (ver clasificaciones-web/README.md, sección "Reutilización").
#
# MariaDB en vez de MySQL: las imágenes oficiales recientes de mysql:8.0/8.4
# están compiladas exigiendo instrucciones de CPU x86-64-v2 (SSE4.2, POPCNT).
# Detectado al desplegar en una VM con una CPU virtual genérica ("Common KVM
# processor") que no las tiene: MySQL revienta con "Fatal glibc error: CPU
# does not support x86-64-v2" nada más arrancar. mariadb:10.11 sí funciona
# ahí. Es un sustituto totalmente compatible para esta app: mismo protocolo
# de red MySQL (SQLPage se conecta exactamente igual) y mismo dialecto SQL
# en todo lo que se usa aquí (JSON_ARRAYAGG, JSON_OBJECT, COUNT(DISTINCT
# a,b,c), collations utf8mb4...). schema.sql e indexes.sql no cambian.
#
# Construir desde la RAÍZ del repo (no desde esta carpeta), porque necesita
# leer sql/ y clasificaciones-web/database/schema.sql sin duplicarlos:
#
#   docker build -f clasificaciones-data/Dockerfile -t clasificaciones-data:2023-24 .
#
# No lleva usuario/contraseña "de fábrica": se configuran al arrancar el
# contenedor con variables de entorno (MYSQL_ROOT_PASSWORD, MYSQL_USER,
# MYSQL_PASSWORD) — la imagen de MariaDB las acepta igual que la de MySQL,
# para ser un sustituto directo.

FROM mariadb:10.11

ENV MYSQL_DATABASE=clasificaciones

# El entrypoint oficial de MySQL ejecuta cada *.sql de initdb.d en una
# conexión de cliente `mysql` nueva y separada. Sin esto, esa conexión no
# negocia utf8mb4 y algunos acentos de los ficheros fuente (que SÍ están en
# UTF-8 correcto) se guardan mal codificados (p.ej. "ª" acaba como "Âª").
# Esta plantilla de configuración la lee automáticamente cualquier cliente
# "mysql" que arranque en el contenedor, incluidas esas conexiones del
# entrypoint, así que basta con ponerla antes de copiar los .sql.
COPY <<'EOF' /etc/mysql/conf.d/utf8mb4-client.cnf
[client]
default-character-set = utf8mb4
EOF

# Los scripts en /docker-entrypoint-initdb.d/ se ejecutan, en orden
# alfabético, la primera vez que el contenedor arranca con un volumen de
# datos vacío. "00-schema.sql" ordena antes que "01-indexes.sql", que a su
# vez ordena antes que "clasificaciones_*.sql": la tabla se crea primero,
# luego sus índices secundarios (más barato crearlos sobre una tabla aún
# vacía que después de cargar 7000+ filas) y solo entonces los datos.
COPY clasificaciones-web/database/schema.sql /docker-entrypoint-initdb.d/00-schema.sql
COPY clasificaciones-web/database/indexes.sql /docker-entrypoint-initdb.d/01-indexes.sql
COPY sql/*.sql /docker-entrypoint-initdb.d/
